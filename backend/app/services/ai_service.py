import httpx
import json
import time
from typing import List, Optional
from app.config import settings
from app.schemas.ai_analysis import (
    AIAnalysisRequest,
    AIAnalysisResponse,
    Cause,
    Solution,
    SparePartRecommendation,
    SeverityLevel,
    UrgencyLevel
)


SYSTEM_PROMPT = """
คุณเป็น AI ผู้เชี่ยวชาญด้านการวิเคราะห์อาการเสียเครื่องจักรในโรงงานอุตสาหกรรม

หน้าที่ของคุณ:
1. วิเคราะห์อาการเสียจากข้อมูลที่ได้รับ (รูปภาพ, ข้อความ)
2. ระบุสาเหตุที่เป็นไปได้เรียงตามความน่าจะเป็น
3. แนะนำวิธีแก้ไขที่เหมาะสม
4. แนะนำอะไหล่ที่ต้องใช้
5. ประมาณเวลาและค่าใช้จ่าย

รูปแบบผลลัพธ์ (JSON):
{
  "causes": [
    {
      "cause": "ชื่อสาเหตุ",
      "confidence": 85.5,
      "description": "รายละเอียดสาเหตุ",
      "severity": "high|medium|low",
      "solution": {
        "steps": ["ขั้นตอนที่ 1", "ขั้นตอนที่ 2"],
        "estimated_time_minutes": 120,
        "estimated_cost": 2500.00,
        "difficulty": "easy|medium|hard"
      },
      "spare_parts": [
        {
          "part_name": "ชื่ออะไหล่",
          "part_number": "หมายเลขอะไหล่",
          "quantity": 2,
          "unit_price": 850.00
        }
      ],
      "prevention": "วิธีป้องกันไม่ให้เกิดซ้ำ"
    }
  ],
  "summary": "สรุปการวิเคราะห์",
  "urgency": "immediate|within_hour|within_day|can_wait",
  "additional_notes": "หมายเหตุเพิ่มเติม"
}

กฎการวิเคราะห์:
- วิเคราะห์จากหลักฐานที่มี ไม่คาดเดา
- ให้สาเหตุอย่างน้อย 2-3 ข้อ
- แสดง confidence score ที่สมเหตุสมผล
- แนะนำวิธีแก้ไขที่ปลอดภัย
- ระบุอะไหล่ที่ต้องใช้จริง
- ประมาณเวลาและค่าใช้จ่ายที่สมเหตุสมผล
"""

ANALYSIS_PROMPT_TEMPLATE = """
วิเคราะห์อาการเสียเครื่องจักร:

ข้อมูลเครื่องจักร:
- ชื่อ: {machine_name}
- รุ่น: {machine_model}
- สถานที่: {machine_location}
- อายุการใช้งาน: {machine_age} ปี

อาการเสียที่รายงาน:
{symptoms}

กรุณาวิเคราะห์และระบุสาเหตุที่เป็นไปได้
"""


class AIService:
    def __init__(self):
        self.api_key = settings.OPENAI_API_KEY
        self.model = settings.AI_MODEL
        self.base_url = "https://api.openai.com/v1"

    async def analyze_breakdown(
        self,
        request: AIAnalysisRequest,
        machine_info: dict
    ) -> dict:
        start_time = time.time()

        # Build user prompt
        user_prompt = ANALYSIS_PROMPT_TEMPLATE.format(
            machine_name=machine_info.get("name", "Unknown"),
            machine_model=machine_info.get("model", "Unknown"),
            machine_location=machine_info.get("location", "Unknown"),
            machine_age=machine_info.get("age", "Unknown"),
            symptoms=request.input_text or "ไม่มีรายละเอียด"
        )

        # Build messages
        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": [
                {"type": "text", "text": user_prompt}
            ]}
        ]

        # Add images if provided
        if request.image_urls:
            for img_url in request.image_urls:
                messages[1]["content"].append({
                    "type": "image_url",
                    "image_url": {"url": img_url}
                })

        # Call OpenAI API
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": self.model,
                    "messages": messages,
                    "response_format": {"type": "json_object"},
                    "temperature": 0.3,
                    "max_tokens": 2000
                },
                timeout=30.0
            )

        result = response.json()
        ai_content = result["choices"][0]["message"]["content"]
        parsed_result = json.loads(ai_content)

        processing_time = int((time.time() - start_time) * 1000)

        return {
            "raw_response": parsed_result,
            "model_version": self.model,
            "processing_time": processing_time
        }

    def parse_analysis(
        self,
        raw_result: dict,
        request: AIAnalysisRequest
    ) -> AIAnalysisResponse:
        causes = []
        for cause_data in raw_result.get("causes", []):
            solution_data = cause_data.get("solution", {})
            spare_parts = [
                SparePartRecommendation(**sp) for sp in cause_data.get("spare_parts", [])
            ]
            solution = Solution(
                steps=solution_data.get("steps", []),
                estimated_time_minutes=solution_data.get("estimated_time_minutes", 0),
                estimated_cost=solution_data.get("estimated_cost", 0.0),
                difficulty=solution_data.get("difficulty", "medium")
            )
            cause = Cause(
                cause=cause_data.get("cause", ""),
                confidence=cause_data.get("confidence", 0.0),
                description=cause_data.get("description", ""),
                severity=SeverityLevel(cause_data.get("severity", "medium")),
                solution=solution,
                spare_parts=spare_parts,
                prevention=cause_data.get("prevention", "")
            )
            causes.append(cause)

        # Get highest confidence
        max_confidence = max([c.confidence for c in causes]) if causes else 0.0

        return AIAnalysisResponse(
            analysis_id="",
            machine_id=request.machine_id,
            input_text=request.input_text,
            input_images=request.image_urls,
            confidence=max_confidence,
            causes=causes,
            summary=raw_result.get("summary", ""),
            urgency=UrgencyLevel(raw_result.get("urgency", "within_hour")),
            additional_notes=raw_result.get("additional_notes"),
            model_version="gpt-4-vision-preview",
            processing_time=0,
            created_at=None
        )


ai_service = AIService()

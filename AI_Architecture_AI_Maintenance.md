# AI Maintenance Assistant - AI Architecture

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AI MAINTENANCE ASSISTANT                            │
│                         AI Architecture Diagram                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              INPUT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   📷 Image  │  │  🎤 Voice   │  │  📝 Text    │  │  📋 Sensor  │        │
│  │   Upload    │  │  Recording  │  │   Input     │  │    Data     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │                │
│         └────────────────┴────────────────┴────────────────┘                │
│                                      │                                      │
│                                      ▼                                      │
│                         ┌─────────────────────┐                            │
│                         │   Preprocessing     │                            │
│                         │   - Image Resize    │                            │
│                         │   - Audio → Text    │                            │
│                         │   - Text Cleaning   │                            │
│                         │   - Data Normalize  │                            │
│                         └──────────┬──────────┘                            │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            AI PROCESSING LAYER                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     RAG (Retrieval-Augmented Generation)           │    │
│  │                                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │    │
│  │  │  Embedding  │───▶│  Vector     │───▶│  Retrieval  │            │    │
│  │  │   Model     │    │   Store     │    │   Engine    │            │    │
│  │  └─────────────┘    └─────────────┘    └──────┬──────┘            │    │
│  │                                               │                    │    │
│  └───────────────────────────────────────────────┼────────────────────┘    │
│                                                  │                         │
│                                                  ▼                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     LLM Processing                                 │    │
│  │                                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │    │
│  │  │   GPT-4V    │───▶│   Reasoning │───▶│   Output    │            │    │
│  │  │   Vision    │    │   Engine    │    │   Generator │            │    │
│  │  └─────────────┘    └─────────────┘    └──────┬──────┘            │    │
│  │                                               │                    │    │
│  └───────────────────────────────────────────────┼────────────────────┘    │
│                                                  │                         │
└──────────────────────────────────────────────────┼─────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            OUTPUT LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  🔴 Cause   │  │  📊 Score   │  │  🔧 Solution│  │  📦 Parts   │        │
│  │  Analysis   │  │  Confidence │  │  Recommendation│  │  Suggestion │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Prompt Engineering

### 2.1 System Prompt

```python
SYSTEM_PROMPT = """
คุณเป็น AI ผู้เชี่ยวชาญด้านการวิเคราะห์อาการเสียเครื่องจักรในโรงงานอุตสาหกรรม

หน้าที่ของคุณ:
1. วิเคราะห์อาการเสียจากข้อมูลที่ได้รับ (รูปภาพ, ข้อความ, เสียง)
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
```

### 2.2 User Prompt Templates

```python
# Template สำหรับวิเคราะห์จากข้อความ
TEXT_ANALYSIS_PROMPT = """
วิเคราะห์อาการเสียเครื่องจักรจากข้อมูลต่อไปนี้:

ข้อมูลเครื่องจักร:
- ชื่อเครื่อง: {machine_name}
- รุ่น: {machine_model}
- สถานที่: {machine_location}
- อายุการใช้งาน: {machine_age} ปี

อาการเสียที่รายงาน:
{symptoms}

ประวัติการซ่อมล่าสุด:
{recent_history}

กรุณาวิเคราะห์และระบุสาเหตุที่เป็นไปได้
"""

# Template สำหรับวิเคราะห์จากภาพ
IMAGE_ANALYSIS_PROMPT = """
วิเคราะห์รูปภาพเครื่องจักรที่มีปัญหา:

ข้อมูลเครื่อง:
- ชื่อ: {machine_name}
- รุ่น: {machine_model}

รูปภาพที่แนบ: {image_count} รูป

อาการเสียที่สังเกตได้จากภาพ:
{visual_symptoms}

กรุณาวิเคราะห์จากภาพและระบุ:
1. จุดที่มีปัญหา
2. สาเหตุที่เป็นไปได้
3. ระดับความเสียหาย
"""

# Template สำหรับวิเคราะห์จากเสียง
VOICE_ANALYSIS_PROMPT = """
วิเคราะห์เสียงเครื่องจักรที่ผิดปกติ:

ข้อมูลเครื่อง:
- ชื่อ: {machine_name}
- ประเภทเครื่อง: {machine_type}

เสียงที่บันทึกได้:
- ความดัง: {volume_db} dB
- ความถี่: {frequency_hz} Hz
- รูปแบบเสียง: {sound_pattern}
- ระยะเวลา: {duration} วินาที

ลักษณะเสียงที่บรรยาย:
{voice_description}

กรุณาวิเคราะห์และระบุสาเหตุจากเสียง
"""
```

### 2.3 Few-Shot Examples

```python
FEW_SHOT_EXAMPLES = """
ตัวอย่างการวิเคราะห์:

INPUT:
- เครื่อง: Motor Pump A (รุ่น ABC-123)
- อาการ: เครื่องส่งเสียงดัง ตะกร้อๆ ตอนเริ่มทำงาน
- อุณหภูมิ: สูงกว่าปกติ 15 องศา

OUTPUT:
{
  "causes": [
    {
      "cause": "Motor Bearing Wear",
      "confidence": 85.5,
      "description": "Bearing สึกหรอจากการใช้งานนาน ทำให้เกิดเสียงตะกร้อ",
      "severity": "high",
      "solution": {
        "steps": [
          "ปิดเครื่องจักรและถอดปลั๊ก",
          "ถอดฝาครอบ Motor",
          "ถอด Bearing เก่า",
          "ทำความสะอาด Housing",
          "ใส่ Bearing ใหม่",
          "ใส่ฝาครอบกลับ",
          "ทดสอบ运转"
        ],
        "estimated_time_minutes": 120,
        "estimated_cost": 2500.00,
        "difficulty": "medium"
      },
      "spare_parts": [
        {
          "part_name": "Bearing 6205-2RS",
          "part_number": "BRG-6205-2RS",
          "quantity": 2,
          "unit_price": 850.00
        }
      ],
      "prevention": "เปลี่ยน Bearing ทุก 12 เดือน หรือ 5,000 ชั่วโมง"
    },
    {
      "cause": "Motor Overload",
      "confidence": 12.0,
      "description": "Load สูงเกินไป ทำให้ Motor ทำงานหนัก",
      "severity": "medium",
      "solution": {
        "steps": [
          "ตรวจสอบ Load ที่ส่งเข้า Motor",
          "ปรับ Current Limit",
          "ตรวจสอบ Belt tension"
        ],
        "estimated_time_minutes": 60,
        "estimated_cost": 500.00,
        "difficulty": "easy"
      },
      "spare_parts": [],
      "prevention": "ตรวจสอบ Load เป็นประจำ ไม่ให้เกิน 80% ของ rated capacity"
    }
  ],
  "summary": "พบปัญหาหลักที่ Motor Bearing ซึ่งสึกหรอจากการใช้งาน แนะนำให้เปลี่ยน Bearing ใหม่",
  "urgency": "within_hour",
  "additional_notes": "ควรหยุดเครื่องเพื่อเปลี่ยน Bearing โดยเร็ว เพื่อป้องกันความเสียหายเพิ่มเติม"
}
"""
```

---

## 3. AI Workflow

### 3.1 Main Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AI ANALYSIS WORKFLOW                                │
└─────────────────────────────────────────────────────────────────────────────┘

START
  │
  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: INPUT COLLECTION                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  📷 Image   │  │  📝 Text    │  │  🎤 Voice   │  │  📊 Sensor  │       │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘       │
│         │                │                │                │                │
│         └────────────────┴────────────────┴────────────────┘                │
│                                      │                                      │
└──────────────────────────────────────┼──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 2: PREPROCESSING                                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Image Processing:                                                  │    │
│  │  - Resize to 1024x1024                                              │    │
│  │  - Normalize colors                                                 │    │
│  │  - Enhance contrast                                                 │    │
│  │  - Extract EXIF data                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Voice Processing:                                                  │    │
│  │  - Convert to text (Whisper)                                        │    │
│  │  - Extract keywords                                                 │    │
│  │  - Analyze sound patterns                                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Text Processing:                                                   │    │
│  │  - Clean and normalize                                              │    │
│  │  - Extract key symptoms                                             │    │
│  │  - Translate if needed                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 3: EMBEDDING & RETRIEVAL (RAG)                                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │   Input Text ──────▶ Embedding Model ──────▶ Vector                │    │
│  │                                    │           │                    │    │
│  │                                    │           ▼                    │    │
│  │                                    │     ┌─────────────┐            │    │
│  │                                    │     │   Vector    │            │    │
│  │                                    │     │    Store    │            │    │
│  │                                    │     │  (Pinecone) │            │    │
│  │                                    │     └──────┬──────┘            │    │
│  │                                    │            │                   │    │
│  │                                    │            ▼                   │    │
│  │                                    │     ┌─────────────┐            │    │
│  │                                    │     │  Retrieved  │            │    │
│  │                                    │     │  Documents  │            │    │
│  │                                    │     │  (Top 5)    │            │    │
│  │                                    │     └──────┬──────┘            │    │
│  │                                    │            │                   │    │
│  │                                    └────────────┼───────────────────┘    │
│  │                                                 │                        │
│  └─────────────────────────────────────────────────┼────────────────────────┘
│                                                    │                        │
└────────────────────────────────────────────────────┼────────────────────────┘
                                                     │
                                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 4: LLM ANALYSIS                                                      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  System Prompt ──────┐                                              │    │
│  │                      │                                              │    │
│  │  User Prompt ────────┤                                              │    │
│  │                      ▼                                              │    │
│  │              ┌─────────────┐                                        │    │
│  │              │    GPT-4    │                                        │    │
│  │              │   Vision    │                                        │    │
│  │              └──────┬──────┘                                        │    │
│  │                     │                                               │    │
│  │  Retrieved ─────────┤                                               │    │
│  │  Context            │                                               │    │
│  │                     ▼                                               │    │
│  │              ┌─────────────┐                                        │    │
│  │              │   Reasoning │                                        │    │
│  │              │   Engine    │                                        │    │
│  │              └──────┬──────┘                                        │    │
│  │                     │                                               │    │
│  └─────────────────────┼───────────────────────────────────────────────┘    │
│                        │                                                    │
└────────────────────────┼────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 5: POST-PROCESSING                                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │   Raw Output ──────▶ Validation ──────▶ Formatting ──────▶ Cache   │    │
│  │                         │                    │                    │    │
│  │                         ▼                    ▼                    │    │
│  │                  ┌─────────────┐      ┌─────────────┐             │    │
│  │                  │  Validate   │      │  Format to  │             │    │
│  │                  │  JSON       │      │  API Response│             │    │
│  │                  └─────────────┘      └─────────────┘             │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 6: OUTPUT                                                            │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  🔴 Causes  │  │  📊 Scores  │  │  🔧 Solutions│  │  📦 Parts   │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Detailed Workflow Steps

```python
# ai_workflow.py

class AIWorkflow:
    async def analyze(self, input_data: dict) -> dict:
        # Step 1: Collect Input
        images = input_data.get("images", [])
        text = input_data.get("text", "")
        voice = input_data.get("voice", None)
        machine_info = input_data.get("machine", {})
        
        # Step 2: Preprocess
        processed = await self.preprocess(images, text, voice, machine_info)
        
        # Step 3: Embedding & Retrieval (RAG)
        context = await self.retrieve_context(processed)
        
        # Step 4: LLM Analysis
        raw_output = await self.llm_analysis(processed, context)
        
        # Step 5: Post-process
        validated = await self.validate_output(raw_output)
        formatted = await self.format_output(validated)
        
        # Step 6: Cache & Return
        await self.cache_result(formatted)
        
        return formatted
    
    async def preprocess(self, images, text, voice, machine_info):
        # Image processing
        processed_images = []
        for img in images:
            processed = await self.process_image(img)
            processed_images.append(processed)
        
        # Voice to text
        if voice:
            voice_text = await self.speech_to_text(voice)
            text = f"{text} {voice_text}"
        
        # Text cleaning
        cleaned_text = await self.clean_text(text)
        
        return {
            "images": processed_images,
            "text": cleaned_text,
            "machine": machine_info
        }
    
    async def retrieve_context(self, processed):
        # Create embedding from text
        embedding = await self.create_embedding(processed["text"])
        
        # Search vector store
        similar_docs = await self.vector_store.search(
            embedding=embedding,
            top_k=5,
            filter={"machine_type": processed["machine"].get("type")}
        )
        
        # Combine context
        context = "\n\n".join([doc.content for doc in similar_docs])
        
        return context
    
    async def llm_analysis(self, processed, context):
        # Build prompt
        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": self.build_prompt(processed, context)}
        ]
        
        # Add images if present
        if processed["images"]:
            messages.append({
                "role": "user",
                "content": [
                    {"type": "text", "text": "รูปภาพเครื่องจักร:"},
                    *[{"type": "image_url", "image_url": {"url": img}} 
                      for img in processed["images"]]
                ]
            })
        
        # Call LLM
        response = await self.llm.chat.completions.create(
            model="gpt-4-vision-preview",
            messages=messages,
            response_format={"type": "json_object"},
            temperature=0.3,
            max_tokens=2000
        )
        
        return json.loads(response.choices[0].message.content)
    
    async def validate_output(self, output):
        # Validate JSON structure
        required_fields = ["causes", "summary", "urgency"]
        for field in required_fields:
            if field not in output:
                raise ValueError(f"Missing field: {field}")
        
        # Validate confidence scores
        for cause in output["causes"]:
            if not 0 <= cause["confidence"] <= 100:
                cause["confidence"] = max(0, min(100, cause["confidence"]))
        
        return output
```

---

## 4. RAG Architecture

### 4.1 RAG System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RAG ARCHITECTURE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                         KNOWLEDGE BASE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Manual     │  │  Repair     │  │  Parts      │  │  Historical │       │
│  │  Documents  │  │  History    │  │  Database   │  │  Failures   │       │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘       │
│         │                │                │                │                │
│         └────────────────┴────────────────┴────────────────┘                │
│                                      │                                      │
│                                      ▼                                      │
│                         ┌─────────────────────┐                            │
│                         │   Document Loader   │                            │
│                         └──────────┬──────────┘                            │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROCESSING PIPELINE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │   Documents ──────▶ Chunking ──────▶ Embedding ──────▶ Storage     │    │
│  │                         │                    │                    │    │
│  │                         ▼                    ▼                    │    │
│  │                  ┌─────────────┐      ┌─────────────┐             │    │
│  │                  │  Split into │      │  Create     │             │    │
│  │                  │  512 tokens │      │  Vectors    │             │    │
│  │                  │  with 50    │      │  (1536 dim) │             │    │
│  │                  │  overlap    │      │             │             │    │
│  │                  └─────────────┘      └─────────────┘             │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VECTOR STORE (Pinecone)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │   Index: maintenance-knowledge                                     │    │
│  │   Dimensions: 1536                                                 │    │
│  │   Metric: cosine                                                   │    │
│  │                                                                     │    │
│  │   Metadata:                                                        │    │
│  │   - machine_type: motor, pump, conveyor, etc.                      │    │
│  │   - failure_type: bearing, electrical, mechanical, etc.            │    │
│  │   - severity: high, medium, low                                    │    │
│  │   - source: manual, history, parts_db                             │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RETRIEVAL SYSTEM                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │   Query ──────▶ Embedding ──────▶ Similarity Search ──────▶ Rerank │    │
│  │                    │                      │                    │    │
│  │                    ▼                      ▼                    │    │
│  │             ┌─────────────┐        ┌─────────────┐              │    │
│  │             │  Convert    │        │  Find Top   │              │    │
│  │             │  to Vector  │        │  10 Matches │              │    │
│  │             └─────────────┘        └─────────────┘              │    │
│  │                                                 │                │    │
│  │                                                 ▼                │    │
│  │                                          ┌─────────────┐         │    │
│  │                                          │  Rerank by  │         │    │
│  │                                          │  Relevance  │         │    │
│  │                                          │  Score      │         │    │
│  │                                          └─────────────┘         │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  Output: Top 5 most relevant documents                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 RAG Implementation

```python
# rag_service.py

from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Pinecone
from langchain.document_loaders import DirectoryLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

class RAGService:
    def __init__(self):
        self.embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
        self.vector_store = Pinecone.from_existing_index(
            index_name="maintenance-knowledge",
            embedding=self.embeddings
        )
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=512,
            chunk_overlap=50,
            length_function=len,
            separators=["\n\n", "\n", " ", ""]
        )
    
    async def ingest_documents(self, directory: str):
        # Load documents
        loader = DirectoryLoader(
            directory,
            glob="**/*.md",
            loader_cls=TextLoader
        )
        documents = loader.load()
        
        # Split documents
        chunks = self.text_splitter.split_documents(documents)
        
        # Add metadata
        for chunk in chunks:
            chunk.metadata["source"] = "manual"
            chunk.metadata["ingested_at"] = datetime.now().isoformat()
        
        # Store in vector database
        self.vector_store.add_documents(chunks)
        
        return len(chunks)
    
    async def retrieve_context(
        self, 
        query: str, 
        filters: dict = None,
        top_k: int = 5
    ) -> list:
        # Search with filters
        results = self.vector_store.similarity_search(
            query=query,
            k=top_k,
            filter=filters
        )
        
        return results
    
    async def retrieve_with_score(
        self, 
        query: str, 
        top_k: int = 5
    ) -> list:
        # Search with relevance scores
        results = self.vector_store.similarity_search_with_score(
            query=query,
            k=top_k
        )
        
        # Filter by minimum score
        filtered = [(doc, score) for doc, score in results if score > 0.7]
        
        return filtered
```

---

## 5. Knowledge Base

### 5.1 Knowledge Base Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KNOWLEDGE BASE STRUCTURE                            │
└─────────────────────────────────────────────────────────────────────────────┘

knowledge_base/
├── manuals/                          # คู่มือเครื่องจักร
│   ├── motor/
│   │   ├── motor_manual_abc123.md
│   │   ├── motor_troubleshooting.md
│   │   └── motor_maintenance_guide.md
│   ├── pump/
│   │   ├── pump_manual_xyz456.md
│   │   ├── pump_troubleshooting.md
│   │   └── pump_maintenance_guide.md
│   └── conveyor/
│       ├── conveyor_manual_789.md
│       └── conveyor_troubleshooting.md
│
├── failures/                         # ประวัติความเสียหาย
│   ├── motor/
│   │   ├── bearing_wear.md
│   │   ├── overload.md
│   │   └── electrical_fault.md
│   ├── pump/
│   │   ├── seal_leak.md
│   │   ├── impeller_damage.md
│   │   └── cavitation.md
│   └── conveyor/
│       ├── belt_wear.md
│       ├── misalignment.md
│       └── roller_failure.md
│
├── parts/                            # ข้อมูลอะไหล่
│   ├── bearings/
│   │   ├── 6205-2rs.md
│   │   ├── 6206-2rs.md
│   │   └── 6308-2rs.md
│   ├── seals/
│   │   ├── mechanical_seal.md
│   │   └── o_ring.md
│   └── belts/
│       ├── v_belt_a.md
│       └── v_belt_b.md
│
├── procedures/                       # ขั้นตอนการซ่อม
│   ├── motor_repair/
│   │   ├── bearing_replacement.md
│   │   ├── winding_repair.md
│   │   └── alignment.md
│   ├── pump_repair/
│   │   ├── seal_replacement.md
│   │   └── impeller_replacement.md
│   └── conveyor_repair/
│       ├── belt_replacement.md
│       └── roller_replacement.md
│
└── safety/                           # ความปลอดภัย
    ├── lockout_tagout.md
    ├── electrical_safety.md
    └── ppe_requirements.md
```

### 5.2 Knowledge Base Content Example

```markdown
# Motor Bearing Wear

## Overview
Motor bearing wear is one of the most common failure modes in industrial motors.

## Symptoms
- Unusual noise (grinding, squealing, or clicking)
- Increased vibration
- Elevated temperature
- Increased current draw

## Causes
1. Normal wear and tear
2. Improper lubrication
3. Contamination
4. Misalignment
5. Overloading

## Diagnosis
1. Visual inspection for discoloration
2. Vibration analysis
3. Temperature measurement
4. Current analysis

## Solution
### Bearing Replacement Procedure
1. **Lockout/Tagout** - Ensure machine is de-energized
2. **Remove coupling** - Disconnect motor from driven equipment
3. **Remove end bells** - Carefully remove both end bells
4. **Remove old bearing** - Use bearing puller
5. **Clean housing** - Remove old grease and debris
6. **Install new bearing** - Use proper installation tools
7. **Reassemble** - Reinstall end bells and coupling
8. **Test** - Run motor and check for abnormalities

## Spare Parts
| Part Number | Description | Quantity | Unit Price |
|-------------|-------------|----------|------------|
| BRG-6205-2RS | Bearing 6205-2RS | 2 | 850 THB |
| GRE-001 | Motor Grease | 1 | 150 THB |

## Prevention
- Lubricate every 2,000 hours or 6 months
- Monitor vibration levels
- Check alignment quarterly
- Replace bearing every 20,000 hours

## Estimated Time
- 2 hours for standard replacement
- 4 hours if shaft is damaged

## Estimated Cost
- Parts: 1,850 THB
- Labor: 700 THB
- Total: 2,550 THB
```

### 5.3 Knowledge Base Update Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE BASE UPDATE PROCESS                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  New Repair │
│  Completed  │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│  Extract    │────▶│  Create     │
│  Knowledge  │     │  Document   │
└─────────────┘     └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Review &   │
                    │  Approve    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
       ┌─────────────┐          ┌─────────────┐
       │  Approved   │          │  Rejected   │
       │  → Add to   │          │  → Revise   │
       │    KB       │          │             │
       └──────┬──────┘          └─────────────┘
              │
              ▼
       ┌─────────────┐
       │  Chunk &    │
       │  Embed      │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │  Update     │
       │  Vector     │
       │  Store      │
       └─────────────┘
```

---

## 6. Embedding Model

### 6.1 Embedding Configuration

```python
# embedding_config.py

EMBEDDING_CONFIG = {
    "model": "text-embedding-3-small",
    "dimensions": 1536,
    "max_tokens": 8191,
    "cost_per_1k_tokens": 0.00002
}

# Usage
embedding = await openai.embeddings.create(
    model=EMBEDDING_CONFIG["model"],
    input=text,
    dimensions=EMBEDDING_CONFIG["dimensions"]
)
```

### 6.2 Embedding Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EMBEDDING PIPELINE                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Raw Text   │
│  (512 tokens)│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Tokenize   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Embedding  │
│  Model      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Vector     │
│  (1536 dim) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Normalize  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Store in   │
│  Pinecone   │
└─────────────┘
```

---

## 7. Voice Processing

### 7.1 Voice to Text Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      VOICE PROCESSING PIPELINE                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Voice      │
│  Recording  │
│  (WAV/MP3)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Audio      │
│  Processing │
│  - Noise    │
│    Reduction│
│  - Normalize│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Whisper    │
│  Model      │
│  (OpenAI)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Text       │
│  Transcript │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Keyword    │
│  Extraction │
│  - Symptoms │
│  - Machine  │
│  - Location │
└─────────────┘
```

### 7.2 Sound Analysis

```python
# sound_analysis.py

import librosa
import numpy as np

class SoundAnalyzer:
    def analyze_sound(self, audio_path: str) -> dict:
        # Load audio
        y, sr = librosa.load(audio_path)
        
        # Extract features
        features = {
            "duration": librosa.get_duration(y=y, sr=sr),
            "rms_energy": float(np.mean(librosa.feature.rms(y=y))),
            "zero_crossing_rate": float(np.mean(librosa.feature.zero_crossing_rate(y))),
            "spectral_centroid": float(np.mean(librosa.feature.spectral_centroid(y=y, sr=sr))),
            "spectral_bandwidth": float(np.mean(librosa.feature.spectral_bandwidth(y=y, sr=sr))),
        }
        
        # Detect anomalies
        anomalies = self.detect_anomalies(features)
        
        return {
            "features": features,
            "anomalies": anomalies,
            "assessment": self.assess_sound(anomalies)
        }
    
    def detect_anomalies(self, features: dict) -> list:
        anomalies = []
        
        # High energy = loud noise
        if features["rms_energy"] > 0.1:
            anomalies.append({
                "type": "high_noise",
                "severity": "high",
                "description": "เสียงดังผิดปกติ"
            })
        
        # High spectral centroid = high frequency noise
        if features["spectral_centroid"] > 3000:
            anomalies.append({
                "type": "high_frequency",
                "severity": "medium",
                "description": "เสียงความถี่สูง อาจเกิดจาก Bearing"
            })
        
        return anomalies
```

---

## 8. Performance Optimization

### 8.1 Caching Strategy

```python
# cache_strategy.py

class AICacheStrategy:
    def __init__(self):
        self.redis = Redis()
        self.ttl = {
            "analysis": 3600,      # 1 hour
            "embedding": 86400,    # 24 hours
            "context": 300         # 5 minutes
        }
    
    async def get_cached_analysis(self, input_hash: str):
        return await self.redis.get(f"analysis:{input_hash}")
    
    async def cache_analysis(self, input_hash: str, result: dict):
        await self.redis.setex(
            f"analysis:{input_hash}",
            self.ttl["analysis"],
            json.dumps(result)
        )
    
    async def get_cached_context(self, query_hash: str):
        return await self.redis.get(f"context:{query_hash}")
    
    async def cache_context(self, query_hash: str, context: list):
        await self.redis.setex(
            f"context:{query_hash}",
            self.ttl["context"],
            json.dumps(context)
        )
```

### 8.2 Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Response Time | < 5s | - |
| Accuracy | > 80% | - |
| Cache Hit Rate | > 70% | - |
| Concurrent Requests | 100 | - |
| Error Rate | < 1% | - |

---

## 9. Monitoring & Logging

### 9.1 Monitoring Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AI MONITORING DASHBOARD                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  Real-time Metrics                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Requests  │  │   Avg Time  │  │   Accuracy  │  │   Errors    │       │
│  │    1,234    │  │    3.2s     │  │    85.5%    │  │    0.5%     │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Request Timeline                                                   │    │
│  │  ───────────────────────────────────────────────────────────────   │    │
│  │  1200 ┤                                                            │    │
│  │       │      ╭──╮                                                  │    │
│  │   800 ┤    ╭─╯  ╰──╮                                               │    │
│  │       │  ╭─╯        ╰─╮                                            │    │
│  │   400 ┤╭─╯            ╰─╮                                          │    │
│  │       │╯                ╰──                                        │    │
│  │     0 ┼──────────────────────────────────────────────────────────  │    │
│  │       00:00  04:00  08:00  12:00  16:00  20:00  24:00             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Logging Configuration

```python
# logging_config.py

import logging
from datetime import datetime

class AILogger:
    def __init__(self):
        self.logger = logging.getLogger("ai_maintenance")
    
    def log_analysis(
        self,
        request_id: str,
        input_data: dict,
        output_data: dict,
        processing_time: float,
        success: bool
    ):
        self.logger.info({
            "timestamp": datetime.now().isoformat(),
            "request_id": request_id,
            "input_type": input_data.get("type"),
            "machine_id": input_data.get("machine_id"),
            "confidence": output_data.get("confidence"),
            "causes_count": len(output_data.get("causes", [])),
            "processing_time_ms": processing_time,
            "success": success
        })
    
    def log_error(
        self,
        request_id: str,
        error: Exception,
        context: dict
    ):
        self.logger.error({
            "timestamp": datetime.now().isoformat(),
            "request_id": request_id,
            "error_type": type(error).__name__,
            "error_message": str(error),
            "context": context
        })
```

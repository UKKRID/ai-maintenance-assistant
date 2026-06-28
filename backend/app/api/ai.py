from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from typing import List, Optional
from datetime import datetime
import uuid

from app.schemas.ai_analysis import (
    AIAnalysisRequest,
    AIAnalysisResponse,
    AIFeedbackRequest,
    AIFeedbackResponse,
    FeedbackType
)
from app.services.ai_service import ai_service

router = APIRouter()


@router.post("/analyze", response_model=AIAnalysisResponse)
async def analyze_breakdown(request: AIAnalysisRequest):
    """
    วิเคราะห์อาการเสียเครื่องจักรด้วย AI

    - **machine_id**: รหัสเครื่องจักร
    - **input_text**: อาการเสีย (optional)
    - **image_urls**: รูปภาพ (optional)
    """
    # Mock machine info (in real app, fetch from database)
    machine_info = {
        "name": "Motor Pump A",
        "model": "ABC-123",
        "location": "Building 1, Floor 2",
        "age": "5"
    }

    try:
        # Call AI service
        raw_result = await ai_service.analyze_breakdown(request, machine_info)

        # Parse result
        analysis = ai_service.parse_analysis(raw_result, request)
        analysis.analysis_id = str(uuid.uuid4())
        analysis.processing_time = raw_result["processing_time"]
        analysis.created_at = datetime.utcnow()

        return analysis

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI Analysis failed: {str(e)}"
        )


@router.post("/analyze/upload", response_model=AIAnalysisResponse)
async def analyze_with_upload(
    machine_id: str = Form(...),
    input_text: Optional[str] = Form(None),
    images: List[UploadFile] = File(...)
):
    """
    วิเคราะห์อาการเสียด้วยการอัพโหลดรูปภาพ

    - **machine_id**: รหัสเครื่องจักร
    - **input_text**: อาการเสีย (optional)
    - **images**: รูปภาพ ( multipart/form-data)
    """
    # In real app, upload images to storage and get URLs
    image_urls = []
    for img in images:
        # Mock: In real app, save to S3/MinIO
        image_urls.append(f"https://storage.example.com/uploads/{img.filename}")

    request = AIAnalysisRequest(
        machine_id=machine_id,
        input_text=input_text,
        image_urls=image_urls
    )

    return await analyze_breakdown(request)


@router.get("/analysis/{analysis_id}", response_model=AIAnalysisResponse)
async def get_analysis(analysis_id: str):
    """
    ดูผลวิเคราะห์ AI

    - **analysis_id**: รหัสการวิเคราะห์
    """
    # Mock: In real app, fetch from database
    return AIAnalysisResponse(
        analysis_id=analysis_id,
        machine_id="machine-001",
        confidence=85.5,
        causes=[],
        summary="Test analysis",
        urgency="within_hour",
        model_version="gpt-4-vision-preview",
        processing_time=3500,
        created_at=datetime.utcnow()
    )


@router.post("/feedback", response_model=AIFeedbackResponse)
async def submit_feedback(request: AIFeedbackRequest):
    """
    ส่ง Feedback การวิเคราะห์

    - **analysis_id**: รหัสการวิเคราะห์
    - **feedback**: helpful/not_helpful/partially_helpful
    - **actual_cause**: สาเหตุจริง (optional)
    - **notes**: หมายเหตุ (optional)
    """
    # Mock: In real app, save to database
    return AIFeedbackResponse(
        analysis_id=request.analysis_id,
        feedback=request.feedback,
        updated_at=datetime.utcnow()
    )


@router.get("/analysis/history/{machine_id}")
async def get_analysis_history(
    machine_id: str,
    page: int = 1,
    limit: int = 20
):
    """
    ดูประวัติการวิเคราะห์ของเครื่องจักร

    - **machine_id**: รหัสเครื่องจักร
    - **page**: หน้า
    - **limit**: จำนวนต่อหน้า
    """
    # Mock: In real app, fetch from database
    return {
        "items": [],
        "total": 0,
        "page": page,
        "limit": limit
    }

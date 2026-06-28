from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from enum import Enum


class SeverityLevel(str, Enum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class UrgencyLevel(str, Enum):
    IMMEDIATE = "immediate"
    WITHIN_HOUR = "within_hour"
    WITHIN_DAY = "within_day"
    CAN_WAIT = "can_wait"


class FeedbackType(str, Enum):
    HELPFUL = "helpful"
    NOT_HELPFUL = "not_helpful"
    PARTIALLY_HELPFUL = "partially_helpful"


class SparePartRecommendation(BaseModel):
    part_name: str
    part_number: str
    quantity: int
    unit_price: float


class Solution(BaseModel):
    steps: List[str]
    estimated_time_minutes: int
    estimated_cost: float
    difficulty: str


class Cause(BaseModel):
    cause: str
    confidence: float
    description: str
    severity: SeverityLevel
    solution: Solution
    spare_parts: List[SparePartRecommendation]
    prevention: str


class AIAnalysisRequest(BaseModel):
    machine_id: str
    input_text: Optional[str] = None
    image_urls: Optional[List[str]] = None


class AIAnalysisResponse(BaseModel):
    analysis_id: str
    repair_id: Optional[str] = None
    machine_id: str
    input_text: Optional[str] = None
    input_images: Optional[List[str]] = None
    confidence: float
    causes: List[Cause]
    summary: str
    urgency: UrgencyLevel
    additional_notes: Optional[str] = None
    model_version: str
    processing_time: int
    created_at: datetime


class AIAnalysisListResponse(BaseModel):
    items: List[AIAnalysisResponse]
    total: int
    page: int
    limit: int


class AIFeedbackRequest(BaseModel):
    analysis_id: str
    feedback: FeedbackType
    actual_cause: Optional[str] = None
    notes: Optional[str] = None


class AIFeedbackResponse(BaseModel):
    analysis_id: str
    feedback: FeedbackType
    updated_at: datetime

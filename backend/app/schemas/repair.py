from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class RepairPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class RepairStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class RepairCreate(BaseModel):
    machine_id: str
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    priority: RepairPriority = RepairPriority.MEDIUM
    estimated_time: Optional[int] = Field(None, ge=0)
    estimated_cost: Optional[float] = Field(None, ge=0)
    notes: Optional[str] = None


class RepairUpdateStatus(BaseModel):
    status: RepairStatus
    notes: Optional[str] = None


class RepairAssign(BaseModel):
    assigned_to: str


class RepairComplete(BaseModel):
    actual_time: Optional[int] = Field(None, ge=0)
    actual_cost: Optional[float] = Field(None, ge=0)
    notes: Optional[str] = None


class RepairResponse(BaseModel):
    repair_id: str
    machine_id: str
    machine_name: Optional[str] = None
    machine_model: Optional[str] = None
    reporter_id: str
    reporter_name: Optional[str] = None
    assigned_to: Optional[str] = None
    assigned_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    priority: str
    status: str
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    estimated_time: Optional[int] = None
    actual_time: Optional[int] = None
    estimated_cost: Optional[float] = None
    actual_cost: Optional[float] = None
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class RepairListResponse(BaseModel):
    items: List[RepairResponse]
    total: int
    page: int
    limit: int


class MessageResponse(BaseModel):
    message: str
    success: bool = True

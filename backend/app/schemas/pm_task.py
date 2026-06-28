from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from enum import Enum


class PMTaskStatus(str, Enum):
    SCHEDULED = "scheduled"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    OVERDUE = "overdue"
    CANCELLED = "cancelled"


class ChecklistItemCreate(BaseModel):
    item_name: str = Field(..., min_length=1, max_length=200)
    is_required: bool = True
    sort_order: int = Field(..., ge=0)


class ChecklistItemResponse(BaseModel):
    checklist_id: str
    item_name: str
    is_required: bool
    is_completed: bool
    sort_order: int
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ChecklistItemUpdate(BaseModel):
    is_completed: bool


class PMTaskCreate(BaseModel):
    machine_id: str
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    scheduled_date: date
    assigned_to: Optional[str] = None
    checklist: Optional[List[ChecklistItemCreate]] = None
    notes: Optional[str] = None


class PMTaskUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    scheduled_date: Optional[date] = None
    assigned_to: Optional[str] = None
    status: Optional[PMTaskStatus] = None
    notes: Optional[str] = None


class PMTaskComplete(BaseModel):
    completed_date: Optional[date] = None
    notes: Optional[str] = None


class PMTaskResponse(BaseModel):
    pm_id: str
    machine_id: str
    machine_name: Optional[str] = None
    machine_model: Optional[str] = None
    assigned_to: Optional[str] = None
    assigned_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    scheduled_date: date
    completed_date: Optional[date] = None
    status: str
    notes: Optional[str] = None
    checklist: List[ChecklistItemResponse] = []
    checklist_progress: Optional[dict] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PMTaskListResponse(BaseModel):
    items: List[PMTaskResponse]
    total: int
    page: int
    limit: int


class MessageResponse(BaseModel):
    message: str
    success: bool = True

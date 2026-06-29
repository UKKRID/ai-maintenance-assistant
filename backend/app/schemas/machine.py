from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from enum import Enum


class MachineStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    UNDER_REPAIR = "under_repair"
    DISPOSED = "disposed"


class MachineCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    model: str = Field(..., min_length=1, max_length=100)
    serial_number: str = Field(..., min_length=1, max_length=100)
    location: str = Field(..., min_length=1, max_length=200)
    department: Optional[str] = Field(None, max_length=100)
    install_date: date
    status: MachineStatus = MachineStatus.ACTIVE
    image_url: Optional[str] = Field(None, max_length=500)


class MachineUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    model: Optional[str] = Field(None, min_length=1, max_length=100)
    serial_number: Optional[str] = Field(None, min_length=1, max_length=100)
    location: Optional[str] = Field(None, min_length=1, max_length=200)
    department: Optional[str] = Field(None, max_length=100)
    install_date: Optional[date] = None
    status: Optional[MachineStatus] = None
    image_url: Optional[str] = Field(None, max_length=500)


class MachineResponse(BaseModel):
    machine_id: str
    name: str
    model: str
    serial_number: str
    location: str
    department: Optional[str] = None
    install_date: date
    status: str
    qr_code: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MachineListResponse(BaseModel):
    items: List[MachineResponse]
    total: int
    page: int
    limit: int


class MessageResponse(BaseModel):
    message: str
    success: bool = True

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class SparePartCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    part_number: str = Field(..., min_length=1, max_length=100)
    category: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None
    unit_price: float = Field(..., gt=0)
    stock_qty: int = Field(0, ge=0)
    min_stock: int = Field(0, ge=0)
    unit: str = Field("piece", max_length=20)
    image_url: Optional[str] = Field(None, max_length=500)


class SparePartUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    part_number: Optional[str] = Field(None, min_length=1, max_length=100)
    category: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None
    unit_price: Optional[float] = Field(None, gt=0)
    stock_qty: Optional[int] = Field(None, ge=0)
    min_stock: Optional[int] = Field(None, ge=0)
    unit: Optional[str] = Field(None, max_length=20)
    image_url: Optional[str] = Field(None, max_length=500)
    is_active: Optional[bool] = None


class StockUpdate(BaseModel):
    quantity: int = Field(..., description="Positive to add, negative to subtract")
    reason: Optional[str] = None


class SparePartResponse(BaseModel):
    part_id: str
    name: str
    part_number: str
    category: Optional[str] = None
    description: Optional[str] = None
    unit_price: float
    stock_qty: int
    min_stock: int
    unit: str
    image_url: Optional[str] = None
    is_active: bool
    stock_status: str
    total_value: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class SparePartListResponse(BaseModel):
    items: List[SparePartResponse]
    total: int
    page: int
    limit: int


class StockSummary(BaseModel):
    total_parts: int
    total_value: float
    low_stock_count: int
    out_of_stock_count: int


class MessageResponse(BaseModel):
    message: str
    success: bool = True

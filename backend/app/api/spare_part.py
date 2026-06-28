from fastapi import APIRouter, HTTPException, Header, Query
from typing import Optional

from app.schemas.spare_part import (
    SparePartCreate,
    SparePartUpdate,
    StockUpdate,
    SparePartResponse,
    SparePartListResponse,
    StockSummary,
    MessageResponse
)
from app.services.spare_part_service import spare_part_service
from app.utils.security import get_current_user_id

router = APIRouter()


def get_current_user(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="ไม่มี Token")
    token = authorization.replace("Bearer ", "")
    email = get_current_user_id(token)
    if not email:
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")
    return email


@router.get("", response_model=SparePartListResponse)
async def get_spare_parts(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    category: Optional[str] = None,
    low_stock: Optional[bool] = None,
    is_active: Optional[bool] = None,
    authorization: Optional[str] = Header(None)
):
    """ดูรายการอะไหล่"""
    get_current_user(authorization)

    result = await spare_part_service.get_spare_parts(
        page=page, limit=limit, search=search,
        category=category, low_stock=low_stock, is_active=is_active,
    )
    return SparePartListResponse(
        items=[SparePartResponse(**p) for p in result["items"]],
        total=result["total"], page=result["page"], limit=result["limit"]
    )


@router.get("/stock-summary", response_model=StockSummary)
async def get_stock_summary(authorization: Optional[str] = Header(None)):
    """ดูสรุป-stock"""
    get_current_user(authorization)
    return await spare_part_service.get_stock_summary()


@router.get("/{part_id}", response_model=SparePartResponse)
async def get_spare_part(part_id: str, authorization: Optional[str] = Header(None)):
    """ดูรายละเอียดอะไหล่"""
    get_current_user(authorization)
    part = await spare_part_service.get_spare_part_by_id(part_id)
    if not part:
        raise HTTPException(status_code=404, detail="ไม่พบอะไหล่")
    return SparePartResponse(**part)


@router.post("", response_model=SparePartResponse, status_code=201)
async def create_spare_part(request: SparePartCreate, authorization: Optional[str] = Header(None)):
    """เพิ่มอะไหล่ (Admin only)"""
    get_current_user(authorization)
    try:
        part = await spare_part_service.create_spare_part(request)
        return SparePartResponse(**part)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{part_id}", response_model=SparePartResponse)
async def update_spare_part(part_id: str, request: SparePartUpdate, authorization: Optional[str] = Header(None)):
    """แก้ไขอะไหล่ (Admin only)"""
    get_current_user(authorization)
    try:
        part = await spare_part_service.update_spare_part(part_id, request)
        return SparePartResponse(**part)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{part_id}/stock", response_model=SparePartResponse)
async def update_stock(part_id: str, request: StockUpdate, authorization: Optional[str] = Header(None)):
    """อัพเดทจำนวน stock"""
    get_current_user(authorization)
    try:
        part = await spare_part_service.update_stock(part_id, request)
        return SparePartResponse(**part)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{part_id}", response_model=MessageResponse)
async def delete_spare_part(part_id: str, authorization: Optional[str] = Header(None)):
    """ลบอะไหล่ (Admin only)"""
    get_current_user(authorization)
    success = await spare_part_service.delete_spare_part(part_id)
    if not success:
        raise HTTPException(status_code=404, detail="ไม่พบอะไหล่")
    return MessageResponse(message="ลบอะไหล่สำเร็จ")

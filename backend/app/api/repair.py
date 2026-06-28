from fastapi import APIRouter, HTTPException, Header, Query
from typing import Optional

from app.schemas.repair import (
    RepairCreate,
    RepairUpdateStatus,
    RepairAssign,
    RepairComplete,
    RepairResponse,
    RepairListResponse,
    MessageResponse
)
from app.services.repair_service import repair_service
from app.utils.security import get_current_user_id

router = APIRouter()


def get_current_user(authorization: Optional[str] = Header(None)):
    """Helper to extract user from token"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="ไม่มี Token")

    token = authorization.replace("Bearer ", "")
    email = get_current_user_id(token)

    if not email:
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")

    return email


@router.get("", response_model=RepairListResponse)
async def get_repairs(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    priority: Optional[str] = None,
    machine_id: Optional[str] = None,
    assigned_to: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """
    ดูรายการงานซ่อม

    - **page**: หน้า (default: 1)
    - **limit**: จำนวนต่อหน้า (default: 20)
    - **search**: ค้นหาจากหัวข้อ/รายละเอียด
    - **status**: กรองตามสถานะ (pending/in_progress/completed/cancelled)
    - **priority**: กรองตามความสำคัญ (low/medium/high/critical)
    - **machine_id**: กรองตามเครื่องจักร
    - **assigned_to**: กรองตามผู้รับผิดชอบ
    """
    get_current_user(authorization)

    result = await repair_service.get_repairs(
        page=page,
        limit=limit,
        search=search,
        status=status,
        priority=priority,
        machine_id=machine_id,
        assigned_to=assigned_to,
    )

    return RepairListResponse(
        items=[RepairResponse(**r) for r in result["items"]],
        total=result["total"],
        page=result["page"],
        limit=result["limit"]
    )


@router.get("/{repair_id}", response_model=RepairResponse)
async def get_repair(
    repair_id: str,
    authorization: Optional[str] = Header(None)
):
    """
    ดูรายละเอียดงานซ่อม

    - **repair_id**: รหัสงานซ่อม
    """
    get_current_user(authorization)

    repair = await repair_service.get_repair_by_id(repair_id)
    if not repair:
        raise HTTPException(status_code=404, detail="ไม่พบงานซ่อม")

    return RepairResponse(**repair)


@router.post("", response_model=RepairResponse, status_code=201)
async def create_repair(
    request: RepairCreate,
    authorization: Optional[str] = Header(None)
):
    """
    สร้างงานซ่อมใหม่

    - **machine_id**: รหัสเครื่องจักร
    - **title**: หัวข้อ
    - **description**: รายละเอียด (optional)
    - **priority**: ความสำคัญ (default: medium)
    - **estimated_time**: เวลาประมาณ (นาที) (optional)
    - **estimated_cost**: ค่าใช้จ่ายประมาณ (optional)
    - **notes**: หมายเหตุ (optional)
    """
    email = get_current_user(authorization)

    # In real app, get user_id from email
    reporter_id = "user-001"  # Mock

    try:
        repair = await repair_service.create_repair(request, reporter_id)
        return RepairResponse(**repair)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{repair_id}/assign", response_model=RepairResponse)
async def assign_repair(
    repair_id: str,
    request: RepairAssign,
    authorization: Optional[str] = Header(None)
):
    """
    มอบหมายงาน (Supervisor only)

    - **repair_id**: รหัสงานซ่อม
    - **assigned_to**: รหัสผู้รับผิดชอบ
    """
    email = get_current_user(authorization)

    # TODO: Check role == supervisor

    try:
        repair = await repair_service.assign_repair(repair_id, request)
        return RepairResponse(**repair)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{repair_id}/status", response_model=RepairResponse)
async def update_status(
    repair_id: str,
    request: RepairUpdateStatus,
    authorization: Optional[str] = Header(None)
):
    """
    อัพเดทสถานะงาน

    - **repair_id**: รหัสงานซ่อม
    - **status**: สถานะใหม่
    - **notes**: หมายเหตุ (optional)
    """
    get_current_user(authorization)

    try:
        repair = await repair_service.update_status(repair_id, request)
        return RepairResponse(**repair)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{repair_id}/complete", response_model=RepairResponse)
async def complete_repair(
    repair_id: str,
    request: RepairComplete,
    authorization: Optional[str] = Header(None)
):
    """
    เสร็จสิ้นงาน

    - **repair_id**: รหัสงานซ่อม
    - **actual_time**: เวลาจริง (นาที) (optional)
    - **actual_cost**: ค่าใช้จ่ายจริง (optional)
    - **notes**: หมายเหตุ (optional)
    """
    get_current_user(authorization)

    try:
        repair = await repair_service.complete_repair(repair_id, request)
        return RepairResponse(**repair)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

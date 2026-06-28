from fastapi import APIRouter, HTTPException, Header, Query
from typing import Optional
from datetime import date

from app.schemas.pm_task import (
    PMTaskCreate,
    PMTaskUpdate,
    PMTaskComplete,
    ChecklistItemUpdate,
    PMTaskResponse,
    PMTaskListResponse,
    MessageResponse
)
from app.services.pm_task_service import pm_task_service
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


@router.get("", response_model=PMTaskListResponse)
async def get_pm_tasks(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    machine_id: Optional[str] = None,
    assigned_to: Optional[str] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    authorization: Optional[str] = Header(None)
):
    """
    ดูตารางงาน PM

    - **page**: หน้า
    - **limit**: จำนวนต่อหน้า
    - **search**: ค้นหาจากหัวข้อ
    - **status**: กรองตามสถานะ (scheduled/in_progress/completed/overdue/cancelled)
    - **machine_id**: กรองตามเครื่องจักร
    - **assigned_to**: กรองตามผู้รับผิดชอบ
    - **start_date**: กรองตั้งแต่วันที่
    - **end_date**: กรองถึงวันที่
    """
    get_current_user(authorization)

    result = await pm_task_service.get_pm_tasks(
        page=page,
        limit=limit,
        search=search,
        status=status,
        machine_id=machine_id,
        assigned_to=assigned_to,
        start_date=start_date,
        end_date=end_date,
    )

    return PMTaskListResponse(
        items=[PMTaskResponse(**t) for t in result["items"]],
        total=result["total"],
        page=result["page"],
        limit=result["limit"]
    )


@router.get("/{pm_id}", response_model=PMTaskResponse)
async def get_pm_task(
    pm_id: str,
    authorization: Optional[str] = Header(None)
):
    """ดูรายละเอียดงาน PM"""
    get_current_user(authorization)

    task = await pm_task_service.get_pm_task_by_id(pm_id)
    if not task:
        raise HTTPException(status_code=404, detail="ไม่พบงาน PM")

    return PMTaskResponse(**task)


@router.post("", response_model=PMTaskResponse, status_code=201)
async def create_pm_task(
    request: PMTaskCreate,
    authorization: Optional[str] = Header(None)
):
    """สร้างงาน PM ใหม่ (Admin only)"""
    get_current_user(authorization)

    try:
        task = await pm_task_service.create_pm_task(request)
        return PMTaskResponse(**task)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{pm_id}", response_model=PMTaskResponse)
async def update_pm_task(
    pm_id: str,
    request: PMTaskUpdate,
    authorization: Optional[str] = Header(None)
):
    """แก้ไขงาน PM"""
    get_current_user(authorization)

    try:
        task = await pm_task_service.update_pm_task(pm_id, request)
        return PMTaskResponse(**task)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{pm_id}/complete", response_model=PMTaskResponse)
async def complete_pm_task(
    pm_id: str,
    request: PMTaskComplete,
    authorization: Optional[str] = Header(None)
):
    """เสร็จสิ้นงาน PM"""
    get_current_user(authorization)

    try:
        task = await pm_task_service.complete_pm_task(pm_id, request)
        return PMTaskResponse(**task)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{pm_id}/checklist/{checklist_id}/{item_id}", response_model=PMTaskResponse)
async def update_checklist_item(
    pm_id: str,
    checklist_id: str,
    item_id: str,
    request: ChecklistItemUpdate,
    authorization: Optional[str] = Header(None)
):
    """อัพเดทรายการ Checklist"""
    get_current_user(authorization)

    try:
        task = await pm_task_service.update_checklist_item(
            pm_id, checklist_id, item_id, request
        )
        return PMTaskResponse(**task)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{pm_id}", response_model=MessageResponse)
async def delete_pm_task(
    pm_id: str,
    authorization: Optional[str] = Header(None)
):
    """ลบงาน PM (Admin only)"""
    get_current_user(authorization)

    success = await pm_task_service.delete_pm_task(pm_id)
    if not success:
        raise HTTPException(status_code=404, detail="ไม่พบงาน PM")

    return MessageResponse(message="ลบงาน PM สำเร็จ")

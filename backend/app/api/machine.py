from fastapi import APIRouter, HTTPException, Header, Query
from typing import Optional

from app.schemas.machine import (
    MachineCreate,
    MachineUpdate,
    MachineResponse,
    MachineListResponse,
    MessageResponse
)
from app.services.machine_service import machine_service
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


@router.get("", response_model=MachineListResponse)
async def get_machines(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    department: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """
    ดูรายการเครื่องจักร

    - **page**: หน้า (default: 1)
    - **limit**: จำนวนต่อหน้า (default: 20)
    - **search**: ค้นหาจากชื่อ/รุ่น/หมายเลข
    - **status**: กรองตามสถานะ (active/inactive/under_repair/disposed)
    - **department**: กรองตามแผนก
    """
    get_current_user(authorization)  # Require auth

    result = await machine_service.get_machines(
        page=page,
        limit=limit,
        search=search,
        status=status,
        department=department
    )

    return MachineListResponse(
        items=[MachineResponse(**m) for m in result["items"]],
        total=result["total"],
        page=result["page"],
        limit=result["limit"]
    )


@router.get("/{machine_id}", response_model=MachineResponse)
async def get_machine(
    machine_id: str,
    authorization: Optional[str] = Header(None)
):
    """
    ดูรายละเอียดเครื่องจักร

    - **machine_id**: รหัสเครื่องจักร
    """
    get_current_user(authorization)  # Require auth

    machine = await machine_service.get_machine_by_id(machine_id)
    if not machine:
        raise HTTPException(status_code=404, detail="ไม่พบเครื่องจักร")

    return MachineResponse(**machine)


@router.post("", response_model=MachineResponse, status_code=201)
async def create_machine(
    request: MachineCreate,
    authorization: Optional[str] = Header(None)
):
    """
    เพิ่มเครื่องจักร (Admin only)

    - **name**: ชื่อเครื่องจักร
    - **model**: รุ่น
    - **serial_number**: หมายเลขเครื่อง
    - **location**: สถานที่ตั้ง
    - **department**: แผนก (optional)
    - **install_date**: วันที่ติดตั้ง
    - **status**: สถานะ (default: active)
    """
    email = get_current_user(authorization)

    # TODO: Check role == admin
    # For now, allow all authenticated users

    try:
        machine = await machine_service.create_machine(request)
        return MachineResponse(**machine)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{machine_id}", response_model=MachineResponse)
async def update_machine(
    machine_id: str,
    request: MachineUpdate,
    authorization: Optional[str] = Header(None)
):
    """
    แก้ไขเครื่องจักร (Admin only)

    - **machine_id**: รหัสเครื่องจักร
    - สามารถแก้ไข field ใดก็ได้
    """
    email = get_current_user(authorization)

    # TODO: Check role == admin

    try:
        machine = await machine_service.update_machine(machine_id, request)
        return MachineResponse(**machine)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{machine_id}", response_model=MessageResponse)
async def delete_machine(
    machine_id: str,
    authorization: Optional[str] = Header(None)
):
    """
    ลบเครื่องจักร (Admin only)

    - **machine_id**: รหัสเครื่องจักร
    """
    email = get_current_user(authorization)

    # TODO: Check role == admin

    success = await machine_service.delete_machine(machine_id)
    if not success:
        raise HTTPException(status_code=404, detail="ไม่พบเครื่องจักร")

    return MessageResponse(message="ลบเครื่องจักรสำเร็จ")

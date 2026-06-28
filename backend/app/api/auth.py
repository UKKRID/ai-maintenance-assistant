from fastapi import APIRouter, HTTPException, Header
from typing import Optional

from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    RefreshTokenRequest,
    AuthResponse,
    TokenResponse,
    MessageResponse,
    UserResponse
)
from app.services.auth_service import auth_service
from app.utils.security import get_current_user_id

router = APIRouter()


@router.post("/login", response_model=AuthResponse)
async def login(request: LoginRequest):
    """
    เข้าสู่ระบบ

    - **email**: อีเมล
    - **password**: รหัสผ่าน
    """
    try:
        result = await auth_service.login(request.email, request.password)
        return AuthResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.post("/register", response_model=AuthResponse)
async def register(request: RegisterRequest):
    """
    สมัครสมาชิก

    - **email**: อีเมล
    - **password**: รหัสผ่าน
    - **full_name**: ชื่อ-นามสกุล
    - **username**: ชื่อผู้ใช้ (optional)
    - **phone**: เบอร์โทรศัพท์ (optional)
    """
    try:
        result = await auth_service.register(
            email=request.email,
            password=request.password,
            full_name=request.full_name,
            username=request.username,
            phone=request.phone
        )
        return AuthResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest):
    """
    ขอ Token ใหม่

    - **refresh_token**: Refresh Token
    """
    try:
        result = await auth_service.refresh_token(request.refresh_token)
        return TokenResponse(
            access_token=result["access_token"],
            expires_in=result["expires_in"]
        )
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.post("/logout", response_model=MessageResponse)
async def logout(authorization: Optional[str] = Header(None)):
    """
    ออกจากระบบ

    - **Authorization**: Bearer Token
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="ไม่มี Token")

    token = authorization.replace("Bearer ", "")
    user_id = get_current_user_id(token)

    if not user_id:
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")

    await auth_service.logout(user_id)
    return MessageResponse(message="ออกจากระบบสำเร็จ")


@router.get("/me", response_model=UserResponse)
async def get_current_user(authorization: Optional[str] = Header(None)):
    """
    ดูข้อมูลผู้ใช้ปัจจุบัน

    - **Authorization**: Bearer Token
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="ไม่มี Token")

    token = authorization.replace("Bearer ", "")
    email = get_current_user_id(token)

    if not email:
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")

    user = await auth_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="ไม่พบผู้ใช้")

    return UserResponse(
        user_id=user["user_id"],
        email=user["email"],
        full_name=user["full_name"],
        username=user["username"],
        phone=user["phone"],
        role=user["role"],
        avatar_url=user["avatar_url"],
        created_at=user["created_at"]
    )

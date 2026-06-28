from typing import Optional
from datetime import datetime, timezone
import uuid

from app.utils.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token
)
from app.config import settings


# Mock database (in real app, use SQLAlchemy)
users_db = {}


class AuthService:
    def __init__(self):
        # Initialize with a demo user
        self._init_demo_user()

    def _init_demo_user(self):
        now = datetime.now(timezone.utc)
        demo_user = {
            "user_id": str(uuid.uuid4()),
            "email": "demo@example.com",
            "username": "demo",
            "full_name": "Demo User",
            "phone": "0812345678",
            "role": "technician",
            "password_hash": get_password_hash("password123"),
            "avatar_url": None,
            "is_active": True,
            "created_at": now,
            "updated_at": now
        }
        users_db[demo_user["email"]] = demo_user

    async def login(self, email: str, password: str) -> dict:
        user = users_db.get(email)
        if not user:
            raise ValueError("Email หรือ Password ไม่ถูกต้อง")

        if not verify_password(password, user["password_hash"]):
            raise ValueError("Email หรือ Password ไม่ถูกต้อง")

        if not user["is_active"]:
            raise ValueError("บัญชีถูกปิดการใช้งาน")

        return self._generate_tokens(user)

    async def register(
        self,
        email: str,
        password: str,
        full_name: str,
        username: Optional[str] = None,
        phone: Optional[str] = None
    ) -> dict:
        # Check if email exists
        if email in users_db:
            raise ValueError("Email นี้ถูกใช้แล้ว")

        # Check if username exists
        if username:
            for u in users_db.values():
                if u["username"] == username:
                    raise ValueError("Username นี้ถูกใช้แล้ว")

        # Create user
        now = datetime.now(timezone.utc)
        user_id = str(uuid.uuid4())
        new_user = {
            "user_id": user_id,
            "email": email,
            "username": username or email.split("@")[0],
            "full_name": full_name,
            "phone": phone,
            "role": "technician",
            "password_hash": get_password_hash(password),
            "avatar_url": None,
            "is_active": True,
            "created_at": now,
            "updated_at": now
        }

        users_db[email] = new_user
        return self._generate_tokens(new_user)

    async def refresh_token(self, refresh_token: str) -> dict:
        payload = decode_token(refresh_token)

        if not payload:
            raise ValueError("Token ไม่ถูกต้องหรือหมดอายุ")

        if payload.get("type") != "refresh":
            raise ValueError("Token ไม่ใช่ Refresh Token")

        email = payload.get("sub")
        user = users_db.get(email)

        if not user:
            raise ValueError("ไม่พบผู้ใช้")

        if not user["is_active"]:
            raise ValueError("บัญชีถูกปิดการใช้งาน")

        return self._generate_tokens(user)

    async def logout(self, user_id: str) -> dict:
        # In real app, invalidate token in Redis
        return {"message": "ออกจากระบบสำเร็จ"}

    async def get_user_by_email(self, email: str) -> Optional[dict]:
        return users_db.get(email)

    async def get_user_by_id(self, user_id: str) -> Optional[dict]:
        for user in users_db.values():
            if user["user_id"] == user_id:
                return user
        return None

    def _generate_tokens(self, user: dict) -> dict:
        access_token = create_access_token(
            data={"sub": user["email"], "role": user["role"]}
        )
        refresh_token = create_refresh_token(
            data={"sub": user["email"]}
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "refresh_token": refresh_token,
            "user": {
                "user_id": user["user_id"],
                "email": user["email"],
                "full_name": user["full_name"],
                "username": user["username"],
                "phone": user["phone"],
                "role": user["role"],
                "avatar_url": user["avatar_url"],
                "created_at": user["created_at"]
            }
        }


auth_service = AuthService()

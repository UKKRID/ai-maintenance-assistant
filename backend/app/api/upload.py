from fastapi import APIRouter, UploadFile, File, HTTPException, Header
from typing import Optional
import os
import uuid
import shutil

from app.utils.security import get_current_user_id

router = APIRouter()

UPLOAD_DIR = "./uploads/images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"]
MAX_SIZE = 10 * 1024 * 1024  # 10MB


def get_current_user(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="ไม่มี Token")
    token = authorization.replace("Bearer ", "")
    email = get_current_user_id(token)
    if not email:
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")
    return email


@router.post("/upload")
async def upload_image(
    file: UploadFile = File(...),
    folder: str = "general",
    authorization: Optional[str] = Header(None)
):
    """
    อัพโหลดรูปภาพ

    - **file**: ไฟล์รูปภาพ (JPEG, PNG, WebP, GIF)
    - **folder**: โฟลเดอร์เก็บรูป (machines, spare_parts, etc.)
    """
    get_current_user(authorization)

    # Validate file type
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"ประเภทไฟล์ไม่ถูกต้อง อนุญาตเฉพาะ: {', '.join(ALLOWED_TYPES)}"
        )

    # Validate file size
    contents = await file.read()
    if len(contents) > MAX_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"ขนาดไฟล์เกินกำหนด (สูงสุด {MAX_SIZE // (1024 * 1024)} MB)"
        )

    # Generate unique filename
    ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    filename = f"{uuid.uuid4().hex}.{ext}"

    # Create folder if not exists
    folder_path = os.path.join(UPLOAD_DIR, folder)
    os.makedirs(folder_path, exist_ok=True)

    # Save file
    file_path = os.path.join(folder_path, filename)
    with open(file_path, "wb") as buffer:
        buffer.write(contents)

    # Return URL
    image_url = f"/uploads/images/{folder}/{filename}"

    return {
        "url": image_url,
        "filename": filename,
        "content_type": file.content_type,
        "size": len(contents)
    }


@router.delete("/{folder}/{filename}")
async def delete_image(
    folder: str,
    filename: str,
    authorization: Optional[str] = Header(None)
):
    """
    ลบรูปภาพ
    """
    get_current_user(authorization)

    file_path = os.path.join(UPLOAD_DIR, folder, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="ไม่พบไฟล์")

    os.remove(file_path)
    return {"message": "ลบไฟล์สำเร็จ"}

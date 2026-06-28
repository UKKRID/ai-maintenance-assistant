# Auth Feature - Installation Guide

## โครงสร้างไฟล์ที่สร้าง

```
MT_Project/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                    # ✓ แก้ไข - เพิ่ม Auth router
│   │   ├── config.py
│   │   ├── database.py                # ✓ สร้างใหม่
│   │   ├── api/
│   │   │   ├── __init__.py            # ✓ แก้ไข - เพิ่ม auth
│   │   │   ├── ai.py
│   │   │   └── auth.py                # ✓ สร้างใหม่
│   │   ├── models/
│   │   │   └── user.py                # ✓ สร้างใหม่
│   │   ├── schemas/
│   │   │   ├── ai_analysis.py
│   │   │   └── auth.py                # ✓ สร้างใหม่
│   │   ├── services/
│   │   │   ├── ai_service.py
│   │   │   └── auth_service.py        # ✓ สร้างใหม่
│   │   └── utils/
│   │       └── security.py            # ✓ สร้างใหม่
│   ├── tests/
│   │   ├── test_ai.py
│   │   └── test_auth.py               # ✓ สร้างใหม่
│   ├── requirements.txt               # ✓ แก้ไข - เพิ่ม dependencies
│   └── .env.example
│
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   │   └── constants/
│   │   │       └── app_colors.dart    # ✓ สร้างใหม่
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── ai_analysis.dart
│   │   │       └── user_entity.dart   # ✓ สร้างใหม่
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── ai_analysis_model.dart
│   │   │   │   └── user_model.dart    # ✓ สร้างใหม่
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       ├── ai_remote_datasource.dart
│   │   │   │       └── auth_remote_datasource.dart  # ✓ สร้างใหม่
│   │   │   └── repositories/
│   │   │       ├── ai_repository.dart
│   │   │       └── auth_repository.dart             # ✓ สร้างใหม่
│   │   ├── presentation/
│   │   │   ├── blocs/
│   │   │   │   ├── ai/
│   │   │   │   └── auth/
│   │   │   │       ├── auth_bloc.dart              # ✓ สร้างใหม่
│   │   │   │       ├── auth_event.dart             # ✓ สร้างใหม่
│   │   │   │       └── auth_state.dart             # ✓ สร้างใหม่
│   │   │   ├── pages/
│   │   │   │   ├── ai/
│   │   │   │   └── auth/
│   │   │   │       ├── login_page.dart             # ✓ สร้างใหม่
│   │   │   │       └── register_page.dart          # ✓ สร้างใหม่
│   │   │   └── widgets/
│   │   │       └── ai/
│   │   └── services/
│   │       └── api/
│   │           └── api_client.dart
│   └── test/
│       ├── ai_analysis_test.dart
│       └── user_entity_test.dart      # ✓ สร้างใหม่
```

---

## Backend Installation

### 1. ติดตั้ง Dependencies

```bash
cd MT_Project/backend
python -m venv venv
source venv/bin/activate  # macOS/Linux

pip install -r requirements.txt
```

### 2. ตั้งค่า Environment Variables

```bash
cp .env.example .env
# แก้ไข .env
# JWT_SECRET_KEY=your-secret-key
# OPENAI_API_KEY=your-api-key
```

### 3. รัน Server

```bash
uvicorn app.main:app --reload --port 8000
```

### 4. ทดสอบ API

```bash
# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "demo@example.com", "password": "password123"}'

# Register
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "new@test.com", "password": "test1234", "full_name": "New User"}'

# Get me (ต้องมี token)
curl http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer <your-token>"
```

### 5. รัน Tests

```bash
pytest tests/test_auth.py -v
```

---

## Mobile Installation

### 1. ติดตั้ง Dependencies

```bash
cd MT_Project/mobile

# สร้าง project (ถ้ายังไม่มี)
flutter create ai_maintenance_assistant
cd ai_maintenance_assistant

# Copy files
cp -r ../mobile/lib/* lib/

# ติดตั้ง dependencies
flutter pub add flutter_bloc dio image_picker http
flutter pub add --dev flutter_test
```

### 2. รัน App

```bash
flutter run
```

### 3. ทดสอบ Feature

1. เปิดแอป → หน้า Login
2. กรอก Demo Account:
   - Email: demo@example.com
   - Password: password123
3. กด "เข้าสู่ระบบ"
4. ไปหน้า Dashboard

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | เข้าสู่ระบบ |
| POST | /api/auth/register | สมัครสมาชิก |
| POST | /api/auth/refresh | ขอ Token ใหม่ |
| POST | /api/auth/logout | ออกจากระบบ |
| GET | /api/auth/me | ดูข้อมูลผู้ใช้ปัจจุบัน |

---

## Flow การใช้งาน

```
1. User เปิดแอป
    ↓
2. ตรวจสอบ Token
    ↓
   ┌─────────────────┐
   │ มี Token?       │
   └────────┬────────┘
   Yes      │ No
   │        │
   │        ▼
   │   ┌─────────────┐
   │   │ Login Page  │
   │   └──────┬──────┘
   │          │
   │   ┌──────┴──────┐
   │   │ Login /     │
   │   │ Register    │
   │   └──────┬──────┘
   │          │
   └────┬─────┘
        │
        ▼
   ┌─────────────┐
   │  Dashboard  │
   └─────────────┘
```

---

## Demo Credentials

| Email | Password | Role |
|-------|----------|------|
| demo@example.com | password123 | technician |

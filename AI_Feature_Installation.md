# AI Analysis Feature - Installation Guide

## โครงสร้างไฟล์ที่สร้าง

```
MT_Project/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                    # FastAPI app
│   │   ├── config.py                  # Settings
│   │   ├── api/
│   │   │   ├── __init__.py
│   │   │   └── ai.py                  # AI API endpoints
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   └── ai_analysis.py         # Pydantic schemas
│   │   └── services/
│   │       ├── __init__.py
│   │       └── ai_service.py          # OpenAI integration
│   ├── tests/
│   │   └── test_ai.py                 # API tests
│   ├── requirements.txt
│   └── .env.example
│
├── mobile/
│   ├── lib/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── ai_analysis.dart   # Domain entities
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── ai_analysis_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       └── ai_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── ai_repository.dart
│   │   ├── presentation/
│   │   │   ├── blocs/
│   │   │   │   └── ai/
│   │   │   │       └── ai_bloc.dart
│   │   │   ├── pages/
│   │   │   │   └── ai/
│   │   │   │       ├── ai_analysis_page.dart
│   │   │   │       └── ai_result_page.dart
│   │   │   └── widgets/
│   │   │       └── ai/
│   │   │           └── cause_card.dart
│   │   └── services/
│   │       └── api/
│   │           └── api_client.dart
│   └── test/
│       └── ai_analysis_test.dart
```

---

## Backend Installation

### 1. ติดตั้ง Dependencies

```bash
cd MT_Project/backend
python -m venv venv
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows

pip install -r requirements.txt
```

### 2. ตั้งค่า Environment Variables

```bash
cp .env.example .env
# แก้ไข .env
# OPENAI_API_KEY=your-api-key-here
```

### 3. รัน Server

```bash
uvicorn app.main:app --reload --port 8000
```

### 4. ทดสอบ API

เปิด browser ไปที่: http://localhost:8000/docs

หรือรัน tests:

```bash
pytest tests/ -v
```

---

## Mobile Installation

### 1. ติดตั้ง Flutter

```bash
# ตรวจสอบ version
flutter --version

# ถ้ายังไม่ได้ติดตั้ง
# https://docs.flutter.dev/get-started/install
```

### 2. ติดตั้ง Dependencies

```bash
cd MT_Project/mobile

# สร้าง project (ถ้ายังไม่มี)
flutter create ai_maintenance_assistant
cd ai_maintenance_assistant

# Copy files จาก mobile/lib/ ไปใส่ใน project
cp -r ../mobile/lib/* lib/

# ติดตั้ง dependencies
flutter pub add flutter_bloc dio image_picker http http_parser mime
flutter pub add --dev flutter_test bloc_test mocktail
```

### 3. รัน App

```bash
# บน simulator/device
flutter run

# หรือ build
flutter build apk
flutter build ios
```

---

## ทดสอบ Feature

### ทดสอบ Backend

```bash
# 1. รัน server
cd backend
uvicorn app.main:app --reload

# 2. เปิด Swagger UI
open http://localhost:8000/docs

# 3. ทดสอบ endpoint
POST /api/ai/analyze
{
  "machine_id": "machine-001",
  "input_text": "Motor making loud noise"
}
```

### ทดสอบ Mobile

```bash
# 1. รัน app
flutter run

# 2. เลือกเครื่องจักร
# 3. กด Scan หรือกรอกอาการ
# 4. กด Analyze with AI
# 5. ดูผลลัพธ์
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/ai/analyze | วิเคราะห์อาการเสีย |
| POST | /api/ai/analyze/upload | วิเคราะห์พร้อมอัพรูป |
| GET | /api/ai/analysis/{id} | ดูผลวิเคราะห์ |
| POST | /api/ai/feedback | ส่ง Feedback |
| GET | /api/ai/analysis/history/{machine_id} | ดูประวัติ |

---

## Flow การใช้งาน

```
1. User เปิดแอป
    ↓
2. เลือกเครื่องจักร
    ↓
3. ถ่ายรูป / พิมพ์อาการเสีย
    ↓
4. กด "Analyze with AI"
    ↓
5. ส่งข้อมูลไป Backend → OpenAI API
    ↓
6. แสดงผลลัพธ์
    - สาเหตุที่เป็นไปได้ (เรียงตาม confidence)
    - วิธีแก้ไข (ขั้นตอน)
    - อะไหล่ที่ต้องใช้
    - เวลา/ค่าใช้จ่ายประมาณ
    ↓
7. User สร้างรายงานซ่อม / ดูอะไหล่
```

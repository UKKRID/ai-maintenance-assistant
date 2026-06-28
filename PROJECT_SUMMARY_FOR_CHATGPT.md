# AI Maintenance Assistant - Project Summary for ChatGPT

## โปรเจค概述

ชื่อโปรเจค: AI Maintenance Assistant
ประเภท: Mobile Application (iOS + Android)
เป้าหมาย: แอปสำหรับช่างซ่อมบำรุง วิเคราะห์อาการเสียเครื่องจักรด้วย AI

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter + BLoC State Management |
| Backend | FastAPI (Python 3.11) |
| Database | PostgreSQL 15 |
| Cache | Redis 7 |
| AI | OpenAI GPT-4 Vision + RAG |
| Vector DB | Pinecone |
| File Storage | MinIO / AWS S3 |
| Container | Docker + Docker Compose |
| Web Server | Nginx |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana |

---

## Features ที่สร้างแล้ว

| # | Feature | Status | Backend | Mobile |
|---|---------|--------|---------|--------|
| 1 | Auth (Login/Register) | ✓ | 5 endpoints | 2 pages |
| 2 | AI Analysis | ✓ | 5 endpoints | 3 pages |
| 3 | Machine Management | ✓ | 5 endpoints | 4 pages |
| 4 | Repair Management | ✓ | 6 endpoints | 3 pages |
| 5 | PM Schedule | ✓ | 7 endpoints | 3 pages |

---

## Database Schema (9 Tables)

```sql
-- USER Table
CREATE TABLE "user" (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'technician' CHECK (role IN ('technician', 'supervisor', 'admin')),
    avatar_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- MACHINE Table
CREATE TABLE machine (
    machine_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    location VARCHAR(200) NOT NULL,
    department VARCHAR(100),
    install_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'under_repair', 'disposed')),
    qr_code VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- REPAIR Table
CREATE TABLE repair (
    repair_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    machine_id UUID NOT NULL REFERENCES machine(machine_id),
    reporter_id UUID NOT NULL REFERENCES "user"(user_id),
    assigned_to UUID REFERENCES "user"(user_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    estimated_time INTEGER,
    actual_time INTEGER,
    estimated_cost DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- PM_TASK Table
CREATE TABLE pm_task (
    pm_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    machine_id UUID NOT NULL REFERENCES machine(machine_id),
    assigned_to UUID REFERENCES "user"(user_id),
    checklist_id UUID REFERENCES pm_checklist(checklist_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'overdue', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- PM_CHECKLIST Table
CREATE TABLE pm_checklist (
    checklist_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_name VARCHAR(200) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL
);

-- SPARE_PART Table
CREATE TABLE spare_part (
    part_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    part_number VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    description TEXT,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_qty INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER NOT NULL DEFAULT 0,
    unit VARCHAR(20) NOT NULL DEFAULT 'piece',
    image_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- REPAIR_SPARE Table (Junction)
CREATE TABLE repair_spare (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_id UUID NOT NULL REFERENCES repair(repair_id),
    part_id UUID NOT NULL REFERENCES spare_part(part_id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

-- AI_ANALYSIS Table
CREATE TABLE ai_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_id UUID NOT NULL REFERENCES repair(repair_id),
    input_text TEXT,
    input_images JSONB,
    ai_response JSONB NOT NULL,
    confidence DECIMAL(5,2),
    causes JSONB,
    solutions JSONB,
    estimated_time INTEGER,
    estimated_cost DECIMAL(10,2),
    feedback VARCHAR(20) CHECK (feedback IN ('helpful', 'not_helpful', 'partially_helpful')),
    model_version VARCHAR(50),
    processing_time INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- REPORT Table
CREATE TABLE report (
    report_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_id UUID NOT NULL UNIQUE REFERENCES repair(repair_id),
    created_by UUID NOT NULL REFERENCES "user"(user_id),
    approved_by UUID REFERENCES "user"(user_id),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'approved', 'rejected')),
    pdf_url VARCHAR(500),
    approved_at TIMESTAMP,
    rejected_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## API Endpoints (ที่สร้างแล้วทั้งหมด)

### Auth Module
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | เข้าสู่ระบบ |
| POST | /api/auth/register | สมัครสมาชิก |
| POST | /api/auth/refresh | ขอ Token ใหม่ |
| POST | /api/auth/logout | ออกจากระบบ |
| GET | /api/auth/me | ดูข้อมูลผู้ใช้ปัจจุบัน |

### AI Module
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/ai/analyze | วิเคราะห์อาการเสีย |
| POST | /api/ai/analyze/upload | วิเคราะห์พร้อมอัพรูป |
| GET | /api/ai/analysis/{id} | ดูผลวิเคราะห์ |
| POST | /api/ai/feedback | ส่ง Feedback |
| GET | /api/ai/analysis/history/{machine_id} | ดูประวัติวิเคราะห์ |

### Machine Module
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/machines | ดูรายการเครื่องจักร |
| GET | /api/machines/{id} | ดูรายละเอียดเครื่อง |
| POST | /api/machines | เพิ่มเครื่องจักร |
| PUT | /api/machines/{id} | แก้ไขเครื่องจักร |
| DELETE | /api/machines/{id} | ลบเครื่องจักร |

### Repair Module
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/repairs | ดูรายการงานซ่อม |
| GET | /api/repairs/{id} | ดูรายละเอียดงานซ่อม |
| POST | /api/repairs | สร้างงานซ่อมใหม่ |
| PUT | /api/repairs/{id}/assign | มอบหมายงาน |
| PUT | /api/repairs/{id}/status | อัพเดทสถานะ |
| PUT | /api/repairs/{id}/complete | เสร็จสิ้นงาน |

### PM Task Module
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/pm-tasks | ดูตาราง PM |
| GET | /api/pm-tasks/{id} | ดูรายละเอียด PM |
| POST | /api/pm-tasks | สร้างงาน PM |
| PUT | /api/pm-tasks/{id} | แก้ไขงาน PM |
| PUT | /api/pm-tasks/{id}/complete | เสร็จสิ้นงาน PM |
| PUT | /api/pm-tasks/{id}/checklist/{cid}/{iid} | อัพเดท Checklist |
| DELETE | /api/pm-tasks/{id} | ลบงาน PM |

---

## Project Structure

### Backend
```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI entry point
│   ├── config.py                  # Settings
│   ├── database.py                # SQLAlchemy setup
│   ├── api/
│   │   ├── __init__.py
│   │   ├── ai.py                  # AI endpoints
│   │   ├── auth.py                # Auth endpoints
│   │   ├── machine.py             # Machine endpoints
│   │   ├── repair.py              # Repair endpoints
│   │   └── pm_task.py             # PM Task endpoints
│   ├── models/
│   │   ├── user.py
│   │   ├── machine.py
│   │   ├── repair.py
│   │   └── pm_task.py
│   ├── schemas/
│   │   ├── ai_analysis.py
│   │   ├── auth.py
│   │   ├── machine.py
│   │   ├── repair.py
│   │   └── pm_task.py
│   ├── services/
│   │   ├── ai_service.py
│   │   ├── auth_service.py
│   │   ├── machine_service.py
│   │   ├── repair_service.py
│   │   └── pm_task_service.py
│   └── utils/
│       └── security.py
├── tests/
│   ├── test_ai.py
│   ├── test_auth.py
│   ├── test_machine.py
│   ├── test_repair.py
│   └── test_pm_task.py
├── requirements.txt
└── .env.example
```

### Mobile (Flutter)
```
mobile/lib/
├── core/constants/
│   └── app_colors.dart
├── domain/entities/
│   ├── ai_analysis.dart
│   └── user_entity.dart
├── data/
│   ├── models/
│   │   ├── ai_analysis_model.dart
│   │   ├── user_model.dart
│   │   ├── machine_model.dart
│   │   ├── repair_model.dart
│   │   └── pm_task_model.dart
│   ├── datasources/remote/
│   │   ├── ai_remote_datasource.dart
│   │   ├── auth_remote_datasource.dart
│   │   ├── machine_remote_datasource.dart
│   │   ├── repair_remote_datasource.dart
│   │   └── pm_task_remote_datasource.dart
│   └── repositories/
│       ├── ai_repository.dart
│       ├── auth_repository.dart
│       ├── machine_repository.dart
│       ├── repair_repository.dart
│       └── pm_task_repository.dart
├── presentation/
│   ├── blocs/
│   │   ├── ai/ai_bloc.dart
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── machine/
│   │   │   ├── machine_bloc.dart
│   │   │   ├── machine_event.dart
│   │   │   └── machine_state.dart
│   │   ├── repair/
│   │   │   ├── repair_bloc.dart
│   │   │   ├── repair_event.dart
│   │   │   └── repair_state.dart
│   │   └── pm_task/
│   │       ├── pm_task_bloc.dart
│   │       ├── pm_task_event.dart
│   │       └── pm_task_state.dart
│   ├── pages/
│   │   ├── ai/
│   │   │   ├── ai_analysis_page.dart
│   │   │   └── ai_result_page.dart
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── machine/
│   │   │   ├── machine_list_page.dart
│   │   │   ├── machine_detail_page.dart
│   │   │   ├── add_machine_page.dart
│   │   │   └── edit_machine_page.dart
│   │   ├── repair/
│   │   │   ├── repair_list_page.dart
│   │   │   ├── repair_detail_page.dart
│   │   │   └── create_repair_page.dart
│   │   └── pm_task/
│   │       ├── pm_schedule_page.dart
│   │       ├── pm_detail_page.dart
│   │       └── create_pm_task_page.dart
│   └── widgets/ai/
│       └── cause_card.dart
└── services/api/
    └── api_client.dart
```

---

## Status Flow

### Repair Status
```
pending → in_progress → completed
    │           │
    └───────────┴──→ cancelled
```

### PM Task Status
```
scheduled → in_progress → completed
    │           │
    └───────────┴──→ overdue
    │
    └──→ cancelled
```

---

## Demo Credentials

| Email | Password | Role |
|-------|----------|------|
| demo@example.com | password123 | technician |

---

## Features ที่ยังไม่สร้าง

| Feature | Priority | Description |
|---------|----------|-------------|
| Spare Parts | High | จัดการอะไหล่ + Stock + AI Recommend |
| Dashboard | Medium | สรุปข้อมูล + กราฟ Analytics |
| Report | Low | Export PDF |

---

## คำสั่งรันระบบ

### Backend
```bash
cd MT_Project/backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
# เปิด http://localhost:8000/docs
```

### Mobile
```bash
cd MT_Project/mobile
flutter create ai_maintenance_assistant
cd ai_maintenance_assistant
cp -r ../mobile/lib/* lib/
flutter pub add flutter_bloc dio flutter_secure_storage http http_parser mime image_picker
flutter run
```

### Test
```bash
cd MT_Project/backend
pytest tests/ -v
```

---

## สำหรับ ChatGPT

คัดลอกเอกสารนี้ไปวางใน ChatGPT แล้วสั่ง:

"สร้าง Feature [ชื่อ Feature] สำหรับโปรเจค AI Maintenance Assistant โดยใช้ข้อมูลจากเอกสารนี้ ห้ามเปลี่ยน Database Schema และ API เดิม"

ตัวอย่าง:
- "สร้าง Feature Spare Parts"
- "สร้าง Feature Dashboard"
- "สร้าง Feature Report Export"

---

## สถิติทั้งหมด

| Category | Count |
|----------|-------|
| Backend Files | 25 |
| Mobile Files | 35 |
| Test Files | 7 |
| Documentation | 15 |
| **Total** | **82 files** |

---

## แผนงานต่อไป (Next Tasks)

### Phase 1: Core Features (สัปดาห์ 1-2)
1. Spare Parts (CRUD + Stock)

### Phase 2: Extended Features (สัปดาห์ 3-4)
2. Dashboard (Summary + Charts)
3. Report (Export PDF)

### Phase 3: Enhancement (สัปดาห์ 5-6)
4. Push Notification
5. Barcode/QR Scanner

### Phase 4: Production (สัปดาห์ 7-8)
6. Testing (Unit/Integration/E2E)
7. Deployment (Docker + CI/CD)
8. Monitoring (Prometheus + Grafana)

# Repair Management Feature - Installation Guide

## ไฟล์ที่สร้างใหม่

```
backend/
├── app/
│   ├── api/
│   │   └── repair.py              ✓ สร้างใหม่
│   ├── models/
│   │   └── repair.py              ✓ สร้างใหม่
│   ├── schemas/
│   │   └── repair.py              ✓ สร้างใหม่
│   └── services/
│       └── repair_service.py      ✓ สร้างใหม่
├── tests/
│   └── test_repair.py             ✓ สร้างใหม่

mobile/lib/
├── data/
│   ├── models/
│   │   └── repair_model.dart      ✓ สร้างใหม่
│   ├── datasources/remote/
│   │   └── repair_remote_datasource.dart  ✓ สร้างใหม่
│   └── repositories/
│       └── repair_repository.dart ✓ สร้างใหม่
├── presentation/
│   ├── blocs/repair/
│   │   ├── repair_bloc.dart       ✓ สร้างใหม่
│   │   ├── repair_event.dart      ✓ สร้างใหม่
│   │   └── repair_state.dart      ✓ สร้างใหม่
│   └── pages/repair/
│       ├── repair_list_page.dart  ✓ สร้างใหม่
│       ├── repair_detail_page.dart ✓ สร้างใหม่
│       └── create_repair_page.dart ✓ สร้างใหม่
```

## ไฟล์ที่แก้ไข

```
backend/app/api/__init__.py         ✓ เพิ่ม repair
backend/app/main.py                 ✓ เพิ่ม repair router
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/repairs | ดูรายการงานซ่อม |
| GET | /api/repairs/{id} | ดูรายละเอียดงานซ่อม |
| POST | /api/repairs | สร้างงานซ่อมใหม่ |
| PUT | /api/repairs/{id}/assign | มอบหมายงาน |
| PUT | /api/repairs/{id}/status | อัพเดทสถานะ |
| PUT | /api/repairs/{id}/complete | เสร็จสิ้นงาน |

---

## API Examples

### GET /api/repairs
```bash
curl -X GET "http://localhost:8000/api/repairs?status=pending&priority=high" \
  -H "Authorization: Bearer <token>"
```

### POST /api/repairs
```bash
curl -X POST "http://localhost:8000/api/repairs" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "machine_id": "machine-001",
    "title": "Motor Noise",
    "description": "Motor making loud noise",
    "priority": "high",
    "estimated_time": 120,
    "estimated_cost": 2500
  }'
```

### PUT /api/repairs/{id}/status
```bash
curl -X PUT "http://localhost:8000/api/repairs/<repair_id>/status" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress", "notes": "Starting work"}'
```

### PUT /api/repairs/{id}/complete
```bash
curl -X PUT "http://localhost:8000/api/repairs/<repair_id>/complete" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"actual_time": 90, "actual_cost": 2200, "notes": "Completed"}'
```

---

## Repair Status Flow

```
pending → in_progress → completed
    │           │
    └───────────┴──→ cancelled
```

---

## Test Cases

```bash
cd MT_Project/backend
pytest tests/test_repair.py -v
```

| Test | Description |
|------|-------------|
| test_get_repairs | ดูรายการงานซ่อม |
| test_get_repairs_with_status | กรองตามสถานะ |
| test_get_repairs_with_priority | กรองตามความสำคัญ |
| test_get_repair_by_id | ดูรายละเอียดงาน |
| test_create_repair | สร้างงานซ่อม |
| test_assign_repair | มอบหมายงาน |
| test_update_status | อัพเดทสถานะ |
| test_complete_repair | เสร็จสิ้นงาน |
| test_get_repairs_without_auth | ไม่มี Token |

# PM Schedule Feature - Installation Guide

## ไฟล์ที่สร้างใหม่ (14 files)

### Backend (5 files)
- `backend/app/models/pm_task.py`
- `backend/app/schemas/pm_task.py`
- `backend/app/services/pm_task_service.py`
- `backend/app/api/pm_task.py`
- `backend/tests/test_pm_task.py`

### Mobile (9 files)
- `mobile/lib/data/models/pm_task_model.dart`
- `mobile/lib/data/datasources/remote/pm_task_remote_datasource.dart`
- `mobile/lib/data/repositories/pm_task_repository.dart`
- `mobile/lib/presentation/blocs/pm_task/pm_task_bloc.dart`
- `mobile/lib/presentation/blocs/pm_task/pm_task_event.dart`
- `mobile/lib/presentation/blocs/pm_task/pm_task_state.dart`
- `mobile/lib/presentation/pages/pm_task/pm_schedule_page.dart`
- `mobile/lib/presentation/pages/pm_task/pm_detail_page.dart`
- `mobile/lib/presentation/pages/pm_task/create_pm_task_page.dart`
- `mobile/test/pm_task_test.dart`

## ไฟล์ที่แก้ไข (2 files)
- `backend/app/api/__init__.py`
- `backend/app/main.py`

---

## API Endpoints

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

## PM Status Flow

```
scheduled → in_progress → completed
    │           │
    └───────────┴──→ overdue
    │
    └──→ cancelled
```

---

## Test

```bash
# Backend
cd MT_Project/backend
pytest tests/test_pm_task.py -v

# Mobile
cd MT_Project/mobile
flutter test test/pm_task_test.dart
```

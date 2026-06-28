# Machine Management Feature - Installation Guide

## ไฟล์ที่สร้างใหม่

```
backend/
├── app/
│   ├── api/
│   │   └── machine.py              ✓ สร้างใหม่
│   ├── models/
│   │   └── machine.py              ✓ สร้างใหม่
│   ├── schemas/
│   │   └── machine.py              ✓ สร้างใหม่
│   └── services/
│       └── machine_service.py      ✓ สร้างใหม่
├── tests/
│   └── test_machine.py             ✓ สร้างใหม่

mobile/lib/
├── data/
│   ├── models/
│   │   └── machine_model.dart      ✓ สร้างใหม่
│   ├── datasources/remote/
│   │   └── machine_remote_datasource.dart  ✓ สร้างใหม่
│   └── repositories/
│       └── machine_repository.dart ✓ สร้างใหม่
├── presentation/
│   ├── blocs/machine/
│   │   ├── machine_bloc.dart       ✓ สร้างใหม่
│   │   ├── machine_event.dart      ✓ สร้างใหม่
│   │   └── machine_state.dart      ✓ สร้างใหม่
│   └── pages/machine/
│       ├── machine_list_page.dart  ✓ สร้างใหม่
│       ├── machine_detail_page.dart ✓ สร้างใหม่
│       ├── add_machine_page.dart   ✓ สร้างใหม่
│       └── edit_machine_page.dart  ✓ สร้างใหม่
```

## ไฟล์ที่แก้ไข

```
backend/app/api/__init__.py         ✓ เพิ่ม machine
backend/app/main.py                 ✓ เพิ่ม machine router
```

---

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/machines | ดูรายการเครื่องจักร | ✓ |
| GET | /api/machines/{id} | ดูรายละเอียดเครื่อง | ✓ |
| POST | /api/machines | เพิ่มเครื่องจักร | ✓ |
| PUT | /api/machines/{id} | แก้ไขเครื่องจักร | ✓ |
| DELETE | /api/machines/{id} | ลบเครื่องจักร | ✓ |

---

## API Examples

### GET /api/machines
```bash
curl -X GET "http://localhost:8000/api/machines?page=1&limit=10" \
  -H "Authorization: Bearer <token>"
```

Response:
```json
{
  "items": [
    {
      "machine_id": "uuid",
      "name": "Motor Pump A",
      "model": "ABC-123",
      "serial_number": "MP-001",
      "location": "Building 1, Floor 2",
      "department": "Production",
      "install_date": "2024-01-15",
      "status": "active",
      "qr_code": null,
      "created_at": "2026-06-28T10:00:00Z",
      "updated_at": "2026-06-28T10:00:00Z"
    }
  ],
  "total": 3,
  "page": 1,
  "limit": 10
}
```

### POST /api/machines
```bash
curl -X POST "http://localhost:8000/api/machines" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Machine",
    "model": "MODEL-001",
    "serial_number": "SN-001",
    "location": "Building 3",
    "department": "Assembly",
    "install_date": "2026-06-28",
    "status": "active"
  }'
```

### PUT /api/machines/{id}
```bash
curl -X PUT "http://localhost:8000/api/machines/<machine_id>" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Machine Name",
    "status": "under_repair"
  }'
```

### DELETE /api/machines/{id}
```bash
curl -X DELETE "http://localhost:8000/api/machines/<machine_id>" \
  -H "Authorization: Bearer <token>"
```

---

## Mobile Flow

```
Machine List Page
    │
    ├── Search/Filter
    │
    ├── Tap Machine → Machine Detail Page
    │                   │
    │                   ├── Edit → Edit Machine Page
    │                   │
    │                   └── Delete → Confirm Dialog
    │
    └── Add Button → Add Machine Page
```

---

## Test Cases

```bash
# Run tests
cd MT_Project/backend
pytest tests/test_machine.py -v
```

| Test | Description |
|------|-------------|
| test_get_machines | ดูรายการเครื่องจักร |
| test_get_machines_with_search | ค้นหาเครื่องจักร |
| test_get_machines_with_status | กรองตามสถานะ |
| test_get_machine_by_id | ดูรายละเอียดเครื่อง |
| test_get_machine_not_found | ไม่พบเครื่องจักร |
| test_create_machine | เพิ่มเครื่องจักร |
| test_create_machine_duplicate_serial | Serial ซ้ำ |
| test_update_machine | แก้ไขเครื่องจักร |
| test_delete_machine | ลบเครื่องจักร |
| test_get_machines_without_auth | ไม่มี Token |

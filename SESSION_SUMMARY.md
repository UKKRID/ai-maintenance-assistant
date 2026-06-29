# AI Maintenance Assistant - Session Summary

## ข้อมูลโปรเจค

| รายการ | รายละเอียด |
|--------|------------|
| ชื่อโปรเจค | AI Maintenance Assistant |
| GitHub | https://github.com/UKKRID/ai-maintenance-assistant |
| Backend | FastAPI (Python) - Port 8000 |
| Frontend | Flutter Web - Port 8080 |
| Database | PostgreSQL (Mock Data) |

---

## สถานะงานปัจจุบัน

| Feature | Backend API | Mobile UI | Status |
|---------|-------------|-----------|--------|
| Auth (Login/Register) | ✓ 5 APIs | ✓ 2 pages | COMPLETED |
| Dashboard | ✓ 2 APIs | ✓ 1 page | COMPLETED |
| Machine Management | ✓ 5 APIs | ✓ 4 pages | COMPLETED |
| Repair Management | ✓ 6 APIs | ✓ 3 pages | NOT TESTED |
| PM Schedule | ✓ 7 APIs | ✓ 3 pages | NOT TESTED |
| Spare Parts | ✓ 5 APIs | - | NOT TESTED |
| AI Analysis | ✓ 5 APIs | ✓ 2 pages | NOT TESTED |

---

## Demo Account

| Email | Password | Role |
|-------|----------|------|
| demo@example.com | password123 | technician |

---

## โครงสร้างโปรเจค

```
MT_Project/
├── backend/
│   ├── app/
│   │   ├── api/ (8 files)
│   │   ├── models/ (5 files)
│   │   ├── schemas/ (7 files)
│   │   ├── services/ (7 files)
│   │   └── utils/ (1 file)
│   ├── tests/ (5 files)
│   └── requirements.txt
│
├── mobile_app/
│   ├── lib/
│   │   ├── core/ (2 files)
│   │   ├── data/ (21 files)
│   │   ├── presentation/ (30 files)
│   │   └── services/ (1 file)
│   └── test/ (2 files)
│
└── Documentation (15 files)
```

---

## API Endpoints (35 endpoints)

### Auth (5)
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/refresh
- POST /api/auth/logout
- GET /api/auth/me

### Machine (5)
- GET /api/machines
- GET /api/machines/{id}
- POST /api/machines
- PUT /api/machines/{id}
- DELETE /api/machines/{id}

### Repair (6)
- GET /api/repairs
- GET /api/repairs/{id}
- POST /api/repairs
- PUT /api/repairs/{id}/assign
- PUT /api/repairs/{id}/status
- PUT /api/repairs/{id}/complete

### PM Task (7)
- GET /api/pm-tasks
- GET /api/pm-tasks/{id}
- POST /api/pm-tasks
- PUT /api/pm-tasks/{id}
- PUT /api/pm-tasks/{id}/complete
- PUT /api/pm-tasks/{id}/checklist/{cid}/{iid}
- DELETE /api/pm-tasks/{id}

### Spare Part (5)
- GET /api/spare-parts
- GET /api/spare-parts/{id}
- GET /api/spare-parts/stock-summary
- POST /api/spare-parts
- PUT /api/spare-parts/{id}

### Dashboard (2)
- GET /api/dashboard/summary
- GET /api/dashboard/analytics

### AI (5)
- POST /api/ai/analyze
- POST /api/ai/analyze/upload
- GET /api/ai/analysis/{id}
- POST /api/ai/feedback
- GET /api/ai/analysis/history/{id}

---

## โค้ดสำคัญที่ต้องรู้

### 1. ApiClient (Token Handling)
```dart
// mobile_app/lib/services/api/api_client.dart
class ApiClient {
  static String? _globalToken;
  
  // Getter ใช้ fallback ไปหา _globalToken
  String? get token => _token ?? _globalToken;
  
  // Setter ตั้งค่าทั้ง instance และ global
  set token(String? value) {
    _token = value;
    _globalToken = value;
  }
  
  // Static method สำหรับตั้ง global token
  static void setToken(String? token) {
    _globalToken = token;
  }
  
  // _headers ต้องใช้ token getter ไม่ใช่ _token
  Map<String, String> get _headers {
    if (token != null) {  // ใช้ token getter
      headers['Authorization'] = 'Bearer $token';
    }
  }
}
```

### 2. AuthRepository (Token Persistence)
```dart
// mobile_app/lib/data/repositories/auth_repository.dart
Future<AuthResponseModel> login({...}) async {
  // ...
  // Set global token
  ApiClient.setToken(result.accessToken);
  
  // Save to localStorage
  html.window.localStorage['access_token'] = result.accessToken;
  // ...
}
```

### 3. Dashboard Navigation
```dart
// mobile_app/lib/presentation/pages/dashboard/dashboard_page.dart
// ใช้ BlocProvider.value เพื่อส่ง BLoC ต่อ
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<MachineBloc>(),
      child: const MachineListPage(),
    ),
  ),
);
```

---

## วิธีรันระบบ

### Backend
```bash
cd MT_Project/backend
source venv/bin/activate
python -m uvicorn app.main:app --reload --port 8000
```

### Flutter Web
```bash
cd MT_Project/mobile_app
flutter build web --release
cd build/web
python3 -m http.server 8080
```

### Access URLs
- Backend API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- Flutter Web: http://localhost:8080

---

## ปัญหาที่พบและแก้ไขแล้ว

| # | ปัญหา | วิธีแก้ |
|---|--------|---------|
| 1 | 401 Unauthorized | แก้ไข `_headers` ใช้ `token` getter |
| 2 | MachineBloc ไม่ได้ส่งต่อ | เพิ่ม `BlocProvider.value` |
| 3 | MachineListPage ไม่โหลดข้อมูล | เพิ่ม `LoadMachines()` ใน initState |
| 4 | Unused imports | ลบ imports ที่ไม่ได้ใช้ |
| 5 | Syntax error | แก้ไข syntax ใน repair_status_chart.dart |

---

## สิ่งที่ต้องทำต่อ

### Phase 2 (ยังไม่เสร็จ)
- [ ] ทดสอบ Repair List/Page
- [ ] ทดสอบ PM Schedule/Page
- [ ] ทดสอบ Add Repair
- [ ] ทดสอบ Add PM Task
- [ ] ทดสอบ Machine Detail/Edit

### Phase 3 (Future)
- [ ] เพิ่ม Image Upload จริง
- [ ] เพิ่ม PDF Export
- [ ] เพิ่ม Push Notification
- [ ] เพิ่ม Offline Mode

---

## ข้อมูลติดต่อ

| Item | Detail |
|------|--------|
| GitHub | https://github.com/UKKRID/ai-maintenance-assistant |
| Backend | http://localhost:8000 |
| Web App | http://localhost:8080 |
| Swagger | http://localhost:8000/docs |

---

## วิธีทำงานต่อ

1. รัน Backend: `cd MT_Project/backend && source venv/bin/activate && python -m uvicorn app.main:app --port 8000`
2. รัน Flutter Web: `cd MT_Project/mobile_app && flutter build web && cd build/web && python3 -m http.server 8080`
3. เปิด browser ไปที่ http://localhost:8080
4. Login ด้วย demo@example.com / password123
5. ทดสอบหน้าที่ต้องการ

---

**สร้างเมื่อ:** 29 มิถุนายน 2026
**สถานะ:** Machine Feature COMPLETED, Ready to continue

# AI Maintenance Assistant - REST API Specification

---

## 1. API Overview

| Item | Value |
|------|-------|
| Base URL | `https://api.aimaintenance.com/v1` |
| Protocol | HTTPS |
| Format | JSON |
| Auth | Bearer Token (JWT) |
| Rate Limit | 100 req/min/user |

---

## 2. Authentication

### 2.1 Auth Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      AUTHENTICATION FLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐         ┌─────────┐         ┌─────────┐           │
│  │  User   │         │  API    │         │  Redis  │           │
│  └────┬────┘         └────┬────┘         └────┬────┘           │
│       │                   │                   │                 │
│       │  POST /auth/login │                   │                 │
│       │──────────────────▶│                   │                 │
│       │                   │                   │                 │
│       │                   │  Check User       │                 │
│       │                   │──────────────────▶│                 │
│       │                   │                   │                 │
│       │                   │  Store Token      │                 │
│       │                   │──────────────────▶│                 │
│       │                   │                   │                 │
│       │  { access_token } │                   │                 │
│       │◀──────────────────│                   │                 │
│       │                   │                   │                 │
│       │  GET /protected   │                   │                 │
│       │  Authorization: Bearer <token>        │                 │
│       │──────────────────▶│                   │                 │
│       │                   │                   │                 │
│       │                   │  Verify Token     │                 │
│       │                   │──────────────────▶│                 │
│       │                   │                   │                 │
│       │  { data }         │                   │                 │
│       │◀──────────────────│                   │                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Token Structure

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

### 2.3 JWT Payload

```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "technician",
  "iat": 1719590400,
  "exp": 1719594000
}
```

### 2.4 Redis Token Storage

```
Key: token:{user_id}
Value: { access_token, refresh_token, expires_at }
TTL: 3600 seconds
```

---

## 3. Permissions

### 3.1 Role-Based Access Control (RBAC)

| Endpoint | Technician | Supervisor | Admin |
|----------|------------|------------|-------|
| **Auth** | | | |
| POST /auth/login | ✓ | ✓ | ✓ |
| POST /auth/register | ✓ | ✓ | ✓ |
| POST /auth/refresh | ✓ | ✓ | ✓ |
| POST /auth/logout | ✓ | ✓ | ✓ |
| **User** | | | |
| GET /users/me | ✓ | ✓ | ✓ |
| PUT /users/me | ✓ | ✓ | ✓ |
| GET /users | ✗ | ✗ | ✓ |
| POST /users | ✗ | ✗ | ✓ |
| PUT /users/:id | ✗ | ✗ | ✓ |
| DELETE /users/:id | ✗ | ✗ | ✓ |
| **Machine** | | | |
| GET /machines | ✓ | ✓ | ✓ |
| GET /machines/:id | ✓ | ✓ | ✓ |
| POST /machines | ✗ | ✗ | ✓ |
| PUT /machines/:id | ✗ | ✗ | ✓ |
| DELETE /machines/:id | ✗ | ✗ | ✓ |
| **Repair** | | | |
| GET /repairs | ✓ | ✓ | ✓ |
| GET /repairs/:id | ✓ | ✓ | ✓ |
| POST /repairs | ✓ | ✓ | ✓ |
| PUT /repairs/:id | ✓ | ✓ | ✓ |
| PUT /repairs/:id/assign | ✗ | ✓ | ✓ |
| PUT /repairs/:id/status | ✓ | ✓ | ✓ |
| **PM** | | | |
| GET /pm-tasks | ✓ | ✓ | ✓ |
| GET /pm-tasks/:id | ✓ | ✓ | ✓ |
| POST /pm-tasks | ✗ | ✗ | ✓ |
| PUT /pm-tasks/:id | ✓ | ✓ | ✓ |
| PUT /pm-tasks/:id/complete | ✓ | ✓ | ✓ |
| **Spare Part** | | | |
| GET /spare-parts | ✓ | ✓ | ✓ |
| GET /spare-parts/:id | ✓ | ✓ | ✓ |
| POST /spare-parts | ✗ | ✗ | ✓ |
| PUT /spare-parts/:id | ✗ | ✗ | ✓ |
| DELETE /spare-parts/:id | ✗ | ✗ | ✓ |
| **AI Analysis** | | | |
| POST /ai/analyze | ✓ | ✓ | ✓ |
| GET /ai/analysis/:id | ✓ | ✓ | ✓ |
| POST /ai/feedback | ✓ | ✓ | ✓ |
| **Report** | | | |
| GET /reports | ✓ | ✓ | ✓ |
| GET /reports/:id | ✓ | ✓ | ✓ |
| POST /reports | ✓ | ✓ | ✓ |
| PUT /reports/:id | ✓ | ✓ | ✓ |
| PUT /reports/:id/approve | ✗ | ✓ | ✓ |
| PUT /reports/:id/reject | ✗ | ✓ | ✓ |
| **Dashboard** | | | |
| GET /dashboard/summary | ✓ | ✓ | ✓ |
| GET /dashboard/analytics | ✗ | ✓ | ✓ |
| GET /dashboard/charts | ✗ | ✓ | ✓ |

### 3.2 Permission Middleware

```python
# permissions.py
from enum import Enum
from functools import wraps
from fastapi import HTTPException, status

class Role(str, Enum):
    TECHNICIAN = "technician"
    SUPERVISOR = "supervisor"
    ADMIN = "admin"

def require_role(allowed_roles: list[Role]):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            current_user = kwargs.get("current_user")
            if current_user.role not in allowed_roles:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Insufficient permissions"
                )
            return await func(*args, **kwargs)
        return wrapper
    return decorator
```

---

## 4. API Endpoints

### 4.1 Authentication

#### POST /auth/login

**Description:** เข้าสู่ระบบ

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "user": {
      "user_id": "uuid",
      "email": "user@example.com",
      "full_name": "สมชาย ใจดี",
      "role": "technician"
    }
  }
}
```

**Response 401:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email หรือ Password ไม่ถูกต้อง"
  }
}
```

---

#### POST /auth/register

**Description:** สมัครสมาชิก

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "full_name": "สมชาย ใจดี",
  "phone": "0812345678",
  "role": "technician"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "newuser@example.com",
    "full_name": "สมชาย ใจดี",
    "role": "technician",
    "created_at": "2026-06-28T10:00:00Z"
  }
}
```

---

#### POST /auth/refresh

**Description:** ขอ Token ใหม่

**Request:**
```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

---

#### POST /auth/logout

**Description:** ออกจากระบบ

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 4.2 User

#### GET /users/me

**Description:** ดูข้อมูลผู้ใช้ปัจจุบัน

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "full_name": "สมชาย ใจดี",
    "phone": "0812345678",
    "role": "technician",
    "avatar_url": "https://storage.example.com/avatars/uuid.jpg",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

---

#### PUT /users/me

**Description:** แก้ไขข้อมูลผู้ใช้

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "full_name": "สมชาย ใจดี (แก้ไข)",
  "phone": "0899999999"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "full_name": "สมชาย ใจดี (แก้ไข)",
    "phone": "0899999999"
  }
}
```

---

#### GET /users

**Description:** ดูรายชื่อผู้ใช้ทั้งหมด (Admin only)

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| role | string | No | กรองตาม Role |
| search | string | No | ค้นหาจากชื่อ/อีเมล |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "user_id": "uuid",
        "email": "user@example.com",
        "full_name": "สมชาย ใจดี",
        "role": "technician",
        "is_active": true,
        "created_at": "2026-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

---

### 4.3 Machine

#### GET /machines

**Description:** ดูรายการเครื่องจักร

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| status | string | No | กรองตามสถานะ |
| location | string | No | กรองตามสถานที่ |
| search | string | No | ค้นหาจากชื่อ/หมายเลข |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "machine_id": "uuid",
        "name": "Motor Pump A",
        "model": "ABC-123",
        "serial_number": "MP-001",
        "location": "Building 1, Floor 2",
        "department": "Production",
        "install_date": "2024-01-01",
        "status": "active",
        "qr_code": "https://api.example.com/qr/uuid"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "total_pages": 3
    }
  }
}
```

---

#### GET /machines/:id

**Description:** ดูรายละเอียดเครื่องจักร

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "machine_id": "uuid",
    "name": "Motor Pump A",
    "model": "ABC-123",
    "serial_number": "MP-001",
    "location": "Building 1, Floor 2",
    "department": "Production",
    "install_date": "2024-01-01",
    "status": "active",
    "qr_code": "https://api.example.com/qr/uuid",
    "statistics": {
      "total_repairs": 12,
      "mtbf_days": 89,
      "mttr_hours": 2.5,
      "total_cost": 45000.00
    },
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

---

#### POST /machines

**Description:** เพิ่มเครื่องจักร (Admin only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "Motor Pump B",
  "model": "ABC-456",
  "serial_number": "MP-002",
  "location": "Building 2, Floor 1",
  "department": "Packaging",
  "install_date": "2026-06-28"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "machine_id": "uuid",
    "name": "Motor Pump B",
    "model": "ABC-456",
    "serial_number": "MP-002",
    "qr_code": "https://api.example.com/qr/uuid",
    "created_at": "2026-06-28T10:00:00Z"
  }
}
```

---

#### PUT /machines/:id

**Description:** แก้ไขข้อมูลเครื่องจักร (Admin only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "Motor Pump A (Updated)",
  "location": "Building 1, Floor 3"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "machine_id": "uuid",
    "name": "Motor Pump A (Updated)",
    "location": "Building 1, Floor 3"
  }
}
```

---

### 4.4 Repair

#### GET /repairs

**Description:** ดูรายการงานซ่อม

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| status | string | No | กรองตามสถานะ |
| priority | string | No | กรองตามความสำคัญ |
| machine_id | string | No | กรองตามเครื่องจักร |
| assigned_to | string | No | กรองตามผู้รับผิดชอบ |
| start_date | string | No | กรองตั้งแต่วันที่ (YYYY-MM-DD) |
| end_date | string | No | กรองถึงวันที่ (YYYY-MM-DD) |
| search | string | No | ค้นหาจากหัวข้อ |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "repair_id": "uuid",
        "title": "Motor Bearing Wear",
        "priority": "high",
        "status": "in_progress",
        "machine": {
          "machine_id": "uuid",
          "name": "Motor Pump A"
        },
        "reporter": {
          "user_id": "uuid",
          "full_name": "สมชาย ใจดี"
        },
        "assigned_to": {
          "user_id": "uuid",
          "full_name": "สมศักดิ์ รักงาน"
        },
        "estimated_time": 120,
        "estimated_cost": 2500.00,
        "created_at": "2026-06-28T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "total_pages": 3
    }
  }
}
```

---

#### GET /repairs/:id

**Description:** ดูรายละเอียดงานซ่อม

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "repair_id": "uuid",
    "title": "Motor Bearing Wear",
    "description": "เครื่องส่งเสียงดัง ตรวจสอบพบว่า Bearing สึกหรอ",
    "priority": "high",
    "status": "in_progress",
    "machine": {
      "machine_id": "uuid",
      "name": "Motor Pump A",
      "model": "ABC-123",
      "serial_number": "MP-001",
      "location": "Building 1, Floor 2"
    },
    "reporter": {
      "user_id": "uuid",
      "full_name": "สมชาย ใจดี"
    },
    "assigned_to": {
      "user_id": "uuid",
      "full_name": "สมศักดิ์ รักงาน"
    },
    "ai_analysis": {
      "analysis_id": "uuid",
      "confidence": 85.5,
      "causes": [
        {
          "cause": "Motor Bearing Wear",
          "confidence": 85.5,
          "solution": "เปลี่ยน Bearing"
        }
      ]
    },
    "spare_parts": [
      {
        "part_id": "uuid",
        "name": "Bearing 6205-2RS",
        "quantity": 2,
        "unit_price": 850.00,
        "total_price": 1700.00
      }
    ],
    "time_log": {
      "started_at": "2026-06-28T14:30:00Z",
      "completed_at": null,
      "estimated_time": 120,
      "actual_time": null
    },
    "cost": {
      "estimated_cost": 2500.00,
      "actual_cost": null
    },
    "photos": [
      "https://storage.example.com/repairs/uuid/photo1.jpg"
    ],
    "notes": "สั่งอะไหล่เรียบร้อย",
    "created_at": "2026-06-28T10:00:00Z",
    "updated_at": "2026-06-28T14:30:00Z"
  }
}
```

---

#### POST /repairs

**Description:** สร้างงานซ่อมใหม่

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "machine_id": "uuid",
  "title": "Motor Bearing Wear",
  "description": "เครื่องส่งเสียงดัง",
  "priority": "high"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "repair_id": "uuid",
    "title": "Motor Bearing Wear",
    "status": "pending",
    "created_at": "2026-06-28T10:00:00Z"
  }
}
```

---

#### PUT /repairs/:id/assign

**Description:** มอบหมายงาน (Supervisor only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "assigned_to": "uuid"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "repair_id": "uuid",
    "assigned_to": {
      "user_id": "uuid",
      "full_name": "สมศักดิ์ รักงาน"
    }
  }
}
```

---

#### PUT /repairs/:id/status

**Description:** อัพเดทสถานะงาน

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "status": "in_progress",
  "notes": "เริ่มทำงานแล้ว"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "repair_id": "uuid",
    "status": "in_progress",
    "started_at": "2026-06-28T14:30:00Z"
  }
}
```

---

#### PUT /repairs/:id/complete

**Description:** เสร็จสิ้นงาน

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "actual_time": 135,
  "actual_cost": 2350.00,
  "notes": "เปลี่ยน Bearing เรียบร้อย ทดสอบ运转 ผ่าน"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "repair_id": "uuid",
    "status": "completed",
    "completed_at": "2026-06-28T16:45:00Z",
    "actual_time": 135,
    "actual_cost": 2350.00
  }
}
```

---

### 4.5 PM Task

#### GET /pm-tasks

**Description:** ดูตารางงาน PM

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| status | string | No | กรองตามสถานะ |
| machine_id | string | No | กรองตามเครื่องจักร |
| start_date | string | No | กรองตั้งแต่วันที่ |
| end_date | string | No | กรองถึงวันที่ |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "pm_id": "uuid",
        "title": "เปลี่ยนน้ำมันเครื่อง",
        "scheduled_date": "2026-06-28",
        "status": "scheduled",
        "machine": {
          "machine_id": "uuid",
          "name": "Motor Pump A"
        },
        "assigned_to": {
          "user_id": "uuid",
          "full_name": "สมชาย ใจดี"
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 30,
      "total_pages": 2
    }
  }
}
```

---

#### GET /pm-tasks/:id

**Description:** ดูรายละเอียดงาน PM

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pm_id": "uuid",
    "title": "เปลี่ยนน้ำมันเครื่อง",
    "description": "เปลี่ยนน้ำมันเครื่องตามรอบ PM",
    "scheduled_date": "2026-06-28",
    "completed_date": null,
    "status": "scheduled",
    "machine": {
      "machine_id": "uuid",
      "name": "Motor Pump A",
      "model": "ABC-123",
      "location": "Building 1, Floor 2"
    },
    "assigned_to": {
      "user_id": "uuid",
      "full_name": "สมชาย ใจดี"
    },
    "checklist": [
      {
        "item_id": "uuid",
        "item_name": "ปิดเครื่องจักร",
        "is_required": true,
        "completed": false
      },
      {
        "item_id": "uuid",
        "item_name": "ระบายน้ำมันเก่า",
        "is_required": true,
        "completed": false
      }
    ],
    "photos": [],
    "notes": null,
    "created_at": "2026-06-01T00:00:00Z"
  }
}
```

---

#### POST /pm-tasks

**Description:** สร้างงาน PM (Admin only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "machine_id": "uuid",
  "title": "เปลี่ยนน้ำมันเครื่อง",
  "description": "เปลี่ยนน้ำมันเครื่องตามรอบ PM",
  "scheduled_date": "2026-06-28",
  "assigned_to": "uuid",
  "checklist": [
    {
      "item_name": "ปิดเครื่องจักร",
      "is_required": true,
      "sort_order": 1
    },
    {
      "item_name": "ระบายน้ำมันเก่า",
      "is_required": true,
      "sort_order": 2
    }
  ]
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "pm_id": "uuid",
    "title": "เปลี่ยนน้ำมันเครื่อง",
    "scheduled_date": "2026-06-28",
    "status": "scheduled",
    "created_at": "2026-06-01T00:00:00Z"
  }
}
```

---

#### PUT /pm-tasks/:id/complete

**Description:** เสร็จสิ้นงาน PM

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "completed_date": "2026-06-28",
  "checklist": [
    {
      "item_id": "uuid",
      "completed": true
    },
    {
      "item_id": "uuid",
      "completed": true
    }
  ],
  "notes": "เปลี่ยนน้ำมันเรียบร้อย"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "pm_id": "uuid",
    "status": "completed",
    "completed_date": "2026-06-28"
  }
}
```

---

### 4.6 Spare Part

#### GET /spare-parts

**Description:** ดูรายการอะไหล่

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| category | string | No | กรองตามหมวดหมู่ |
| low_stock | boolean | No | แสดงเฉพาะอะไหล่ใกล้หมด |
| search | string | No | ค้นหาจากชื่อ/หมายเลข |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "part_id": "uuid",
        "name": "Bearing 6205-2RS",
        "part_number": "BRG-6205-2RS",
        "category": "Bearing",
        "unit_price": 850.00,
        "stock_qty": 12,
        "min_stock": 5,
        "unit": "piece",
        "stock_status": "in_stock"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

---

#### GET /spare-parts/:id

**Description:** ดูรายละเอียดอะไหล่

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "part_id": "uuid",
    "name": "Bearing 6205-2RS",
    "part_number": "BRG-6205-2RS",
    "category": "Bearing",
    "description": "Bearing สำหรับ Motor Pump",
    "unit_price": 850.00,
    "stock_qty": 12,
    "min_stock": 5,
    "unit": "piece",
    "image_url": "https://storage.example.com/parts/uuid.jpg",
    "compatible_machines": [
      {
        "machine_id": "uuid",
        "name": "Motor Pump A"
      }
    ],
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

---

#### POST /spare-parts

**Description:** เพิ่มอะไหล่ (Admin only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "Bearing 6205-2RS",
  "part_number": "BRG-6205-2RS",
  "category": "Bearing",
  "description": "Bearing สำหรับ Motor Pump",
  "unit_price": 850.00,
  "stock_qty": 12,
  "min_stock": 5,
  "unit": "piece"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "part_id": "uuid",
    "name": "Bearing 6205-2RS",
    "created_at": "2026-06-28T10:00:00Z"
  }
}
```

---

### 4.7 AI Analysis

#### POST /ai/analyze

**Description:** วิเคราะห์อาการเสียด้วย AI

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request:**
```
repair_id: uuid
input_text: เครื่องส่งเสียงดัง ตรวจสอบพบว่า Bearing สึกหรอ
images: [file1.jpg, file2.jpg]
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "analysis_id": "uuid",
    "repair_id": "uuid",
    "input_text": "เครื่องส่งเสียงดัง ตรวจสอบพบว่า Bearing สึกหรอ",
    "input_images": [
      "https://storage.example.com/analysis/uuid/img1.jpg"
    ],
    "ai_response": {
      "summary": "พบปัญหาที่ Motor Bearing ซึ่งสึกหรอจากการใช้งาน"
    },
    "confidence": 85.5,
    "causes": [
      {
        "cause": "Motor Bearing Wear",
        "confidence": 85.5,
        "description": "Bearing สึกหรอจากการใช้งานนาน",
        "solution": "เปลี่ยน Bearing ใหม่",
        "steps": [
          "ปิดเครื่องจักร",
          "ถอด Bearing เก่า",
          "ใส่ Bearing ใหม่",
          "ทดสอบ运转"
        ],
        "estimated_time": 120,
        "estimated_cost": 2500.00
      },
      {
        "cause": "Motor Overload",
        "confidence": 12.0,
        "description": "มี Load สูงเกินไป",
        "solution": "ตรวจสอบ Load และปรับ Current",
        "estimated_time": 60,
        "estimated_cost": 500.00
      },
      {
        "cause": "Electrical Fault",
        "confidence": 2.5,
        "description": "ปัญหาทางไฟฟ้า",
        "solution": "ตรวจสอบ Wiring",
        "estimated_time": 90,
        "estimated_cost": 800.00
      }
    ],
    "model_version": "gpt-4-vision-2026",
    "processing_time": 3500,
    "created_at": "2026-06-28T14:32:00Z"
  }
}
```

---

#### GET /ai/analysis/:id

**Description:** ดูผลวิเคราะห์ AI

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "analysis_id": "uuid",
    "repair_id": "uuid",
    "confidence": 85.5,
    "causes": [...],
    "feedback": null,
    "created_at": "2026-06-28T14:32:00Z"
  }
}
```

---

#### POST /ai/feedback

**Description:** ส่ง Feedback การวิเคราะห์

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "analysis_id": "uuid",
  "feedback": "helpful",
  "actual_cause": "Motor Bearing Wear",
  "notes": "วิเคราะห์ถูกต้อง"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "analysis_id": "uuid",
    "feedback": "helpful",
    "updated_at": "2026-06-28T15:00:00Z"
  }
}
```

---

### 4.8 Report

#### GET /reports

**Description:** ดูรายการรายงาน

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | หน้า (default: 1) |
| limit | integer | No | จำนวนต่อหน้า (default: 20) |
| status | string | No | กรองตามสถานะ |
| created_by | string | No | กรองตามผู้สร้าง |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "report_id": "uuid",
        "title": "รายงานซ่อม Motor Pump A",
        "status": "pending",
        "repair": {
          "repair_id": "uuid",
          "title": "Motor Bearing Wear"
        },
        "created_by": {
          "user_id": "uuid",
          "full_name": "สมชาย ใจดี"
        },
        "created_at": "2026-06-28T17:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 30,
      "total_pages": 2
    }
  }
}
```

---

#### GET /reports/:id

**Description:** ดูรายละเอียดรายงาน

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "report_id": "uuid",
    "title": "รายงานซ่อม Motor Pump A",
    "content": "รายงานการซ่อม Motor Bearing Wear...",
    "status": "pending",
    "repair": {
      "repair_id": "uuid",
      "title": "Motor Bearing Wear",
      "machine": {
        "name": "Motor Pump A"
      }
    },
    "created_by": {
      "user_id": "uuid",
      "full_name": "สมชาย ใจดี"
    },
    "approved_by": null,
    "pdf_url": null,
    "created_at": "2026-06-28T17:00:00Z"
  }
}
```

---

#### POST /reports

**Description:** สร้างรายงาน

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "repair_id": "uuid",
  "title": "รายงานซ่อม Motor Pump A",
  "content": "รายงานการซ่อม Motor Bearing Wear..."
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "report_id": "uuid",
    "title": "รายงานซ่อม Motor Pump A",
    "status": "draft",
    "created_at": "2026-06-28T17:00:00Z"
  }
}
```

---

#### PUT /reports/:id/approve

**Description:** อนุมัติรายงาน (Supervisor only)

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "report_id": "uuid",
    "status": "approved",
    "approved_by": {
      "user_id": "uuid",
      "full_name": "สมศักดิ์ หัวหน้า"
    },
    "approved_at": "2026-06-28T18:00:00Z"
  }
}
```

---

#### PUT /reports/:id/reject

**Description:** ปฏิเสธรายงาน (Supervisor only)

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "rejected_reason": "กรุณาเพิ่มรายละเอียดอะไหล่ที่ใช้"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "report_id": "uuid",
    "status": "rejected",
    "rejected_reason": "กรุณาเพิ่มรายละเอียดอะไหล่ที่ใช้"
  }
}
```

---

### 4.9 Dashboard

#### GET /dashboard/summary

**Description:** ดูสรุป Dashboard

**Headers:**
```
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "total_repairs": 12,
    "pending_repairs": 5,
    "completed_repairs": 7,
    "overdue_pm": 2,
    "upcoming_pm": 3,
    "low_stock_parts": 4,
    "mtbf_days": 89,
    "mttr_hours": 2.5,
    "total_cost_month": 45000.00,
    "breakdown_by_type": [
      {
        "type": "Motor",
        "count": 40
      },
      {
        "type": "Belt",
        "count": 30
      },
      {
        "type": "Sensor",
        "count": 20
      }
    ],
    "recent_repairs": [
      {
        "repair_id": "uuid",
        "title": "Motor Bearing Wear",
        "status": "in_progress",
        "created_at": "2026-06-28T10:00:00Z"
      }
    ]
  }
}
```

---

#### GET /dashboard/analytics

**Description:** ดู Analytics (Supervisor only)

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| period | string | No | day/week/month/year (default: month) |
| start_date | string | No | วันที่เริ่มต้น |
| end_date | string | No | วันที่สิ้นสุด |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": "month",
    "total_repairs": 50,
    "total_cost": 125000.00,
    "average_mttr": 2.5,
    "average_mtbf": 89,
    "top_issues": [
      {
        "issue": "Motor Bearing Wear",
        "count": 15,
        "percentage": 30
      }
    ],
    "cost_by_department": [
      {
        "department": "Production",
        "cost": 75000.00
      },
      {
        "department": "Packaging",
        "cost": 50000.00
      }
    ],
    "trend": [
      {
        "date": "2026-06-01",
        "repairs": 5,
        "cost": 12500.00
      }
    ]
  }
}
```

---

## 5. File Upload

### 5.1 Upload Endpoint

#### POST /upload

**Description:** อัพโหลดไฟล์

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request:**
```
file: [binary data]
type: repair|pm|ai|avatar|machine
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "file_id": "uuid",
    "filename": "photo1.jpg",
    "url": "https://storage.example.com/uploads/uuid/photo1.jpg",
    "size": 1024000,
    "mime_type": "image/jpeg",
    "created_at": "2026-06-28T10:00:00Z"
  }
}
```

### 5.2 File Storage Configuration

```python
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Database
    DATABASE_URL: str = "postgresql://user:pass@localhost:5432/aimaintenance"
    
    # JWT
    JWT_SECRET_KEY: str = "your-secret-key"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # File Upload
    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB
    ALLOWED_EXTENSIONS: list = ["jpg", "jpeg", "png", "pdf"]
    
    # AI
    OPENAI_API_KEY: str = ""
    AI_MODEL: str = "gpt-4-vision"
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### 5.3 File Upload Service

```python
# services/file_service.py
import os
import uuid
from datetime import datetime
from fastapi import UploadFile, HTTPException

class FileService:
    def __init__(self, upload_dir: str):
        self.upload_dir = upload_dir
        os.makedirs(upload_dir, exist_ok=True)
    
    async def upload_file(
        self, 
        file: UploadFile, 
        file_type: str
    ) -> dict:
        # Validate file size
        content = await file.read()
        if len(content) > settings.MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail="File size exceeds limit"
            )
        
        # Validate extension
        ext = file.filename.split(".")[-1].lower()
        if ext not in settings.ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400,
                detail="File type not allowed"
            )
        
        # Generate unique filename
        file_id = str(uuid.uuid4())
        filename = f"{file_id}.{ext}"
        file_path = os.path.join(self.upload_dir, file_type, filename)
        
        # Create directory
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        # Save file
        with open(file_path, "wb") as f:
            f.write(content)
        
        # Return file info
        return {
            "file_id": file_id,
            "filename": file.filename,
            "url": f"https://storage.example.com/uploads/{file_type}/{filename}",
            "size": len(content),
            "mime_type": file.content_type,
            "created_at": datetime.utcnow().isoformat()
        }

file_service = FileService(settings.UPLOAD_DIR)
```

---

## 6. AI API Integration

### 6.1 AI Service

```python
# services/ai_service.py
import httpx
from typing import List, Optional
from pydantic import BaseModel

class AICause(BaseModel):
    cause: str
    confidence: float
    description: str
    solution: str
    steps: List[str]
    estimated_time: int
    estimated_cost: float

class AIAnalysisResponse(BaseModel):
    summary: str
    confidence: float
    causes: List[AICause]
    model_version: str
    processing_time: int

class AIService:
    def __init__(self, api_key: str, model: str):
        self.api_key = api_key
        self.model = model
        self.base_url = "https://api.openai.com/v1"
    
    async def analyze_breakdown(
        self,
        text: str,
        images: List[str]
    ) -> AIAnalysisResponse:
        # Prepare messages
        messages = [
            {
                "role": "system",
                "content": """You are an expert maintenance engineer. 
                Analyze the breakdown description and images to identify 
                possible causes, solutions, and estimates."""
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"วิเคราะห์อาการเสีย: {text}"
                    }
                ]
            }
        ]
        
        # Add images
        for image_url in images:
            messages[1]["content"].append({
                "type": "image_url",
                "image_url": {
                    "url": image_url
                }
            })
        
        # Call OpenAI API
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": self.model,
                    "messages": messages,
                    "response_format": {"type": "json_object"}
                },
                timeout=30.0
            )
        
        # Parse response
        result = response.json()
        return self._parse_response(result)
    
    def _parse_response(self, result: dict) -> AIAnalysisResponse:
        # Parse AI response into structured format
        content = result["choices"][0]["message"]["content"]
        # ... parsing logic
        return AIAnalysisResponse(...)

ai_service = AIService(settings.OPENAI_API_KEY, settings.AI_MODEL)
```

### 6.2 AI Endpoint Implementation

```python
# routers/ai.py
from fastapi import APIRouter, UploadFile, File, Form, Depends
from typing import List, Optional

router = APIRouter(prefix="/ai", tags=["AI"])

@router.post("/analyze")
async def analyze_breakdown(
    repair_id: str = Form(...),
    input_text: Optional[str] = Form(None),
    images: List[UploadFile] = File(...),
    current_user = Depends(get_current_user)
):
    # Save images
    image_urls = []
    for image in images:
        result = await file_service.upload_file(image, "ai")
        image_urls.append(result["url"])
    
    # Call AI service
    analysis = await ai_service.analyze_breakdown(
        text=input_text or "",
        images=image_urls
    )
    
    # Save to database
    db_analysis = await db.ai_analysis.create({
        "repair_id": repair_id,
        "input_text": input_text,
        "input_images": image_urls,
        "ai_response": analysis.dict(),
        "confidence": analysis.confidence,
        "causes": analysis.causes,
        "solutions": [c.solution for c in analysis.causes],
        "estimated_time": analysis.causes[0].estimated_time,
        "estimated_cost": analysis.causes[0].estimated_cost,
        "model_version": analysis.model_version,
        "processing_time": analysis.processing_time
    })
    
    return {
        "success": True,
        "data": db_analysis
    }

@router.post("/feedback")
async def submit_feedback(
    analysis_id: str,
    feedback: str,
    actual_cause: Optional[str] = None,
    notes: Optional[str] = None,
    current_user = Depends(get_current_user)
):
    # Update analysis with feedback
    await db.ai_analysis.update(
        analysis_id,
        {
            "feedback": feedback,
            "actual_cause": actual_cause,
            "notes": notes
        }
    )
    
    return {
        "success": True,
        "data": {
            "analysis_id": analysis_id,
            "feedback": feedback
        }
    }
```

---

## 7. Redis Caching

### 7.1 Cache Strategy

| Data | TTL | Invalidation |
|------|-----|--------------|
| User Profile | 5 min | On update |
| Machine List | 10 min | On create/update/delete |
| Dashboard Summary | 1 min | On any repair/pm update |
| Spare Parts List | 15 min | On stock update |
| AI Analysis | No cache | - |

### 7.2 Cache Implementation

```python
# services/cache_service.py
import json
import redis
from typing import Optional, Any

class CacheService:
    def __init__(self, redis_url: str):
        self.redis = redis.from_url(redis_url)
    
    async def get(self, key: str) -> Optional[Any]:
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    async def set(
        self, 
        key: str, 
        value: Any, 
        ttl: int = 300
    ):
        self.redis.setex(
            key,
            ttl,
            json.dumps(value)
        )
    
    async def delete(self, key: str):
        self.redis.delete(key)
    
    async def delete_pattern(self, pattern: str):
        keys = self.redis.keys(pattern)
        if keys:
            self.redis.delete(*keys)

cache_service = CacheService(settings.REDIS_URL)
```

---

## 8. Error Handling

### 8.1 Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message in Thai",
    "details": {
      "field": "email",
      "issue": "already exists"
    }
  }
}
```

### 8.2 Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| INVALID_CREDENTIALS | 401 | Email หรือ Password ไม่ถูกต้อง |
| TOKEN_EXPIRED | 401 | Token หมดอายุ |
| TOKEN_INVALID | 401 | Token ไม่ถูกต้อง |
| INSUFFICIENT_PERMISSIONS | 403 | ไม่มีสิทธิ์เข้าถึง |
| RESOURCE_NOT_FOUND | 404 | ไม่พบข้อมูล |
| VALIDATION_ERROR | 422 | ข้อมูลไม่ถูกต้อง |
| DUPLICATE_ENTRY | 409 | ข้อมูลซ้ำ |
| FILE_TOO_LARGE | 413 | ไฟล์ใหญ่เกินไป |
| AI_ANALYSIS_FAILED | 500 | การวิเคราะห์ AI ล้มเหลว |
| RATE_LIMIT_EXCEEDED | 429 | จำนวน request เกินกำหนด |

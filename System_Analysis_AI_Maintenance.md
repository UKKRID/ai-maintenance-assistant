# AI Maintenance Assistant - System Analysis

---

## 1. Use Case Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AI MAINTENANCE ASSISTANT                            │
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │   Login/    │    │   View      │    │   View      │                     │
│  │   Register  │    │   Dashboard │    │   Report    │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │  Analyze    │    │   Create    │    │   Manage    │                     │
│  │  Breakdown  │    │   Repair    │    │   PM Task   │                     │
│  └─────────────┘    │   Report    │    └─────────────┘                     │
│                     └─────────────┘                                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │  Recommend  │    │   Manage    │    │   Export    │                     │
│  │  Spare Part │    │   Machine   │    │   Report    │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │   Manage    │    │   View      │    │   Manage    │                     │
│  │   User      │    │   Analytics │    │   System    │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            ACTORS                                           │
│                                                                             │
│    ┌──────────┐        ┌──────────┐        ┌──────────┐                     │
│    │Technician│        │Supervisor│        │  Admin   │                     │
│    └──────────┘        └──────────┘        └──────────┘                     │
│         │                   │                   │                           │
└─────────┼───────────────────┼───────────────────┼───────────────────────────┘
```

### Use Case Matrix

| Use Case ID | Use Case Name | Actor | Precondition | Postcondition | Priority |
|-------------|---------------|-------|--------------|---------------|----------|
| UC-01 | Login | All | User has account | User logged in | High |
| UC-02 | Register | Technician | None | Account created | High |
| UC-03 | Analyze Breakdown | Technician | Machine exists | Analysis displayed | High |
| UC-04 | Create Repair Report | Technician | Breakdown analyzed | Report created | High |
| UC-05 | Complete PM Task | Technician | PM scheduled | PM status updated | Medium |
| UC-06 | Recommend Spare Part | Technician | Breakdown analyzed | Parts suggested | High |
| UC-07 | View Machine History | Technician | Machine exists | History displayed | Medium |
| UC-08 | View Dashboard | Supervisor | Reports exist | Dashboard shown | High |
| UC-09 | Approve Report | Supervisor | Report submitted | Report approved | Medium |
| UC-10 | View Analytics | Supervisor | Data exists | Analytics shown | High |
| UC-11 | Manage Users | Admin | Admin logged in | Users managed | Medium |
| UC-12 | Manage Machines | Admin | Admin logged in | Machines managed | High |
| UC-13 | Manage System Config | Admin | Admin logged in | Config updated | Low |
| UC-14 | Export Reports | Supervisor/Admin | Reports exist | PDF/Excel exported | Medium |
| UC-15 | Manage PM Schedule | Admin | Machines exist | PM scheduled | Medium |

---

## 2. User Flow

### 2.1 Technician Flow

```
START
  │
  ▼
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Success?│
    └────┬────┘
    Yes  │  No
    │    └───→ Show Error → Back to Login
    ▼
┌─────────────────┐
│  Home Screen    │
│  - Analyze Bug  │
│  - My Tasks     │
│  - History      │
└────────┬────────┘
         │
    ┌────┴──────────────────┐
    │     Select Action     │
    └────┬──────────┬───────┘
         │          │
         ▼          ▼
┌─────────────┐  ┌─────────────┐
│ Analyze Bug │  │  My Tasks   │
│ 1.拍照/พิมพ์ │  │  PM Checklist│
│ 2.AI วิเคราะห์│  │             │
│ 3.แสดงผล     │  │             │
└──────┬──────┘  └──────┬──────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│  Select     │  │  Complete   │
│  Action     │  │  PM Task    │
│  - Fix Self │  │  - Check ✓  │
│  - Call Help│  │  - Note     │
│  - Order    │  │  - Photo    │
│    Part     │  │  - Submit   │
└──────┬──────┘  └──────┬──────┘
       │                │
       ▼                │
┌─────────────┐         │
│ Create      │         │
│ Repair      │         │
│ Report      │         │
│ - Auto-fill │         │
│ - Photo     │         │
│ - Parts used│         │
│ - Submit    │         │
└──────┬──────┘         │
       │                │
       └────────┬───────┘
                ▼
         ┌─────────────┐
         │  Dashboard  │
         │  (Updated)  │
         └─────────────┘
```

### 2.2 Supervisor Flow

```
START
  │
  ▼
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Success?│
    └────┬────┘
    Yes  │  No
    │    └───→ Show Error → Back to Login
    ▼
┌─────────────────┐
│  Dashboard      │
│  - Total Jobs   │
│  - Pending      │
│  - MTBF/MTTR    │
└────────┬────────┘
         │
    ┌────┴──────────────────┐
    │     Select Action     │
    └────┬──────────┬───────┘
         │          │
         ▼          ▼
┌─────────────┐  ┌─────────────┐
│ View Reports│  │  Analytics  │
│ - All Jobs  │  │  - Chart    │
│ - Filter    │  │  - Trend    │
│ - Search    │  │  - Export   │
└──────┬──────┘  └──────┬──────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│ Approve     │  │  Export     │
│ Report      │  │  Report     │
│ - Review    │  │  - PDF      │
│ - Approve/  │  │  - Excel    │
│   Reject    │  │             │
└──────┬──────┘  └──────┬──────┘
       │                │
       └────────┬───────┘
                ▼
         ┌─────────────┐
         │  Dashboard  │
         │  (Updated)  │
         └─────────────┘
```

### 2.3 Admin Flow

```
START
  │
  ▼
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Success?│
    └────┬────┘
    Yes  │  No
    │    └───→ Show Error → Back to Login
    ▼
┌─────────────────┐
│  Admin Panel    │
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    │         │        │        │
    ▼         ▼        ▼        ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ Users  │ │Machines│ │ Config │ │ Report │
└───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
    │          │          │          │
    ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│- Add   │ │- Add   │ │- System│ │- View  │
│- Edit  │ │- Edit  │ │- AI    │ │- Export│
│- Delete│ │- Delete│ │- Alert │ │        │
│- Assign│ │- PM Sched│ │       │ │        │
└────────┘ └────────┘ └────────┘ └────────┘
    │          │          │          │
    └──────────┴──────────┴──────────┘
                │
                ▼
         ┌─────────────┐
         │   Success   │
         │   Message   │
         └─────────────┘
```

---

## 3. Functional Requirements

### 3.1 Authentication & User Management

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-001 | Auth | User Login | รองรับ Email/Password Login | High |
| FR-002 | Auth | Register | ช่างสามารถสมัครสมาชิกได้ | High |
| FR-003 | Auth | Password Reset | ลืมรหัสผ่านส่ง Email /reset | Medium |
| FR-004 | Auth | Logout | ออกจากระบบ | Medium |
| FR-005 | User | View Profile | ดูข้อมูลส่วนตัว | Low |
| FR-006 | User | Edit Profile | แก้ไขข้อมูลส่วนตัว | Low |
| FR-007 | User | Change Password | เปลี่ยนรหัสผ่าน | Medium |
| FR-008 | User | Role Management | Admin จัดการ Role (Technician/Supervisor/Admin) | High |

### 3.2 AI Breakdown Analysis

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-101 | AI | Photo Capture | ถ่ายรูปเครื่องจักร/อะไหล่ | High |
| FR-102 | AI | Photo Upload | อัพโหลดรูปจาก Gallery | High |
| FR-103 | AI | Text Input | พิมพ์อธิบายอาการเสีย | High |
| FR-104 | AI | Voice Input | พูดแทนพิมพ์ (Voice-to-Text) | Low |
| FR-105 | AI | AI Analysis | ส่งรูป/ข้อความไป AI วิเคราะห์สาเหตุ | High |
| FR-106 | AI | Show Causes | แสดงสาเหตุที่เป็นไปได้ (เรียงตามความน่าจะเป็น) | High |
| FR-107 | AI | Show Solutions | แสดงวิธีแก้ไขแต่ละสาเหตุ | High |
| FR-108 | AI | Confidence Score | แสดง % Confidence ของแต่ละสาเหตุ | Medium |
| FR-109 | AI | Feedback | บันทึกว่าวิธีไหนใช้ได้จริง (Train AI) | Medium |

### 3.3 Repair Report

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-201 | Report | Auto Create | สร้างรายงานอัตโนมัติจาก AI Analysis | High |
| FR-202 | Report | Manual Create | สร้างรายงานด้วยมือ | High |
| FR-203 | Report | Add Photo | แนบรูปภาพในรายงาน | High |
| FR-204 | Report | Add Parts | บันทึกอะไหล่ที่ใช้ | High |
| FR-205 | Report | Time Log | บันทึกเวลาเริ่ม-จบงาน | Medium |
| FR-206 | Report | Cost Estimate | ประมาณการค่าใช้จ่าย | Low |
| FR-207 | Report | Submit | ส่งรายงานให้ Supervisor | High |
| FR-208 | Report | Status | สถานะรายงาน (Draft/Pending/Approved/Rejected) | High |
| FR-209 | Report | History | ดูประวัติรายงานทั้งหมด | Medium |
| FR-210 | Report | Export PDF | ส่งออกเป็น PDF | Medium |

### 3.4 Preventive Maintenance (PM)

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-301 | PM | PM Schedule | ดูตาราง PM ที่กำหนด | High |
| FR-302 | PM | PM Checklist | ทำ Checklist สำเร็จรูป | High |
| FR-303 | PM | Custom Checklist | สร้าง Checklist เอง | Medium |
| FR-304 | PM | Complete Task | ทำเครื่องหมายว่าเสร็จ | High |
| FR-305 | PM | Add Note | บันทึกหมายเหตุ | Medium |
| FR-306 | PM | Add Photo | แนบรูปภาพ | Medium |
| FR-307 | PM | Overdue Alert | แจ้งเตือน PM ที่เกินกำหนด | High |
| FR-308 | PM | PM History | ดูประวัติ PM ทั้งหมด | Medium |

### 3.5 Spare Part Recommendation

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-401 | Spare | AI Recommend | AI แนะนำอะไหล่จากอาการเสีย | High |
| FR-402 | Spare | Parts List | แสดงรายการอะไหล่ที่แนะนำ | High |
| FR-403 | Spare | Part Detail | แสดงรายละเอียดอะไหล่ (รุ่น/หมายเลข/ราคา) | High |
| FR-404 | Spare | Compatibility | แสดงว่าอะไหล่ใช้กับเครื่องไหนได้บ้าง | Medium |
| FR-405 | Spare | Stock Check | แสดงจำนวนอะไหล่ในคลัง | Medium |
| FR-406 | Spare | Order Link | ส่งไปหน้าสั่งซื้อ (ถ้ามีระบบจัดซื้อ) | Low |
| FR-407 | Spare | Part Photo | แสดงรูปอะไหล่ | Medium |

### 3.6 Machine History

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-501 | History | Machine List | แสดงรายการเครื่องจักรทั้งหมด | High |
| FR-502 | History | Machine Detail | แสดงข้อมูลเครื่องจักร | High |
| FR-503 | History | Repair History | แสดงประวัติซ่อมทั้งหมด | High |
| FR-504 | History | PM History | แสดงประวัติ PM ทั้งหมด | High |
| FR-505 | History | Timeline | แสดง Timeline เหตุการณ์ทั้งหมด | Medium |
| FR-506 | History | Search | ค้นหาเครื่องจักร | Medium |
| FR-507 | History | Filter | กรองตามสถานะ/ประเภท | Low |

### 3.7 Dashboard & Analytics

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-601 | Dashboard | Summary Cards | แสดงสรุป (งานทั้งหมด/รอดำเนินการ/เสร็จแล้ว) | High |
| FR-602 | Dashboard | Chart | แสดงกราฟ (Breakdown by Type/Time) | High |
| FR-603 | Dashboard | MTBF | คำนวณ Mean Time Between Failures | Medium |
| FR-604 | Dashboard | MTTR | คำนวณ Mean Time To Repair | Medium |
| FR-605 | Dashboard | Trend | แสดงแนวโน้ม Breakdown | Medium |
| FR-606 | Dashboard | Top Issues | แสดงปัญหาที่พบบ่อยที่สุด | Medium |
| FR-607 | Dashboard | Export | ส่งออก Dashboard เป็น PDF/Excel | Low |

### 3.8 Admin Management

| FR-ID | Module | Requirement | Description | Priority |
|-------|--------|-------------|-------------|----------|
| FR-701 | Admin | CRUD Users | เพิ่ม/แก้ไข/ลบ/ดู User | High |
| FR-702 | Admin | CRUD Machines | เพิ่ม/แก้ไข/ลบ/ดู Machine | High |
| FR-703 | Admin | Assign Role | กำหนด Role ให้ User | High |
| FR-704 | Admin | Manage PM Schedule | ตั้งตาราง PM ให้เครื่องจักร | High |
| FR-705 | Admin | System Config | ตั้งค่าระบบ (AI Model, Notification) | Medium |
| FR-706 | Admin | Audit Log | ดูประวัติการใช้งาน | Medium |
| FR-707 | Admin | Backup | สำรองข้อมูล | Low |

---

## 4. Non-Functional Requirements

### 4.1 Performance

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-001 | Response Time | หน้าจอโหลดเสร็จภายใน | < 2 วินาที |
| NFR-002 | Response Time | AI Analysis เสร็จภายใน | < 5 วินาที |
| NFR-003 | Concurrency | รองรับผู้ใช้พร้อมกัน | 500 คน |
| NFR-004 | Availability | ระบบ uptime | 99.5% |
| NFR-005 | Database | Query response time | < 500ms |

### 4.2 Scalability

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-010 | Horizontal | รองรับการเพิ่ม server | Auto-scale |
| NFR-011 | Data | รองรับข้อมูลเครื่องจักร | 10,000+ เครื่อง |
| NFR-012 | Data | รองรับรายงาน | 1 ล้าน+ records |
| NFR-013 | Growth | รองรับโรงงาน | 500+ โรงงาน |

### 4.3 Security

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-020 | Auth | Authentication method | JWT + OAuth2 |
| NFR-021 | Auth | Password policy | Min 8 chars, 1 uppercase, 1 number |
| NFR-022 | Data | Encryption at rest | AES-256 |
| NFR-023 | Data | Encryption in transit | TLS 1.3 |
| NFR-024 | Access | Role-Based Access Control | RBAC |
| NFR-025 | API | Rate limiting | 100 req/min/user |
| NFR-026 | Audit | Log all critical actions | Yes |
| NFR-027 | GDPR | Data retention policy | Configurable |

### 4.4 Usability

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-030 | UI | รองรับภาษา | Thai + English |
| NFR-031 | UI | Font size | ไม่เล็กกว่า 14px |
| NFR-032 | UI | Touch target | ไม่เล็กกว่า 44x44 px |
| NFR-033 | UX | Learning curve | ใช้งานเป็นภายใน 15 นาที |
| NFR-034 | UX | Error message | แสดงข้อความเข้าใจง่าย |
| NFR-035 | Accessibility | Color contrast | WCAG 2.1 AA |

### 4.5 Reliability

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-040 | Backup | Database backup | ทุก 6 ชั่วโมง |
| NFR-041 | Backup | Retention | 30 วัน |
| NFR-042 | Recovery | RTO (Recovery Time Objective) | < 4 ชั่วโมง |
| NFR-043 | Recovery | RPO (Recovery Point Objective) | < 1 ชั่วโมง |
| NFR-044 | Monitoring | Error alerting | Real-time |

### 4.6 Compatibility

| NFR-ID | Category | Requirement | Target |
|--------|----------|-------------|--------|
| NFR-050 | Mobile | iOS version | iOS 14+ |
| NFR-051 | Mobile | Android version | Android 8.0+ |
| NFR-052 | Screen | รองรับหน้าจอ | 4.7" - 12.9" |
| NFR-053 | Network | รองรับการเชื่อมต่อ | 3G/4G/WiFi |
| NFR-054 | Offline | ใช้งานออฟไลน์ | บางฟีเจอร์ |

---

## 5. Business Process

### 5.1 Breakdown Repair Process

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        BREAKDOWN REPAIR PROCESS                         │
└──────────────────────────────────────────────────────────────────────────┘

START
  │
  ▼
┌─────────────────────┐
│  เครื่องจักรมีปัญหา    │
│  (Breakdown occurs)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ช่างแจ้งปัญหา         │
│  (Technician reports)│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│  ถ่ายรูป/พิมพ์อาการ    │────▶│  AI วิเคราะห์สาเหตุ    │
│  (Capture symptoms)  │     │  (AI analyzes)       │
└─────────────────────┘     └──────────┬──────────┘
                                       │
                          ┌────────────┴────────────┐
                          │                         │
                          ▼                         ▼
               ┌─────────────────┐       ┌─────────────────┐
               │  แก้ไขเองได้      │       │  ต้องขอความช่วยเหลือ│
               │  (Self-repair)  │       │  (Need help)     │
               └────────┬────────┘       └────────┬────────┘
                        │                         │
                        ▼                         ▼
               ┌─────────────────┐       ┌─────────────────┐
               │  แนะนำอะไหล่     │       │  แจ้งหัวหน้า/วิศวกร│
               │  (Spare parts)  │       │  (Escalate)      │
               └────────┬────────┘       └────────┬────────┘
                        │                         │
                        ▼                         ▼
               ┌─────────────────┐       ┌─────────────────┐
               │  เปลี่ยนอะไหล่    │       │  ส่งทีมมาช่วย     │
               │  (Replace)      │       │  (Team support)  │
               └────────┬────────┘       └────────┬────────┘
                        │                         │
                        └────────────┬────────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  สร้างรายงานซ่อม       │
                          │  (Create report)     │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  ส่งให้ Supervisor   │
                          │  (Submit for review) │
                          └──────────┬──────────┘
                                     │
                          ┌──────────┴──────────┐
                          │                     │
                          ▼                     ▼
               ┌─────────────────┐       ┌─────────────────┐
               │  Approve ✓      │       │  Reject ✗       │
               │  (Approved)     │       │  (Rejected)     │
               └────────┬────────┘       └────────┬────────┘
                        │                         │
                        ▼                         ▼
               ┌─────────────────┐       ┌─────────────────┐
               │  เครื่องกลับมา   │       │  ส่งกลับแก้ไข    │
               │  ทำงานได้        │       │  (Revise)       │
               │  (Machine fixed)│       └─────────────────┘
               └────────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │  Update History │
               │  (บันทึกประวัติ) │
               └─────────────────┘
```

### 5.2 Preventive Maintenance Process

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     PREVENTIVE MAINTENANCE PROCESS                      │
└──────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│  Admin ตั้งตาราง PM  │
│  (Set PM schedule)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ระบบแจ้งเตือนล่วงหน้า │
│  (Reminder sent)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ช่างรับงาน PM        │
│  (Accept PM task)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ทำ Checklist        │
│  (Complete tasks)   │
└──────────┬──────────┘
           │
      ┌────┴────┐
      │  ผ่าน?  │
      └────┬────┘
      Yes  │  No
      │    │
      │    └───▶ ซ่อม/เปลี่ยนอะไหล่ ──▶ ทำต่อ
      │
      ▼
┌─────────────────────┐
│  ถ่ายรูป/บันทึกผล    │
│  (Record results)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ส่งรายงาน PM        │
│  (Submit PM report) │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  บันทึกในระบบ         │
│  (Save to system)   │
└─────────────────────┘
```

### 5.3 Machine Registration Process

```
┌──────────────────────────────────────────────────────────────────────────┐
│                   MACHINE REGISTRATION PROCESS                          │
└──────────────────────────────────────────────────────────────────────────┘

START
  │
  ▼
┌─────────────────────┐
│  Admin เพิ่มเครื่องจักร│
│  (Add machine)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  กรอกข้อมูลเครื่อง     │
│  - ชื่อเครื่อง         │
│  - รุ่น/หมายเลข       │
│  - สถานที่ตั้ง         │
│  - วันที่ติดตั้ง        │
│  - รอบ PM            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  สร้าง QR Code       │
│  (Generate QR)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ติด QR Code บนเครื่อง│
│  (Attach QR)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ตั้งตาราง PM        │
│  (Set PM schedule)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  เครื่องพร้อมใช้งาน   │
│  (Machine ready)    │
└─────────────────────┘
```

### 5.4 User Management Process

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    USER MANAGEMENT PROCESS                              │
└──────────────────────────────────────────────────────────────────────────┘

START
  │
  ▼
┌─────────────────────┐
│  Admin สร้างบัญชี    │
│  (Admin creates)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  กำหนด Role         │
│  - Technician       │
│  - Supervisor       │
│  - Admin            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  กำหนดสิทธิ์          │
│  (Assign permissions)│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  ส่ง Email เชิญ      │
│  (Send invite)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  User ตั้งรหัสผ่าน    │
│  (Set password)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  User ใช้งานได้       │
│  (Account active)   │
└─────────────────────┘
```

---

## 6. Data Model (Summary)

### 6.1 Entity Relationship

| Entity | Key Attributes | Relationships |
|--------|---------------|---------------|
| User | id, name, email, password, role, phone | has many RepairReport |
| Machine | id, name, model, serial_no, location, install_date | has many RepairReport, has many PMTask |
| Breakdown | id, machine_id, description, photo, ai_analysis | belongs to Machine, has many SparePart |
| RepairReport | id, breakdown_id, technician_id, status, created_at | belongs to Breakdown, belongs to User |
| PMTask | id, machine_id, checklist, status, due_date | belongs to Machine |
| SparePart | id, name, model, price, stock | used in many Breakdown |
| AuditLog | id, user_id, action, timestamp | belongs to User |

---

## 7. API Endpoints (Summary)

### 7.1 Core APIs

| Module | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| Auth | POST | /api/auth/login | Login |
| Auth | POST | /api/auth/register | Register |
| Auth | POST | /api/auth/forgot-password | Reset password |
| Machine | GET | /api/machines | List machines |
| Machine | POST | /api/machines | Create machine |
| Machine | GET | /api/machines/:id | Get machine detail |
| Machine | PUT | /api/machines/:id | Update machine |
| Breakdown | POST | /api/breakdowns/analyze | AI analyze |
| Breakdown | GET | /api/breakdowns | List breakdowns |
| Report | POST | /api/reports | Create report |
| Report | GET | /api/reports | List reports |
| Report | PUT | /api/reports/:id/approve | Approve report |
| PM | GET | /api/pm-tasks | List PM tasks |
| PM | PUT | /api/pm-tasks/:id/complete | Complete PM |
| Spare | GET | /api/spare-parts | List spare parts |
| Dashboard | GET | /api/dashboard/summary | Dashboard summary |
| Dashboard | GET | /api/dashboard/analytics | Analytics data |
| User | GET | /api/users | List users |
| User | POST | /api/users | Create user |

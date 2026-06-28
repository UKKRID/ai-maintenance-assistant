# AI Maintenance Assistant - QA Test Plan

---

## 1. Test Cases

### 1.1 Authentication Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-001 | Auth | Login สำเร็จ | 1. เปิดแอป<br>2. กรอก Email/Password<br>3. กด Login | เข้าสู่ Dashboard สำเร็จ | High |
| TC-002 | Auth | Login ผิด Password | 1. กรอก Email<br>2. กรอก Password ผิด<br>3. กด Login | แสดง Error "Email หรือ Password ไม่ถูกต้อง" | High |
| TC-003 | Auth | Login Email ไม่ถูก format | 1. กรอก Email "abc"<br>2. กด Login | แสดง Error "Email ไม่ถูกต้อง" | Medium |
| TC-004 | Auth | Login Password ว่าง | 1. กรอก Email<br>2. ไม่กรอก Password<br>3. กด Login | แสดง Error "กรุณากรอกรหัสผ่าน" | Medium |
| TC-005 | Auth | Register สำเร็จ | 1. กรอกข้อมูลครบ<br>2. กด Register | สมัครสำเร็จ ไปหน้า Login | High |
| TC-006 | Auth | Register Email ซ้ำ | 1. กรอก Email ที่มีอยู่แล้ว<br>2. กด Register | แสดง Error "Email นี้ถูกใช้แล้ว" | Medium |
| TC-007 | Auth | Logout สำเร็จ | 1. Login สำเร็จ<br>2. กด Logout | กลับหน้า Login | High |
| TC-008 | Auth | Token หมดอายุ | 1. Login สำเร็จ<br>2. รอ Token หมดอายุ<br>3. ทำอะไรก็ได้ | แสดง Error และกลับหน้า Login | High |

---

### 1.2 AI Analysis Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-101 | AI | วิเคราะห์จากข้อความ | 1. เลือกเครื่อง<br>2. พิมพ์อาการเสีย<br>3. กดวิเคราะห์ | แสดงผลวิเคราะห์ 3 สาเหตุ | High |
| TC-102 | AI | วิเคราะห์จากรูป | 1. เลือกเครื่อง<br>2. ถ่ายรูป 1 รูป<br>3. กดวิเคราะห์ | แสดงผลวิเคราะห์ | High |
| TC-103 | AI | วิเคราะห์จากข้อความ + รูป | 1. เลือกเครื่อง<br>2. ถ่ายรูป + พิมพ์อาการ<br>3. กดวิเคราะห์ | แสดงผลวิเคราะห์ | High |
| TC-104 | AI | ไม่กรอกข้อมูล | 1. เลือกเครื่อง<br>2. ไม่กรอกอะไร<br>3. กดวิเคราะห์ | แสดง Error "กรุณากรอกข้อมูล" | High |
| TC-105 | AI |  Confidence Score แสดงถูกต้อง | 1. วิเคราะห์สำเร็จ<br>2. ดู Confidence | แสดง % ที่สมเหตุสมผล (0-100) | Medium |
| TC-106 | AI | แสดง Solutions ครบถ้วน | 1. วิเคราะห์สำเร็จ<br>2. ดู Solutions | แสดง Steps, Time, Cost | High |
| TC-107 | AI | แสดง Spare Parts | 1. วิเคราะห์สำเร็จ<br>2. ดู Spare Parts | แสดงรายการอะไหล่ที่แนะนำ | Medium |
| TC-108 | AI | ส่ง Feedback | 1. วิเคราะห์สำเร็จ<br>2. กด helpful<br>3. ยืนยัน | บันทึก Feedback สำเร็จ | Low |

---

### 1.3 Camera Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-201 | Camera | เปิดกล้องสำเร็จ | 1. กด Scan<br>2. เปิดกล้อง | กล้องทำงานปกติ | High |
| TC-202 | Camera | ถ่ายรูปสำเร็จ | 1. เปิดกล้อง<br>2. กดปุ่มถ่าย | บันทึกรูปสำเร็จ | High |
| TC-203 | Camera | เลือกรูปจาก Gallery | 1. กด Gallery<br>2. เลือกรูป | เพิ่มรูปสำเร็จ | Medium |
| TC-204 | Camera | ลบารูป | 1. เลือกรูป 3 รูป<br>2. ลบรูป 1 รูป | เหลือ 2 รูป | Low |
| TC-205 | Camera | ถ่ายรูปหลายรูป | 1. ถ่ายรูป 5 รูป | แสดงรูปทั้ง 5 รูป | Medium |
| TC-206 | Camera | ไม่เลือกเครื่อง | 1. ไม่เลือกเครื่อง<br>2. กดวิเคราะห์ | แสดง Error "กรุณาเลือกเครื่อง" | High |

---

### 1.4 Dashboard Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-301 | Dashboard | แสดง Summary Cards | 1. เปิด Dashboard | แสดงตัวเลขสรุปถูกต้อง | High |
| TC-302 | Dashboard | แสดง Recent Jobs | 1. เปิด Dashboard | แสดงงานล่าสุด 3 รายการ | Medium |
| TC-303 | Dashboard | กด Summary Card | 1. กด "งานทั้งหมด" | ไปหน้ากรองงาน | Medium |
| TC-304 | Dashboard | กด Job Item | 1. กดงานล่าสุด | ไปหน้ารายละเอียดงาน | Medium |
| TC-305 | Dashboard | Pull to Refresh | 1. ลากหน้าจอลง | โหลดข้อมูลใหม่ | Low |

---

### 1.5 Repair Report Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-401 | Report | สร้างรายงานสำเร็จ | 1. กรอกข้อมูลครบ<br>2. กดส่ง | สร้างรายงานสำเร็จ | High |
| TC-402 | Report | บันทึก Draft | 1. กรอกข้อมูลบางส่วน<br>2. กด Draft | บันทึก Draft สำเร็จ | Medium |
| TC-403 | Report | ส่งรายงานซ้ำ | 1. ส่งรายงานแล้ว<br>2. ส่งอีกครั้ง | แสดง Error "ส่งแล้ว" | Medium |
| TC-404 | Report | Approve Report | 1. Supervisor login<br>2. กด Approve | สถานะเปลี่ยนเป็น Approved | High |
| TC-405 | Report | Reject Report | 1. Supervisor login<br>2. กด Reject<br>3. กรอกเหตุผล | สถานะเปลี่ยนเป็น Rejected | High |

---

### 1.6 PM Module

| TC ID | Module | Test Case | Steps | Expected Result | Priority |
|-------|--------|-----------|-------|-----------------|----------|
| TC-501 | PM | ดูตาราง PM | 1. กด PM Schedule | แสดงตาราง PM | High |
| TC-502 | PM | เริ่มงาน PM | 1. กด Start | ไปหน้า PM Checklist | High |
| TC-503 | PM | ทำ Checklist | 1. ทำเครื่องหมายเสร็จทุกข้อ | ปุ่ม Complete ขึ้นสี | High |
| TC-504 | PM | เสร็จงาน PM | 1. ทำ Checklist เสร็จ<br>2. กด Complete | บันทึกสำเร็จ | High |
| TC-505 | PM | PM Overdue | 1. ดู PM ที่เกินกำหนด | แสดงสีแดง + แจ้งเตือน | Medium |

---

## 2. UAT (User Acceptance Testing)

### 2.1 UAT Scenario

| UAT ID | Scenario | Steps | Expected Result | Acceptance Criteria |
|--------|----------|-------|-----------------|---------------------|
| UAT-001 | ช่างซ่อม: แจ้งเครื่องเสีย | 1. Login<br>2. กด Scan<br>3. สแกน QR<br>4. พิมพ์อาการ<br>5. กดวิเคราะห์<br>6. ดูผล<br>7. กดสร้างรายงาน<br>8. กดส่ง | รายงานถูกส่งให้ Supervisor | ใช้เวลา < 5 นาที |
| UAT-002 | ช่างซ่อม: ดูประวัติเครื่อง | 1. Login<br>2. กด History<br>3. เลือกเครื่อง<br>4. ดู Timeline | แสดงประวัติทั้งหมด | ข้อมูลครบถ้วน |
| UAT-003 | Supervisor: อนุมัติรายงาน | 1. Login<br>2. ดู Dashboard<br>3. เลือกรายงาน<br>4. กด Approve | รายงานได้รับอนุมัติ | ใช้เวลา < 1 นาที |
| UAT-004 | Supervisor: ดู Analytics | 1. Login<br>2. กด Analytics<br>3. เลือกช่วงเวลา | แสดงกราฟถูกต้อง | ข้อมูลตรงจริง |
| UAT-005 | Admin: เพิ่มเครื่องจักร | 1. Login<br>2. กด Machine<br>3. กด Add<br>4. กรอกข้อมูล<br>5. กด Save | เพิ่มเครื่องสำเร็จ | มี QR Code |
| UAT-006 | Admin: จัดการ User | 1. Login<br>2. กด Users<br>3. กด Add User<br>4. กรอกข้อมูล<br>5. กด Save | เพิ่ม User สำเร็จ | ส่ง Email เชิญ |

### 2.2 UAT Checklist

| # | Checklist | Pass/Fail | Notes |
|---|-----------|-----------|-------|
| 1 | แอปเปิดได้ปกติ | | |
| 2 | Login สำเร็จ | | |
| 3 | Dashboard แสดงข้อมูลถูกต้อง | | |
| 4 | กล้องทำงานปกติ | | |
| 5 | AI วิเคราะห์ได้ผลลัพธ์ | | |
| 6 | สร้างรายงานสำเร็จ | | |
| 7 | PM Checklist ทำงานได้ | | |
| 8 | ดูประวัติเครื่องได้ | | |
| 9 | Export PDF ได้ | | |
| 10 | ไม่มี Crash | | |

---

## 3. Edge Cases

### 3.1 Input Edge Cases

| EC ID | Category | Edge Case | Expected Behavior |
|-------|----------|-----------|-------------------|
| EC-001 | Text | กรอกข้อความ 10,000 ตัวอักษร | รับได้สูงสุด 5,000 ตัวอักษร |
| EC-002 | Text | กรอกข้อความมี HTML/Script | Sanitize ข้อความ |
| EC-003 | Text | กรอกข้อความภาษาจีน/อาหรับ | แสดงถูกต้อง (RTL support) |
| EC-004 | Number | ใส่ค่าติดลบ | ไม่รับค่าติดลบ |
| EC-005 | Number | ใส่ค่าเกิน Integer MAX | แสดง Error |
| EC-006 | Date | เลือกวันที่ในอดีต | ไม่ยอมรับ (สำหรับ PM) |
| EC-007 | Date | เลือกวันที่在未来 10 ปี | ยอมรับ |
| EC-008 | Email | กรอก email ยาวมาก (>255 chars) | แสดง Error |
| EC-009 | Password | กรอก Password 1 ตัวอักษร | แสดง Error "อย่างน้อย 8 ตัว" |
| EC-010 | Password | กรอก Password 256 ตัวอักษร | ยอมรับ |

### 3.2 Image Edge Cases

| EC ID | Category | Edge Case | Expected Behavior |
|-------|----------|-----------|-------------------|
| EC-101 | Image | อัพโหลดไฟล์ 0 bytes | แสดง Error |
| EC-102 | Image | อัพโหลดไฟล์ 100 MB | แสดง Error "ไฟล์ใหญ่เกินไป" |
| EC-103 | Image | อัพโหลดไฟล์ .exe | แสดง Error "ประเภทไฟล์ไม่ถูกต้อง" |
| EC-104 | Image | อัพโหลด GIF | แปลงเป็น JPEG |
| EC-105 | Image | รูปหมุน 90 องศา | แสดงถูกต้อง |
| EC-106 | Image | รูปกลับหัว | แสดงถูกต้อง |
| EC-107 | Image | รูป Black & White | วิเคราะห์ได้ |
| EC-108 | Image | รูปมีข้อความ (OCR) | แสดงผลถูกต้อง |

### 3.3 Data Edge Cases

| EC ID | Category | Edge Case | Expected Behavior |
|-------|----------|-----------|-------------------|
| EC-201 | List | ไม่มีข้อมูล (Empty) | แสดง "ไม่มีข้อมูล" |
| EC-202 | List | มีข้อมูล 1,000 รายการ | Paginate อัตโนมัติ |
| EC-203 | Search | ค้นหาคำว่าง | แสดงทั้งหมด |
| EC-204 | Search | ค้นหาไม่พบ | แสดง "ไม่พบผลลัพธ์" |
| EC-205 | Pagination | เลือกหน้าสุดท้าย | แสดงถูกต้อง |
| EC-206 | Pagination | เปลี่ยน Limit | โหลดใหม่ถูกต้อง |

---

## 4. Failure Scenarios

### 4.1 Network Failure

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-001 | ไม่มีอินเตอร์เน็ต | ปิด WiFi/Mobile Data | แสดง "ไม่มีการเชื่อมต่อ" + ใช้ Cached Data |
| FS-002 | อินเตอร์เน็ตช้า | ใช้ 2G/Edge | Loading indicator + Timeout 30 วินาที |
| FS-003 | หายไปกลางคัน | อินเตอร์เน็ตหายขณะส่งข้อมูล | บันทึกเป็น Draft + ลองใหม่ |
| FS-004 | DNS ล่ม | DNS Resolution Failed | แสดง Error "ไม่สามารถเชื่อมต่อได้" |
| FS-005 | SSL Error | Certificate หมดอายุ | แสดง Error + แนะนำติดต่อ Admin |

### 4.2 Server Failure

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-010 | Server ล่ม | Backend ไม่ทำงาน | แสดง "ระบบไม่พร้อมใช้งาน" + Retry |
| FS-011 | Server ช้า | Response > 10 วินาที | Loading indicator + Timeout |
| FS-012 | Server คืน 500 | Internal Server Error | แสดง Error + Log สำหรับ Admin |
| FS-013 | Server คืน 503 | Service Unavailable | แสดง "ระบบปิดปรับปรุง" |
| FS-014 | Server คืน 429 | Rate Limit Exceeded | แสดง "ลองใหม่อีกครั้ง" + นับถอยหลัง |

### 4.3 AI Failure Scenarios

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-020 | AI วิเคราะห์ผิด | รูปไม่ชัด / ข้อมูลน้อย | แสดง "ไม่สามารถวิเคราะห์ได้" + แนะนำข้อมูลเพิ่ม |
| FS-021 | AI ไม่ตอบ | OpenAI API ล่ม | แสดง Error + ลองใหม่ |
| FS-022 | AI ตอบช้า | API Response > 30 วินาที | Loading + Cancel option |
| FS-023 | AI ตอบผิด format | JSON ผิด format | Parse Error + ลองใหม่ |
| FS-024 | AI Confidence ต่ำ | Confidence < 50% | แสดง "ผลวิเคราะห์อาจไม่แม่นยำ" |
| FS-025 | AI ไม่รู้จักอาการ | อาการหายาก | แสดง "ไม่พบข้อมูล" + แนะนำติดต่อผู้เชี่ยวชาญ |

### 4.4 Camera Failure Scenarios

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-030 | กล้องไม่ทำงาน | Camera permission ถูกปฏิเสธ | แสดง "กรุณาให้สิทธิ์กล้อง" |
| FS-031 | กล้องค้าง | Camera freeze | ปิดและเปิดใหม่ |
| FS-032 | รูปไม่ชัด | กล้องสกปรก / มือสั่น | แสดง "รูปไม่ชัด กรุณาถ่ายใหม่" |
| FS-033 | รูปมืด | แสงน้อย | แสดง "แสงไม่พอ กรุณาหาที่สว่าง" |
| FS-034 | รูปสีเพี้ยน | White balance ผิด | AI ยังวิเคราะห์ได้ |
| FS-035 | Storage เต็ม | พื้นที่เก็บข้อมูลไม่พอ | แสดง Error + แนะนำลบไฟล์ |

### 4.5 Data Failure Scenarios

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-040 | Database ล่ม | PostgreSQL ไม่ทำงาน | แสดง Error + ลองใหม่ |
| FS-041 | Cache ล่ม | Redis ไม่ทำงาน | ใช้ Data จาก Database |
| FS-042 | Data ซ้ำ | Insert ข้อมูลซ้ำ | แสดง Error "ข้อมูลมีอยู่แล้ว" |
| FS-043 | Data สูญหาย | ฐานข้อมูลถูกลบ | Backup + Restore |
| FS-044 | Concurrent Update | 2 คนแก้ไขพร้อมกัน | แสดง "ข้อมูลถูกแก้ไขโดยผู้อื่น" |

### 4.6 Device Failure Scenarios

| FS ID | Scenario | Trigger | Expected Behavior |
|-------|----------|---------|-------------------|
| FS-050 | RAM ไม่พอ | แอปกิน RAM เกินไป | Kill process + แสดง Error |
| FS-051 | Battery ต่ำ | Battery < 10% | แจ้งเตือน + โหมดประหยัด |
| FS-052 | Storage เต็ม | พื้นที่ไม่พอ | แสดง Error + แนะนำลบข้อมูล |
| FS-053 | App Crash | Exception ที่ไม่ได้จัดการ | บันทึก Crash Log + Restart |
| FS-054 | App ANR | UI Thread ค้าง > 5 วินาที | Kill + Restart |

---

## 5. Test Data

### 5.1 Valid Test Data

```json
{
  "valid_user": {
    "email": "test@example.com",
    "password": "Password123",
    "full_name": "สมชาย ใจดี",
    "phone": "0812345678"
  },
  "valid_machine": {
    "name": "Motor Pump A",
    "model": "ABC-123",
    "serial_number": "MP-001",
    "location": "Building 1, Floor 2",
    "department": "Production"
  },
  "valid_repair": {
    "machine_id": "uuid",
    "title": "Motor Bearing Wear",
    "description": "เครื่องส่งเสียงดัง",
    "priority": "high"
  }
}
```

### 5.2 Invalid Test Data

```json
{
  "invalid_email": [
    "",
    "abc",
    "abc@",
    "@abc.com",
    "abc@abc",
    "a" * 256 + "@test.com"
  ],
  "invalid_password": [
    "",
    "1234567",
    "Password",
    "12345678",
    "a" * 257
  ],
  "invalid_phone": [
    "",
    "123",
    "abc",
    "081234567890"
  ]
}
```

---

## 6. Test Environment

| Environment | URL | Purpose |
|-------------|-----|---------|
| Development | dev.api.aimaintenance.com | Development |
| Staging | staging.api.aimaintenance.com | Testing |
| Production | api.aimaintenance.com | Live |

---

## 7. Bug Report Template

```markdown
**Bug ID:** BUG-XXX
**Title:** [Short description]
**Module:** [Module name]
**Severity:** Critical / High / Medium / Low
**Priority:** P1 / P2 / P3 / P4

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Screenshots:**
[If applicable]

**Environment:**
- Device: [iPhone 14 / Samsung S23]
- OS: [iOS 17 / Android 14]
- App Version: [1.0.0]
- Network: [WiFi / 4G / Offline]

**Additional Notes:**
[Any other relevant information]
```

---

## 8. Test Summary

| Category | Total | Pass | Fail | Blocked |
|----------|-------|------|------|---------|
| Authentication | 8 | - | - | - |
| AI Analysis | 8 | - | - | - |
| Camera | 6 | - | - | - |
| Dashboard | 5 | - | - | - |
| Repair Report | 5 | - | - | - |
| PM Module | 5 | - | - | - |
| **Total** | **37** | - | - | - |

# AI Maintenance Assistant - UX Wireframe

---

## 1. Login Screen

```
┌──────────────────────────┐
│          ☰               │
│                          │
│                          │
│      ┌──────────────┐    │
│      │   🔧 logo    │    │
│      └──────────────┘    │
│                          │
│   AI Maintenance        │
│     Assistant            │
│                          │
│  ┌────────────────────┐  │
│  │ 📧 Email           │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🔒 Password        │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │     LOGIN          │  │
│  └────────────────────┘  │
│                          │
│  Forgot Password?        │
│                          │
│  ───────── or ─────────  │
│                          │
│  ┌────────────────────┐  │
│  │    📱 OTP Login    │  │
│  └────────────────────┘  │
│                          │
│  No account? Register    │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Logo | Image | ไอคอนประแจ + AI สีน้ำเงิน |
| Email Input | TextField | placeholder: "Email", keyboard: email, icon: 📧 |
| Password Input | TextField | placeholder: "Password", secure: true, icon: 🔒, toggle show/hide |
| Login Button | Button | สีน้ำเงิน, full-width, loading state: spinner |
| Forgot Password | Text Link | สีน้ำเงิน, ไปหน้า Reset Password |
| OTP Login | Button | outline สีน้ำเงิน |
| Register Link | Text Link | ไปหน้า Register |

| Button | Action | Icon |
|--------|--------|------|
| Login | POST /api/auth/login → Dashboard | None |
| Forgot Password | Navigate to /forgot-password | None |
| OTP Login | Navigate to /otp-login | None |
| Register | Navigate to /register | None |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Email | required, format email | "กรุณากรอก Email" / "Email ไม่ถูกต้อง" |
| Password | required, min 8 chars | "กรุณากรอกรหัสผ่าน" / "รหัสผ่านต้องมีอย่างน้อย 8 ตัว" |

**User Flow:** Open App → Login Screen → กรอก Email/Password → กด Login → สำเร็จ → Dashboard / ล้มเหลว → แสดง Error

**UX Reason:**
- หน้าจอโล่ง ไม่โหลดมาก → ช่างไม่ต้องอ่านเยอะ
- แสดง logo ชัดเจน → จำได้ว่าเป็นแอปไหน
- OTP Login เพิ่มทางเลือก → ช่างบางคนจำรหัสผ่านไม่ได้
- Password toggle → ตรวจสอบก่อนกด Login ลดความผิดพลาด

---

## 2. Dashboard Screen

```
┌──────────────────────────┐
│  ☰  Dashboard    👤     │
│──────────────────────────│
│                          │
│  Welcome back,           │
│  สมชาย 🔧                │
│                          │
│  ┌──────────┐┌──────────┐│
│  │ 📊 Total ││ ⏳ Active││
│  │   156    ││    12    ││
│  └──────────┘└──────────┘│
│  ┌──────────┐┌──────────┐│
│  │ ✅ Done  ││ 📅 PM Due││
│  │   138    ││    5     ││
│  └──────────┘└──────────┘│
│                          │
│  📈 Weekly Breakdown     │
│  ┌────────────────────┐  │
│  │  ▓▓               │  │
│  │  ▓▓  ▓▓           │  │
│  │  ▓▓  ▓▓  ▓▓       │  │
│  │ Mon Tue Wed Thu    │  │
│  └────────────────────┘  │
│                          │
│  🔥 Top Issues           │
│  ┌────────────────────┐  │
│  │ 1. Motor Overheat  │  │
│  │ 2. Belt Wear       │  │
│  │ 3. Bearing Noise   │  │
│  └────────────────────┘  │
│                          │
│  ──────────────────────── │
│                          │
│  🏠  📷  📋  📊  👤     │
│  Home Scan  PM  Rpt  Me  │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Header | AppBar | Title: "Dashboard", icons: hamburger menu + profile |
| Welcome Text | Text | "Welcome back, {ชื่อ} 🔧" |
| Stat Cards (x4) | Card | Total Jobs / Active / Done / PM Due — แต่ละใบมีไอคอน + ตัวเลข |
| Weekly Chart | BarChart | กราฟแท่ง 7 วัน แสดงจำนวน Breakdown |
| Top Issues | List | แสดง 3 ปัญหาที่พบบ่อยที่สุด |
| Bottom Nav | TabBar | Home / Scan / PM / Reports / Profile |

| Button | Action | Icon |
|--------|--------|------|
| Hamburger Menu | เปิด Side Drawer (Settings, Help, Logout) | ☰ |
| Profile | Navigate to Profile Screen | 👤 |
| Stat Card | Navigate to filtered report list | แต่ละใบ |
| Bottom Nav | Switch tab | แต่ละ icon |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| (none — read-only dashboard) | — | — |

**User Flow:** Login → Dashboard → ดูสรุปข้อมูล → เลือกดูรายละเอียด/ไปหน้าอื่น

**UX Reason:**
- Summary Cards แสดงข้อมูลสำคัญสุดบน → เห็นภาพรวมทันที
- กราฟรายสัปดาห์ → มองเห็นแนวโน้ม Breakdown
- Top Issues → รู้ว่าปัญหาไหนเจอบ่อย ควรแก้ที่ต้นเหตุ
- Bottom Nav → access key functions ได้ทันที ไม่ต้องเข้าเมนู

---

## 3. Scan Machine Screen

```
┌──────────────────────────┐
│  ← Scan Machine          │
│──────────────────────────│
│                          │
│  ┌────────────────────┐  │
│  │                    │  │
│  │   ┌────────────┐   │  │
│  │   │            │   │  │
│  │   │  [Camera   │   │  │
│  │   │   View]    │   │  │
│  │   │            │   │  │
│  │   │  ┌──────┐  │   │  │
│  │   │  │ □ □  │  │   │  │
│  │   │  │ □ □  │  │   │  │
│  │   │  └──────┘  │   │  │
│  │   │            │   │  │
│  │   └────────────┘   │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│  📷 Scan QR Code         │
│  or take photo           │
│                          │
│  ┌──────────┐┌──────────┐│
│  │  📷 Take ││ 🖼 Gallery││
│  │  Photo   ││          ││
│  └──────────┘└──────────┘│
│                          │
│  ┌────────────────────┐  │
│  │  📱 Scan QR Code   │  │
│  └────────────────────┘  │
│                          │
│  ──── or type manually ──│
│                          │
│  ┌────────────────────┐  │
│  │ Machine ID / Name  │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │  🔍 Search         │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Back Button | IconButton | ← กลับหน้าก่อน |
| Title | AppBar | "Scan Machine" |
| Camera Preview | CameraView | แสดงภาพจากกล้อง, กรอบสี่เหลี่ยม guide สำหรับ QR |
| Take Photo | Button | สีน้ำเงิน, ไอคอน 📷 |
| Gallery | Button | outline, ไอคอน 🖼 |
| Scan QR | Button | สีเขียว, ไอคอน 📱, ไปหน้า QR Scanner |
| Manual Input | TextField | placeholder: "Machine ID / Name" |
| Search Button | Button | 🔍 ค้นหาเครื่องจักร |

| Button | Action | Icon |
|--------|--------|------|
| Take Photo | เปิดกล้อง → ถ่ายรูป → ส่งไป AI Analysis | 📷 |
| Gallery | เปิด Gallery → เลือกรูป → ส่งไป AI Analysis | 🖼 |
| Scan QR | เปิด QR Scanner → สแกน → แสดงข้อมูลเครื่อง | 📱 |
| Search | POST /api/machines/search → แสดงผลลัพธ์ | 🔍 |
| Back | Pop navigation stack | ← |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Machine ID | required (ถ้าไม่สแกน QR) | "กรุณากรอก Machine ID" |
| Photo | required (ถ้าไม่สแกน QR) | "กรุณาถ่ายรูปหรือเลือกรูป" |

**User Flow:** Dashboard → กด Scan → เลือกวิธี (ถ่ายรูป/QR/พิมพ์) → ได้ข้อมูลเครื่อง → ไป AI Diagnosis

**UX Reason:**
- Camera Preview ขนาดใหญ่ → ช่างถ่ายรูปได้ง่าย แม้สวมถุงมือ
- 3 ทางเลือก → ยืดหยุ่นตามสถานการณ์จริง
- QR Scan เร็วที่สุด → ใช้เมื่ออยู่หน้าเครื่อง
- Manual input → สำรองเมื่อ QR เสีย/กล้องไม่ทำงาน

---

## 4. AI Diagnosis Screen

```
┌──────────────────────────┐
│  ← AI Diagnosis          │
│──────────────────────────│
│                          │
│  Machine: CNC-001        │
│  Location: Line A-3      │
│                          │
│  ┌────────────────────┐  │
│  │  📷 [Photo taken]  │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ Describe the issue │  │
│  │ (type or voice)    │  │
│  └────────────────────┘  │
│  🎤 voice input          │
│                          │
│  ┌────────────────────┐  │
│  │  🤖 Analyze Now    │  │
│  └────────────────────┘  │
│                          │
│  ═══ AI Analysis ═══════ │
│                          │
│  📊 Possible Causes      │
│  ┌────────────────────┐  │
│  │ ⚠️ 1. Overheating  │  │
│  │    Confidence: 85% │  │
│  │    → Check cooling │  │
│  │    system, clean   │  │
│  │    filters         │  │
│  │                    │  │
│  │ ⚠️ 2. Belt Wear    │  │
│  │    Confidence: 60% │  │
│  │    → Replace belt  │  │
│  │    assembly        │  │
│  │                    │  │
│  │ ⚠️ 3. Lubrication  │  │
│  │    Confidence: 45% │  │
│  │    → Apply grease  │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 💬 Was this helpful?│  │
│  │ 👍 Yes  👎 No      │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📝 Create Report   │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🔧 Spare Parts     │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Machine Info | Text | ชื่อเครื่อง + ตำแหน่งตั้ง |
| Photo Preview | ImageView | รูปที่ถ่ายมา |
| Issue Description | TextField | placeholder: "Describe the issue...", multiline, min 3 lines |
| Voice Input | IconButton | 🎤 กดค้างเพื่อพูด → Voice-to-Text |
| Analyze Button | Button | สีน้ำเงินเข้ม, 🤖, loading: "Analyzing..." |
| Cause Card (xN) | Card | แต่ละใบ: สาเหตุ + Confidence % + วิธีแก้ |
| Confidence Bar | ProgressBar | แสดง % ด้วยสี (เขียว > 70%, เหลือง 40-70%, แดง < 40%) |
| Feedback | ButtonGroup | 👍 Yes / 👎 No → บันทึกเพื่อ Train AI |
| Create Report | Button | สีน้ำเงิน, ไปหน้า Repair Report |
| Spare Parts | Button | outline, ไปหน้า Spare Parts |

| Button | Action | Icon |
|--------|--------|------|
| Analyze Now | POST /api/breakdowns/analyze → แสดงผลลัพธ์ | 🤖 |
| Voice Input | เริ่ม/หยุด voice recording → convert to text | 🎤 |
| 👍 Yes | POST /api/feedback (positive) | 👍 |
| 👎 No | POST /api/feedback (negative) | 👎 |
| Create Report | Navigate to /reports/create?breakdown_id={id} | 📝 |
| Spare Parts | Navigate to /spare-parts?cause={cause_id} | 🔧 |
| Back | Pop navigation stack | ← |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Issue Description | min 10 chars | "กรุณาอธิบายอาการอย่างน้อย 10 ตัวอักษร" |
| Photo | required | "กรุณาแนบรูปภาพ" |

**User Flow:** Scan Machine → ได้ข้อมูลเครื่อง → ถ่ายรูป/พิมพ์อาการ → กด Analyze → แสดงสาเหตุ + วิธีแก้ → เลือกสร้างรายงาน/สั่งอะไหล่

**UX Reason:**
- Confidence Bar ชัดเจน → ช่างรู้ว่าสาเหตุไหนน่าเชื่อถือที่สุด
- Voice Input → สะดวกเมื่อมือเปื้อนน้ำมัน/สวมถุงมือ
- Feedback button → สะสมข้อมูลฝึก AI ให้แม่นขึ้น
- ปุ่ม Create Report + Spare Parts → ไปต่อได้ทันที ไม่ต้องกลับไปหน้าอื่น

---

## 5. Repair Report Screen

```
┌──────────────────────────┐
│  ← Repair Report         │
│──────────────────────────│
│                          │
│  ┌───────┬───────┬──────┐│
│  │ Draft │Active │ Done ││
│  └───────┴───────┴──────┘│
│                          │
│  📋 New Report           │
│                          │
│  Machine: CNC-001        │
│  Cause: Overheating      │
│  Date: 2026-06-28        │
│                          │
│  ┌────────────────────┐  │
│  │ 🔧 Repair Details  │  │
│  │────────────────────│  │
│  │ Action Taken:      │  │
│  │ ┌────────────────┐ │  │
│  │ │ Cleaned cooling│ │  │
│  │ │ fans, replaced │ │  │
│  │ │ thermal paste  │ │  │
│  │ └────────────────┘ │  │
│  │                    │  │
│  │ Time Start:        │  │
│  │ ┌────────────────┐ │  │
│  │ │ 09:00          │ │  │
│  │ └────────────────┘ │  │
│  │                    │  │
│  │ Time End:          │  │
│  │ ┌────────────────┐ │  │
│  │ │ 11:30          │ │  │
│  │ └────────────────┘ │  │
│  │                    │  │
│  │ Duration: 2h 30m   │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🔩 Parts Used      │  │
│  │────────────────────│  │
│  │ □ Thermal Paste x1 │  │
│  │ □ Cooling Fan x1   │  │
│  │ + Add Part         │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📷 Photos          │  │
│  │ [📷] [📷] [+]     │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 💰 Est. Cost:      │  │
│  │ ฿1,250             │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │  📝 Notes          │  │
│  │ ┌────────────────┐ │  │
│  │ │                │ │  │
│  │ └────────────────┘ │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │  💾 Save Draft     │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │  📤 Submit Report  │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Tab Bar | TabBar | Draft / Active / Done — กรองรายงานตามสถานะ |
| Machine Info | Text | ชื่อเครื่อง, สาเหตุ, วันที่ (auto-fill จาก AI) |
| Action Taken | TextField | multiline, placeholder: "Describe repair action..." |
| Time Start | TimePicker | เลือกเวลาเริ่มงาน |
| Time End | TimePicker | เลือกเวลาจบงาน |
| Duration | Text | คำนวณอัตโนมัติ (Time End - Time Start) |
| Parts Used | ListView | checkbox + ชื่ออะไหล่ + จำนวน |
| Add Part | Button | + เพิ่มอะไหล่ |
| Photos | PhotoGrid | แสดงรูปแนบ + ปุ่มเพิ่ม |
| Est. Cost | Text | คำนวณจากอะไหล่ที่เลือก |
| Notes | TextField | multiline, placeholder: "Additional notes..." |
| Save Draft | Button | outline สีเทา |
| Submit | Button | สีน้ำเงินเข้ม |

| Button | Action | Icon |
|--------|--------|------|
| Save Draft | POST /api/reports (status: draft) | 💾 |
| Submit Report | POST /api/reports (status: pending) → ส่งให้ Supervisor | 📤 |
| Add Part | เปิด modal เลือกอะไหล่ | + |
| Add Photo | เปิดกล้อง/Gallery | 📷 |
| Back | Pop navigation stack | ← |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Action Taken | required, min 5 chars | "กรุณากรอกรายละเอียดงาน" |
| Time Start | required | "กรุณาเลือกเวลาเริ่มงาน" |
| Time End | required, > Time Start | "เวลาจบงานต้องมากกว่าเวลาเริ่ม" |

**User Flow:** AI Diagnosis → กด Create Report → หน้า Report (auto-fill จาก AI) → กรอกรายละเอียด → เพิ่มอะไหล่/รูป → Save Draft หรือ Submit → ส่งให้ Supervisor

**UX Reason:**
- Auto-fill จาก AI → ลดงานซ้ำ ช่างแค่ตรวจสอบ
- Duration คำนวณอัตโนมัติ → ไม่ต้องนั่งคำนวณเอง
- Tab Draft/Active/Done → จัดการงานได้ง่าย
- Parts Used checkbox → เลือกง่าย ไม่ต้องพิมพ์ใหม่
- Save Draft → ทำงานได้แม้ยังไม่เสร็จ ( network หาย เป็นต้น)

---

## 6. PM Schedule Screen

```
┌──────────────────────────┐
│  ← PM Schedule           │
│──────────────────────────│
│                          │
│  ┌───────┬───────┬──────┐│
│  │ Upcoming│Due │Done  ││
│  └───────┴───────┴──────┘│
│                          │
│  🔍 Search machine...    │
│                          │
│  ┌────────────────────┐  │
│  │ 🔴 Overdue         │  │
│  │────────────────────│  │
│  │ CNC-003            │  │
│  │ Due: 2026-06-25    │  │
│  │ 3 days overdue     │  │
│  │ [Start PM]         │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🟡 Due Today       │  │
│  │────────────────────│  │
│  │ Press-001          │  │
│  │ Due: 2026-06-28    │  │
│  │ [Start PM]         │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🟢 Upcoming        │  │
│  │────────────────────│  │
│  │ CNC-001            │  │
│  │ Due: 2026-07-05    │  │
│  │ In 7 days          │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 🟢 Upcoming        │  │
│  │────────────────────│  │
│  │ Conveyor-002       │  │
│  │ Due: 2026-07-12    │  │
│  │ In 14 days         │  │
│  └────────────────────┘  │
│                          │
│  ──────────────────────── │
│                          │
│  🏠  📷  📋  📊  👤     │
│  Home Scan  PM  Rpt  Me  │
└──────────────────────────┘
```

| PM Task Card (Expanded) |
|------------------------|
| ``` |
| ┌────────────────────┐  |
| │ CNC-001            │  |
| │ Checklist:         │  |
| │ ☑ Check oil level  │  |
| │ ☑ Clean filters    │  |
| │ ☐ Check belt       │  |
| │ ☐ Lubricate        │  |
| │ ☐ Test run         │  |
| │                    │  |
| │ 📷 Add Photo       │  |
│ │ 📝 Notes: ...      │  |
| │                    │  |
│ │ [Complete PM] ✓    │  |
| └────────────────────┘  |
| ``` |

| Component | Type | Detail |
|-----------|------|--------|
| Tab Bar | TabBar | Upcoming / Due / Done |
| Search | TextField | placeholder: "Search machine...", filter list |
| PM Task Card | Card | สถานะ (🔴🟡🟢) + ชื่อเครื่อง + Due Date |
| Status Badge | Badge | 🔴 Overdue / 🟡 Due Today / 🟢 Upcoming |
| Overdue Card | Card | สีพื้นหลังแดงจาง, แสดงจำนวนวันเกิน |
| Checklist | CheckboxList | ☑/☐ แต่ละรายการ PM |
| Add Photo | Button | 📷 แนบรูป做完 PM |
| Notes | TextField | บันทึกหมายเหตุ |
| Complete PM | Button | สีเขียว, ✓ |

| Button | Action | Icon |
|--------|--------|------|
| Start PM | Expand card → แสดง Checklist | ▼ |
| Complete PM | PUT /api/pm-tasks/:id/complete → Done tab | ✓ |
| Add Photo | เปิดกล้อง/Gallery → แนบรูป | 📷 |
| Search | Filter PM list by machine name | 🔍 |
| Back | Pop navigation stack | ← |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Search | — | — |
| Notes | — (optional) | — |
| Photo | — (optional) | — |

**User Flow:** Dashboard → กด PM tab → เห็นรายการ PM → กด Start PM → ทำ Checklist → เพิ่มรูป/หมายเหตุ → กด Complete PM → เสร็จ

**UX Reason:**
- Status Badge สีสัน → รู้ทันทีว่างานไหนเกินกำหนด
- Overdue สีแดง → ดึงความสนใจ ไม่ลืม
- Checklist format → ทำทีละขั้น ไม่ลืมรายการ
- Tab Upcoming/Due/Done → จัดลำดับความสำคัญ
- Complete button สีเขียว → สื่อถึง "เสร็จแล้ว" ชัดเจน

---

## 7. Machine History Screen

```
┌──────────────────────────┐
│  ← Machine History       │
│──────────────────────────│
│                          │
│  🔍 Search machine...    │
│                          │
│  ┌────────────────────┐  │
│  │ CNC-001            │  │
│  │ Line A-3           │  │
│  │ Status: Active     │  │
│  │ Installed: 2024-01 │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📊 Overview        │  │
│  │────────────────────│  │
│  │ Total Breakdowns: 15│ │
│  │ Total PM: 48       │  │
│  │ MTBF: 45 days      │  │
│  │ MTTR: 2.5 hours    │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📅 Timeline        │  │
│  │────────────────────│  │
│  │                    │  │
│  │ ● 2026-06-28       │  │
│  │ │ Breakdown        │  │
│  │ │ Overheating      │  │
│  │ │ Status: Active   │  │
│  │ │                  │  │
│  │ ● 2026-06-20       │  │
│  │ │ PM Completed     │  │
│  │ │ Routine check    │  │
│  │ │                  │  │
│  │ ● 2026-06-15       │  │
│  │ │ Repair Done      │  │
│  │ │ Belt replaced    │  │
│  │ │ Time: 3 hours    │  │
│  │ │                  │  │
│  │ ● 2026-06-01       │  │
│  │ │ PM Completed     │  │
│  │ │ Oil change       │  │
│  │ │                  │  │
│  │ ● 2026-05-20       │  │
│  │ │ Breakdown        │  │
│  │ │ Motor failure    │  │
│  │ │ Time: 8 hours    │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📋 Spare Parts     │  │
│  │────────────────────│  │
│  │ Thermal Paste x3   │  │
│  │ Belt x2            │  │
│  │ Fan x1             │  │
│  │ Bearing x4         │  │
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ 📤 Export History  │  │
│  └────────────────────┘  │
│                          │
└──────────────────────────┘
```

| Component | Type | Detail |
|-----------|------|--------|
| Search | TextField | placeholder: "Search machine...", auto-suggest |
| Machine Card | Card | ชื่อ, ตำแหน่ง, สถานะ, วันที่ติดตั้ง |
| Overview Card | Card | Total Breakdowns, Total PM, MTBF, MTTR |
| Timeline | ListView | vertical timeline, icon แต่ละ event type |
| Timeline Item | Card | ● dot + วันที่ + ประเภท + รายละเอียด |
| Spare Parts Summary | Card | สรุปอะไหล่ที่เคยใช้ |
| Export Button | Button | outline, ส่งออก PDF/Excel |

| Button | Action | Icon |
|--------|--------|------|
| Search | Filter machine list | 🔍 |
| Machine Card | Expand → แสดง Timeline | ▼ |
| Export | POST /api/machines/:id/export → Download PDF | 📤 |
| Timeline Item | กดดูรายละเอียด Report นั้น | — |
| Back | Pop navigation stack | ← |

| Input | Validation | Error Message |
|-------|-----------|---------------|
| Search | — | — |

**User Flow:** Dashboard → กด History → ค้นหาเครื่อง → เลือกเครื่อง → เห็น Overview + Timeline → กดดูรายละเอียด/Export

**UX Reason:**
- Timeline format → เห็นประวัติเรียงตามเวลา มองเห็น pattern
- MTBF/MTTR → ข้อมูลสำคัญสำหรับตัดสินใจซ่อม/เปลี่ยน
- Overview Card → สรุปข้อมูลเครื่องในที่เดียว
- Export → ส่งให้ผู้บริหาร/เก็บเอกสาร

---

## 8. Component Library Summary

### 8.1 Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Blue | #1E40AF | Button, Link, Active tab |
| Success Green | #059669 | Complete, Overdue resolved |
| Warning Yellow | #D97706 | Due today, Medium priority |
| Error Red | #DC2626 | Overdue, Error, Delete |
| Background | #F3F4F6 | Screen background |
| Card | #FFFFFF | Card background |
| Text Primary | #111827 | Title, Body |
| Text Secondary | #6B7280 | Subtitle, Helper |

### 8.2 Typography

| Type | Size | Weight | Usage |
|------|------|--------|-------|
| H1 | 24px | Bold | Screen title |
| H2 | 20px | SemiBold | Section title |
| H3 | 16px | Medium | Card title |
| Body | 14px | Regular | Content |
| Caption | 12px | Regular | Helper, Timestamp |

### 8.3 Spacing

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon padding |
| sm | 8px | Between elements |
| md | 16px | Card padding |
| lg | 24px | Section gap |
| xl | 32px | Screen margin |

### 8.4 Components

| Component | Variants |
|-----------|----------|
| Button | Primary / Secondary / Outline / Danger |
| Card | Default / Elevation / Outlined |
| TextField | Standard / Outlined / Filled |
| Badge | Success / Warning / Error / Info |
| TabBar | 2 tabs / 3 tabs / Scrollable |
| BottomNav | 5 items |
| Toast | Success / Error / Info |
| Modal | Bottom Sheet / Center Dialog |
| Loading | Spinner / Skeleton / Shimmer |

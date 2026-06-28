# AI Maintenance Assistant - Product Plan

---

## 1. Pain Point Analysis

| # | Pain Point | Current Workaround | Impact | Severity |
|---|-----------|-------------------|--------|----------|
| 1 | วิเคราะห์อาการเสียได้ช้า ต้องรอผู้เชี่ยวชาญ | โทรสอบถาม ค้นคู่มือ纸质 | เครื่องจักรหยุดนาน | High |
| 2 | รายงานซ่อมเขียนมือ ไม่มีมาตรฐาน | กระดาษ/Excel | ข้อมูลสูญหาย ตรวจสอบยาก | High |
| 3 | งาน PM บันทึกไม่สม่ำเสมอ | กระดาษ/ปากกา | ลืมทำ PM ทำให้เครื่องเสียเร็ว | Medium |
| 4 | หาอะไหล่ยาก ไม่รู้รุ่น/หมายเลข | ค้นจากแคตตาล็อก纸质 | สั่งผิดรุ่น เสียเวลา | Medium |
| 5 | ไม่มีประวัติเครื่องจักรรวมศูนย์ | Excel/纸质 | ตัดสินใจผิด ซื้อเครื่องใหม่ไม่คุ้ม | Low |

---

## 2. User Persona

| Persona | ช่างซ่อมบำรุง | วิศวกรโรงงาน | หัวหน้างานซ่อม |
|---------|-------------|--------------|---------------|
| **Age** | 25-45 ปี | 30-50 ปี | 35-55 ปี |
| **Role** | ซ่อม/เปลี่ยนอะไหล่ ตามงาน | วางแผน วิเคราะห์ จัดซื้อ | คุมทีม ตัดสินใจ รายงานผู้บริหาร |
| **Tech Level** | ต่ำ-กลาง (ใช้มือถือเป็น) | กลาง-สูง | กลาง |
| **Pain** | ไม่รู้สาเหตุเสีย ต้องเดา | ข้อมูลกระจาย ต้องรวบรวมเอง | ไม่เห็นภาพรวม รายงานช้า |
| **Goal** | ซ่อมเร็ว ไม่ซ้ำซาก | ลดต้นทุน วางแผนได้แม่น | เห็น dashboard ตัดสินใจเร็ว |
| **Device** | มือถือ Android ราคาไม่แพง | มือถือ/Tablet | Tablet/มือถือ |
| **Usage** | ทุกวัน หน้างานจริง | 3-5 ครั้ง/สัปดาห์ | ทุกวัน ดู dashboard |

---

## 3. Feature Prioritization (MoSCoW)

| # | Feature | Must Have | Should Have | Could Have | Won't Have (MVP) | Effort | Impact |
|---|---------|-----------|-------------|------------|------------------|--------|--------|
| 1 | AI วิเคราะห์อาการเสีย (ถ่ายรูป/พิมพ์) | ✓ | | | | High | High |
| 2 | สร้างรายงานซ่อม (Auto-form) | ✓ | | | | Medium | High |
| 3 | บันทึกงาน PM (Checklist) | ✓ | | | | Low | Medium |
| 4 | แนะนำอะไหล่ (AI + Database) | ✓ | | | | High | Medium |
| 5 | เก็บประวัติเครื่องจักร | ✓ | | | | Medium | Medium |
| 6 | Dashboard สถิติเครื่องจักร | | ✓ | | | Medium | High |
| 7 | Push Notification เตือน PM | | ✓ | | | Low | Medium |
| 8 | ถ่ายรูป/วิดีโอแนบรายงาน | | ✓ | | | Low | Low |
| 9 | Export PDF/Excel | | | ✓ | | Low | Low |
| 10 | Chatbot ถาม-ตอบ (AI) | | | ✓ | | Medium | Medium |
| 11 | Barcode/QR Scan เครื่องจักร | | | ✓ | | Low | Low |
| 12 | Multi-language (EN/TH) | | | ✓ | | Medium | Low |
| 13 | Voice-to-text บันทึกงาน | | | | ✓ | High | Low |
| 14 | AR แสดงอะไหล่/ขั้นตอนซ่อม | | | | ✓ | Very High | Low |
| 15 | Offline Mode เต็มรูปแบบ | | | | ✓ | High | Medium |

---

## 4. MVP Definition

| Component | Detail |
|-----------|--------|
| **Scope** | 5 Features Must Have เท่านั้น |
| **Platform** | iOS + Android (React Native / Flutter) |
| **Backend** | Node.js + PostgreSQL + Firebase Auth |
| **AI Model** | GPT-4 Vision (วิเคราะห์รูป) + GPT-4 Text (แนะนำอะไหล่) |
| **Timeline** | 3 เดือน |
| **Team** | 1 PM, 2 Mobile Dev, 1 Backend, 1 AI Engineer, 1 Designer |
| **Budget Est.** | ฿800,000 - 1,200,000 |

### MVP Feature Breakdown

| Feature | MVP Scope | Not in MVP |
|---------|-----------|------------|
| AI วิเคราะห์ | ถ่ายรูป + พิมพ์อาการ → แสดงสาเหตุ + วิธีแก้ | วิเคราะห์เสียง, วิเคราะห์วิดีโอ |
| รายงานซ่อม | สร้างรายงานอัตโนมัติ ส่งออก PDF | ลายเซ็นดิจิทัล, Approval Flow |
| บันทึก PM | Checklist สำเร็จรูป + Custom | แจ้งเตือน PM, สถิติ PM |
| แนะนำอะไหล่ | แสดงอะไหล่จาก DB + ราคา | สั่งซื้อออนไลน์, เปรียบเทียบราคา |
| ประวัติเครื่องจักร | ดูประวัติซ่อม/PM แต่ละเครื่อง | Dashboard สถิติ, Predictive |

---

## 5. Roadmap 12 เดือน

| Phase | เดือน | Milestone | Features | Success Metric |
|-------|-------|-----------|----------|----------------|
| **Phase 0** | เดือน 1 | Discovery & Design | UX Research, Wireframe, Tech Stack | User Interview 15 คน, Prototype พร้อม |
| **Phase 1** | เดือน 2-3 | MVP Development | 5 Must Have Features | App ใช้งานได้ Beta Test |
| **Phase 2** | เดือน 4 | Beta Launch | เปิดให้ 5-10 โรงงานทดลอง | MAU 50+, NPS > 40 |
| **Phase 3** | เดือน 5-6 | V1.0 Launch | Dashboard + Push Notification + Export | MAU 200+, โรงงาน 20+ |
| **Phase 4** | เดือน 7-9 | V1.5 Growth | Chatbot AI, Barcode Scan, Multi-language | MAU 500+, โรงงาน 50+ |
| **Phase 5** | เดือน 10-11 | V2.0 Scale | Offline Mode, Voice-to-text, API เปิดให้ Partner | MAU 1000+, โรงงาน 100+ |
| **Phase 6** | เดือน 12 | V2.5 Enterprise | AR, Predictive Maintenance, SSO, Multi-plant | ARR ฿5M+, Enterprise Deal 5+ |

---

## 6. Revenue Model (Bonus)

| Tier | Price/Month | Features |
|------|------------|----------|
| **Free** | ฿0 | เครื่องจักร 5 เครื่อง, วิเคราะห์ 10 ครั้ง/เดือน |
| **Pro** | ฿299/เครื่อง | ไม่จำกัดเครื่อง, ไม่จำกัดวิเคราะห์, Dashboard |
| **Enterprise** | ฿999/เครื่อง | ทุกฟีเจอร์ + API + Custom + SSO + Support |

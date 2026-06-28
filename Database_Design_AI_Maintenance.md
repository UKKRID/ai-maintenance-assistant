# AI Maintenance Assistant - Database Design

---

## 1. ER Diagram (Text)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ENTITY RELATIONSHIP DIAGRAM                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
│      USER        │          │     MACHINE      │          │   SPARE_PART     │
├──────────────────┤          ├──────────────────┤          ├──────────────────┤
│ PK user_id       │          │ PK machine_id    │          │ PK part_id       │
│    username      │          │    name          │          │    name          │
│    email         │          │    model         │          │    part_number   │
│    password_hash │          │    serial_number │          │    category      │
│    full_name     │          │    location      │          │    description   │
│    phone         │          │    department    │          │    unit_price    │
│    role          │          │    install_date  │          │    stock_qty     │
│    avatar_url    │          │    status        │          │    min_stock     │
│    is_active     │          │    qr_code       │          │    unit          │
│    created_at    │          │    created_at    │          │    image_url     │
│    updated_at    │          │    updated_at    │          │    is_active     │
└────────┬─────────┘          └────────┬─────────┘          │    created_at    │
         │                             │                     │    updated_at    │
         │                             │                     └────────┬─────────┘
         │ 1                           │ 1                            │
         │                             │                              │
         │ *                           │ *                            │ *
         │                             │                     ┌────────┴─────────┐
         │                             │                     │ REPAIR_SPARE     │
         │                             │                     ├──────────────────┤
         │                             │                     │ PK id            │
         │                             │                     │ FK repair_id     │
         │                             │                     │ FK part_id       │
         │                             │                     │    quantity      │
         │                             │                     │    unit_price    │
         │                             │                     │    total_price   │
         │                             │                     └──────────────────┘
         │                             │
         │                             │ 1
         │                             │
         │                             │ *
┌────────┴─────────┐          ┌────────┴─────────┐
│     REPAIR       │          │   PM_TASK        │
├──────────────────┤          ├──────────────────┤
│ PK repair_id     │          │ PK pm_id         │
│ FK machine_id    │          │ FK machine_id    │
│ FK reporter_id   │          │ FK assigned_to   │
│ FK assigned_to   │          │ FK checklist_id  │
│    title         │          │    title         │
│    description   │          │    description   │
│    priority      │          │    scheduled_date│
│    status        │          │    completed_date│
│    started_at    │          │    status        │
│    completed_at  │          │    notes         │
│    estimated_time│          │    created_at    │
│    actual_time   │          │    updated_at    │
│    estimated_cost│          └────────┬─────────┘
│    actual_cost   │                   │
│    notes         │                   │ *
│    created_at    │          ┌────────┴─────────┐
│    updated_at    │          │ PM_CHECKLIST     │
└────────┬─────────┘          ├──────────────────┤
         │                    │ PK checklist_id  │
         │ *                  │    item_name     │
         │                    │    is_required   │
         │                    │    sort_order    │
         │                    └──────────────────┘
         │
         │ 1
         │
         │ *
┌────────┴─────────┐          ┌──────────────────┐
│  AI_ANALYSIS     │          │    REPORT        │
├──────────────────┤          ├──────────────────┤
│ PK analysis_id   │◄─────────│ PK report_id     │
│ FK repair_id     │          │ FK repair_id     │
│    input_text    │          │ FK created_by    │
│    input_images  │          │ FK approved_by   │
│    ai_response   │          │    title         │
│    confidence    │          │    content       │
│    causes        │          │    status        │
│    solutions     │          │    pdf_url       │
│    estimated_time│          │    approved_at   │
│    estimated_cost│          │    rejected_reason│
│    feedback      │          │    created_at    │
│    model_version │          │    updated_at    │
│    processing_time│         └──────────────────┘
│    created_at    │
└──────────────────┘


RELATIONSHIPS:
═══════════════════════════════════════════════════════════════════════════════

USER (1) ──────────── (*) REPAIR          [reporter_id]
USER (1) ──────────── (*) REPAIR          [assigned_to]
USER (1) ──────────── (*) PM_TASK         [assigned_to]
USER (1) ──────────── (*) REPORT          [created_by]
USER (1) ──────────── (*) REPORT          [approved_by]

MACHINE (1) ────────── (*) REPAIR
MACHINE (1) ────────── (*) PM_TASK

REPAIR (1) ─────────── (*) AI_ANALYSIS
REPAIR (1) ─────────── (1) REPORT
REPAIR (*) ─────────── (*) SPARE_PART     [via REPAIR_SPARE]

PM_TASK (*) ────────── (1) PM_CHECKLIST
```

---

## 2. Table Definitions

### 2.1 USER Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| user_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสผู้ใช้ |
| username | VARCHAR(50) | UNIQUE, NOT NULL | ชื่อผู้ใช้ |
| email | VARCHAR(100) | UNIQUE, NOT NULL | อีเมล |
| password_hash | VARCHAR(255) | NOT NULL | รหัสผ่าน (hash) |
| full_name | VARCHAR(100) | NOT NULL | ชื่อ-นามสกุล |
| phone | VARCHAR(20) | | เบอร์โทรศัพท์ |
| role | ENUM | NOT NULL, DEFAULT 'technician' | ตำแหน่ง |
| avatar_url | VARCHAR(500) | | รูปโปรไฟล์ |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | สถานะการใช้งาน |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

**Role Enum Values:**
- technician
- supervisor
- admin

```sql
CREATE TABLE "user" (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'technician' 
        CHECK (role IN ('technician', 'supervisor', 'admin')),
    avatar_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

### 2.2 MACHINE Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| machine_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสเครื่องจักร |
| name | VARCHAR(100) | NOT NULL | ชื่อเครื่องจักร |
| model | VARCHAR(100) | NOT NULL | รุ่นเครื่องจักร |
| serial_number | VARCHAR(100) | UNIQUE, NOT NULL | หมายเลขเครื่อง |
| location | VARCHAR(200) | NOT NULL | สถานที่ตั้ง |
| department | VARCHAR(100) | | แผนก/สายการผลิต |
| install_date | DATE | NOT NULL | วันที่ติดตั้ง |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'active' | สถานะ |
| qr_code | VARCHAR(500) | | QR Code URL |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

**Status Values:**
- active (ใช้งาน)
- inactive (ไม่ใช้งาน)
- under_repair (กำลังซ่อม)
- disposed (จำหน่ายแล้ว)

```sql
CREATE TABLE machine (
    machine_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    location VARCHAR(200) NOT NULL,
    department VARCHAR(100),
    install_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'under_repair', 'disposed')),
    qr_code VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

### 2.3 REPAIR Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| repair_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสงานซ่อม |
| machine_id | UUID | FK → machine, NOT NULL | เครื่องจักร |
| reporter_id | UUID | FK → user, NOT NULL | ผู้แจ้งงาน |
| assigned_to | UUID | FK → user | ผู้รับผิดชอบ |
| title | VARCHAR(200) | NOT NULL | หัวข้อ |
| description | TEXT | | รายละเอียด |
| priority | VARCHAR(20) | NOT NULL, DEFAULT 'medium' | ความสำคัญ |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'pending' | สถานะ |
| started_at | TIMESTAMP | | เวลาเริ่มงาน |
| completed_at | TIMESTAMP | | เวลาจบงาน |
| estimated_time | INTEGER | | เวลาประมาณ (นาที) |
| actual_time | INTEGER | | เวลาจริง (นาที) |
| estimated_cost | DECIMAL(10,2) | | ค่าใช้จ่ายประมาณ |
| actual_cost | DECIMAL(10,2) | | ค่าใช้จ่ายจริง |
| notes | TEXT | | หมายเหตุ |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

**Priority Values:**
- low
- medium
- high
- critical

**Status Values:**
- pending (รอดำเนินการ)
- in_progress (กำลังดำเนินการ)
- completed (เสร็จแล้ว)
- cancelled (ยกเลิก)

```sql
CREATE TABLE repair (
    repair_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    machine_id UUID NOT NULL REFERENCES machine(machine_id),
    reporter_id UUID NOT NULL REFERENCES "user"(user_id),
    assigned_to UUID REFERENCES "user"(user_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority VARCHAR(20) NOT NULL DEFAULT 'medium'
        CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
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
```

---

### 2.4 PM_TASK Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| pm_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสงาน PM |
| machine_id | UUID | FK → machine, NOT NULL | เครื่องจักร |
| assigned_to | UUID | FK → user | ผู้รับผิดชอบ |
| checklist_id | UUID | FK → pm_checklist | Checklist |
| title | VARCHAR(200) | NOT NULL | หัวข้อ |
| description | TEXT | | รายละเอียด |
| scheduled_date | DATE | NOT NULL | วันที่กำหนด |
| completed_date | DATE | | วันที่ทำเสร็จ |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'scheduled' | สถานะ |
| notes | TEXT | | หมายเหตุ |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

**Status Values:**
- scheduled (กำหนดแล้ว)
- in_progress (กำลังดำเนินการ)
- completed (เสร็จแล้ว)
- overdue (เกินกำหนด)
- cancelled (ยกเลิก)

```sql
CREATE TABLE pm_task (
    pm_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    machine_id UUID NOT NULL REFERENCES machine(machine_id),
    assigned_to UUID REFERENCES "user"(user_id),
    checklist_id UUID REFERENCES pm_checklist(checklist_id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'in_progress', 'completed', 'overdue', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

### 2.5 PM_CHECKLIST Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| checklist_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัส Checklist |
| item_name | VARCHAR(200) | NOT NULL | ชื่อรายการ |
| is_required | BOOLEAN | NOT NULL, DEFAULT TRUE | จำเป็นหรือไม่ |
| sort_order | INTEGER | NOT NULL | ลำดับ |

```sql
CREATE TABLE pm_checklist (
    checklist_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_name VARCHAR(200) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL
);
```

---

### 2.6 SPARE_PART Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| part_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสอะไหล่ |
| name | VARCHAR(100) | NOT NULL | ชื่ออะไหล่ |
| part_number | VARCHAR(100) | UNIQUE, NOT NULL | หมายเลขอะไหล่ |
| category | VARCHAR(50) | | หมวดหมู่ |
| description | TEXT | | รายละเอียด |
| unit_price | DECIMAL(10,2) | NOT NULL | ราคาต่อหน่วย |
| stock_qty | INTEGER | NOT NULL, DEFAULT 0 | จำนวนในคลัง |
| min_stock | INTEGER | NOT NULL, DEFAULT 0 | จำนวนขั้นต่ำ |
| unit | VARCHAR(20) | NOT NULL, DEFAULT 'piece' | หน่วย |
| image_url | VARCHAR(500) | | รูปภาพ |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | สถานะ |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

```sql
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
```

---

### 2.7 REPAIR_SPARE (Junction Table)

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| id | UUID | PK, DEFAULT uuid_generate_v4() | รหัส |
| repair_id | UUID | FK → repair, NOT NULL | งานซ่อม |
| part_id | UUID | FK → spare_part, NOT NULL | อะไหล่ |
| quantity | INTEGER | NOT NULL, DEFAULT 1 | จำนวน |
| unit_price | DECIMAL(10,2) | NOT NULL | ราคาต่อหน่วย (ขณะนั้น) |
| total_price | DECIMAL(10,2) | NOT NULL | ราคารวม |

```sql
CREATE TABLE repair_spare (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_id UUID NOT NULL REFERENCES repair(repair_id),
    part_id UUID NOT NULL REFERENCES spare_part(part_id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);
```

---

### 2.8 AI_ANALYSIS Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| analysis_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสการวิเคราะห์ |
| repair_id | UUID | FK → repair, NOT NULL | งานซ่อม |
| input_text | TEXT | | ข้อความอธิบาย |
| input_images | JSONB | | รูปภาพที่ส่งเข้ามา |
| ai_response | JSONB | NOT NULL | ผลลัพธ์จาก AI |
| confidence | DECIMAL(5,2) | | ความน่าจะเป็นสูงสุด |
| causes | JSONB | | สาเหตุที่เป็นไปได้ |
| solutions | JSONB | | วิธีแก้ไข |
| estimated_time | INTEGER | | เวลาประมาณ (นาที) |
| estimated_cost | DECIMAL(10,2) | | ค่าใช้จ่ายประมาณ |
| feedback | VARCHAR(20) | | ผลตอบรับ |
| model_version | VARCHAR(50) | | เวอร์ชันโมเดล AI |
| processing_time | INTEGER | | เวลาประมวลผล (ms) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |

**Feedback Values:**
- helpful (มีประโยชน์)
- not_helpful (ไม่มีประโยชน์)
- partially_helpful (มีประโยชน์บางส่วน)

```sql
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
```

---

### 2.9 REPORT Table

| Column | Data Type | Constraint | Description |
|--------|-----------|------------|-------------|
| report_id | UUID | PK, DEFAULT uuid_generate_v4() | รหัสรายงาน |
| repair_id | UUID | FK → repair, NOT NULL, UNIQUE | งานซ่อม |
| created_by | UUID | FK → user, NOT NULL | ผู้สร้าง |
| approved_by | UUID | FK → user | ผู้อนุมัติ |
| title | VARCHAR(200) | NOT NULL | หัวข้อ |
| content | TEXT | NOT NULL | เนื้อหา |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'draft' | สถานะ |
| pdf_url | VARCHAR(500) | | ไฟล์ PDF |
| approved_at | TIMESTAMP | | เวลาอนุมัติ |
| rejected_reason | TEXT | | เหตุผลที่ปฏิเสธ |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่สร้าง |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | วันที่แก้ไข |

**Status Values:**
- draft (ฉบับร่าง)
- pending (รอตรวจ)
- approved (อนุมัติ)
- rejected (ปฏิเสธ)

```sql
CREATE TABLE report (
    report_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    repair_id UUID NOT NULL UNIQUE REFERENCES repair(repair_id),
    created_by UUID NOT NULL REFERENCES "user"(user_id),
    approved_by UUID REFERENCES "user"(user_id),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'pending', 'approved', 'rejected')),
    pdf_url VARCHAR(500),
    approved_at TIMESTAMP,
    rejected_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## 3. Relationships Summary

| From Table | To Table | Relationship | FK Column | Description |
|------------|----------|--------------|-----------|-------------|
| repair | machine | Many-to-One | machine_id | งานซ่อมเกี่ยวกับเครื่องจักร |
| repair | user | Many-to-One | reporter_id | ใครแจ้งงาน |
| repair | user | Many-to-One | assigned_to | ใครรับผิดชอบ |
| pm_task | machine | Many-to-One | machine_id | PM ของเครื่องไหน |
| pm_task | user | Many-to-One | assigned_to | ใครรับผิดชอบ PM |
| pm_task | pm_checklist | Many-to-One | checklist_id | ใช้ Checklist ไหน |
| ai_analysis | repair | Many-to-One | repair_id | วิเคราะห์งานไหน |
| report | repair | One-to-One | repair_id | รายงานของงานไหน |
| report | user | Many-to-One | created_by | ใครสร้างรายงาน |
| report | user | Many-to-One | approved_by | ใครอนุมัติ |
| repair_spare | repair | Many-to-One | repair_id | งานซ่อมไหนใช้อะไหล่ |
| repair_spare | spare_part | Many-to-One | part_id | ใช้อะไหล่ไหน |

---

## 4. Indexes

```sql
-- User indexes
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_role ON "user"(role);
CREATE INDEX idx_user_is_active ON "user"(is_active);

-- Machine indexes
CREATE INDEX idx_machine_serial ON machine(serial_number);
CREATE INDEX idx_machine_status ON machine(status);
CREATE INDEX idx_machine_location ON machine(location);
CREATE INDEX idx_machine_department ON machine(department);

-- Repair indexes
CREATE INDEX idx_repair_machine ON repair(machine_id);
CREATE INDEX idx_repair_reporter ON repair(reporter_id);
CREATE INDEX idx_repair_assigned ON repair(assigned_to);
CREATE INDEX idx_repair_status ON repair(status);
CREATE INDEX idx_repair_priority ON repair(priority);
CREATE INDEX idx_repair_created ON repair(created_at);

-- PM Task indexes
CREATE INDEX idx_pm_machine ON pm_task(machine_id);
CREATE INDEX idx_pm_assigned ON pm_task(assigned_to);
CREATE INDEX idx_pm_status ON pm_task(status);
CREATE INDEX idx_pm_scheduled ON pm_task(scheduled_date);

-- Spare Part indexes
CREATE INDEX idx_spare_part_number ON spare_part(part_number);
CREATE INDEX idx_spare_category ON spare_part(category);
CREATE INDEX idx_spare_stock ON spare_part(stock_qty);

-- Repair Spare indexes
CREATE INDEX idx_repair_spare_repair ON repair_spare(repair_id);
CREATE INDEX idx_repair_spare_part ON repair_spare(part_id);

-- AI Analysis indexes
CREATE INDEX idx_ai_repair ON ai_analysis(repair_id);
CREATE INDEX idx_ai_created ON ai_analysis(created_at);

-- Report indexes
CREATE INDEX idx_report_repair ON report(repair_id);
CREATE INDEX idx_report_created ON report(created_by);
CREATE INDEX idx_report_status ON report(status);
```

---

## 5. Sample Queries

### 5.1 Dashboard Summary

```sql
-- จำนวนงานตามสถานะ
SELECT 
    status,
    COUNT(*) as count
FROM repair
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY status;

-- MTBF (Mean Time Between Failures)
SELECT 
    machine_id,
    AVG(time_between_failures) as mtbf
FROM (
    SELECT 
        machine_id,
        LAG(completed_at) OVER (PARTITION BY machine_id ORDER BY completed_at) as prev_completed,
        completed_at - LAG(completed_at) OVER (PARTITION BY machine_id ORDER BY completed_at) as time_between_failures
    FROM repair
    WHERE status = 'completed'
) sub
WHERE time_between_failures IS NOT NULL
GROUP BY machine_id;
```

### 5.2 Machine History

```sql
-- ประวัติเครื่องจักร
SELECT 
    r.repair_id,
    r.title,
    r.status,
    r.priority,
    r.created_at,
    r.completed_at,
    u.full_name as assigned_to
FROM repair r
LEFT JOIN "user" u ON r.assigned_to = u.user_id
WHERE r.machine_id = :machine_id
ORDER BY r.created_at DESC;
```

### 5.3 AI Analysis History

```sql
-- ประวัติการวิเคราะห์ AI
SELECT 
    a.analysis_id,
    a.input_text,
    a.confidence,
    a.causes,
    a.solutions,
    a.feedback,
    a.created_at
FROM ai_analysis a
JOIN repair r ON a.repair_id = r.repair_id
WHERE r.machine_id = :machine_id
ORDER BY a.created_at DESC;
```

### 5.4 Spare Parts Low Stock

```sql
-- อะไหล่ใกล้หมด
SELECT 
    part_id,
    name,
    part_number,
    stock_qty,
    min_stock
FROM spare_part
WHERE stock_qty <= min_stock
AND is_active = TRUE
ORDER BY stock_qty ASC;
```

### 5.5 PM Schedule

```sql
-- ตาราง PM ที่ต้องทำ
SELECT 
    p.pm_id,
    p.title,
    p.scheduled_date,
    p.status,
    m.name as machine_name,
    m.location
FROM pm_task p
JOIN machine m ON p.machine_id = m.machine_id
WHERE p.scheduled_date >= CURRENT_DATE
AND p.status IN ('scheduled', 'overdue')
ORDER BY p.scheduled_date ASC;
```

---

## 6. Triggers

### 6.1 Auto-update updated_at

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_updated_at BEFORE UPDATE ON "user"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_machine_updated_at BEFORE UPDATE ON machine
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_repair_updated_at BEFORE UPDATE ON repair
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pm_task_updated_at BEFORE UPDATE ON pm_task
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_spare_part_updated_at BEFORE UPDATE ON spare_part
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_report_updated_at BEFORE UPDATE ON report
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 6.2 Auto-update PM Status to Overdue

```sql
CREATE OR REPLACE FUNCTION check_pm_overdue()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.scheduled_date < CURRENT_DATE AND NEW.status = 'scheduled' THEN
        NEW.status = 'overdue';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER check_pm_overdue_trigger BEFORE INSERT OR UPDATE ON pm_task
    FOR EACH ROW EXECUTE FUNCTION check_pm_overdue();
```

### 6.3 Update Stock on Repair

```sql
CREATE OR REPLACE FUNCTION update_stock_on_repair()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE spare_part
    SET stock_qty = stock_qty - NEW.quantity
    WHERE part_id = NEW.part_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_stock_trigger AFTER INSERT ON repair_spare
    FOR EACH ROW EXECUTE FUNCTION update_stock_on_repair();
```

---

## 7. Views

### 7.1 Repair Summary View

```sql
CREATE VIEW v_repair_summary AS
SELECT 
    r.repair_id,
    r.title,
    r.priority,
    r.status,
    m.name as machine_name,
    m.serial_number,
    m.location,
    u.full_name as assigned_to,
    r.created_at,
    r.completed_at,
    r.actual_time,
    r.actual_cost
FROM repair r
JOIN machine m ON r.machine_id = m.machine_id
LEFT JOIN "user" u ON r.assigned_to = u.user_id;
```

### 7.2 PM Schedule View

```sql
CREATE VIEW v_pm_schedule AS
SELECT 
    p.pm_id,
    p.title,
    p.scheduled_date,
    p.status,
    m.name as machine_name,
    m.serial_number,
    m.location,
    u.full_name as assigned_to
FROM pm_task p
JOIN machine m ON p.machine_id = m.machine_id
LEFT JOIN "user" u ON p.assigned_to = u.user_id;
```

### 7.3 Spare Parts Status View

```sql
CREATE VIEW v_spare_parts_status AS
SELECT 
    part_id,
    name,
    part_number,
    category,
    stock_qty,
    min_stock,
    unit_price,
    CASE 
        WHEN stock_qty = 0 THEN 'out_of_stock'
        WHEN stock_qty <= min_stock THEN 'low_stock'
        ELSE 'in_stock'
    END as stock_status
FROM spare_part
WHERE is_active = TRUE;
```

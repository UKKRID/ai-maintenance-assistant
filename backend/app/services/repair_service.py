from typing import Optional
from datetime import datetime, timezone
import uuid

from app.schemas.repair import RepairCreate, RepairUpdateStatus, RepairAssign, RepairComplete


# Mock database
repairs_db = {}

# Mock related data
machines_mock = {
    "machine-001": {"machine_id": "machine-001", "name": "Motor Pump A", "model": "ABC-123"},
    "machine-002": {"machine_id": "machine-002", "name": "Conveyor Belt B", "model": "XYZ-456"},
}

users_mock = {
    "user-001": {"user_id": "user-001", "full_name": "Somchai Jaidee"},
    "user-002": {"user_id": "user-002", "full_name": "Somkid Rakngan"},
}


class RepairService:
    def __init__(self):
        self._init_demo_repairs()

    def _init_demo_repairs(self):
        now = datetime.now(timezone.utc)
        demo_repairs = [
            {
                "repair_id": str(uuid.uuid4()),
                "machine_id": "machine-001",
                "reporter_id": "user-001",
                "assigned_to": "user-002",
                "title": "Motor Bearing Wear",
                "description": "Motor making loud noise, bearing needs replacement",
                "priority": "high",
                "status": "in_progress",
                "started_at": now,
                "completed_at": None,
                "estimated_time": 120,
                "actual_time": None,
                "estimated_cost": 2500.00,
                "actual_cost": None,
                "notes": None,
                "created_at": now,
                "updated_at": now,
            },
            {
                "repair_id": str(uuid.uuid4()),
                "machine_id": "machine-002",
                "reporter_id": "user-001",
                "assigned_to": None,
                "title": "Belt Misalignment",
                "description": "Conveyor belt running off track",
                "priority": "medium",
                "status": "pending",
                "started_at": None,
                "completed_at": None,
                "estimated_time": 60,
                "actual_time": None,
                "estimated_cost": 800.00,
                "actual_cost": None,
                "notes": None,
                "created_at": now,
                "updated_at": now,
            },
        ]
        for repair in demo_repairs:
            repairs_db[repair["repair_id"]] = repair

    async def get_repairs(
        self,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        machine_id: Optional[str] = None,
        assigned_to: Optional[str] = None,
    ) -> dict:
        repairs = list(repairs_db.values())

        # Filter by search
        if search:
            search_lower = search.lower()
            repairs = [
                r for r in repairs
                if search_lower in r["title"].lower()
                or (r["description"] and search_lower in r["description"].lower())
            ]

        # Filter by status
        if status:
            repairs = [r for r in repairs if r["status"] == status]

        # Filter by priority
        if priority:
            repairs = [r for r in repairs if r["priority"] == priority]

        # Filter by machine
        if machine_id:
            repairs = [r for r in repairs if r["machine_id"] == machine_id]

        # Filter by assigned
        if assigned_to:
            repairs = [r for r in repairs if r["assigned_to"] == assigned_to]

        # Sort by created_at descending
        repairs.sort(key=lambda x: x["created_at"], reverse=True)

        # Pagination
        total = len(repairs)
        start = (page - 1) * limit
        end = start + limit
        items = repairs[start:end]

        # Enrich with related data
        enriched_items = []
        for r in items:
            enriched = r.copy()
            machine = machines_mock.get(r["machine_id"], {})
            enriched["machine_name"] = machine.get("name")
            enriched["machine_model"] = machine.get("model")
            reporter = users_mock.get(r["reporter_id"], {})
            enriched["reporter_name"] = reporter.get("full_name")
            if r["assigned_to"]:
                assignee = users_mock.get(r["assigned_to"], {})
                enriched["assigned_name"] = assignee.get("full_name")
            enriched_items.append(enriched)

        return {
            "items": enriched_items,
            "total": total,
            "page": page,
            "limit": limit,
        }

    async def get_repair_by_id(self, repair_id: str) -> Optional[dict]:
        repair = repairs_db.get(repair_id)
        if not repair:
            return None

        enriched = repair.copy()
        machine = machines_mock.get(repair["machine_id"], {})
        enriched["machine_name"] = machine.get("name")
        enriched["machine_model"] = machine.get("model")
        reporter = users_mock.get(repair["reporter_id"], {})
        enriched["reporter_name"] = reporter.get("full_name")
        if repair["assigned_to"]:
            assignee = users_mock.get(repair["assigned_to"], {})
            enriched["assigned_name"] = assignee.get("full_name")
        return enriched

    async def create_repair(self, data: RepairCreate, reporter_id: str) -> dict:
        now = datetime.now(timezone.utc)
        new_repair = {
            "repair_id": str(uuid.uuid4()),
            "machine_id": data.machine_id,
            "reporter_id": reporter_id,
            "assigned_to": None,
            "title": data.title,
            "description": data.description,
            "priority": data.priority.value,
            "status": "pending",
            "started_at": None,
            "completed_at": None,
            "estimated_time": data.estimated_time,
            "actual_time": None,
            "estimated_cost": data.estimated_cost,
            "actual_cost": None,
            "notes": data.notes,
            "created_at": now,
            "updated_at": now,
        }

        repairs_db[new_repair["repair_id"]] = new_repair

        # Enrich
        enriched = new_repair.copy()
        machine = machines_mock.get(data.machine_id, {})
        enriched["machine_name"] = machine.get("name")
        enriched["machine_model"] = machine.get("model")
        reporter = users_mock.get(reporter_id, {})
        enriched["reporter_name"] = reporter.get("full_name")
        return enriched

    async def assign_repair(self, repair_id: str, data: RepairAssign) -> dict:
        repair = repairs_db.get(repair_id)
        if not repair:
            raise ValueError("ไม่พบงานซ่อม")

        repair["assigned_to"] = data.assigned_to
        repair["updated_at"] = datetime.now(timezone.utc)

        enriched = repair.copy()
        assignee = users_mock.get(data.assigned_to, {})
        enriched["assigned_name"] = assignee.get("full_name")
        return enriched

    async def update_status(self, repair_id: str, data: RepairUpdateStatus) -> dict:
        repair = repairs_db.get(repair_id)
        if not repair:
            raise ValueError("ไม่พบงานซ่อม")

        old_status = repair["status"]
        repair["status"] = data.status.value
        repair["updated_at"] = datetime.now(timezone.utc)

        # Handle status transitions
        if data.status.value == "in_progress" and old_status == "pending":
            repair["started_at"] = datetime.now(timezone.utc)
        elif data.status.value == "completed":
            repair["completed_at"] = datetime.now(timezone.utc)
        elif data.status.value == "cancelled":
            repair["completed_at"] = datetime.now(timezone.utc)

        if data.notes:
            repair["notes"] = data.notes

        return repair

    async def complete_repair(self, repair_id: str, data: RepairComplete) -> dict:
        repair = repairs_db.get(repair_id)
        if not repair:
            raise ValueError("ไม่พบงานซ่อม")

        now = datetime.now(timezone.utc)
        repair["status"] = "completed"
        repair["completed_at"] = now
        repair["actual_time"] = data.actual_time
        repair["actual_cost"] = data.actual_cost
        repair["updated_at"] = now

        if data.notes:
            repair["notes"] = data.notes

        # Calculate actual time if started
        if repair["started_at"] and not data.actual_time:
            delta = now - repair["started_at"]
            repair["actual_time"] = int(delta.total_seconds() / 60)

        return repair


repair_service = RepairService()

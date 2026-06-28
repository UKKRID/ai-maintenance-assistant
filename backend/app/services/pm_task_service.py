from typing import Optional, List
from datetime import datetime, timezone, date
import uuid

from app.schemas.pm_task import (
    PMTaskCreate,
    PMTaskUpdate,
    PMTaskComplete,
    ChecklistItemCreate,
    ChecklistItemUpdate
)


# Mock database
pm_tasks_db = {}
pm_checklist_db = {}

# Mock related data
machines_mock = {
    "machine-001": {"machine_id": "machine-001", "name": "Motor Pump A", "model": "ABC-123"},
    "machine-002": {"machine_id": "machine-002", "name": "Conveyor Belt B", "model": "XYZ-456"},
    "machine-003": {"machine_id": "machine-003", "name": "CNC Machine C", "model": "DEF-789"},
}

users_mock = {
    "user-001": {"user_id": "user-001", "full_name": "Somchai Jaidee"},
    "user-002": {"user_id": "user-002", "full_name": "Somkid Rakngan"},
}


class PMTaskService:
    def __init__(self):
        self._init_demo_data()

    def _init_demo_data(self):
        now = datetime.now(timezone.utc)
        today = date.today()

        # Demo checklists
        checklist_ids = []
        for i in range(3):
            cl_id = str(uuid.uuid4())
            checklist_ids.append(cl_id)
            items = [
                {"checklist_id": str(uuid.uuid4()), "pm_id": None, "item_name": "Check oil level", "is_required": True, "is_completed": False, "sort_order": 1, "completed_at": None},
                {"checklist_id": str(uuid.uuid4()), "pm_id": None, "item_name": "Clean filters", "is_required": True, "is_completed": False, "sort_order": 2, "completed_at": None},
                {"checklist_id": str(uuid.uuid4()), "pm_id": None, "item_name": "Inspect belts", "is_required": False, "is_completed": False, "sort_order": 3, "completed_at": None},
            ]
            pm_checklist_db[cl_id] = items

        # Demo PM tasks
        demo_tasks = [
            {
                "pm_id": str(uuid.uuid4()),
                "machine_id": "machine-001",
                "assigned_to": "user-001",
                "checklist_id": checklist_ids[0],
                "title": "Monthly Oil Change",
                "description": "Change engine oil and filter",
                "scheduled_date": today,
                "completed_date": None,
                "status": "scheduled",
                "notes": None,
                "created_at": now,
                "updated_at": now,
            },
            {
                "pm_id": str(uuid.uuid4()),
                "machine_id": "machine-002",
                "assigned_to": "user-002",
                "checklist_id": checklist_ids[1],
                "title": "Weekly Belt Inspection",
                "description": "Check belt tension and alignment",
                "scheduled_date": today,
                "completed_date": None,
                "status": "in_progress",
                "notes": None,
                "created_at": now,
                "updated_at": now,
            },
            {
                "pm_id": str(uuid.uuid4()),
                "machine_id": "machine-003",
                "assigned_to": "user-001",
                "checklist_id": checklist_ids[2],
                "title": "Quarterly Calibration",
                "description": "Calibrate CNC machine",
                "scheduled_date": date(2026, 6, 15),
                "completed_date": None,
                "status": "overdue",
                "notes": "Overdue by 2 weeks",
                "created_at": now,
                "updated_at": now,
            },
            {
                "pm_id": str(uuid.uuid4()),
                "machine_id": "machine-001",
                "assigned_to": "user-002",
                "checklist_id": checklist_ids[0],
                "title": "Monthly Oil Change",
                "description": "Change engine oil and filter",
                "scheduled_date": date(2026, 5, 28),
                "completed_date": date(2026, 5, 28),
                "status": "completed",
                "notes": "Completed on time",
                "created_at": now,
                "updated_at": now,
            },
        ]

        for task in demo_tasks:
            pm_tasks_db[task["pm_id"]] = task
            # Update checklist pm_id
            if task["checklist_id"] and task["checklist_id"] in pm_checklist_db:
                for item in pm_checklist_db[task["checklist_id"]]:
                    item["pm_id"] = task["pm_id"]

    async def get_pm_tasks(
        self,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None,
        status: Optional[str] = None,
        machine_id: Optional[str] = None,
        assigned_to: Optional[str] = None,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
    ) -> dict:
        tasks = list(pm_tasks_db.values())

        # Filter by search
        if search:
            search_lower = search.lower()
            tasks = [t for t in tasks if search_lower in t["title"].lower()]

        # Filter by status
        if status:
            tasks = [t for t in tasks if t["status"] == status]

        # Filter by machine
        if machine_id:
            tasks = [t for t in tasks if t["machine_id"] == machine_id]

        # Filter by assigned
        if assigned_to:
            tasks = [t for t in tasks if t["assigned_to"] == assigned_to]

        # Filter by date range
        if start_date:
            tasks = [t for t in tasks if t["scheduled_date"] >= start_date]
        if end_date:
            tasks = [t for t in tasks if t["scheduled_date"] <= end_date]

        # Sort by scheduled_date
        tasks.sort(key=lambda x: x["scheduled_date"])

        # Pagination
        total = len(tasks)
        start = (page - 1) * limit
        end = start + limit
        items = tasks[start:end]

        # Enrich with related data
        enriched_items = []
        for t in items:
            enriched = self._enrich_task(t)
            enriched_items.append(enriched)

        return {
            "items": enriched_items,
            "total": total,
            "page": page,
            "limit": limit,
        }

    async def get_pm_task_by_id(self, pm_id: str) -> Optional[dict]:
        task = pm_tasks_db.get(pm_id)
        if not task:
            return None
        return self._enrich_task(task)

    async def create_pm_task(self, data: PMTaskCreate) -> dict:
        now = datetime.now(timezone.utc)
        pm_id = str(uuid.uuid4())

        new_task = {
            "pm_id": pm_id,
            "machine_id": data.machine_id,
            "assigned_to": data.assigned_to,
            "checklist_id": None,
            "title": data.title,
            "description": data.description,
            "scheduled_date": data.scheduled_date,
            "completed_date": None,
            "status": "scheduled",
            "notes": data.notes,
            "created_at": now,
            "updated_at": now,
        }

        # Create checklist if provided
        if data.checklist:
            checklist_id = str(uuid.uuid4())
            new_task["checklist_id"] = checklist_id
            checklist_items = []
            for i, item in enumerate(data.checklist):
                checklist_items.append({
                    "checklist_id": str(uuid.uuid4()),
                    "pm_id": pm_id,
                    "item_name": item.item_name,
                    "is_required": item.is_required,
                    "is_completed": False,
                    "sort_order": item.sort_order,
                    "completed_at": None,
                })
            pm_checklist_db[checklist_id] = checklist_items

        pm_tasks_db[pm_id] = new_task
        return self._enrich_task(new_task)

    async def update_pm_task(self, pm_id: str, data: PMTaskUpdate) -> dict:
        task = pm_tasks_db.get(pm_id)
        if not task:
            raise ValueError("ไม่พบงาน PM")

        if data.title is not None:
            task["title"] = data.title
        if data.description is not None:
            task["description"] = data.description
        if data.scheduled_date is not None:
            task["scheduled_date"] = data.scheduled_date
        if data.assigned_to is not None:
            task["assigned_to"] = data.assigned_to
        if data.status is not None:
            task["status"] = data.status.value
        if data.notes is not None:
            task["notes"] = data.notes

        task["updated_at"] = datetime.now(timezone.utc)
        return self._enrich_task(task)

    async def complete_pm_task(self, pm_id: str, data: PMTaskComplete) -> dict:
        task = pm_tasks_db.get(pm_id)
        if not task:
            raise ValueError("ไม่พบงาน PM")

        task["status"] = "completed"
        task["completed_date"] = data.completed_date or date.today()
        task["updated_at"] = datetime.now(timezone.utc)

        if data.notes:
            task["notes"] = data.notes

        # Mark all checklist items as completed
        if task["checklist_id"] and task["checklist_id"] in pm_checklist_db:
            for item in pm_checklist_db[task["checklist_id"]]:
                item["is_completed"] = True
                item["completed_at"] = datetime.now(timezone.utc)

        return self._enrich_task(task)

    async def update_checklist_item(
        self,
        pm_id: str,
        checklist_id: str,
        item_id: str,
        data: ChecklistItemUpdate
    ) -> dict:
        task = pm_tasks_db.get(pm_id)
        if not task:
            raise ValueError("ไม่พบงาน PM")

        if task["checklist_id"] != checklist_id:
            raise ValueError("Checklist ไม่ตรงกับงาน PM")

        items = pm_checklist_db.get(checklist_id, [])
        for item in items:
            if item["checklist_id"] == item_id:
                item["is_completed"] = data.is_completed
                if data.is_completed:
                    item["completed_at"] = datetime.now(timezone.utc)
                else:
                    item["completed_at"] = None
                break
        else:
            raise ValueError("ไม่พบรายการ Checklist")

        return self._enrich_task(task)

    async def delete_pm_task(self, pm_id: str) -> bool:
        if pm_id in pm_tasks_db:
            task = pm_tasks_db[pm_id]
            if task["checklist_id"] and task["checklist_id"] in pm_checklist_db:
                del pm_checklist_db[task["checklist_id"]]
            del pm_tasks_db[pm_id]
            return True
        return False

    def _enrich_task(self, task: dict) -> dict:
        enriched = task.copy()

        # Add machine info
        machine = machines_mock.get(task["machine_id"], {})
        enriched["machine_name"] = machine.get("name")
        enriched["machine_model"] = machine.get("model")

        # Add assigned user info
        if task["assigned_to"]:
            user = users_mock.get(task["assigned_to"], {})
            enriched["assigned_name"] = user.get("full_name")

        # Add checklist
        checklist = []
        if task["checklist_id"] and task["checklist_id"] in pm_checklist_db:
            checklist = pm_checklist_db[task["checklist_id"]]
        enriched["checklist"] = checklist

        # Calculate checklist progress
        if checklist:
            total = len(checklist)
            completed = sum(1 for item in checklist if item["is_completed"])
            enriched["checklist_progress"] = {
                "total": total,
                "completed": completed,
                "percentage": round((completed / total) * 100) if total > 0 else 0
            }
        else:
            enriched["checklist_progress"] = {"total": 0, "completed": 0, "percentage": 0}

        return enriched


pm_task_service = PMTaskService()

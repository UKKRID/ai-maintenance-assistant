from typing import Optional, List
from datetime import datetime, timezone
import uuid

from app.schemas.machine import MachineCreate, MachineUpdate


# Mock database (in real app, use SQLAlchemy)
machines_db = {}


class MachineService:
    def __init__(self):
        self._init_demo_machines()

    def _init_demo_machines(self):
        demo_machines = [
            {
                "machine_id": str(uuid.uuid4()),
                "name": "Motor Pump A",
                "model": "ABC-123",
                "serial_number": "MP-001",
                "location": "Building 1, Floor 2",
                "department": "Production",
                "install_date": "2024-01-15",
                "status": "active",
                "qr_code": None,
                "image_url": None,
                "created_at": datetime.now(timezone.utc),
                "updated_at": datetime.now(timezone.utc)
            },
            {
                "machine_id": str(uuid.uuid4()),
                "name": "Conveyor Belt B",
                "model": "XYZ-456",
                "serial_number": "CB-002",
                "location": "Building 2, Floor 1",
                "department": "Packaging",
                "install_date": "2023-06-20",
                "status": "active",
                "qr_code": None,
                "image_url": None,
                "created_at": datetime.now(timezone.utc),
                "updated_at": datetime.now(timezone.utc)
            },
            {
                "machine_id": str(uuid.uuid4()),
                "name": "CNC Machine C",
                "model": "DEF-789",
                "serial_number": "CNC-003",
                "location": "Building 1, Floor 3",
                "department": "Machining",
                "install_date": "2022-03-10",
                "status": "under_repair",
                "qr_code": None,
                "image_url": None,
                "created_at": datetime.now(timezone.utc),
                "updated_at": datetime.now(timezone.utc)
            }
        ]
        for machine in demo_machines:
            machines_db[machine["serial_number"]] = machine

    async def get_machines(
        self,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None,
        status: Optional[str] = None,
        department: Optional[str] = None
    ) -> dict:
        machines = list(machines_db.values())

        # Filter by search
        if search:
            search_lower = search.lower()
            machines = [
                m for m in machines
                if search_lower in m["name"].lower()
                or search_lower in m["model"].lower()
                or search_lower in m["serial_number"].lower()
            ]

        # Filter by status
        if status:
            machines = [m for m in machines if m["status"] == status]

        # Filter by department
        if department:
            machines = [m for m in machines if m["department"] == department]

        # Pagination
        total = len(machines)
        start = (page - 1) * limit
        end = start + limit
        items = machines[start:end]

        return {
            "items": items,
            "total": total,
            "page": page,
            "limit": limit
        }

    async def get_machine_by_id(self, machine_id: str) -> Optional[dict]:
        for machine in machines_db.values():
            if machine["machine_id"] == machine_id:
                return machine
        return None

    async def get_machine_by_serial(self, serial_number: str) -> Optional[dict]:
        return machines_db.get(serial_number)

    async def create_machine(self, data: MachineCreate) -> dict:
        # Check if serial_number exists
        if data.serial_number in machines_db:
            raise ValueError("Serial Number นี้ถูกใช้แล้ว")

        now = datetime.now(timezone.utc)
        new_machine = {
            "machine_id": str(uuid.uuid4()),
            "name": data.name,
            "model": data.model,
            "serial_number": data.serial_number,
            "location": data.location,
            "department": data.department,
            "install_date": str(data.install_date),
            "status": data.status.value,
            "qr_code": None,
            "image_url": data.image_url,
            "created_at": now,
            "updated_at": now
        }

        machines_db[data.serial_number] = new_machine
        return new_machine

    async def update_machine(self, machine_id: str, data: MachineUpdate) -> dict:
        # Find machine
        machine = None
        for m in machines_db.values():
            if m["machine_id"] == machine_id:
                machine = m
                break

        if not machine:
            raise ValueError("ไม่พบเครื่องจักร")

        # Check if serial_number exists (if updating)
        if data.serial_number and data.serial_number != machine["serial_number"]:
            if data.serial_number in machines_db:
                raise ValueError("Serial Number นี้ถูกใช้แล้ว")
            # Remove old entry and add new one
            old_serial = machine["serial_number"]
            del machines_db[old_serial]
            machine["serial_number"] = data.serial_number

        # Update fields
        if data.name is not None:
            machine["name"] = data.name
        if data.model is not None:
            machine["model"] = data.model
        if data.location is not None:
            machine["location"] = data.location
        if data.department is not None:
            machine["department"] = data.department
        if data.install_date is not None:
            machine["install_date"] = str(data.install_date)
        if data.status is not None:
            machine["status"] = data.status.value
        if data.image_url is not None:
            machine["image_url"] = data.image_url

        machine["updated_at"] = datetime.now(timezone.utc)

        # Save back
        machines_db[machine["serial_number"]] = machine
        return machine

    async def delete_machine(self, machine_id: str) -> bool:
        # Find and delete
        for serial, machine in machines_db.items():
            if machine["machine_id"] == machine_id:
                del machines_db[serial]
                return True
        return False


machine_service = MachineService()

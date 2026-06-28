from typing import Optional
from datetime import datetime, timezone
import uuid

from app.schemas.spare_part import SparePartCreate, SparePartUpdate, StockUpdate


# Mock database
spare_parts_db = {}
repair_spare_db = []


class SparePartService:
    def __init__(self):
        self._init_demo_data()

    def _init_demo_data(self):
        now = datetime.now(timezone.utc)
        demo_parts = [
            {
                "part_id": str(uuid.uuid4()),
                "name": "Bearing 6205-2RS",
                "part_number": "BRG-6205-2RS",
                "category": "Bearing",
                "description": "Deep groove ball bearing",
                "unit_price": 850.00,
                "stock_qty": 12,
                "min_stock": 5,
                "unit": "piece",
                "image_url": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "part_id": str(uuid.uuid4()),
                "name": "V-Belt A-68",
                "part_number": "BLT-A68",
                "category": "Belt",
                "description": "V-belt for conveyor",
                "unit_price": 450.00,
                "stock_qty": 3,
                "min_stock": 5,
                "unit": "piece",
                "image_url": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "part_id": str(uuid.uuid4()),
                "name": "Engine Oil 10W-40",
                "part_number": "OIL-10W40",
                "category": "Lubricant",
                "description": "Synthetic engine oil 4L",
                "unit_price": 1200.00,
                "stock_qty": 0,
                "min_stock": 10,
                "unit": "bottle",
                "image_url": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "part_id": str(uuid.uuid4()),
                "name": "Oil Filter OF-123",
                "part_number": "FLT-OF123",
                "category": "Filter",
                "description": "Oil filter for motor",
                "unit_price": 350.00,
                "stock_qty": 20,
                "min_stock": 10,
                "unit": "piece",
                "image_url": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
            {
                "part_id": str(uuid.uuid4()),
                "name": "Mechanical Seal MS-100",
                "part_number": "SEL-MS100",
                "category": "Seal",
                "description": "Mechanical seal for pump",
                "unit_price": 2500.00,
                "stock_qty": 2,
                "min_stock": 3,
                "unit": "piece",
                "image_url": None,
                "is_active": True,
                "created_at": now,
                "updated_at": now,
            },
        ]
        for part in demo_parts:
            spare_parts_db[part["part_number"]] = part

    async def get_spare_parts(
        self,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None,
        category: Optional[str] = None,
        low_stock: Optional[bool] = None,
        is_active: Optional[bool] = None,
    ) -> dict:
        parts = list(spare_parts_db.values())

        if search:
            search_lower = search.lower()
            parts = [p for p in parts if search_lower in p["name"].lower() or search_lower in p["part_number"].lower()]

        if category:
            parts = [p for p in parts if p["category"] == category]

        if low_stock:
            parts = [p for p in parts if p["stock_qty"] <= p["min_stock"]]

        if is_active is not None:
            parts = [p for p in parts if p["is_active"] == is_active]

        total = len(parts)
        start = (page - 1) * limit
        end = start + limit
        items = parts[start:end]

        enriched = [self._enrich_part(p) for p in items]
        return {"items": enriched, "total": total, "page": page, "limit": limit}

    async def get_spare_part_by_id(self, part_id: str) -> Optional[dict]:
        for part in spare_parts_db.values():
            if part["part_id"] == part_id:
                return self._enrich_part(part)
        return None

    async def get_spare_part_by_number(self, part_number: str) -> Optional[dict]:
        part = spare_parts_db.get(part_number)
        if part:
            return self._enrich_part(part)
        return None

    async def create_spare_part(self, data: SparePartCreate) -> dict:
        if data.part_number in spare_parts_db:
            raise ValueError("Part Number นี้ถูกใช้แล้ว")

        now = datetime.now(timezone.utc)
        new_part = {
            "part_id": str(uuid.uuid4()),
            "name": data.name,
            "part_number": data.part_number,
            "category": data.category,
            "description": data.description,
            "unit_price": data.unit_price,
            "stock_qty": data.stock_qty,
            "min_stock": data.min_stock,
            "unit": data.unit,
            "image_url": data.image_url,
            "is_active": True,
            "created_at": now,
            "updated_at": now,
        }
        spare_parts_db[data.part_number] = new_part
        return self._enrich_part(new_part)

    async def update_spare_part(self, part_id: str, data: SparePartUpdate) -> dict:
        part = None
        for p in spare_parts_db.values():
            if p["part_id"] == part_id:
                part = p
                break

        if not part:
            raise ValueError("ไม่พบอะไหล่")

        if data.part_number and data.part_number != part["part_number"]:
            if data.part_number in spare_parts_db:
                raise ValueError("Part Number นี้ถูกใช้แล้ว")
            old_number = part["part_number"]
            del spare_parts_db[old_number]
            part["part_number"] = data.part_number

        if data.name is not None: part["name"] = data.name
        if data.category is not None: part["category"] = data.category
        if data.description is not None: part["description"] = data.description
        if data.unit_price is not None: part["unit_price"] = data.unit_price
        if data.stock_qty is not None: part["stock_qty"] = data.stock_qty
        if data.min_stock is not None: part["min_stock"] = data.min_stock
        if data.unit is not None: part["unit"] = data.unit
        if data.image_url is not None: part["image_url"] = data.image_url
        if data.is_active is not None: part["is_active"] = data.is_active

        part["updated_at"] = datetime.now(timezone.utc)
        spare_parts_db[part["part_number"]] = part
        return self._enrich_part(part)

    async def update_stock(self, part_id: str, data: StockUpdate) -> dict:
        part = None
        for p in spare_parts_db.values():
            if p["part_id"] == part_id:
                part = p
                break

        if not part:
            raise ValueError("ไม่พบอะไหล่")

        new_qty = part["stock_qty"] + data.quantity
        if new_qty < 0:
            raise ValueError("จำนวนในคลังไม่พอ")

        part["stock_qty"] = new_qty
        part["updated_at"] = datetime.now(timezone.utc)
        return self._enrich_part(part)

    async def delete_spare_part(self, part_id: str) -> bool:
        for part_number, part in spare_parts_db.items():
            if part["part_id"] == part_id:
                del spare_parts_db[part_number]
                return True
        return False

    async def get_stock_summary(self) -> dict:
        parts = list(spare_parts_db.values())
        total_parts = len(parts)
        total_value = sum(p["stock_qty"] * p["unit_price"] for p in parts)
        low_stock_count = sum(1 for p in parts if p["stock_qty"] <= p["min_stock"] and p["stock_qty"] > 0)
        out_of_stock_count = sum(1 for p in parts if p["stock_qty"] == 0)

        return {
            "total_parts": total_parts,
            "total_value": float(total_value),
            "low_stock_count": low_stock_count,
            "out_of_stock_count": out_of_stock_count,
        }

    def _enrich_part(self, part: dict) -> dict:
        enriched = part.copy()
        enriched["stock_status"] = self._get_stock_status(part)
        enriched["total_value"] = float(part["stock_qty"] * part["unit_price"])
        return enriched

    def _get_stock_status(self, part: dict) -> str:
        if part["stock_qty"] == 0:
            return "out_of_stock"
        elif part["stock_qty"] <= part["min_stock"]:
            return "low_stock"
        else:
            return "in_stock"


spare_part_service = SparePartService()

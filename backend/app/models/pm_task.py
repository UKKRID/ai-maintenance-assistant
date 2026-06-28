from sqlalchemy import Column, String, DateTime, Text, Date, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timezone
import uuid

from app.database import Base


class PMTask(Base):
    __tablename__ = "pm_task"

    pm_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    machine_id = Column(UUID(as_uuid=True), nullable=False)
    assigned_to = Column(UUID(as_uuid=True))
    checklist_id = Column(UUID(as_uuid=True))
    title = Column(String(200), nullable=False)
    description = Column(Text)
    scheduled_date = Column(Date, nullable=False)
    completed_date = Column(Date)
    status = Column(String(20), nullable=False, default="scheduled")
    notes = Column(Text)
    created_at = Column(DateTime, nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class PMChecklist(Base):
    __tablename__ = "pm_checklist"

    checklist_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pm_id = Column(UUID(as_uuid=True), nullable=False)
    item_name = Column(String(200), nullable=False)
    is_required = Column(Boolean, nullable=False, default=True)
    is_completed = Column(Boolean, nullable=False, default=False)
    sort_order = Column(Integer, nullable=False)
    completed_at = Column(DateTime)

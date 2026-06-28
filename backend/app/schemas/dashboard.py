from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class RepairStatusChart(BaseModel):
    status: str
    count: int
    percentage: float


class MonthlyCostChart(BaseModel):
    month: str
    year: int
    total_cost: float
    repair_count: int


class PMStatusChart(BaseModel):
    status: str
    count: int
    percentage: float


class TopIssue(BaseModel):
    issue: str
    count: int
    percentage: float


class DepartmentCost(BaseModel):
    department: str
    cost: float
    percentage: float


class MachineHealth(BaseModel):
    machine_id: str
    machine_name: str
    status: str
    last_repair_date: Optional[datetime] = None
    repair_count: int
    health_score: float


class RecentActivity(BaseModel):
    activity_id: str
    activity_type: str
    title: str
    description: Optional[str] = None
    timestamp: datetime
    user_name: Optional[str] = None


class DashboardSummaryResponse(BaseModel):
    total_machines: int
    active_machines: int
    total_repairs: int
    pending_repairs: int
    in_progress_repairs: int
    completed_repairs: int
    total_pm_tasks: int
    overdue_pm_tasks: int
    completed_pm_tasks: int
    total_spare_parts: int
    low_stock_parts: int
    out_of_stock_parts: int
    total_repair_cost: float
    total_spare_part_value: float
    mtbf_days: float
    mttr_hours: float
    recent_activities: List[RecentActivity]
    top_issues: List[TopIssue]


class DashboardAnalyticsResponse(BaseModel):
    period: str
    start_date: str
    end_date: str
    repair_status_chart: List[RepairStatusChart]
    monthly_cost_chart: List[MonthlyCostChart]
    pm_status_chart: List[PMStatusChart]
    top_issues: List[TopIssue]
    department_costs: List[DepartmentCost]
    machine_health: List[MachineHealth]
    total_repairs: int
    total_cost: float
    average_mttr: float
    average_mtbf: float

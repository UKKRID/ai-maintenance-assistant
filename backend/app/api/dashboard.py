from fastapi import APIRouter, Header, Query
from typing import Optional

from app.schemas.dashboard import (
    DashboardSummaryResponse,
    DashboardAnalyticsResponse,
    RepairStatusChart,
    MonthlyCostChart,
    PMStatusChart,
    TopIssue,
    DepartmentCost,
    MachineHealth,
    RecentActivity
)
from app.services.dashboard_service import dashboard_service
from app.utils.security import get_current_user_id

router = APIRouter()


def get_current_user(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        from fastapi import HTTPException
        raise HTTPException(status_code=401, detail="ไม่มี Token")
    token = authorization.replace("Bearer ", "")
    email = get_current_user_id(token)
    if not email:
        from fastapi import HTTPException
        raise HTTPException(status_code=401, detail="Token ไม่ถูกต้อง")
    return email


@router.get("/summary", response_model=DashboardSummaryResponse)
async def get_dashboard_summary(authorization: Optional[str] = Header(None)):
    """
    ดูสรุป Dashboard

    - **total_machines**: จำนวนเครื่องจักรทั้งหมด
    - **active_machines**: เครื่องจักรที่ใช้งาน
    - **total_repairs**: งานซ่อมทั้งหมด
    - **pending_repairs**: งานซ่อมที่รอ
    - **in_progress_repairs**: งานซ่อมที่กำลังทำ
    - **completed_repairs**: งานซ่อมที่เสร็จแล้ว
    - **total_pm_tasks**: งาน PM ทั้งหมด
    - **overdue_pm_tasks**: งาน PM ที่เกินกำหนด
    - **completed_pm_tasks**: งาน PM ที่เสร็จแล้ว
    - **total_spare_parts**: อะไหล่ทั้งหมด
    - **low_stock_parts**: อะไหล่ใกล้หมด
    - **out_of_stock_parts**: อะไหล่หมด
    - **total_repair_cost**: ต้นทุนการซ่อมทั้งหมด
    - **total_spare_part_value**: มูลค่าอะไหล่ทั้งหมด
    - **mtbf_days**: Mean Time Between Failures
    - **mttr_hours**: Mean Time To Repair
    - **recent_activities**: กิจกรรมล่าสุด
    - **top_issues**: ปัญหาที่พบบ่อย
    """
    get_current_user(authorization)

    machines = dashboard_service.get_total_machines()
    repairs = dashboard_service.get_total_repairs()
    cost = dashboard_service.get_total_cost()
    upcoming_pm = dashboard_service.get_upcoming_pm()

    return DashboardSummaryResponse(
        total_machines=machines["total"],
        active_machines=machines["active"],
        total_repairs=repairs["total"],
        pending_repairs=repairs["pending"],
        in_progress_repairs=repairs["in_progress"],
        completed_repairs=repairs["completed"],
        total_pm_tasks=len(upcoming_pm) + 10,
        overdue_pm_tasks=2,
        completed_pm_tasks=5,
        total_spare_parts=15,
        low_stock_parts=3,
        out_of_stock_parts=1,
        total_repair_cost=cost["total_repair_cost"],
        total_spare_part_value=125000.00,
        mtbf_days=45.0,
        mttr_hours=2.5,
        recent_activities=[],
        top_issues=[
            {"issue": "Bearing Wear", "count": 5, "percentage": 35.0},
            {"issue": "Belt Misalignment", "count": 3, "percentage": 21.0},
            {"issue": "Motor Overload", "count": 2, "percentage": 14.0},
        ]
    )


@router.get("/analytics", response_model=DashboardAnalyticsResponse)
async def get_dashboard_analytics(
    period: str = Query("month", regex="^(day|week|month|year)$"),
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """
    ดู Analytics Dashboard

    - **period**: ช่วงเวลา (day/week/month/year)
    - **start_date**: วันที่เริ่มต้น (optional)
    - **end_date**: วันที่สิ้นสุด (optional)
    """
    get_current_user(authorization)

    repair_chart = dashboard_service.repair_status_chart()
    monthly_cost = dashboard_service.monthly_cost_chart()
    pm_chart = dashboard_service.pm_status_chart()
    repairs = dashboard_service.get_total_repairs()

    return DashboardAnalyticsResponse(
        period=period,
        start_date=start_date or "2026-01-01",
        end_date=end_date or "2026-12-31",
        repair_status_chart=[RepairStatusChart(**c) for c in repair_chart],
        monthly_cost_chart=[MonthlyCostChart(**c) for c in monthly_cost],
        pm_status_chart=[PMStatusChart(**c) for c in pm_chart],
        top_issues=[
            TopIssue(issue="Bearing Wear", count=5, percentage=35.0),
            TopIssue(issue="Belt Misalignment", count=3, percentage=21.0),
            TopIssue(issue="Motor Overload", count=2, percentage=14.0),
        ],
        department_costs=[
            DepartmentCost(department="Production", cost=15000.00, percentage=60.0),
            DepartmentCost(department="Packaging", cost=7500.00, percentage=30.0),
            DepartmentCost(department="Machining", cost=2500.00, percentage=10.0),
        ],
        machine_health=[
            MachineHealth(
                machine_id="machine-001", machine_name="Motor Pump A",
                status="active", repair_count=3, health_score=85.0
            ),
            MachineHealth(
                machine_id="machine-002", machine_name="Conveyor Belt B",
                status="active", repair_count=2, health_score=90.0
            ),
        ],
        total_repairs=repairs["total"],
        total_cost=25000.00,
        average_mttr=2.5,
        average_mtbf=45.0,
    )

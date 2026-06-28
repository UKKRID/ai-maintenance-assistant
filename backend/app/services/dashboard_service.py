from datetime import datetime, timezone, date, timedelta
from typing import Optional, List
from collections import defaultdict

from app.services.machine_service import machines_db
from app.services.repair_service import repairs_db
from app.services.pm_task_service import pm_tasks_db


class DashboardService:
    def __init__(self):
        pass

    def get_total_machines(self) -> dict:
        total = len(machines_db)
        active = sum(1 for m in machines_db.values() if m["status"] == "active")
        inactive = sum(1 for m in machines_db.values() if m["status"] == "inactive")
        under_repair = sum(1 for m in machines_db.values() if m["status"] == "under_repair")
        disposed = sum(1 for m in machines_db.values() if m["status"] == "disposed")

        return {
            "total": total,
            "active": active,
            "inactive": inactive,
            "under_repair": under_repair,
            "disposed": disposed,
        }

    def get_total_repairs(self) -> dict:
        total = len(repairs_db)
        pending = sum(1 for r in repairs_db.values() if r["status"] == "pending")
        in_progress = sum(1 for r in repairs_db.values() if r["status"] == "in_progress")
        completed = sum(1 for r in repairs_db.values() if r["status"] == "completed")
        cancelled = sum(1 for r in repairs_db.values() if r["status"] == "cancelled")

        return {
            "total": total,
            "pending": pending,
            "in_progress": in_progress,
            "completed": completed,
            "cancelled": cancelled,
        }

    def get_pending_repairs(self) -> List[dict]:
        pending = [r for r in repairs_db.values() if r["status"] == "pending"]
        pending.sort(key=lambda x: x["created_at"], reverse=True)
        return pending[:10]

    def get_upcoming_pm(self, days: int = 7) -> List[dict]:
        today = date.today()
        end_date = today + timedelta(days=days)

        upcoming = []
        for task in pm_tasks_db.values():
            scheduled = task["scheduled_date"]
            if isinstance(scheduled, str):
                scheduled = date.fromisoformat(scheduled)

            if today <= scheduled <= end_date and task["status"] in ["scheduled", "overdue"]:
                upcoming.append(task)

        upcoming.sort(key=lambda x: x["scheduled_date"])
        return upcoming[:10]

    def get_total_cost(self) -> dict:
        repair_cost = 0.0
        for r in repairs_db.values():
            if r["actual_cost"]:
                repair_cost += float(r["actual_cost"])
            elif r["estimated_cost"]:
                repair_cost += float(r["estimated_cost"])

        return {
            "total_repair_cost": repair_cost,
            "average_repair_cost": repair_cost / len(repairs_db) if repairs_db else 0,
            "cost_by_status": {
                "in_progress": sum(float(r.get("estimated_cost", 0) or 0) for r in repairs_db.values() if r["status"] == "in_progress"),
                "completed": sum(float(r.get("actual_cost", 0) or r.get("estimated_cost", 0) or 0) for r in repairs_db.values() if r["status"] == "completed"),
                "pending": sum(float(r.get("estimated_cost", 0) or 0) for r in repairs_db.values() if r["status"] == "pending"),
            }
        }

    def get_dashboard_summary(self) -> dict:
        machines = self.get_total_machines()
        repairs = self.get_total_repairs()
        cost = self.get_total_cost()
        upcoming_pm = self.get_upcoming_pm()
        pending_repairs = self.get_pending_repairs()

        total_repair_time = 0
        completed_count = 0
        for r in repairs_db.values():
            if r["status"] == "completed" and r["actual_time"]:
                total_repair_time += r["actual_time"]
                completed_count += 1

        mttr = total_repair_time / completed_count if completed_count > 0 else 0

        return {
            "machines": machines,
            "repairs": repairs,
            "cost": cost,
            "upcoming_pm_count": len(upcoming_pm),
            "upcoming_pm": upcoming_pm,
            "pending_repairs_count": len(pending_repairs),
            "pending_repairs": pending_repairs,
            "average_mttr_minutes": round(mttr, 2),
        }

    def repair_status_chart(self) -> List[dict]:
        """
        SQLAlchemy Query:
            SELECT status, COUNT(*) as count
            FROM repair
            GROUP BY status
        """
        status_counts = defaultdict(int)
        for r in repairs_db.values():
            status_counts[r["status"]] += 1

        total = len(repairs_db) if repairs_db else 1
        chart_data = []

        for status in ["pending", "in_progress", "completed", "cancelled"]:
            count = status_counts.get(status, 0)
            chart_data.append({
                "status": status,
                "count": count,
                "percentage": round((count / total) * 100, 2)
            })

        return chart_data

    def monthly_cost_chart(self, months: int = 6) -> List[dict]:
        """
        SQLAlchemy Query:
            SELECT 
                EXTRACT(MONTH FROM created_at) as month,
                EXTRACT(YEAR FROM created_at) as year,
                SUM(COALESCE(actual_cost, estimated_cost, 0)) as total_cost,
                COUNT(*) as repair_count
            FROM repair
            WHERE created_at >= NOW() - INTERVAL '6 months'
            GROUP BY year, month
            ORDER BY year, month
        """
        monthly_data = defaultdict(lambda: {"cost": 0.0, "count": 0})

        for r in repairs_db.values():
            created = r["created_at"]
            if isinstance(created, str):
                created = datetime.fromisoformat(created)

            month_key = created.strftime("%Y-%m")
            cost = float(r.get("actual_cost") or r.get("estimated_cost") or 0)
            monthly_data[month_key]["cost"] += cost
            monthly_data[month_key]["count"] += 1

        chart_data = []
        today = date.today()

        for i in range(months - 1, -1, -1):
            target_date = today - timedelta(days=i * 30)
            month_key = target_date.strftime("%Y-%m")
            month_name = target_date.strftime("%b")
            year = target_date.year

            data = monthly_data.get(month_key, {"cost": 0.0, "count": 0})
            chart_data.append({
                "month": month_name,
                "year": year,
                "total_cost": round(data["cost"], 2),
                "repair_count": data["count"]
            })

        return chart_data

    def pm_status_chart(self) -> List[dict]:
        """
        SQLAlchemy Query:
            SELECT status, COUNT(*) as count
            FROM pm_task
            GROUP BY status
        """
        status_counts = defaultdict(int)
        for t in pm_tasks_db.values():
            status_counts[t["status"]] += 1

        total = len(pm_tasks_db) if pm_tasks_db else 1
        chart_data = []

        for status in ["scheduled", "in_progress", "completed", "overdue", "cancelled"]:
            count = status_counts.get(status, 0)
            chart_data.append({
                "status": status,
                "count": count,
                "percentage": round((count / total) * 100, 2)
            })

        return chart_data


dashboard_service = DashboardService()

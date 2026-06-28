import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def get_auth_header():
    response = client.post(
        "/api/auth/login",
        json={"email": "demo@example.com", "password": "password123"}
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_get_pm_tasks():
    headers = get_auth_header()
    response = client.get("/api/pm-tasks", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert data["total"] >= 3


def test_get_pm_tasks_with_status():
    headers = get_auth_header()
    response = client.get("/api/pm-tasks?status=scheduled", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert all(t["status"] == "scheduled" for t in data["items"])


def test_get_pm_task_by_id():
    headers = get_auth_header()
    list_response = client.get("/api/pm-tasks", headers=headers)
    pm_id = list_response.json()["items"][0]["pm_id"]
    response = client.get(f"/api/pm-tasks/{pm_id}", headers=headers)
    assert response.status_code == 200
    assert response.json()["pm_id"] == pm_id


def test_get_pm_task_not_found():
    headers = get_auth_header()
    response = client.get("/api/pm-tasks/nonexistent", headers=headers)
    assert response.status_code == 404


def test_create_pm_task():
    headers = get_auth_header()
    response = client.post(
        "/api/pm-tasks",
        headers=headers,
        json={
            "machine_id": "machine-001",
            "title": "Test PM Task",
            "description": "Test description",
            "scheduled_date": "2026-07-01",
            "checklist": [
                {"item_name": "Check item 1", "is_required": True, "sort_order": 1},
                {"item_name": "Check item 2", "is_required": False, "sort_order": 2}
            ]
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test PM Task"
    assert len(data["checklist"]) == 2


def test_update_pm_task():
    headers = get_auth_header()
    list_response = client.get("/api/pm-tasks?status=scheduled", headers=headers)
    if list_response.json()["items"]:
        pm_id = list_response.json()["items"][0]["pm_id"]
        response = client.put(
            f"/api/pm-tasks/{pm_id}",
            headers=headers,
            json={"title": "Updated PM Task"}
        )
        assert response.status_code == 200
        assert response.json()["title"] == "Updated PM Task"


def test_update_checklist_item():
    headers = get_auth_header()
    list_response = client.get("/api/pm-tasks", headers=headers)
    task = list_response.json()["items"][0]
    if task["checklist"]:
        checklist = task["checklist"][0]
        response = client.put(
            f"/api/pm-tasks/{task['pm_id']}/checklist/{checklist['checklist_id']}/{checklist['checklist_id']}",
            headers=headers,
            json={"is_completed": True}
        )
        assert response.status_code == 200


def test_complete_pm_task():
    headers = get_auth_header()
    list_response = client.get("/api/pm-tasks?status=scheduled", headers=headers)
    if list_response.json()["items"]:
        pm_id = list_response.json()["items"][0]["pm_id"]
        response = client.put(
            f"/api/pm-tasks/{pm_id}/complete",
            headers=headers,
            json={"notes": "Completed test"}
        )
        assert response.status_code == 200
        assert response.json()["status"] == "completed"


def test_delete_pm_task():
    headers = get_auth_header()
    # Create first
    create_response = client.post(
        "/api/pm-tasks",
        headers=headers,
        json={
            "machine_id": "machine-001",
            "title": "To Delete",
            "scheduled_date": "2026-07-01"
        }
    )
    pm_id = create_response.json()["pm_id"]

    # Then delete
    response = client.delete(f"/api/pm-tasks/{pm_id}", headers=headers)
    assert response.status_code == 200


def test_get_pm_tasks_without_auth():
    response = client.get("/api/pm-tasks")
    assert response.status_code == 401

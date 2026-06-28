import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def get_auth_header():
    """Helper to get auth header"""
    response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "password123"
        }
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_get_repairs():
    headers = get_auth_header()
    response = client.get("/api/repairs", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert data["total"] >= 2  # Demo repairs


def test_get_repairs_with_status():
    headers = get_auth_header()
    response = client.get("/api/repairs?status=pending", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert all(r["status"] == "pending" for r in data["items"])


def test_get_repairs_with_priority():
    headers = get_auth_header()
    response = client.get("/api/repairs?priority=high", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert all(r["priority"] == "high" for r in data["items"])


def test_get_repair_by_id():
    headers = get_auth_header()
    # First get list
    list_response = client.get("/api/repairs", headers=headers)
    repair_id = list_response.json()["items"][0]["repair_id"]

    # Then get by id
    response = client.get(f"/api/repairs/{repair_id}", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["repair_id"] == repair_id


def test_get_repair_not_found():
    headers = get_auth_header()
    response = client.get("/api/repairs/nonexistent-id", headers=headers)
    assert response.status_code == 404


def test_create_repair():
    headers = get_auth_header()
    response = client.post(
        "/api/repairs",
        headers=headers,
        json={
            "machine_id": "machine-001",
            "title": "Test Repair",
            "description": "Test description",
            "priority": "medium",
            "estimated_time": 60,
            "estimated_cost": 1000.00,
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Repair"
    assert data["status"] == "pending"


def test_assign_repair():
    headers = get_auth_header()
    # First get list
    list_response = client.get("/api/repairs?status=pending", headers=headers)
    if list_response.json()["items"]:
        repair_id = list_response.json()["items"][0]["repair_id"]

        response = client.put(
            f"/api/repairs/{repair_id}/assign",
            headers=headers,
            json={"assigned_to": "user-002"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["assigned_to"] == "user-002"


def test_update_status():
    headers = get_auth_header()
    # First get list
    list_response = client.get("/api/repairs?status=pending", headers=headers)
    if list_response.json()["items"]:
        repair_id = list_response.json()["items"][0]["repair_id"]

        response = client.put(
            f"/api/repairs/{repair_id}/status",
            headers=headers,
            json={"status": "in_progress", "notes": "Starting work"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "in_progress"
        assert data["started_at"] is not None


def test_complete_repair():
    headers = get_auth_header()
    # First get an in_progress repair
    list_response = client.get("/api/repairs?status=in_progress", headers=headers)
    if list_response.json()["items"]:
        repair_id = list_response.json()["items"][0]["repair_id"]

        response = client.put(
            f"/api/repairs/{repair_id}/complete",
            headers=headers,
            json={
                "actual_time": 90,
                "actual_cost": 2200.00,
                "notes": "Completed successfully"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "completed"
        assert data["completed_at"] is not None


def test_get_repairs_without_auth():
    response = client.get("/api/repairs")
    assert response.status_code == 401

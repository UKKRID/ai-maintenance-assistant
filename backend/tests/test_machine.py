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


def test_get_machines():
    headers = get_auth_header()
    response = client.get("/api/machines", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert data["total"] >= 3  # Demo machines


def test_get_machines_with_search():
    headers = get_auth_header()
    response = client.get("/api/machines?search=Motor", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["total"] >= 1


def test_get_machines_with_status():
    headers = get_auth_header()
    response = client.get("/api/machines?status=active", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert all(m["status"] == "active" for m in data["items"])


def test_get_machine_by_id():
    headers = get_auth_header()
    # First get list
    list_response = client.get("/api/machines", headers=headers)
    machine_id = list_response.json()["items"][0]["machine_id"]

    # Then get by id
    response = client.get(f"/api/machines/{machine_id}", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["machine_id"] == machine_id


def test_get_machine_not_found():
    headers = get_auth_header()
    response = client.get("/api/machines/nonexistent-id", headers=headers)
    assert response.status_code == 404


def test_create_machine():
    headers = get_auth_header()
    response = client.post(
        "/api/machines",
        headers=headers,
        json={
            "name": "Test Machine",
            "model": "TEST-001",
            "serial_number": "TEST-SN-001",
            "location": "Test Location",
            "department": "Test Dept",
            "install_date": "2026-01-01",
            "status": "active"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Machine"
    assert data["serial_number"] == "TEST-SN-001"


def test_create_machine_duplicate_serial():
    headers = get_auth_header()
    response = client.post(
        "/api/machines",
        headers=headers,
        json={
            "name": "Duplicate Machine",
            "model": "DUP-001",
            "serial_number": "MP-001",  # Already exists
            "location": "Test Location",
            "install_date": "2026-01-01"
        }
    )
    assert response.status_code == 400


def test_update_machine():
    headers = get_auth_header()
    # First get list
    list_response = client.get("/api/machines", headers=headers)
    machine_id = list_response.json()["items"][0]["machine_id"]

    # Then update
    response = client.put(
        f"/api/machines/{machine_id}",
        headers=headers,
        json={
            "name": "Updated Machine Name"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated Machine Name"


def test_delete_machine():
    headers = get_auth_header()
    # First create
    create_response = client.post(
        "/api/machines",
        headers=headers,
        json={
            "name": "To Delete",
            "model": "DEL-001",
            "serial_number": "DELETE-SN-001",
            "location": "Test",
            "install_date": "2026-01-01"
        }
    )
    machine_id = create_response.json()["machine_id"]

    # Then delete
    response = client.delete(f"/api/machines/{machine_id}", headers=headers)
    assert response.status_code == 200

    # Verify deleted
    get_response = client.get(f"/api/machines/{machine_id}", headers=headers)
    assert get_response.status_code == 404


def test_get_machines_without_auth():
    response = client.get("/api/machines")
    assert response.status_code == 401

import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def get_auth_header():
    response = client.post("/api/auth/login", json={"email": "demo@example.com", "password": "password123"})
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_get_spare_parts():
    headers = get_auth_header()
    response = client.get("/api/spare-parts", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert data["total"] >= 5


def test_get_spare_parts_with_search():
    headers = get_auth_header()
    response = client.get("/api/spare-parts?search=Bearing", headers=headers)
    assert response.status_code == 200


def test_get_spare_parts_low_stock():
    headers = get_auth_header()
    response = client.get("/api/spare-parts?low_stock=true", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert all(p["stock_qty"] <= p["min_stock"] for p in data["items"])


def test_get_stock_summary():
    headers = get_auth_header()
    response = client.get("/api/spare-parts/stock-summary", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "total_parts" in data
    assert "total_value" in data


def test_get_spare_part_by_id():
    headers = get_auth_header()
    list_response = client.get("/api/spare-parts", headers=headers)
    part_id = list_response.json()["items"][0]["part_id"]
    response = client.get(f"/api/spare-parts/{part_id}", headers=headers)
    assert response.status_code == 200
    assert response.json()["part_id"] == part_id


def test_get_spare_part_not_found():
    headers = get_auth_header()
    response = client.get("/api/spare-parts/nonexistent", headers=headers)
    assert response.status_code == 404


def test_create_spare_part():
    headers = get_auth_header()
    response = client.post("/api/spare-parts", headers=headers, json={
        "name": "Test Part", "part_number": "TEST-001", "unit_price": 100.00, "stock_qty": 10, "min_stock": 5
    })
    assert response.status_code == 201
    assert response.json()["name"] == "Test Part"


def test_create_spare_part_duplicate():
    headers = get_auth_header()
    response = client.post("/api/spare-parts", headers=headers, json={
        "name": "Duplicate", "part_number": "BRG-6205-2RS", "unit_price": 100.00
    })
    assert response.status_code == 400


def test_update_spare_part():
    headers = get_auth_header()
    list_response = client.get("/api/spare-parts", headers=headers)
    part_id = list_response.json()["items"][0]["part_id"]
    response = client.put(f"/api/spare-parts/{part_id}", headers=headers, json={"name": "Updated Part"})
    assert response.status_code == 200
    assert response.json()["name"] == "Updated Part"


def test_update_stock():
    headers = get_auth_header()
    list_response = client.get("/api/spare-parts", headers=headers)
    part_id = list_response.json()["items"][0]["part_id"]
    response = client.put(f"/api/spare-parts/{part_id}/stock", headers=headers, json={"quantity": 5})
    assert response.status_code == 200


def test_update_stock_negative():
    headers = get_auth_header()
    list_response = client.get("/api/spare-parts", headers=headers)
    part_id = list_response.json()["items"][0]["part_id"]
    response = client.put(f"/api/spare-parts/{part_id}/stock", headers=headers, json={"quantity": -1000})
    assert response.status_code == 400


def test_delete_spare_part():
    headers = get_auth_header()
    create_response = client.post("/api/spare-parts", headers=headers, json={
        "name": "To Delete", "part_number": "DEL-001", "unit_price": 50.00
    })
    part_id = create_response.json()["part_id"]
    response = client.delete(f"/api/spare-parts/{part_id}", headers=headers)
    assert response.status_code == 200


def test_get_spare_parts_without_auth():
    response = client.get("/api/spare-parts")
    assert response.status_code == 401

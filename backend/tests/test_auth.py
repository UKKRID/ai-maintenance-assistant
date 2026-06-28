import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_login_success():
    response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "password123"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert "user" in data
    assert data["user"]["email"] == "demo@example.com"


def test_login_wrong_password():
    response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "wrongpassword"
        }
    )
    assert response.status_code == 401


def test_login_nonexistent_user():
    response = client.post(
        "/api/auth/login",
        json={
            "email": "nonexistent@example.com",
            "password": "password123"
        }
    )
    assert response.status_code == 401


def test_register_success():
    response = client.post(
        "/api/auth/register",
        json={
            "email": "newuser@test.com",
            "password": "test1234",
            "full_name": "New User",
            "phone": "0899999999"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "newuser@test.com"
    assert data["user"]["full_name"] == "New User"


def test_register_duplicate_email():
    response = client.post(
        "/api/auth/register",
        json={
            "email": "demo@example.com",
            "password": "test1234",
            "full_name": "Duplicate User"
        }
    )
    assert response.status_code == 400


def test_refresh_token():
    # First login
    login_response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "password123"
        }
    )
    refresh_token = login_response.json()["refresh_token"]

    # Then refresh
    response = client.post(
        "/api/auth/refresh",
        json={
            "refresh_token": refresh_token
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data


def test_get_me():
    # First login
    login_response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "password123"
        }
    )
    access_token = login_response.json()["access_token"]

    # Then get me
    response = client.get(
        "/api/auth/me",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "demo@example.com"


def test_get_me_without_token():
    response = client.get("/api/auth/me")
    assert response.status_code == 401


def test_logout():
    # First login
    login_response = client.post(
        "/api/auth/login",
        json={
            "email": "demo@example.com",
            "password": "password123"
        }
    )
    access_token = login_response.json()["access_token"]

    # Then logout
    response = client.post(
        "/api/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "ออกจากระบบสำเร็จ"

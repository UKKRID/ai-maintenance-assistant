import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "AI Maintenance Assistant API" in data["message"]


def test_analyze_breakdown():
    response = client.post(
        "/api/ai/analyze",
        json={
            "machine_id": "machine-001",
            "input_text": "Motor making loud noise and vibrating"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "analysis_id" in data
    assert "causes" in data
    assert "confidence" in data


def test_get_analysis():
    # First create an analysis
    create_response = client.post(
        "/api/ai/analyze",
        json={
            "machine_id": "machine-001",
            "input_text": "Test issue"
        }
    )
    analysis_id = create_response.json()["analysis_id"]

    # Then get it
    response = client.get(f"/api/ai/analysis/{analysis_id}")
    assert response.status_code == 200


def test_submit_feedback():
    response = client.post(
        "/api/ai/feedback",
        json={
            "analysis_id": "test-analysis-id",
            "feedback": "helpful",
            "notes": "Very accurate"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["feedback"] == "helpful"

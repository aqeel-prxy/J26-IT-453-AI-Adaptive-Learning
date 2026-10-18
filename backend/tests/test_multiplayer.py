import sys
import os
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app

client = TestClient(app)


def test_student_multiplayer_lifecycle():
    # 1. Create a Student Peer Room
    create_payload = {
        "room_type": "STUDENT_PEER",
        "host_id": "stu_host_123",
        "host_name": "Kavindu",
        "host_avatar": "fox_math",
        "topic": "Quadratic Equations",
        "question_count": 3,
        "time_per_question": 15
    }
    res = client.post("/api/v1/multiplayer/create", json=create_payload)
    assert res.status_code == 200
    room_data = res.json()
    pin = room_data["pin"]
    assert len(pin) >= 4
    assert room_data["room_type"] == "STUDENT_PEER"
    assert room_data["status"] == "LOBBY"
    assert len(room_data["players"]) == 1

    # 2. Another student joins via PIN
    join_payload = {
        "pin": pin,
        "player_id": "stu_join_456",
        "player_name": "Sahan",
        "player_avatar": "owl_scholar"
    }
    res_join = client.post("/api/v1/multiplayer/join", json=join_payload)
    assert res_join.status_code == 200
    assert len(res_join.json()["players"]) == 2

    # 3. Add a bot peer
    res_bot = client.post(f"/api/v1/multiplayer/add-bot/{pin}")
    assert res_bot.status_code == 200
    assert len(res_bot.json()["players"]) == 3

    # 4. Start the match
    res_start = client.post(f"/api/v1/multiplayer/start/{pin}")
    assert res_start.status_code == 200
    started_data = res_start.json()
    assert started_data["status"] == "IN_PROGRESS"
    assert started_data["current_question"] is not None

    # 5. Submit an answer
    ans_payload = {
        "pin": pin,
        "player_id": "stu_host_123",
        "question_index": 0,
        "selected_option_index": started_data["current_question"]["correct_index"],
        "response_time_ms": 4000
    }
    res_ans = client.post("/api/v1/multiplayer/submit-answer", json=ans_payload)
    assert res_ans.status_code == 200
    ans_data = res_ans.json()
    assert ans_data["is_correct"] is True
    assert ans_data["earned_score"] > 100

    # 6. Advance question
    res_next = client.post(f"/api/v1/multiplayer/next-question/{pin}")
    assert res_next.status_code == 200

    # 7. Get classroom/game analytics
    res_analytics = client.get(f"/api/v1/multiplayer/analytics/{pin}")
    assert res_analytics.status_code == 200
    analytics = res_analytics.json()
    assert "podium" in analytics
    assert "ml_engagement_summary" in analytics


def test_teacher_classroom_quiz():
    # 1. Create a Teacher Classroom Quiz
    create_payload = {
        "room_type": "TEACHER_CLASSROOM",
        "host_id": "teacher_001",
        "host_name": "Mr. Perera",
        "host_avatar": "owl_scholar",
        "topic": "Indices & Logarithms",
        "question_count": 5,
        "time_per_question": 30,
        "ml_insights_enabled": True
    }
    res = client.post("/api/v1/multiplayer/create", json=create_payload)
    assert res.status_code == 200
    room = res.json()
    assert room["room_type"] == "TEACHER_CLASSROOM"
    assert room["max_players"] == 50
    assert "qr_code_data" in room

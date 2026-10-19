import random
import csv
import io
from typing import Dict, Any, List, Optional
from fastapi import WebSocket


# Comprehensive Question Bank for Grade 10/11 Mathematics
QUESTION_BANK: Dict[str, List[Dict[str, Any]]] = {
    "Quadratic Equations": [
        {
            "question_id": "quad-1",
            "question_text": "What are the roots of the quadratic equation x² - 5x + 6 = 0?",
            "options": ["x = 2 or x = 3", "x = -2 or x = -3", "x = 1 or x = 6", "x = -1 or x = 6"],
            "correct_index": 0,
            "explanation": "Factoring gives (x - 2)(x - 3) = 0, so x = 2 or x = 3.",
            "topic": "Quadratic Equations",
            "difficulty": "Easy"
        },
        {
            "question_id": "quad-2",
            "question_text": "Which expression represents the discriminant of ax² + bx + c = 0?",
            "options": ["b² - 4ac", "b² + 4ac", "-b ± √(b² - 4ac)", "4ac - b²"],
            "correct_index": 0,
            "explanation": "The discriminant Δ = b² - 4ac determines nature of roots.",
            "topic": "Quadratic Equations",
            "difficulty": "Easy"
        },
        {
            "question_id": "quad-3",
            "question_text": "If the discriminant Δ = 0, what does it tell us about the roots?",
            "options": ["Real and equal roots", "Two distinct real roots", "No real roots", "Roots are zero"],
            "correct_index": 0,
            "explanation": "Δ = 0 implies exactly one repeated real root.",
            "topic": "Quadratic Equations",
            "difficulty": "Medium"
        },
        {
            "question_id": "quad-4",
            "question_text": "Solve for x in 2x² + 7x + 3 = 0 using factorization.",
            "options": ["x = -1/2 or x = -3", "x = 1/2 or x = 3", "x = -1 or x = -3/2", "x = 2 or x = 3"],
            "correct_index": 0,
            "explanation": "(2x + 1)(x + 3) = 0 → x = -1/2 or x = -3.",
            "topic": "Quadratic Equations",
            "difficulty": "Medium"
        },
        {
            "question_id": "quad-5",
            "question_text": "What value of c makes x² - 6x + c a perfect square trinomial?",
            "options": ["9", "36", "6", "3"],
            "correct_index": 0,
            "explanation": "(b/2)² = (-6/2)² = (-3)² = 9.",
            "topic": "Quadratic Equations",
            "difficulty": "Medium"
        },
        {
            "question_id": "quad-6",
            "question_text": "Find the sum of roots for the quadratic equation 3x² - 12x + 5 = 0.",
            "options": ["4", "-4", "5/3", "12"],
            "correct_index": 0,
            "explanation": "Sum of roots = -b / a = -(-12) / 3 = 4.",
            "topic": "Quadratic Equations",
            "difficulty": "Hard"
        },
        {
            "question_id": "quad-7",
            "question_text": "Find the product of roots for the equation 2x² - 8x - 14 = 0.",
            "options": ["-7", "7", "-4", "4"],
            "correct_index": 0,
            "explanation": "Product of roots = c / a = -14 / 2 = -7.",
            "topic": "Quadratic Equations",
            "difficulty": "Hard"
        },
        {
            "question_id": "quad-8",
            "question_text": "What is the vertex form of y = x² - 4x + 7?",
            "options": ["(x - 2)² + 3", "(x - 2)² + 7", "(x + 2)² + 3", "(x - 4)² + 3"],
            "correct_index": 0,
            "explanation": "x² - 4x + 4 + 3 = (x - 2)² + 3.",
            "topic": "Quadratic Equations",
            "difficulty": "Hard"
        },
        {
            "question_id": "quad-9",
            "question_text": "Solve x² = 49 by square root method.",
            "options": ["x = ±7", "x = 7", "x = -7", "x = 24.5"],
            "correct_index": 0,
            "explanation": "Taking square root of both sides gives x = ±7.",
            "topic": "Quadratic Equations",
            "difficulty": "Easy"
        },
        {
            "question_id": "quad-10",
            "question_text": "For which value of k does x² + kx + 16 = 0 have equal roots?",
            "options": ["k = ±8", "k = 4", "k = 16", "k = ±4"],
            "correct_index": 0,
            "explanation": "Δ = k² - 4(1)(16) = 0 → k² = 64 → k = ±8.",
            "topic": "Quadratic Equations",
            "difficulty": "Medium"
        }
    ],
    "Indices & Logarithms": [
        {
            "question_id": "idx-1",
            "question_text": "Simplify: 2³ × 2⁴",
            "options": ["2⁷", "2¹²", "4⁷", "4¹²"],
            "correct_index": 0,
            "explanation": "By product rule, aᵐ × aⁿ = aᵐ⁺ⁿ → 2³⁺⁴ = 2⁷.",
            "topic": "Indices & Logarithms",
            "difficulty": "Easy"
        },
        {
            "question_id": "idx-2",
            "question_text": "Evaluate: log₁₀(1000)",
            "options": ["3", "10", "100", "4"],
            "correct_index": 0,
            "explanation": "10³ = 1000, therefore log₁₀(1000) = 3.",
            "topic": "Indices & Logarithms",
            "difficulty": "Easy"
        },
        {
            "question_id": "idx-3",
            "question_text": "What is the value of (27)^(2/3)?",
            "options": ["9", "3", "18", "81"],
            "correct_index": 0,
            "explanation": "(³√27)² = 3² = 9.",
            "topic": "Indices & Logarithms",
            "difficulty": "Medium"
        },
        {
            "question_id": "idx-4",
            "question_text": "Simplify: log₂(8) + log₂(4)",
            "options": ["5", "6", "12", "7"],
            "correct_index": 0,
            "explanation": "log₂(8) = 3 and log₂(4) = 2. 3 + 2 = 5 (or log₂(32) = 5).",
            "topic": "Indices & Logarithms",
            "difficulty": "Medium"
        },
        {
            "question_id": "idx-5",
            "question_text": "Solve for x: 3ˣ = 81",
            "options": ["x = 4", "x = 3", "x = 27", "x = 9"],
            "correct_index": 0,
            "explanation": "3⁴ = 81, so x = 4.",
            "topic": "Indices & Logarithms",
            "difficulty": "Easy"
        },
        {
            "question_id": "idx-6",
            "question_text": "Evaluate: (16)^(-1/2)",
            "options": ["1/4", "-4", "-1/4", "4"],
            "correct_index": 0,
            "explanation": "16^(-1/2) = 1 / √16 = 1/4.",
            "topic": "Indices & Logarithms",
            "difficulty": "Medium"
        },
        {
            "question_id": "idx-7",
            "question_text": "Simplify: log(a) - log(b)",
            "options": ["log(a / b)", "log(a - b)", "log(a × b)", "log(a) / log(b)"],
            "correct_index": 0,
            "explanation": "By the quotient law of logarithms, log(a) - log(b) = log(a/b).",
            "topic": "Indices & Logarithms",
            "difficulty": "Easy"
        },
        {
            "question_id": "idx-8",
            "question_text": "What is the value of 5⁰?",
            "options": ["1", "0", "5", "Undefined"],
            "correct_index": 0,
            "explanation": "Any non-zero real number raised to power 0 equals 1.",
            "topic": "Indices & Logarithms",
            "difficulty": "Easy"
        },
        {
            "question_id": "idx-9",
            "question_text": "Solve for x: log₃(x) = 4",
            "options": ["81", "12", "64", "27"],
            "correct_index": 0,
            "explanation": "In exponential form: x = 3⁴ = 81.",
            "topic": "Indices & Logarithms",
            "difficulty": "Medium"
        },
        {
            "question_id": "idx-10",
            "question_text": "Simplify: (x³ y⁴)² / (x² y³)",
            "options": ["x⁴ y⁵", "x³ y⁵", "x⁴ y³", "x² y⁴"],
            "correct_index": 0,
            "explanation": "(x⁶ y⁸) / (x² y³) = x⁶⁻² y⁸⁻³ = x⁴ y⁵.",
            "topic": "Indices & Logarithms",
            "difficulty": "Hard"
        }
    ],
    "Perimeter & Area of Plane Figures": [
        {
            "question_id": "geo-1",
            "question_text": "What is the area of a right-angled triangle with base 8 cm and height 6 cm?",
            "options": ["24 cm²", "48 cm²", "14 cm²", "36 cm²"],
            "correct_index": 0,
            "explanation": "Area = 1/2 × base × height = 1/2 × 8 × 6 = 24 cm².",
            "topic": "Perimeter & Area of Plane Figures",
            "difficulty": "Easy"
        },
        {
            "question_id": "geo-2",
            "question_text": "Find the circumference of a circle with radius 7 cm (take π = 22/7).",
            "options": ["44 cm", "154 cm", "22 cm", "88 cm"],
            "correct_index": 0,
            "explanation": "C = 2πr = 2 × (22/7) × 7 = 44 cm.",
            "topic": "Perimeter & Area of Plane Figures",
            "difficulty": "Easy"
        },
        {
            "question_id": "geo-3",
            "question_text": "What is the area of a circle with radius 7 cm (take π = 22/7)?",
            "options": ["154 cm²", "44 cm²", "77 cm²", "308 cm²"],
            "correct_index": 0,
            "explanation": "A = πr² = (22/7) × 7 × 7 = 154 cm².",
            "topic": "Perimeter & Area of Plane Figures",
            "difficulty": "Medium"
        },
        {
            "question_id": "geo-4",
            "question_text": "What is the area of a trapezium with parallel sides 10 cm and 6 cm, and height 4 cm?",
            "options": ["32 cm²", "64 cm²", "40 cm²", "24 cm²"],
            "correct_index": 0,
            "explanation": "Area = 1/2 × (a + b) × h = 1/2 × (10 + 6) × 4 = 32 cm².",
            "topic": "Perimeter & Area of Plane Figures",
            "difficulty": "Medium"
        },
        {
            "question_id": "geo-5",
            "question_text": "If the perimeter of a square is 36 cm, what is its area?",
            "options": ["81 cm²", "72 cm²", "36 cm²", "144 cm²"],
            "correct_index": 0,
            "explanation": "Side = 36 / 4 = 9 cm. Area = 9² = 81 cm².",
            "topic": "Perimeter & Area of Plane Figures",
            "difficulty": "Easy"
        }
    ],
    "Linear Equations": [
        {
            "question_id": "lin-1",
            "question_text": "Solve for x: 3x + 5 = 20",
            "options": ["x = 5", "x = 15", "x = 25/3", "x = 4"],
            "correct_index": 0,
            "explanation": "3x = 15 → x = 5.",
            "topic": "Linear Equations",
            "difficulty": "Easy"
        },
        {
            "question_id": "lin-2",
            "question_text": "Solve the system: x + y = 10 and x - y = 4.",
            "options": ["x = 7, y = 3", "x = 6, y = 4", "x = 8, y = 2", "x = 5, y = 5"],
            "correct_index": 0,
            "explanation": "Adding both equations: 2x = 14 → x = 7; y = 10 - 7 = 3.",
            "topic": "Linear Equations",
            "difficulty": "Medium"
        },
        {
            "question_id": "lin-3",
            "question_text": "What is the gradient (slope) of the line 2y = 6x + 8?",
            "options": ["3", "6", "4", "2"],
            "correct_index": 0,
            "explanation": "y = 3x + 4, so gradient m = 3.",
            "topic": "Linear Equations",
            "difficulty": "Easy"
        },
        {
            "question_id": "lin-4",
            "question_text": "Solve for y: 4(y - 2) = 2(y + 6)",
            "options": ["y = 10", "y = 5", "y = 8", "y = 7"],
            "correct_index": 0,
            "explanation": "4y - 8 = 2y + 12 → 2y = 20 → y = 10.",
            "topic": "Linear Equations",
            "difficulty": "Medium"
        },
        {
            "question_id": "lin-5",
            "question_text": "Which coordinate point lies on the line y = 2x - 3?",
            "options": ["(4, 5)", "(3, 2)", "(2, 2)", "(5, 6)"],
            "correct_index": 0,
            "explanation": "For x = 4, y = 2(4) - 3 = 8 - 3 = 5.",
            "topic": "Linear Equations",
            "difficulty": "Easy"
        }
    ]
}

BOT_NAMES = [
    {"name": "Nimal", "avatar": "panda_zen"},
    {"name": "Kasun", "avatar": "fox_math"},
    {"name": "Sanduni", "avatar": "owl_scholar"},
    {"name": "Dilshan", "avatar": "cosmic_star"},
    {"name": "Tharushi", "avatar": "robot_tech"},
    {"name": "Buddhika", "avatar": "lion_brave"}
]


class RoomManager:
    """Singleton Manager for Live Multiplayer Quiz Rooms"""

    _rooms: Dict[str, Dict[str, Any]] = {}
    _connections: Dict[str, Dict[str, WebSocket]] = {}  # pin -> {player_id: WebSocket}

    @classmethod
    def generate_unique_pin(cls) -> str:
        for _ in range(100):
            pin = f"{random.randint(1000, 9999)}"
            if pin not in cls._rooms:
                return pin
        return f"{random.randint(10000, 99999)}"

    @classmethod
    def create_room(
        cls,
        room_type: str,
        host_id: str,
        host_name: str,
        host_avatar: str = "fox_math",
        topic: str = "Quadratic Equations",
        grade_level: int = 10,
        question_count: int = 5,
        time_per_question: int = 30,
        ml_insights_enabled: bool = True,
        quiz_source: str = "AUTO_GENERATE",
        custom_questions: Optional[List[Dict[str, Any]]] = None
    ) -> Dict[str, Any]:
        pin = cls.generate_unique_pin()
        max_players = 5 if room_type == "STUDENT_PEER" else 50

        # Select or generate questions
        if quiz_source == "CUSTOM_UPLOAD" and custom_questions and len(custom_questions) > 0:
            questions = custom_questions[:question_count]
        else:
            topic_bank = QUESTION_BANK.get(topic, QUESTION_BANK["Quadratic Equations"])
            # Sample without replacement up to bank size
            sample_size = min(question_count, len(topic_bank))
            questions = random.sample(topic_bank, sample_size)

        host_player = {
            "player_id": host_id,
            "name": host_name,
            "avatar": host_avatar,
            "score": 0,
            "correct_count": 0,
            "is_host": True,
            "is_ready": True,
            "last_response_time_ms": None,
            "predicted_state": "FOCUSED"
        }

        room_data = {
            "pin": pin,
            "room_type": room_type,
            "status": "LOBBY",
            "host_id": host_id,
            "topic": topic,
            "grade_level": grade_level,
            "question_count": len(questions),
            "current_question_index": 0,
            "time_per_question": time_per_question,
            "ml_insights_enabled": ml_insights_enabled,
            "max_players": max_players,
            "players": [host_player],
            "questions": questions,
            "answers": {},  # question_idx -> {player_id: answer_data}
            "qr_code_data": f"ADAPTIVE_QUIZ_ROOM_{pin}"
        }

        cls._rooms[pin] = room_data
        cls._connections[pin] = {}
        return room_data

    @classmethod
    def get_room(cls, pin: str) -> Optional[Dict[str, Any]]:
        return cls._rooms.get(pin)

    @classmethod
    def join_room(
        cls,
        pin: str,
        player_id: str,
        player_name: str,
        player_avatar: str = "fox_math",
        is_teacher: bool = False
    ) -> Dict[str, Any]:
        room = cls._rooms.get(pin)
        if not room:
            raise ValueError(f"Room with PIN {pin} does not exist.")

        if room["status"] != "LOBBY":
            raise ValueError("Quiz is already in progress or completed.")

        # Check existing
        for p in room["players"]:
            if p["player_id"] == player_id:
                return room

        if len(room["players"]) >= room["max_players"]:
            raise ValueError(f"Room is full (max {room['max_players']} players).")

        new_player = {
            "player_id": player_id,
            "name": player_name,
            "avatar": player_avatar,
            "score": 0,
            "correct_count": 0,
            "is_host": False,
            "is_ready": True,
            "last_response_time_ms": None,
            "predicted_state": "FOCUSED"
        }
        room["players"].append(new_player)
        return room

    @classmethod
    def add_bot_peer(cls, pin: str) -> Optional[Dict[str, Any]]:
        room = cls._rooms.get(pin)
        if not room:
            return None

        if len(room["players"]) >= room["max_players"]:
            return None

        used_names = {p["name"] for p in room["players"]}
        available_bots = [b for b in BOT_NAMES if b["name"] not in used_names]
        if not available_bots:
            available_bots = [{"name": f"Student {len(room['players']) + 1}", "avatar": "fox_math"}]

        bot = random.choice(available_bots)
        bot_id = f"bot_{random.randint(1000, 9999)}"

        bot_player = {
            "player_id": bot_id,
            "name": f"{bot['name']} (Peer)",
            "avatar": bot["avatar"],
            "score": 0,
            "correct_count": 0,
            "is_host": False,
            "is_ready": True,
            "last_response_time_ms": None,
            "predicted_state": "FOCUSED",
            "is_bot": True
        }
        room["players"].append(bot_player)
        return bot_player

    @classmethod
    def start_game(cls, pin: str) -> Dict[str, Any]:
        room = cls._rooms.get(pin)
        if not room:
            raise ValueError("Room not found.")

        room["status"] = "IN_PROGRESS"
        room["current_question_index"] = 0
        return room

    @classmethod
    def submit_answer(
        cls,
        pin: str,
        player_id: str,
        question_index: int,
        selected_option_index: Optional[int] = 0,
        response_time_ms: int = 5000,
        text_answer: Optional[str] = None
    ) -> Dict[str, Any]:
        room = cls._rooms.get(pin)
        if not room:
            raise ValueError("Room not found.")

        if question_index >= len(room["questions"]):
            raise ValueError("Invalid question index.")

        question = room["questions"][question_index]
        is_mcq = bool(question.get("options") and len(question["options"]) > 0)
        if is_mcq:
            is_correct = (selected_option_index == question.get("correct_index", 0))
        else:
            # For non-MCQ questions shown to student, student text submission earns points
            is_correct = True

        # Calculate score: Base 100 for correct + Speed bonus up to 50
        time_limit_ms = room["time_per_question"] * 1000
        time_fraction = max(0.0, 1.0 - (response_time_ms / time_limit_ms))
        earned_score = 0
        if is_correct:
            earned_score = 100 + int(50 * time_fraction)

        # Update player state
        target_player = None
        for p in room["players"]:
            if p["player_id"] == player_id:
                p["score"] += earned_score
                if is_correct:
                    p["correct_count"] += 1
                p["last_response_time_ms"] = response_time_ms

                # Component 3 Telemetry Affective State Inference
                if not is_correct and response_time_ms > 20000:
                    p["predicted_state"] = "FRUSTRATED"
                elif not is_correct and response_time_ms < 3000:
                    p["predicted_state"] = "BORED"
                elif is_correct and response_time_ms < 12000:
                    p["predicted_state"] = "FOCUSED"
                else:
                    p["predicted_state"] = "FOCUSED"

                target_player = p
                break

        # Record answer
        if question_index not in room["answers"]:
            room["answers"][question_index] = {}

        room["answers"][question_index][player_id] = {
            "selected_option": selected_option_index,
            "is_correct": is_correct,
            "earned_score": earned_score,
            "response_time_ms": response_time_ms
        }

        # Simulate answers for any bots in this room for this question
        for p in room["players"]:
            if p.get("is_bot") and p["player_id"] not in room["answers"][question_index]:
                bot_correct = random.random() > 0.35  # 65% accuracy
                bot_time_ms = random.randint(4000, max(5000, time_limit_ms - 2000))
                bot_fraction = max(0.0, 1.0 - (bot_time_ms / time_limit_ms))
                bot_points = (100 + int(50 * bot_fraction)) if bot_correct else 0

                p["score"] += bot_points
                if bot_correct:
                    p["correct_count"] += 1
                p["last_response_time_ms"] = bot_time_ms

                room["answers"][question_index][p["player_id"]] = {
                    "selected_option": question["correct_index"] if bot_correct else (question["correct_index"] + 1) % 4,
                    "is_correct": bot_correct,
                    "earned_score": bot_points,
                    "response_time_ms": bot_time_ms
                }

        # Re-sort players by score descending
        room["players"].sort(key=lambda x: x["score"], reverse=True)

        return {
            "is_correct": is_correct,
            "earned_score": earned_score,
            "correct_index": question["correct_index"],
            "explanation": question["explanation"],
            "updated_player": target_player,
            "leaderboard": room["players"]
        }

    @classmethod
    def next_question(cls, pin: str) -> Dict[str, Any]:
        room = cls._rooms.get(pin)
        if not room:
            raise ValueError("Room not found.")

        if room["current_question_index"] + 1 < len(room["questions"]):
            room["current_question_index"] += 1
        else:
            room["status"] = "FINISHED"

        return room

    @classmethod
    def get_classroom_analytics(cls, pin: str) -> Dict[str, Any]:
        room = cls._rooms.get(pin)
        if not room:
            raise ValueError("Room not found.")

        players = sorted(room["players"], key=lambda x: x["score"], reverse=True)
        total_students = len(players)
        total_questions = len(room["questions"])

        avg_score = (sum(p["score"] for p in players) / total_students) if total_students > 0 else 0
        total_possible = total_students * total_questions
        total_correct = sum(p["correct_count"] for p in players)
        accuracy_pct = (total_correct / total_possible * 100) if total_possible > 0 else 0

        # Component 3 ML Engagement Summary
        state_counts = {"FOCUSED": 0, "FRUSTRATED": 0, "BORED": 0, "AT_RISK": 0}
        for p in players:
            st = p.get("predicted_state", "FOCUSED")
            state_counts[st] = state_counts.get(st, 0) + 1

        focused_pct = round((state_counts["FOCUSED"] / total_students * 100), 1) if total_students > 0 else 100
        frustrated_pct = round((state_counts["FRUSTRATED"] / total_students * 100), 1) if total_students > 0 else 0
        bored_pct = round((state_counts["BORED"] / total_students * 100), 1) if total_students > 0 else 0

        # Question level analytics
        question_performance = []
        for q_idx, q in enumerate(room["questions"]):
            q_answers = room["answers"].get(q_idx, {})
            q_total = len(q_answers)
            q_correct = sum(1 for a in q_answers.values() if a.get("is_correct"))
            q_acc = (q_correct / q_total * 100) if q_total > 0 else 0
            avg_time = (sum(a.get("response_time_ms", 0) for a in q_answers.values()) / q_total / 1000) if q_total > 0 else 0

            question_performance.append({
                "question_index": q_idx + 1,
                "question_text": q["question_text"],
                "accuracy_percentage": round(q_acc, 1),
                "avg_response_time_sec": round(avg_time, 1),
                "cognitive_load": "HIGH" if q_acc < 50 else ("OPTIMAL" if q_acc < 85 else "LOW")
            })

        return {
            "pin": pin,
            "topic": room["topic"],
            "total_students": total_students,
            "class_average_score": round(avg_score, 1),
            "class_accuracy_percentage": round(accuracy_pct, 1),
            "podium": players[:3],
            "all_players": players,
            "ml_engagement_summary": {
                "focused_percentage": focused_pct,
                "frustrated_percentage": frustrated_pct,
                "boredom_percentage": bored_pct,
                "adaptive_recommendation": (
                    "High conceptual struggle detected on factoring trinomials. Suggest reviewing algebraic tiles."
                    if frustrated_pct > 30 else
                    "Optimal classroom engagement! Majority of students demonstrated active flow state."
                )
            },
            "question_performance": question_performance
        }

    @classmethod
    def parse_csv_quiz(cls, csv_text: str) -> List[Dict[str, Any]]:
        """Parses CSV formatted quiz questions"""
        questions = []
        reader = csv.reader(io.StringIO(csv_text.strip()))
        for idx, row in enumerate(reader):
            if idx == 0 and any("question" in cell.lower() for cell in row):
                continue  # skip header
            if len(row) >= 6:
                q_text = row[0].strip()
                options = [row[1].strip(), row[2].strip(), row[3].strip(), row[4].strip()]
                try:
                    c_idx = int(row[5].strip())
                    if c_idx < 0 or c_idx > 3:
                        c_idx = 0
                except Exception:
                    c_idx = 0
                explanation = row[6].strip() if len(row) > 6 else ""

                questions.append({
                    "question_id": f"custom_{idx + 1}",
                    "question_text": q_text,
                    "options": options,
                    "correct_index": c_idx,
                    "explanation": explanation,
                    "topic": "Custom Quiz",
                    "difficulty": "Custom"
                })
        return questions

    # WebSocket connection management
    @classmethod
    async def register_ws(cls, pin: str, player_id: str, ws: WebSocket):
        if pin not in cls._connections:
            cls._connections[pin] = {}
        cls._connections[pin][player_id] = ws

    @classmethod
    async def unregister_ws(cls, pin: str, player_id: str):
        if pin in cls._connections and player_id in cls._connections[pin]:
            del cls._connections[pin][player_id]

    @classmethod
    async def broadcast(cls, pin: str, message: Dict[str, Any]):
        if pin in cls._connections:
            for pid, ws in list(cls._connections[pin].items()):
                try:
                    await ws.send_json(message)
                except Exception:
                    cls._connections[pin].pop(pid, None)

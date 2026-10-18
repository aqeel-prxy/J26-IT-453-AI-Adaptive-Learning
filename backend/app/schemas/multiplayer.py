from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


class QuizQuestionSchema(BaseModel):
    question_id: str
    question_text: str
    options: List[str]
    correct_index: int
    explanation: str = ""
    topic: str = "Mathematics"
    difficulty: str = "Medium"


class RoomPlayerSchema(BaseModel):
    player_id: str
    name: str
    avatar: str = "fox_math"
    score: int = 0
    correct_count: int = 0
    is_host: bool = False
    is_ready: bool = True
    last_response_time_ms: Optional[int] = None
    predicted_state: Optional[str] = "FOCUSED"  # FOCUSED, FRUSTRATED, BORED, AT_RISK


class CreateRoomRequest(BaseModel):
    room_type: str = "STUDENT_PEER"  # STUDENT_PEER or TEACHER_CLASSROOM
    host_id: str
    host_name: str
    host_avatar: str = "fox_math"
    topic: str = "Quadratic Equations"
    grade_level: int = 10
    question_count: int = 5
    time_per_question: int = 30
    ml_insights_enabled: bool = True
    quiz_source: str = "AUTO_GENERATE"  # AUTO_GENERATE or CUSTOM_UPLOAD
    custom_questions: Optional[List[QuizQuestionSchema]] = None


class JoinRoomRequest(BaseModel):
    pin: str
    player_id: str
    player_name: str
    player_avatar: str = "fox_math"
    is_teacher: bool = False


class SubmitAnswerRequest(BaseModel):
    pin: str
    player_id: str
    question_index: int
    selected_option_index: int
    response_time_ms: int = 5000


class RoomDetailsResponse(BaseModel):
    pin: str
    room_type: str
    status: str  # LOBBY, IN_PROGRESS, FINISHED
    topic: str
    grade_level: int = 10
    question_count: int
    current_question_index: int = 0
    time_per_question: int
    ml_insights_enabled: bool
    players: List[RoomPlayerSchema]
    max_players: int
    qr_code_data: str
    questions: Optional[List[QuizQuestionSchema]] = None
    current_question: Optional[QuizQuestionSchema] = None


class ClassroomAnalyticsResponse(BaseModel):
    pin: str
    topic: str
    total_students: int
    class_average_score: float
    class_accuracy_percentage: float
    podium: List[RoomPlayerSchema]
    all_players: List[RoomPlayerSchema]
    ml_engagement_summary: Dict[str, Any]
    question_performance: List[Dict[str, Any]]

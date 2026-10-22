from typing import List, Dict, Any
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect, Body
from app.schemas.multiplayer import (
    CreateRoomRequest,
    JoinRoomRequest,
    SubmitAnswerRequest,
    RoomDetailsResponse,
    ClassroomAnalyticsResponse,
    QuizQuestionSchema,
)
from app.services.multiplayer.room_manager import RoomManager

router = APIRouter(prefix="/multiplayer", tags=["Multiplayer Quiz (Component 3)"])


@router.post("/create", response_model=RoomDetailsResponse)
async def create_room(payload: CreateRoomRequest):
    """Create a new multiplayer quiz room (Student Peer or Teacher Classroom)"""
    custom_q = None
    if payload.custom_questions:
        custom_q = [q.model_dump() for q in payload.custom_questions]

    room = RoomManager.create_room(
        room_type=payload.room_type,
        host_id=payload.host_id,
        host_name=payload.host_name,
        host_avatar=payload.host_avatar,
        topic=payload.topic,
        grade_level=payload.grade_level,
        question_count=payload.question_count,
        time_per_question=payload.time_per_question,
        ml_insights_enabled=payload.ml_insights_enabled,
        quiz_source=payload.quiz_source,
        custom_questions=custom_q,
    )
    return RoomDetailsResponse(
        pin=room["pin"],
        room_type=room["room_type"],
        status=room["status"],
        topic=room["topic"],
        grade_level=room["grade_level"],
        question_count=room["question_count"],
        current_question_index=room["current_question_index"],
        time_per_question=room["time_per_question"],
        ml_insights_enabled=room["ml_insights_enabled"],
        players=room["players"],
        max_players=room["max_players"],
        qr_code_data=room["qr_code_data"],
        questions=[QuizQuestionSchema(**q) for q in room["questions"]],
        current_question=QuizQuestionSchema(**room["questions"][0]) if room["questions"] else None
    )


@router.get("/room/{pin}", response_model=RoomDetailsResponse)
async def get_room_details(pin: str):
    """Retrieve current details for a room by 4-digit PIN"""
    room = RoomManager.get_room(pin)
    if not room:
        raise HTTPException(status_code=404, detail="Room not found. Check the 4-digit PIN.")

    curr_idx = room["current_question_index"]
    curr_q = room["questions"][curr_idx] if curr_idx < len(room["questions"]) else None

    return RoomDetailsResponse(
        pin=room["pin"],
        room_type=room["room_type"],
        status=room["status"],
        topic=room["topic"],
        grade_level=room["grade_level"],
        question_count=room["question_count"],
        current_question_index=room["current_question_index"],
        time_per_question=room["time_per_question"],
        ml_insights_enabled=room["ml_insights_enabled"],
        players=room["players"],
        max_players=room["max_players"],
        qr_code_data=room["qr_code_data"],
        questions=[QuizQuestionSchema(**q) for q in room["questions"]],
        current_question=QuizQuestionSchema(**curr_q) if curr_q else None
    )


@router.post("/join", response_model=RoomDetailsResponse)
async def join_room(payload: JoinRoomRequest):
    """Join an active room using a 4-digit PIN"""
    try:
        room = RoomManager.join_room(
            pin=payload.pin,
            player_id=payload.player_id,
            player_name=payload.player_name,
            player_avatar=payload.player_avatar,
            is_teacher=payload.is_teacher,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Broadcast player joined to active room websockets
    await RoomManager.broadcast(payload.pin, {
        "event": "PLAYER_JOINED",
        "players": room["players"]
    })

    curr_idx = room["current_question_index"]
    curr_q = room["questions"][curr_idx] if curr_idx < len(room["questions"]) else None

    return RoomDetailsResponse(
        pin=room["pin"],
        room_type=room["room_type"],
        status=room["status"],
        topic=room["topic"],
        grade_level=room["grade_level"],
        question_count=room["question_count"],
        current_question_index=room["current_question_index"],
        time_per_question=room["time_per_question"],
        ml_insights_enabled=room["ml_insights_enabled"],
        players=room["players"],
        max_players=room["max_players"],
        qr_code_data=room["qr_code_data"],
        questions=[QuizQuestionSchema(**q) for q in room["questions"]],
        current_question=QuizQuestionSchema(**curr_q) if curr_q else None
    )


@router.post("/add-bot/{pin}")
async def add_bot_peer(pin: str):
    """Add a simulated classmate / peer bot to a student lobby"""
    bot = RoomManager.add_bot_peer(pin)
    if not bot:
        raise HTTPException(status_code=400, detail="Cannot add bot. Room full or not found.")

    room = RoomManager.get_room(pin)
    await RoomManager.broadcast(pin, {
        "event": "PLAYER_JOINED",
        "players": room["players"]
    })
    return {"status": "success", "bot": bot, "players": room["players"]}


@router.post("/start/{pin}", response_model=RoomDetailsResponse)
async def start_quiz(pin: str):
    """Start the quiz session (host only)"""
    try:
        room = RoomManager.start_game(pin)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    curr_q = room["questions"][0] if room["questions"] else None
    await RoomManager.broadcast(pin, {
        "event": "GAME_STARTED",
        "current_question_index": 0,
        "current_question": curr_q
    })

    return RoomDetailsResponse(
        pin=room["pin"],
        room_type=room["room_type"],
        status=room["status"],
        topic=room["topic"],
        grade_level=room["grade_level"],
        question_count=room["question_count"],
        current_question_index=room["current_question_index"],
        time_per_question=room["time_per_question"],
        ml_insights_enabled=room["ml_insights_enabled"],
        players=room["players"],
        max_players=room["max_players"],
        qr_code_data=room["qr_code_data"],
        questions=[QuizQuestionSchema(**q) for q in room["questions"]],
        current_question=QuizQuestionSchema(**curr_q) if curr_q else None
    )


@router.post("/submit-answer")
async def submit_answer(payload: SubmitAnswerRequest):
    """Submit player answer and update real-time mini-leaderboard"""
    try:
        res = RoomManager.submit_answer(
            pin=payload.pin,
            player_id=payload.player_id,
            question_index=payload.question_index,
            selected_option_index=payload.selected_option_index or 0,
            response_time_ms=payload.response_time_ms,
            text_answer=payload.text_answer,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    await RoomManager.broadcast(payload.pin, {
        "event": "LEADERBOARD_UPDATE",
        "leaderboard": res["leaderboard"]
    })

    return res


@router.post("/next-question/{pin}", response_model=RoomDetailsResponse)
async def next_question(pin: str):
    """Advance to the next question in the match (host controller)"""
    try:
        room = RoomManager.next_question(pin)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    curr_idx = room["current_question_index"]
    is_finished = (room["status"] == "FINISHED")
    curr_q = room["questions"][curr_idx] if not is_finished and curr_idx < len(room["questions"]) else None

    await RoomManager.broadcast(pin, {
        "event": "GAME_FINISHED" if is_finished else "NEXT_QUESTION",
        "current_question_index": curr_idx,
        "current_question": curr_q
    })

    return RoomDetailsResponse(
        pin=room["pin"],
        room_type=room["room_type"],
        status=room["status"],
        topic=room["topic"],
        grade_level=room["grade_level"],
        question_count=room["question_count"],
        current_question_index=room["current_question_index"],
        time_per_question=room["time_per_question"],
        ml_insights_enabled=room["ml_insights_enabled"],
        players=room["players"],
        max_players=room["max_players"],
        qr_code_data=room["qr_code_data"],
        questions=[QuizQuestionSchema(**q) for q in room["questions"]],
        current_question=QuizQuestionSchema(**curr_q) if curr_q else None
    )


@router.get("/analytics/{pin}", response_model=ClassroomAnalyticsResponse)
async def get_classroom_analytics(pin: str):
    """Retrieve classroom podium and Component 3 ML engagement/frustration analytics"""
    try:
        analytics = RoomManager.get_classroom_analytics(pin)
        return ClassroomAnalyticsResponse(**analytics)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/parse-csv", response_model=List[QuizQuestionSchema])
async def parse_csv_quiz(body: Dict[str, str] = Body(...)):
    """Parse custom CSV question upload into structured quiz questions"""
    csv_text = body.get("csv_text", "")
    questions = RoomManager.parse_csv_quiz(csv_text)
    return [QuizQuestionSchema(**q) for q in questions]


@router.websocket("/ws/{pin}/{player_id}")
async def websocket_endpoint(websocket: WebSocket, pin: str, player_id: str):
    """Bidirectional WebSocket connection for live synchronized quiz events"""
    await websocket.accept()
    await RoomManager.register_ws(pin, player_id, websocket)

    try:
        while True:
            data = await websocket.receive_json()
            event_type = data.get("event")

            if event_type == "PING":
                await websocket.send_json({"event": "PONG"})
            elif event_type == "CHAT_MESSAGE":
                await RoomManager.broadcast(pin, {
                    "event": "CHAT_MESSAGE",
                    "player_id": player_id,
                    "message": data.get("message", "")
                })
    except WebSocketDisconnect:
        await RoomManager.unregister_ws(pin, player_id)
        room = RoomManager.get_room(pin)
        if room:
            await RoomManager.broadcast(pin, {
                "event": "PLAYER_LEFT",
                "player_id": player_id
            })

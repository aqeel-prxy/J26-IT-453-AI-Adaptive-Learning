# REST API v1 Shared Contract Specification — J26-IT-453

This document defines the REST API contract for base URL prefix `/api/v1/`.

All request and response payloads use JSON formatting (`Content-Type: application/json`).

---

## 1. Authentication Endpoints (`/api/v1/auth/`)
*Owning Component*: Shared Core

### `POST /api/v1/auth/login`
- **Description**: Authenticates student and returns OAuth2 JWT access token.
- **Request Body**:
  ```json
  {
    "email": "student@example.lk",
    "password": "secure_password_123"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
    "token_type": "bearer",
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "anonymized_code": "STU_HASH_8F3A"
  }
  ```
- **Errors**: `401 Unauthorized` (Invalid credentials).

---

## 2. Student Management Endpoints (`/api/v1/students/`)
*Owning Component*: Shared Core

### `GET /api/v1/students/me`
- **Headers**: `Authorization: Bearer <token>`
- **Response (200 OK)**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "email": "student@example.lk",
    "grade_level": 10,
    "created_at": "2026-10-03T14:00:00Z"
  }
  ```

---

## 3. Mathematics Curriculum & Attempt Endpoints (`/api/v1/mathematics/`)
*Owning Component*: Shared Core

### `GET /api/v1/mathematics/topics`
- **Response (200 OK)**:
  ```json
  {
    "topics": [
      {
        "topic_category": "Quadratic Equations",
        "grade_level": 10,
        "concept_count": 4
      }
    ]
  }
  ```

### `GET /api/v1/mathematics/concepts/{concept_id}`
- **Response (200 OK)**:
  ```json
  {
    "concept_id": "c1111111-1111-1111-1111-111111111111",
    "topic_category": "Quadratic Equations",
    "code": "MATH-G10-QUAD-01",
    "title": "Solving Quadratic Equations by Factorization",
    "prerequisites": []
  }
  ```

### `POST /api/v1/mathematics/attempts/submit`
- **Description**: Submits student solution for analysis, profiling, representation selection, and engagement tracking.
- **Request Body**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "question_id": "q2222222-2222-2222-2222-222222222222",
    "student_solution": "x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3",
    "response_time_ms": 14200
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "attempt_id": "att-33333333-3333-3333-3333-333333333333",
    "is_correct": false,
    "error_diagnosis": {
      "failed_step_index": 3,
      "error_category": "Sign Error",
      "explanation_text": "In step 3, setting (x + 2) = 0 yields x = -2, not x = 2.",
      "corrected_step": "x = -2 or x = -3"
    },
    "learner_profile": {
      "concept_id": "c1111111-1111-1111-1111-111111111111",
      "mastery_probability": 0.42,
      "trend": "improving"
    },
    "recommended_representation": {
      "representation_id": "rep-44444444-4444-4444-4444-444444444444",
      "format_type": "STEP_BY_STEP",
      "content_payload": {
        "steps": [
          "1. Set quadratic expression to zero: x^2 + bx + c = 0",
          "2. Factor into (x - p)(x - q) = 0",
          "3. Solve each linear term: x = p or x = q"
        ]
      }
    },
    "engagement": {
      "current_streak_days": 4,
      "virtual_pet_health": 95,
      "earned_points": 10,
      "feedback_message": "Good effort! Watch out for sign changes when solving factorized equations."
    }
  }
  ```

---

## 4. Learner Profiling Endpoints (`/api/v1/learner/`)
*Owning Component*: Component 2 (Jayasinghe)

### `GET /api/v1/learner/profile/{student_id}`
- **Response (200 OK)**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "mastery_vector": [
      {
        "concept_id": "c1111111-1111-1111-1111-111111111111",
        "concept_code": "MATH-G10-QUAD-01",
        "mastery_probability": 0.42,
        "forgetting_factor": 0.95,
        "last_practiced_at": "2026-10-03T14:20:00Z"
      }
    ]
  }
  ```

---

## 5. Learning Path Planning Endpoints (`/api/v1/learning-path/`)
*Owning Component*: Component 1 (Aqeel)

### `GET /api/v1/learning-path/curriculum/{topic}`
- **Description**: Returns the curriculum Directed Acyclic Graph (DAG) for a topic (e.g. `indices-and-logarithms`), including all concept nodes and their prerequisite edges.
- **Response (200 OK)**:
  ```json
  {
    "topic_category": "Indices and Logarithms",
    "grade_level": 11,
    "concepts": [
      {
        "concept_id": "c1000000-0000-0000-0000-000000000001",
        "code": "MATH-G11-IND-01",
        "title": "Laws of Positive Integral Indices",
        "prerequisites": [],
        "order_index": 1
      },
      {
        "concept_id": "c1000000-0000-0000-0000-000000000002",
        "code": "MATH-G11-IND-02",
        "title": "Fractional and Negative Indices",
        "prerequisites": ["c1000000-0000-0000-0000-000000000001"],
        "order_index": 2
      },
      {
        "concept_id": "c1000000-0000-0000-0000-000000000003",
        "code": "MATH-G11-LOG-01",
        "title": "Introduction to Logarithms and Index Form Equivalence",
        "prerequisites": ["c1000000-0000-0000-0000-000000000002"],
        "order_index": 3
      }
    ]
  }
  ```

### `POST /api/v1/learning-path/plan`
- **Description**: Generates a goal-aware and prerequisite-adaptive learning pathway for a student.
- **Request Body**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "topic_category": "Indices and Logarithms",
    "goal_type": "TERM_TEST",
    "target_date": "2026-11-15",
    "available_daily_minutes": 30
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "plan_id": "p1111111-1111-1111-1111-111111111111",
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "goal_type": "TERM_TEST",
    "topic_category": "Indices and Logarithms",
    "recommended_activity": {
      "activity_type": "REVISE_PREREQUISITE",
      "concept_id": "c1000000-0000-0000-0000-000000000001",
      "concept_title": "Laws of Positive Integral Indices",
      "rationale": "Predicted readiness for Logarithms is low (0.34); prerequisite 'Laws of Indices' requires reinforcement first.",
      "estimated_duration_minutes": 15
    },
    "pathway_nodes": [
      {
        "concept_id": "c1000000-0000-0000-0000-000000000001",
        "status": "IN_PROGRESS",
        "readiness_probability": 0.58,
        "is_prerequisite_revision": true
      },
      {
        "concept_id": "c1000000-0000-0000-0000-000000000002",
        "status": "LOCKED",
        "readiness_probability": 0.41,
        "is_prerequisite_revision": false
      }
    ]
  }
  ```

### `POST /api/v1/learning-path/diagnostic/submit`
- **Description**: Ingests diagnostic assessment results and returns initial readiness estimates and first pathway recommendations.
- **Request Body**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "topic_category": "Indices and Logarithms",
    "goal_type": "COMPREHENSIVE",
    "responses": [
      {
        "question_id": "q1000000-0000-0000-0000-000000000001",
        "concept_id": "c1000000-0000-0000-0000-000000000001",
        "is_correct": true,
        "response_time_ms": 12000
      }
    ]
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "plan_id": "p1111111-1111-1111-1111-111111111111",
    "initial_readiness_vector": {
      "c1000000-0000-0000-0000-000000000001": 0.85,
      "c1000000-0000-0000-0000-000000000002": 0.62
    },
    "recommended_next_step": {
      "activity_type": "LESSON_UNIT",
      "concept_id": "c1000000-0000-0000-0000-000000000002",
      "concept_title": "Fractional and Negative Indices",
      "rationale": "Direct progression approved: prerequisite Laws of Indices verified (accuracy 100%)."
    }
  }
  ```

### `POST /api/v1/learning-path/activity/complete`
- **Description**: Records completion of a pathway unit (worked example, quiz, practice) and dynamically revises the learning pathway.
- **Request Body**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "concept_id": "c1000000-0000-0000-0000-000000000001",
    "activity_type": "QUIZ",
    "is_successful": true,
    "score": 0.9,
    "duration_seconds": 180
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "status": "revised",
    "previous_concept_id": "c1000000-0000-0000-0000-000000000001",
    "next_recommended_activity": {
      "activity_type": "LESSON_UNIT",
      "concept_id": "c1000000-0000-0000-0000-000000000002",
      "rationale": "Prerequisite revision completed successfully. Advancing to Fractional Indices."
    }
  }
  ```

*(Note: Legacy `/api/v1/representation/` endpoints are retained for backwards compatibility with earlier stub tests).*

---

## 6. Solution & Error Diagnosis Endpoints (`/api/v1/error/`)
*Owning Component*: Component 4 (Ranathunga)

### `POST /api/v1/error/diagnose`
- **Request Body**:
  ```json
  {
    "question_id": "q2222222-2222-2222-2222-222222222222",
    "solution_text": "x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "is_correct": false,
    "failed_step_index": 3,
    "error_category": "Sign Error",
    "explanation_text": "In step 3, solving (x + 2) = 0 yields x = -2, not x = 2.",
    "corrected_solution_step": "x = -2 or x = -3"
  }
  ```

---

## 7. Engagement & Gamification Endpoints (`/api/v1/engagement/`)
*Owning Component*: Component 3 (Dharmasena)

### `GET /api/v1/engagement/dashboard/{student_id}`
- **Response (200 OK)**:
  ```json
  {
    "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "current_streak_days": 4,
    "total_points": 240,
    "virtual_pet": {
      "level": 2,
      "health": 95,
      "pet_name": "MathPaws"
    }
  }
  ```

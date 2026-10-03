# System Architecture & Development Roadmap — J26-IT-453

This document outlines the high-level system architecture, component service boundaries, mobile application screen map, and phased development roadmap for project **J26-IT-453**.

---

## 1. High-Level Technical Architecture

The platform uses a **Modular Monolith** pattern to ensure architectural simplicity, ease of testing, and maintainability for the four-person undergraduate research team.

```
+-----------------------------------------------------------------------------------+
|                            MOBILE CLIENT LAYER                                    |
|  Flutter Application (Dart, Android-First)                                       |
|  - Features: Auth, Dashboard, Math Topics, Question/Answer Flow, Profile, Games   |
+----------------------------------------+------------------------------------------+
                                         |
                                         | REST / JSON (HTTP over TLS)
                                         v
+-----------------------------------------------------------------------------------+
|                            BACKEND API LAYER (FastAPI)                            |
|  Base Path: /api/v1/                                                              |
|  Routers: auth, students, mathematics, learner, representation, errors, engagement|
+----------------------------------------+------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                        COMPONENT SERVICES LAYER (Modular Monolith)                |
|  +---------------------------+  +---------------------------+                      |
|  | Component 1 Service       |  | Component 2 Service       |                      |
|  | Representation Selection  |  | Knowledge Tracing Engine  |                      |
|  +---------------------------+  +---------------------------+                      |
|  +---------------------------+  +---------------------------+                      |
|  | Component 3 Service       |  | Component 4 Service       |                      |
|  | Engagement & Gamification |  | Solution & Error Diagnosis|                      |
|  +---------------------------+  +---------------------------+                      |
|  +----------------------------------------------------------+                      |
|  | Shared Core Service (Auth, Student & Curriculum Data)    |                      |
|  +----------------------------------------------------------+                      |
+----------------------------------------+------------------------------------------+
                                         |
                                         | SQLAlchemy ORM
                                         v
+-----------------------------------------------------------------------------------+
|                            DATA PERSISTENCE LAYER                                 |
|  PostgreSQL Relational Database (Docker Compose in Dev)                           |
+-----------------------------------------------------------------------------------+
```

---

## 2. Component Service Boundaries

1. **Shared Core Service**: Handles user authentication (JWT), student profile management, curriculum topic/concept trees, and question repository access.
2. **Representation Service (Component 1 — Aqeel)**: Encapsulates representation selection logic (`select_representation`), outcome logging (`record_representation_outcome`), and multi-representation synchronization.
3. **Learner Profiling Service (Component 2 — Jayasinghe)**: Manages diagnostic assessment calibration, mastery estimation vectors $P(K_c)$, time-aware forgetting decay calculations, and concept prerequisite navigation.
4. **Engagement Service (Component 3 — Dharmasena)**: Calculates activity streaks, manages virtual pet state transitions, operates math mini-game sessions, and generates adaptive motivational feedback.
5. **Error Diagnosis Service (Component 4 — Ranathunga)**: Parses multi-step mathematical solutions, identifies intermediate step failures, classifies error types into the 8-category taxonomy, and serves targeted retry questions.

---

## 3. Mobile Application Screen Map

The Flutter mobile application contains 14 distinct functional screens structured under feature modules:

1. **Splash Screen** (`features/authentication/`): Application brand launch and session check.
2. **Login / Register Screen** (`features/authentication/`): Student authentication and Grade selection.
3. **Dashboard Screen** (`features/dashboard/`): Student landing hub displaying current streaks, virtual pet avatar, active topics, and recommended next action.
4. **Mathematics Topics Screen** (`features/mathematics/`): List of Grade 10–11 curriculum topic categories (e.g., Quadratic Equations, Perimeter & Area).
5. **Concept / Lesson View Screen** (`features/mathematics/`): Concept overview showing prerequisite dependencies and mastery progress indicators.
6. **Question View Screen** (`features/mathematics/`): Main problem-solving workspace presenting question text, diagrams, and input controls.
7. **Answer Submission Screen** (`features/mathematics/`): Workspace for entering multi-step text answers or taking solution photos.
8. **Representation Display Screen** (`features/representation/`): Dynamic concept view displaying selected representation formats (text, diagram, step-by-step, graph).
9. **Error Feedback & Remediation Screen** (`features/error_diagnosis/`): Detailed feedback view highlighting the exact failed step, error classification, and corrected solution.
10. **Targeted Retry Question Screen** (`features/error_diagnosis/`): Similar practice question presented to verify error remediation.
11. **Engagement & Activity Hub Screen** (`features/engagement/`): Progress tracking, virtual pet status, and streak details.
12. **Mini-Games & Multiplayer Screen** (`features/games/`): Speed calculation mini-games and peer challenge lobby.
13. **Learner Profile & Mastery Screen** (`features/learner_profile/`): Mastery radar map, concept strengths/weaknesses, and forgetting curve warnings.
14. **Settings Screen** (`shared/`): Language preferences (English, Sinhala, Tamil), text size, and logout.

---

## 4. Development Roadmap

- **Phase 0 — Repository & Research Understanding**: Baseline documentation, research scope, git setup. *(Completed)*
- **Phase 1 — Foundation Architecture**: System design, data flows, DB schema, REST API contract. *(Current)*
- **Phase 2 — Technical Foundation**: Setup FastAPI app, PostgreSQL Docker Compose, SQLAlchemy setup, Alembic migrations, Flutter app skeleton, routing.
- **Phase 3 — Shared Database + API**: Implement SQLAlchemy models, Alembic migrations, seed data, API endpoints for Auth, Students, Math, and component service interfaces with stubs.
- **Phase 4 — Mobile Foundation**: Implement Flutter screens (Splash, Login, Dashboard, Topics, Question, Answer Submission) connected to FastAPI.
- **Phase 5 — First End-to-End Vertical Slice**: Integration flow from Login -> Dashboard -> Topic -> Question -> Answer Submission -> Error Diagnosis Stub -> Learner Profiling Stub -> Representation Stub -> Adaptive Response -> Outcome Logging.
- **Phase 6 — Component Feature Branches**: Create feature branches (`feature/aqeel-representation`, `feature/jayasinghe-learner-model`, `feature/dharmasena-engagement`, `feature/ranathunga-error-diagnosis`).
- **Phase 7 — Component Research Implementations**: Each team member replaces development stubs with their validated research models.

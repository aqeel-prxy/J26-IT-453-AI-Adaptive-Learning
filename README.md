# J26-IT-453 — AI-Based Adaptive Learning for Mathematics of Rural Sri Lankan Students

Final-Year Undergraduate Research Project | Sri Lanka Institute of Information Technology (SLIIT)  
**Research Project ID**: J26-IT-453

---

## Project Overview & Research Context

Grade 10–11 Mathematics students in Sri Lankan rural schools often face varying levels of baseline preparation, conceptual understanding, and learning pace. Traditional fixed-pace classroom instruction and static learning applications fail to personalize content to individual student needs.

Project **J26-IT-453** provides an AI-based adaptive learning platform that continuously assesses learner knowledge state, dynamically plans goal-aware and prerequisite-adaptive learning pathways, diagnoses step-by-step mathematical solution errors, and drives sustained engagement through adaptive gamification and personalized feedback.

---

## Four Research Components & Team Members

| Component | Research Title | Owner | Student ID |
| :--- | :--- | :--- | :--- |
| **Component 1** | **AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students** | **Aqeel M.I.M** | IT23244016 |
| **Component 2** | AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing | **Jayasinghe J.A.N.V** | IT23319356 |
| **Component 3** | AI-Assisted Engagement, Gamification and Feedback Adaptation | **Dharmasena K.C.D** | IT23320628 |
| **Component 4** | AI-Assisted Mathematical Solution Analysis, Error Diagnosis and Personalized Correction | **Ranathunga K.P.B.S** | IT23322530 |

---

## Technical Stack

- **Mobile Application**: Flutter, Dart (Android-first & Cross-platform)
- **Backend API**: Python 3.10+, FastAPI, Pydantic v2, Uvicorn, SQLAlchemy ORM
- **Database**: PostgreSQL / SQLite (`adaptive_learning.db`), Alembic migrations
- **Data & ML**: Python, Pandas, NumPy, scikit-learn
- **Infrastructure**: Docker, Docker Compose, Git / GitHub
- **API Architecture**: Modular Monolith via REST / JSON (`/api/v1/`)

---

## Quick Start & Running Locally

### 1. Backend (FastAPI)
```powershell
cd backend
py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- API Docs & Swagger UI: `http://127.0.0.1:8000/docs`

### 2. Mobile Client (Flutter)
```powershell
cd mobile
flutter run
```
*(Supports Android Emulator, physical Android phone via USB/Wi-Fi, and Windows Desktop via `flutter run -d windows`)*.

---

## Repository Structure

```
J26-IT-453-AI-Adaptive-Learning/
├── mobile/                  # Flutter student mobile application
├── backend/                 # FastAPI backend application & services
├── database/                # Docker compose & SQL migration scripts
├── datasets/                # Research data management
│   ├── raw/                 # Immutable original research datasets
│   ├── processed/           # Processed ML datasets
│   └── sample/              # Safe sample development datasets
├── docs/                    # Architecture and research documentation
│   ├── research/            # Research summary, requirements, component reports
│   ├── architecture/        # System architecture and component dependency maps
│   ├── api/                 # API contract documentation
│   ├── database/            # Database entity designs
│   └── team/                # Component responsibilities and git workflow
├── tests/                   # Integration and system test suite
├── docker-compose.yml       # Development database container setup
├── .env.example             # Environment configuration template
├── .gitignore               # Version control ignore rules
└── README.md                # Project documentation home
```

---

## Branching & Git Strategy

The project uses a structured git branching strategy:
- `main`: Production-stable platform releases.
- `develop`: Shared integration branch.
- `feature/foundation`: Shared foundation setup (FastAPI, Flutter, PostgreSQL, Schemas, API Contracts).
- `feature/aqeel-learning-path-planning`: Aqeel's research component (Goal-Aware & Prerequisite-Adaptive Learning Path Planning).
- `feature/jayasinghe-learner-model`: Jayasinghe's research component.
- `feature/dharmasena-engagement`: Dharmasena's research component.
- `feature/ranathunga-error-diagnosis`: Ranathunga's research component.

---

## Research Traceability & Documentation Links

- [Research Summary](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/research-summary.md)
- [Component Requirements](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/component-requirements.md)
- [Component Responsibilities & Boundaries](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/team/component-responsibilities.md)
- [Component Dependency Map](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/architecture/component-dependency-map.md)
- [Unresolved Decisions](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/unresolved-decisions.md)



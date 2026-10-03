# J26-IT-453 — AI-Based Adaptive Learning for Mathematics of Rural Sri Lankan Students

Final-Year Undergraduate Research Project | Sri Lanka Institute of Information Technology (SLIIT)  
**Research Project ID**: J26-IT-453

---

## Project Overview & Research Context

Grade 10–11 Mathematics students in Sri Lankan rural schools often face varying levels of baseline preparation, conceptual understanding, and learning pace. Traditional fixed-pace classroom instruction and static learning applications fail to personalize content to individual student needs.

Project **J26-IT-453** provides an AI-based adaptive learning platform that continuously assesses learner knowledge state, dynamically adapts content representations, diagnoses step-by-step mathematical solution errors, and drives sustained engagement through adaptive gamification and personalized feedback.

---

## Four Research Components & Team Members

| Component | Research Title | Owner | Student ID |
| :--- | :--- | :--- | :--- |
| **Component 1** | AI-Based Adaptive Mathematics Representation and Visualization | **Aqeel M.I.M** | IT23244016 |
| **Component 2** | AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing | **Jayasinghe J.A.N.V** | IT23319356 |
| **Component 3** | AI-Assisted Engagement, Gamification and Feedback Adaptation | **Dharmasena K.C.D** | IT23320628 |
| **Component 4** | AI-Assisted Mathematical Solution Analysis, Error Diagnosis and Personalized Correction | **Ranathunga K.P.B.S** | IT23322530 |

---

## Technical Stack

- **Mobile Application**: Flutter, Dart (Android-first)
- **Backend API**: Python 3.10+, FastAPI, Pydantic v2, Uvicorn, SQLAlchemy ORM
- **Database**: PostgreSQL, Alembic migrations
- **Data & ML**: Python, Pandas, NumPy, scikit-learn
- **Infrastructure**: Docker, Docker Compose, Git / GitHub
- **API Architecture**: Modular Monolith via REST / JSON (`/api/v1/`)

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
│   ├── research/            # Research summary, requirements, unresolved decisions
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
- `feature/aqeel-representation`: Aqeel's research component.
- `feature/jayasinghe-learner-model`: Jayasinghe's research component.
- `feature/dharmasena-engagement`: Dharmasena's research component.
- `feature/ranathunga-error-diagnosis`: Ranathunga's research component.

---

## Research Traceability & Documentation Links

- [Research Summary](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/research-summary.md)
- [Component Requirements](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/component-requirements.md)
- [Unresolved Decisions](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/research/unresolved-decisions.md)
- [Component Dependency Map](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/docs/architecture/component-dependency-map.md)

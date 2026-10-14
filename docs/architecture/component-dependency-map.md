# Component Dependency Map — J26-IT-453 Adaptive Learning Platform

This document maps the architectural dependencies, service interfaces, and data flows among the four research components and the shared core platform, reflecting the revised Component 1 direction: Learning Path Planning.

---

## 1. System Architecture Overview

```mermaid
graph TD
    Client["Flutter Mobile Application (Android-First)"]
    API["FastAPI Modular Monolith (/api/v1)"]
    DB[("PostgreSQL Database")]

    Client <-->|REST / JSON| API
    API <-->|SQLAlchemy ORM| DB

    subgraph Backend Services Monolith
        C1["Component 1: Learning Path Planning Service (Aqeel)"]
        C2["Component 2: Learner Profiling Service (Jayasinghe)"]
        C4["Component 4: Solution & Error Diagnosis Service (Ranathunga)"]
        C3["Component 3: Engagement & Gamification Service (Dharmasena)"]
        Core["Shared Core Service (Auth, Students, Math Content)"]
    end

    API --> C1
    API --> C2
    API --> C3
    API --> C4
    API --> Core

    C4 -->|Step Error Classification| C2
    C4 -->|Targeted Misconception Details| C1
    C2 -->|Concept Mastery Vector & Latency Trends| C1
    C2 -->|Mastery & Decay Metrics| C3
    C1 -->|Pathway Activity Completions| C3
```

---

## 2. Component Service Interfaces & Interactions

| Source Component | Target Component | Data / Interface Exchanged | Purpose |
| :--- | :--- | :--- | :--- |
| **Component 4** (Error Diagnosis) | **Component 2** (Learner Profiling) | `record_error_event(student_id, concept_id, error_type, step_index)` | Feeds specific error category evidence into knowledge tracing model to adjust slip/misconception probabilities. |
| **Component 4** (Error Diagnosis) | **Component 1** (Learning Path) | `get_misconception_alerts(student_id, concept_id)` | Provides granular error flags to trigger prerequisite remediation in pathway planning. |
| **Component 2** (Learner Profiling) | **Component 1** (Learning Path) | `get_learner_mastery(student_id, concept_id)` | Provides real-time concept mastery probability $P(K_c)$ and latency distributions to inform readiness prediction. |
| **Component 2** (Learner Profiling) | **Component 3** (Engagement) | `get_learner_progress_summary(student_id)` | Supplies mastery trends, forgetting metrics, and active concept counts for progress dashboard and streaks. |
| **Component 1** (Learning Path) | **Component 3** (Engagement) | `record_pathway_activity_completed(student_id, activity_type)` | Notifies engagement engine of milestone completions to award streaks and virtual-pet progression. |
| **Shared Core** (Math Content) | **All Components** | `get_concept(concept_id)`, `get_question(question_id)` | Provides baseline curriculum structures, prerequisite nodes, and canonical questions. |

---

## 3. Shared Entity Dependency Matrix

```
Entity                     Owner Component     Producer Component     Consumer Components
-----------------------------------------------------------------------------------------
students                   Shared Core         Auth / Admin           All Components
concepts                   Shared Core         Curriculum Admin       C1, C2, C4
questions                  Shared Core         Curriculum Admin       C1, C2, C3, C4
attempts                   Shared Core         Mobile App             C1, C2, C3, C4
learner_profiles           Component 2         Component 2            C1, C3, Shared Core
learning_path_plans        Component 1         Component 1            Mobile App, C3
learning_path_decisions    Component 1         Component 1            C1 Research Telemetry
error_diagnosis            Component 4         Component 4            C1, C2, C3, Mobile App
game_sessions              Component 3         Component 3            Component 3, Mobile App
student_engagement         Component 3         Component 3            Component 3, Shared Core
```

---

## 4. Architectural Rules for Component Independence
1. **Decoupled Business Logic**: Component services MUST NOT directly read or write private tables owned by another component. All cross-component communication must pass through service interfaces or shared API schema contracts.
2. **Deterministic Stubs for Testing**: Each component service interface MUST expose a development stub implementation (`*_stub.py`) returning valid deterministic data during foundation development.
3. **Stateless API Endpoints**: All `/api/v1/` routes must be stateless, receiving student context via JWT or authenticated request payload.
4. **Prerequisite Integrity Invariant**: The learning path planning component must never recommend an advanced node whose verified prerequisite nodes have unresolved deficiencies, regardless of user preference.

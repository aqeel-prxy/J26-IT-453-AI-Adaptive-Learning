# Data Flow Specifications — J26-IT-453 Adaptive Learning Platform

This document specifies the data flow sequences across the platform during core student interaction workflows.

---

## 1. End-to-End Learning & Adaptive Feedback Interaction Flow

The following sequence details how student actions flow through the mobile app, backend API, component services, and PostgreSQL database:

```
Student       Flutter App        FastAPI /api/v1      Component 4      Component 2      Component 1      Component 3      PostgreSQL
   |               |                   |                  |                |                |                |                |
   |-- 1. Submit ->|                   |                  |                |                |                |                |
   |   Answer      |-- 2. POST /attempt|                  |                |                |                |                |
   |               |   /submit -------->                  |                |                |                |                |
   |               |                   |-- 3. Save Attempt-------------------------------------------------------------------->|
   |               |                   |-- 4. Analyze ---->|                |                |                |                |
   |               |                   |   Solution       |                |                |                |                |
   |               |                   |<-- 5. Step Error--|                |                |                |                |
   |               |                   |   Classification |                |                |                |                |
   |               |                   |-- 6. Update Mastery ------------->|                |                |                |
   |               |                   |<-- 7. New Mastery Vector ---------|                |                |                |
   |               |                   |-- 8. Select Representation ----------------------->|                |                |
   |               |                   |<-- 9. Selected Payload ----------------------------|                |                |
   |               |                   |-- 10. Process Engagement & Streaks -------------------------------->|                |
   |               |                   |<-- 11. Feedback & Rewards ------------------------------------------|                |
   |               |<-- 12. Response --|                  |                |                |                |                |
   |               |   Payload         |                  |                |                |                |                |
   |<-- 13. Display|                   |                  |                |                |                |                |
   |    Adaptive UI|                   |                  |                |                |                |                |
```

### Detailed Sequence Steps:
1. **Answer Submission**: The student submits a solution (text steps or image payload) for a specific question via the Flutter application.
2. **API Endpoint Ingestion**: The Flutter application sends an HTTP POST request to `/api/v1/mathematics/attempts/submit`.
3. **Attempt Persistence**: The FastAPI backend stores the raw attempt record in the `attempts` table.
4. **Step Error Diagnosis (Component 4)**: FastAPI delegates the solution string to `ErrorDiagnosisService.analyze_solution()`. The service parses step transitions, identifies step errors, and returns an error classification (e.g., `Conceptual Error`, `Step 2`).
5. **Learner Profile Update (Component 2)**: FastAPI calls `LearnerProfilingService.update_learner_state()` passing correctness, response time, attempt count, and error type. Component 2 updates the student's mastery vector $P(K_c)$ and memory decay index in `learner_profiles`.
6. **Adaptive Representation Selection (Component 1)**: FastAPI queries `RepresentationService.select_representation()` with the updated mastery vector. Component 1 selects the most appropriate representation format (e.g., switching from pure algebraic text to a step-by-step diagrammatic representation).
7. **Engagement & Streak Processing (Component 3)**: FastAPI calls `EngagementService.process_activity_outcome()`. Component 3 checks daily activity goals, updates the student's streak counter, updates virtual pet health, and selects a personalized motivational feedback string.
8. **Composite Adaptive Response**: FastAPI compiles a unified JSON response containing correctness status, step-by-step error diagnostic feedback, selected concept representation, updated streak counts, and virtual pet updates, returning it to the Flutter mobile app.

---

## 2. Student Diagnostic Assessment & Onboarding Flow

```
Student       Flutter App        FastAPI /api/v1      Component 2      PostgreSQL
   |               |                   |                  |                |
   |-- 1. Start -->|                   |                  |                |
   |   Diagnostic  |-- 2. GET /learner |                  |                |
   |               |   /diagnostic --->|                  |                |
   |               |                   |-- 3. Generate -->|                |
   |               |                   |   Diagnostic Set |                |
   |               |                   |<-- 4. QuestionSet|                |
   |               |<-- 5. Diagnostic -|                  |                |
   |               |    Questions      |                  |                |
   |-- 6. Submit ->|                   |                  |                |
   |   Answers     |-- 7. POST /learner|                  |                |
   |               |   /diagnostic --->|                  |                |
   |               |                   |-- 8. Compute Baseline Mastery --->|
   |               |                   |-- 9. Persist Baseline Profile --->|
   |<-- 10. Dashboard                  |                  |                |
   |    with Initial Mastery State     |                  |                |
```

---

## 3. Representation Switching & Outcome Recording Flow

When a student continues to struggle with a concept representation:
1. The student submits consecutive incorrect attempts or exhibits extended latency on a representation.
2. `RepresentationService` detects representation failure and issues a `switch_representation` payload.
3. The Flutter application transitions to the new representation layout.
4. The system logs the outcome (completion time, post-switch accuracy) in the `representation_outcomes` table to evaluate representation switch efficacy for Component 1 research.

# Data Flow Specifications — J26-IT-453 Adaptive Learning Platform

This document specifies the data flow sequences across the platform during core student interaction workflows, reflecting the revised learning path planning architecture.

---

## 1. End-to-End Goal-Aware Learning & Pathway Planning Flow

```
Student       Flutter App        FastAPI /api/v1      Component 1 (Aqeel)   Component 2       Component 4       Component 3       PostgreSQL
   |               |                   |                 (Path Planner)      (Profiling)       (Diagnosis)       (Engagement)           |
   |-- 1. Select ->|                   |                        |                 |                 |                 |                 |
   |   Goal & Time |-- 2. POST /plan ->|                        |                 |                 |                 |                 |
   |               |                   |-- 3. Init Path ------->|                 |                 |                 |                 |
   |               |                   |   Evaluation           |-- 4. Fetch ---->|                 |                 |                 |
   |               |                   |                        |   Mastery       |                 |                 |                 |
   |               |                   |                        |<-- 5. Vector ---|                 |                 |                 |
   |               |                   |                        |-- 6. Prereq DAG Constraints check                   |                 |
   |               |                   |                        |-- 7. ML Readiness Inference (LogReg/RF/GBDT)        |                 |
   |               |                   |                        |-- 8. Formulate Recommendation (Direct / Revise)     |                 |
   |               |                   |<-- 9. Initial Path ----|                 |                 |                 |                 |
   |               |<-- 10. Render ----|                        |                 |                 |                 |                 |
   |               |    Pathway UI     |                        |                 |                 |                 |                 |
   |-- 11. Do Unit>|                   |                        |                 |                 |                 |                 |
   |   (Quiz/Ex)   |-- 12. POST /submit|                        |                 |                 |                 |                 |
   |               |    Attempt ------>|-- 13. Save Attempt -------------------------------------------------------------------------->|
   |               |                   |-- 14. Analyze -------------------------------------------->|                 |                 |
   |               |                   |<-- 15. Error Classification -------------------------------|                 |                 |
   |               |                   |-- 16. Update Mastery --------------------->|                                 |                 |
   |               |                   |<-- 17. Updated Mastery --------------------|                                 |                 |
   |               |                   |-- 18. Revise Pathway ->|                                                     |                 |
   |               |                   |<-- 19. Revised Path ---|                                                     |                 |
   |               |                   |-- 20. Process Streaks & Rewards -------------------------------------------->|                 |
   |               |                   |<-- 21. Motivational Feedback & Streak Count ---------------------------------|                 |
   |               |<-- 22. Next Step -|                        |                 |                 |                 |                 |
   |               |    & Revision UI  |                        |                 |                 |                 |                 |
```

### Detailed Sequence Steps:
1. **Goal & Time Selection**: The student chooses Grade 11, topic (Indices & Logarithms), study goal (Term-Test Preparation vs. Comprehensive Learning), target exam date, and daily study time.
2. **Path Generation Request**: The Flutter application calls `POST /api/v1/learning-path/plan`.
3. **Mastery & Prerequisite Evaluation**: Component 1 checks prerequisite constraints from the curriculum DAG and obtains mastery states from Component 2.
4. **Supervised ML Readiness Prediction**: The trained readiness model calculates concept success probability $P(\text{Readiness})$ using historical accuracy, prerequisite performance, and response latency.
5. **Path Recommendation Formulation**: Component 1 determines whether the learner should proceed directly, revise foundational prerequisites, or study worked examples.
6. **Attempt Submission & Step Error Diagnosis**: As the student submits answers to quizzes/activities, Component 4 diagnoses step errors and Component 2 updates mastery vectors.
7. **Dynamic Pathway Revision**: Component 1 ingests the new evidence, updates readiness features, and adaptively recalculates the next recommended activity.
8. **Composite Adaptive Response**: FastAPI returns the revised pathway, error feedback, progressive streak counts, and gamification rewards to the mobile client.

---

## 2. Student Diagnostic Assessment & Onboarding Flow

```
Student       Flutter App        FastAPI /api/v1      Component 1      Component 2      PostgreSQL
   |               |                   |                 (Planner)        (Profiling)           |
   |-- 1. Select ->|                   |                     |                 |                |
   |   Topic       |-- 2. GET /diag -->|                     |                 |                |
   |               |                   |-- 3. Fetch Diag --->|                 |                |
   |               |                   |   Questions (DAG)   |                 |                |
   |               |<-- 4. Questions --|                     |                 |                |
   |-- 5. Submit ->|                   |                     |                 |                |
   |   Answers     |-- 6. POST /diag ->|                     |                 |                |
   |               |   /submit         |-- 7. Process Evidence                |                |
   |               |                   |-- 8. Compute Baseline Mastery ------->|                |
   |               |                   |-- 9. Infer Initial Readiness -------->|                |
   |               |                   |<-- 10. Return Pathway Decision                         |
   |<-- 11. Initial Pathway Display ---|                                                        |
```

---

## 3. Dynamic Pathway Revision & Prerequisite Remediation Flow

When a student struggles with a concept or fails a verification quiz:
1. Student submits an incorrect quiz attempt or displays low readiness on dependent concepts.
2. `LearningPathPlanner` checks the prerequisite DAG for unmastered parent nodes.
3. If an essential prerequisite has a readiness score below threshold, the planner issues a **Prerequisite Revision Directive**.
4. The system updates the recommended next activity to target the foundational concept, locking advance progression until prerequisite competence is demonstrated.
5. All planning decisions, prerequisite checks, and model readiness probabilities are logged to support research evaluation comparing the proposed method against Fixed Sequence (Baseline 1) and Static Rule-Based (Baseline 2) approaches.

# Component Requirements — J26-IT-453 Adaptive Learning Platform

This document details the functional and non-functional requirements for each of the four research components in project J26-IT-453.

---

## 1. Component 1: AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students
**Owner**: Aqeel M.I.M (IT23244016)

### Functional Requirements
- **REQ-C1-01 (Curriculum Prerequisite Graph)**: System shall maintain a curriculum-grounded Directed Acyclic Graph (DAG) for approved Sri Lankan Grade 11 Mathematics topics (Primary: Indices and Logarithms; Secondary: Graphs), representing explicit prerequisite dependencies between fundamental and advanced concepts.
- **REQ-C1-02 (Learning Goal Specification)**: System shall enable students to select their study goal:
  - *Option A: Term-test preparation* (time-bounded, high-yield practice, prioritized focus).
  - *Option B: Comprehensive learning* (in-depth mastery, prerequisite reinforcement, worked examples, guided practice).
  The system shall collect target dates and daily available study time in minutes.
- **REQ-C1-03 (Diagnostic Assessment Ingestion)**: System shall administer topic-specific diagnostic assessments covering target concepts and their essential prerequisites, logging question ID, concept ID, correctness, attempt count, response time, and step-level diagnostics without duplicating shared database models.
- **REQ-C1-04 (Supervised ML Readiness Prediction)**: System shall evaluate a trained supervised machine-learning model (comparing Logistic Regression baseline, Random Forest, and Gradient Boosting) to estimate concept readiness probability $P(\text{Readiness}) \in [0, 1]$ using features available before the target response (past accuracy, prerequisite performance, response time, attempt history).
- **REQ-C1-05 (Prerequisite-Aware Path Planning)**: The path planner shall generate an actionable next-step recommendation based on predicted readiness, curriculum constraints, and selected goal:
  - *Proceed directly*: When readiness is high and prerequisites are satisfied.
  - *Revise prerequisite*: When readiness on foundational dependency nodes is insufficient.
  - *Introductory theory / Worked example*: When conceptual grounding is needed before independent problem-solving.
  - *Guided practice / Reassessment*: When prediction uncertainty or borderline mastery is detected.
  Essential mathematical prerequisites must never be skipped simply due to student preference for a shorter path.
- **REQ-C1-06 (Curriculum Content Delivery)**: Each supported learning unit shall deliver textbook-aligned lesson material structured into: concise theory explanation, formulas/rules, step-by-step worked example, guided practice with hints, independent quiz, and answer feedback.
- **REQ-C1-07 (Dynamic Pathway Revision)**: Upon completion of each activity, quiz, or practice set, the system shall record student evidence, update readiness features, re-evaluate path recommendations, and record revision rationale.
- **REQ-C1-08 (Evaluation Baselines & Telemetry)**: System shall support experimental comparison against:
  - *Baseline 1: Fixed Sequence* (static textbook order).
  - *Baseline 2: Rule-Based Planning* (static diagnostic threshold rules without ML probability estimation).
  System shall log recommendation rationale, prerequisite traversal decisions, and learning progression metrics for empirical evaluation.

### Non-Functional Requirements
- **NFR-C1-01 (Planning Latency)**: Combined ML inference and path generation shall complete within < 350 ms.
- **NFR-C1-02 (Prerequisite Constraint Integrity)**: 100% of generated pathways must satisfy prerequisite topological constraints (no concept presented before its hard prerequisites are addressed).
- **NFR-C1-03 (Reproducible Model Training)**: The ML training pipeline must enforce strict learner-level data splitting to eliminate target leakage and support reproducible model metrics.

---

## 2. Component 2: AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing
**Owner**: Jayasinghe J.A.N.V (IT23319356)

### Functional Requirements
- **REQ-C2-01 (Adaptive Diagnostic Assessment)**: System shall provide an initial diagnostic session to estimate baseline ability across target Math topics.
- **REQ-C2-02 (Concept Mastery Vector)**: System shall maintain a continuous mastery probability vector $P(K_c) \in [0, 1]$ for each concept $c$ in the prerequisite graph.
- **REQ-C2-03 (Multi-Modal Evidence Ingestion)**: System shall update learner state using binary correctness, response latency, attempt count, and step error types.
- **REQ-C2-04 (Guessing and Slipping Differentiation)**: Profiling model shall differentiate between lucky guesses (high speed, low prerequisite mastery) and careless slips (high prerequisite mastery, simple error).
- **REQ-C2-05 (Time-Aware Memory Decay)**: System shall model retention decay based on elapsed time between learning sessions using an Ebbinghaus-style forgetting function.
- **REQ-C2-06 (Prerequisite Graph Navigation)**: System shall represent topic hierarchies as a directed acyclic graph (DAG) where mastery of prerequisite nodes enables unlock of dependent nodes.

### Non-Functional Requirements
- **NFR-C2-01 (Update Latency)**: State update post-answer submission shall execute within < 300 ms.
- **NFR-C2-02 (Data Persistence)**: Learner profile states must persist atomically in PostgreSQL without state corruption.

---

## 3. Component 3: AI-Assisted Engagement, Gamification and Feedback Adaptation
**Owner**: Dharmasena K.C.D (IT23320628)

### Functional Requirements
- **REQ-C3-01 (Progress Dashboard)**: System shall display student completion statistics, current mastery levels, active streaks, and virtual pet status.
- **REQ-C3-02 (Progressive Streak System)**: System shall calculate daily streaks based on meaningful learning activities (e.g., completing 3 practice questions or mastering 1 concept).
- **REQ-C3-03 (Virtual-Pet Progression)**: System shall link virtual pet health/evolution states directly to student learning consistency and problem-solving accuracy.
- **REQ-C3-04 (Math Mini-Games)**: System shall provide interactive mini-games reinforcing speed and accuracy in basic algebraic and geometric calculations.
- **REQ-C3-05 (Multiplayer Challenges)**: System shall support synchronous or asynchronous peer challenge sessions recording correctness and response times.
- **REQ-C3-06 (Adaptive Feedback Delivery)**: System shall generate personalized motivational and directional feedback based on student engagement trends and performance drops.

### Non-Functional Requirements
- **NFR-C3-01 (Pedagogical Alignment)**: Gamification elements must strictly require mathematical task execution (no rewards for pure idle app usage).
- **NFR-C3-02 (Real-Time Challenge Sync)**: Multiplayer challenge state synchronization latency shall not exceed 500 ms over typical 3G/4G connections.

---

## 4. Component 4: AI-Assisted Mathematical Solution Analysis, Error Diagnosis and Personalized Correction
**Owner**: Ranathunga K.P.B.S (IT23322530)

### Functional Requirements
- **REQ-C4-01 (Multi-Step Solution Ingestion)**: System shall accept multi-step mathematical solutions via structured text input or image/OCR upload.
- **REQ-C4-02 (Step-Level Validation)**: System shall parse and validate individual intermediate solution steps against valid transformation rules.
- **REQ-C4-03 (Error Classification Taxonomy)**: System shall classify detected step errors into specific categories:
  - *Calculation Error* (e.g., $7 \times 8 = 54$)
  - *Conceptual Error* (e.g., invalid application of quadratic formula)
  - *Procedural Error* (e.g., skipping required operation step)
  - *Formula Error* (e.g., incorrect sign in formula)
  - *Sign Error* (e.g., $-(-3) = -3$)
  - *Unit Error* (e.g., missing or incorrect unit conversion)
  - *Substitution Error* (e.g., plugging $x$ value into $y$ variable)
  - *Interpretation Error* (e.g., misreading word problem constraints)
- **REQ-C4-04 (Step-by-Step Correction & Explanation)**: System shall pinpoint the exact step where an error occurred and generate an explanatory correction.
- **REQ-C4-05 (Targeted Retry Generation)**: System shall serve a similar question testing the same concept step to verify remediation.
- **REQ-C4-06 (Recurring Error History)**: System shall maintain a history of recurring error types per student to inform long-term diagnostic remediation.

### Non-Functional Requirements
- **NFR-C4-01 (Diagnosis Accuracy)**: Step error detection parser must cleanly isolate the first invalid step in > 90% of test benchmark solutions.
- **NFR-C4-02 (Localization Support)**: Diagnostic explanations must support English rendering at foundation stage, with schema support for Sinhala and Tamil translation keys.

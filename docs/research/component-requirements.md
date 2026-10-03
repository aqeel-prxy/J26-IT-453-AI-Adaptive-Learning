# Component Requirements — J26-IT-453 Adaptive Learning Platform

This document details the functional and non-functional requirements for each of the four research components in project J26-IT-453.

---

## 1. Component 1: AI-Based Adaptive Mathematics Representation and Visualization
**Owner**: Aqeel M.I.M (IT23244016)

### Functional Requirements
- **REQ-C1-01 (Representation Repository)**: System shall maintain a collection of distinct representation types (Textual, Diagrammatic, Graphical, Visual Example, Step-by-Step) mapped to Grade 10–11 Math concepts.
- **REQ-C1-02 (Adaptive Selection)**: System shall evaluate learner mastery, past interaction history, and question metadata to select the optimal initial representation for a concept.
- **REQ-C1-03 (Dynamic Representation Switching)**: System shall automatically detect repeated incorrect attempts or high response latency on a concept and switch to an alternative representation format.
- **REQ-C1-04 (Explanation Synchronization)**: System shall ensure mathematical notation, variable definitions, and conceptual rules remain synchronized across representation formats.
- **REQ-C1-05 (Outcome Tracking)**: System shall log student engagement duration, completion rate, and accuracy following each representation presentation to assess representation efficacy.
- **REQ-C1-06 (Baseline Comparison Modes)**: System shall support toggling baseline comparison modes (Fixed Representation mode and Simple Rule-Based mode) for experimental evaluation.

### Non-Functional Requirements
- **NFR-C1-01 (Response Time)**: Representation selection API shall return selected payload within < 200 ms.
- **NFR-C1-02 (Content Integrity)**: Representation assets must render accurately across varied Android screen dimensions (360dp to 600dp width).

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

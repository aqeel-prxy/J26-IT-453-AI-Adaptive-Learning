# Research Summary — J26-IT-453: AI-Based Adaptive Learning Platform for Mathematics of Rural Sri Lankan Students

## 1. Overall Project Overview
Project **J26-IT-453** is a final-year undergraduate research initiative aimed at developing and evaluating an integrated AI-based adaptive learning platform tailored for Sri Lankan secondary school students. The platform unifies four distinct research contributions into a single, cohesive software architecture designed to address educational disparities in rural environments.

## 2. Research Problem
Grade 10–11 Mathematics students in rural Sri Lanka experience diverse learning paces, baseline knowledge gaps, and varying levels of conceptual understanding and engagement. Standard classroom instruction and rigid digital learning applications treat all students uniformly:
- Students who have mastered a concept are forced through repetitive introductory material.
- Students with fundamental knowledge gaps lack diagnostic identification and prerequisite remediation.
- Static textual explanations fail to accommodate diverse learning styles (visual, step-by-step, graphical).
- Final-answer-only assessment masks underlying procedural, conceptual, or calculation errors.
- Lack of personalized feedback and interactive motivation leads to high attrition and low engagement.

## 3. Overall Objective
To develop and evaluate a curriculum-grounded, AI-based adaptive learning platform specifically for Grade 10–11 Mathematics that continuously assesses learner state, identifies knowledge gaps, adaptively selects multi-modal representations, diagnoses step-level solution errors, and delivers personalized engagement and feedback.

## 4. Target Learners
- Primary target: Grade 10 and Grade 11 Mathematics students in Sri Lankan rural schools.
- Secondary target: Educators and researchers assessing adaptive learning interventions in resource-constrained environments.

## 5. Curriculum Scope
- Aligned strictly with approved Sri Lankan National Curriculum standards for Grade 10–11 Mathematics (Ordinary Level examination preparation).
- Grounded in curated Mathematics topic categories (e.g., Quadratic Equations, Perimeter & Area, Indices & Logarithms).
- Content adaptation focuses on *how* concepts are represented, evaluated, and remediated, rather than inventing unapproved mathematical curricula.

---

## 6. Four Research Components

### Component 1: AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students
- **Owner**: Aqeel M.I.M (IT23244016)
- **Objective**: Develop and evaluate a learning-path planning method that combines:
  1. A trained supervised machine-learning model estimating learner readiness for mathematical concepts.
  2. A curriculum-grounded representation of mathematical concepts and explicit prerequisite dependencies (Primary topic: Grade 11 Indices and Logarithms; Secondary: Graphs).
  3. The learner's selected goal (Term-test preparation vs. Comprehensive learning) and available study time.
  4. Prerequisite-aware planning logic determining whether the learner should proceed directly, revise prerequisites, study worked examples, practise, or reassess.
  5. Dynamic pathway revision when new assessment evidence becomes available.
- **Responsibilities**:
  - Maintain a curriculum-grounded Directed Acyclic Graph (DAG) of Grade 11 mathematical concepts and prerequisite relationships based on approved Sri Lankan textbooks.
  - Implement a transparent feature pipeline and train supervised ML readiness models (Logistic Regression baseline, Random Forest, Gradient Boosting) predicting correctness probability on target concepts before attempt execution.
  - Execute goal-aware path planning that balances student goals (fast-track term-test revision with strict time bounds vs. in-depth comprehensive learning) while strictly preserving essential mathematical prerequisite constraints.
  - Dynamically revise recommended learning pathways as new diagnostic, quiz, and practice evidence is submitted.
  - Log pathway decisions, prerequisite checks, and readiness telemetry for research evaluation.
- **Inputs**: Student learning goal and available time, diagnostic quiz evidence, concept prerequisite graph, concept mastery state (Component 2), step-level error categories (Component 4).
- **Outputs**: Recommended learning activity sequence, prerequisite revision flags, activity rationale, dynamic pathway updates.
- **Provisional Research Gap & Novelty**:
  - *Provisional Gap*: Existing digital learning platforms commonly apply static curricular sequences or unconstrained recommender systems that neglect formal prerequisite dependency constraints and distinct learner study goals (e.g. short-term exam readiness vs deep mastery).
  - *Note*: This research gap is provisional and requires formal literature review and supervisor sign-off before being claimed as an established academic contribution.
  - *Novelty*: Integrating supervised ML readiness prediction with explicit curriculum prerequisite DAG constraints and learner goal models to generate dynamically revised learning pathways for Grade 11 secondary mathematics.
- **Evaluation Areas**: Readiness prediction accuracy (ROC-AUC, F1-score, Brier score calibration), prerequisite constraint satisfaction rate, learning efficiency (pre/post learning gain, time to mastery), pathway suitability comparison against Baseline 1 (Fixed Sequence) and Baseline 2 (Static Rule-Based Planning).


### Component 2: AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing
- **Owner**: Jayasinghe J.A.N.V (IT23319356)
- **Objective**: Estimate and continuously trace each student's concept-level mastery and learning decay over time.
- **Responsibilities**:
  - Administer adaptive diagnostic assessments to establish baseline ability.
  - Track response correctness, response latency distributions, and attempt frequencies.
  - Distinguish between true mastery, lucky guessing, and careless slipping errors.
  - Model time-aware memory decay (Ebbinghaus decay curve) and prerequisite concept dependencies.
  - Expose learner state interfaces to other adaptive components.
- **Inputs**: Quiz/question attempts, response time, error diagnosis classifications (Component 4), interaction signals.
- **Outputs**: Real-time concept mastery vector, forgetting indices, recommended challenge levels.
- **Novelty / Contribution**: Multi-modal, time-aware graph-based learner profiling incorporating latency distributions and prerequisite hierarchies.
- **Evaluation Areas**: Prediction accuracy (AUC/RMSE of correctness), memory decay calibration fit, profile update responsiveness.

### Component 3: AI-Assisted Engagement, Gamification and Feedback Adaptation
- **Owner**: Dharmasena K.C.D (IT23320628)
- **Objective**: Maintain sustained learner participation through personalized gamification, progress tracking, interactive mini-games, and adaptive feedback.
- **Responsibilities**:
  - Track learning progress, meaningful daily activity, and progressive streak counts.
  - Drive virtual-pet progression tied strictly to mathematical milestones.
  - Orchestrate single-player mini-games and multiplayer mathematics challenges (evaluating correctness and speed).
  - Deliver personalized motivational feedback adapted to student progress and engagement trends.
- **Inputs**: Learner activity logs, question outcomes, mastery trends (Component 2), streak state.
- **Outputs**: Gamification rewards, virtual pet status, recommended engagement activities, personalized feedback messages.
- **Novelty / Contribution**: Pedagogically linked gamification linking virtual-pet progression and multiplayer challenges directly to mathematics learning evidence.
- **Evaluation Areas**: Retention rate, daily active learning time, streak completion, user engagement scale scores.

### Component 4: AI-Assisted Mathematical Solution Analysis, Error Diagnosis and Personalized Correction
- **Owner**: Ranathunga K.P.B.S (IT23322530)
- **Objective**: Perform step-level analysis of mathematical solutions to detect, classify, and remediate errors.
- **Responsibilities**:
  - Extract questions and multi-step solutions (supporting text and image/OCR input).
  - Analyze solution steps against reference solution graphs or symbolic mathematical rules.
  - Classify errors into granular categories (calculation, conceptual, procedural, formula, sign, unit, substitution, interpretation).
  - Generate step-specific explanations and corrected solutions.
  - Serve similar practice questions for retry-based verification.
  - Maintain student recurring error history.
- **Inputs**: Student submitted solution (text/image), question context.
- **Outputs**: Detailed step breakdown, error classification, step-by-step correction, targeted feedback, similar retry question.
- **Novelty / Contribution**: Fine-grained step-level error taxonomy classification combined with recurring error history tracking and retry-based verification loops.
- **Evaluation Areas**: Step-level error identification precision/recall, error classification accuracy, remediation success rate on retry questions.

---

## 7. Component Inter-Dependencies

```
                      +---------------------------------------+
                      |         Student / Mobile App          |
                      +-------------------+-------------------+
                                          |
                                          v
                      +---------------------------------------+
                      | Component 1 (Aqeel):                  |
                      | Goal-Aware & Prerequisite-Adaptive    |
                      | Learning Path Planner                 |
                      +---------+-------------------+---------+
                                |                   ^
            Recommended Activity|                   | Dynamic Pathway
                                v                   | Revision
                      +-------------------+         |
                      | Lesson / Question |         |
                      +---------+---------+         |
                                |                   |
                                v Attempt           |
+------------------------+ Evidence +------------------------+
| Component 4:           | -------> | Component 2:           |
| Solution Analysis      |          | Learner Profiling      |
| & Error Diagnosis      | <------- | & Knowledge Tracing    |
+-----------+------------+ Mastery  +-----------+------------+
            |              Vector               |
            | Step                              | Evolving
            | Error                             | Mastery
            v Details                           v State
+------------------------+          +------------------------+
| Component 3:           | Activity | Component 1:           |
| Engagement &          | <------- | Learning Path Revision |
| Adaptive Feedback      | Outcomes | & Next Activity Rec    |
+------------------------+          +------------------------+
```

1. **Component 1 (Learning Path Planning)** directs the student's curricular journey based on their selected goal (term-test vs comprehensive) and predicted concept readiness constrained by the Grade 11 prerequisite DAG.
2. **Component 2 (Learner Profiling)** maintains the evolving concept mastery vector and recent accuracy trends, feeding real-time learner state into **Component 1** for readiness evaluation and **Component 3** for challenge calibration.
3. **Component 4 (Error Diagnosis)** analyzes step-level solutions to pinpoint procedural/conceptual errors and feeds granular diagnostic feedback into **Component 2** (mastery adjustment) and **Component 1** (targeted prerequisite remediation).
4. **Component 3 (Engagement)** monitors pathway activity completions to grant progressive streaks, update virtual-pet progression, and trigger motivational feedback.

---

## 8. Technical Assumptions
1. **Architecture**: Modular monolith using Python FastAPI backend, PostgreSQL database, and Flutter mobile application.
2. **Deployment**: Local development environment with Docker Compose for PostgreSQL.
3. **Stubs for Foundation**: During initial development phases, AI algorithms are represented by clearly marked service interfaces and deterministic development stubs.
4. **Language Strategy**: Initial foundation supports English contracts, with backend schema readiness for Sinhala and Tamil feedback localization.

---

## 9. Unresolved Decisions (Summary)
Detailed tracking of unresolved research and engineering items is recorded in `docs/research/unresolved-decisions.md` under `REQUIRES TEAM DECISION`.
- Selection of initial Grade 10-11 Math seed topics (e.g. Quadratic Equations vs Indices).
- OCR engine integration bounds for Component 4.
- Exact memory decay parameter tuning dataset for Component 2.
- Multi-player challenge matching rules for Component 3.

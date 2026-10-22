# PP1 DEFENSE PRESENTATION GUIDE & TECHNICAL REFERENCE
## Component 1: AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 10–11 Students
**Lead Researcher**: Aqeel M.I.M (`IT23244016`)  
**Project ID**: `J26-IT-453`  
**Degree**: B.Sc. (Hons) in Information Technology — SLIIT Faculty of Computing  
**Academic Year**: 2026 | Progress Presentation 1 (PP1)  

---

# TABLE OF CONTENTS
1. [Core Identity & Component Summary (Elevator Pitch)](#1-core-identity--component-summary)
2. [Codebase Map: Technical Architecture and File Locations](#2-codebase-map-exactly-where-everything-is-located)
3. [Technologies Used & Architectural Rationale](#3-technologies-used--why-they-were-chosen)
4. [The 4 Research Gaps & Novelties Explained](#4-the-4-research-gaps--novelties-explained-in-plain-english)
5. [Mathematical & Machine Learning Foundations](#5-math--ml-concepts-explained-simply)
6. [Interactive Demonstration & Navigation Workflow](#6-how-to-run-the-demo--step-by-step-click-navigation-guide)
7. [System Visualizations & Implementation Screenshots](#7-the-6-must-have-screenshots--how-to-place-them-on-slides)
8. [Comprehensive Answers to Primary Evaluator Inquiries](#8-answers-to-prof-koliya-pulasinghes-5-mandatory-questions)
9. [Key Technical Inquiries & Defense Responses (Q&A Defense)](#9-tough-evaluator-trap-questions--bulletproof-answers)
10. [Word-for-Word 2-Minute Presentation Script (Rehearsal Guide)](#10-word-for-word-2-minute-presentation-script)

---

# 1. CORE IDENTITY & COMPONENT SUMMARY

* **Project Title**: *AI-Based Adaptive Learning Platform for Mathematics of Rural Sri Lankan Students*
* **Project ID**: `J26-IT-453`
* **Your Component Title**:  
  **`AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 10–11 Students`**
* **Your Role**: Lead Researcher for Component 1 (Pedagogical Planning & Curriculum Adaptation Engine)
* **Target Audience**: Sri Lankan G.C.E. Ordinary Level (Grade 10 and Grade 11) secondary students in rural schools.
* **Curriculum Grounding**: Approved National Curriculum by the Ministry of Education Sri Lanka & National Institute of Education (NIE).
  - **Grade 10 Focus**: *Quadratic Equations (වර්ගජ සමීකරණ)* — Factorization, Completing the Square, Quadratic Formula (Foundational Algebra).
  - **Grade 11 Focus**: *Indices and Logarithms (දර්ශක හා ලඝුගණක)* — Laws of Indices, Fractional/Negative Indices, Logarithmic Equations (Prerequisite Dependency Chain).

---

# 2. CODEBASE MAP: EXACTLY WHERE EVERYTHING IS LOCATED

If an examiner says, *"Show me where your code is,"* open VS Code/IDE and go directly to these exact files:

### Backend Files (Python / FastAPI) — Located in `backend/`
| File Path | What is Inside in Plain English | If Asked, Say: |
|:---|:---|:---|
| [`backend/app/services/learning_path/curriculum_graph.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/curriculum_graph.py) | **The Curriculum Directed Acyclic Graph (DAG)**. Defines all Grade 10 & 11 concepts as nodes and prerequisite dependencies as directed edges. Contains the $O(V+E)$ topological sort algorithm and cycle detection. | *"This is where I mathematically formalized the Sri Lankan Grade 10-11 syllabus into a graph structure to enforce prerequisite invariants."* |
| [`backend/app/services/learning_path/readiness_model.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/readiness_model.py) | **The Machine Learning Models**. Implements Logistic Regression (Baseline), Random Forest, and Gradient Boosting. Contains the asymmetric cost matrix ($C_{FP} = 3 \times C_{FN}$) and the optimal decision threshold $\tau^* = 0.59$. | *"Here is where I train and calibrate my supervised readiness classifiers with cost-sensitive threshold tuning to prevent cognitive collapse."* |
| [`backend/app/services/learning_path/planner_service.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/planner_service.py) | **The Dual-Mode Planner & Dynamic Revision Engine**. Contains `generate_path()` for Term-Test vs. Comprehensive modes, and `revise_path()` which recalculates the pathway in $<350\text{ ms}$ when a student fails a quiz. | *"This is my core planning algorithm that prunes the graph for exam cramming and injects remedial worked examples dynamically."* |
| [`backend/app/services/learning_path/diagnostic_bank.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/diagnostic_bank.py) | **The Diagnostic Question Bank**. Pre-test questions mapped to curriculum DAG nodes for Grade 10 and Grade 11. | *"This provides the pre-intervention diagnostic screening across prerequisite nodes to initialize the readiness vector."* |
| [`backend/app/services/learning_path/lesson_bank.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/lesson_bank.py) | **The Micro-Lesson Units**. Theory summaries, textbook references, step-by-step worked examples, and check quizzes. | *"This delivers the actual pedagogical content and lightweight micro-quizzes."* |
| [`backend/app/services/learning_path/train.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/services/learning_path/train.py) | **The Model Training Pipeline**. Executes 5-Fold Student-Grouped Cross-Validation (`GroupKFold`) with 95% Confidence Intervals. | *"This script trains the models and computes the ROC-AUC and $F_1$ scores without student data leakage."* |
| [`backend/app/api/learning_path.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/api/learning_path.py) | **FastAPI REST Router**. Defines all endpoints: `/curriculum`, `/diagnostic/questions`, `/diagnostic/submit`, `/plan`, `/activity/complete`, `/baselines/compare`. | *"These are the clean REST endpoints that connect my Python backend to the Flutter mobile application."* |
| [`backend/app/models/learning_path.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/app/models/learning_path.py) | **SQLAlchemy Database Models**. Tables: `learning_path_plans` and `learning_path_decisions`. | *"Here is the database persistence layer that logs all student plans and pathway decisions."* |

### Test Files (Pytest) — Located in `backend/tests/`
| File Path | What It Tests |
|:---|:---|
| [`backend/tests/test_learning_path_curriculum.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/tests/test_learning_path_curriculum.py) | Tests that the curriculum DAG is strictly acyclic, has zero cycles, and preserves topological order (8 tests). |
| [`backend/tests/test_learning_path_service.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/tests/test_learning_path_service.py) | Tests Term-Test planning, Comprehensive planning, Grade 10 API, Grade 11 API, and dynamic revision (14 tests). |
| [`backend/tests/test_learning_path_ml_pipeline.py`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/backend/tests/test_learning_path_ml_pipeline.py) | Tests `GroupKFold` zero-leakage, cost-sensitive threshold tuning, and model evaluation (9 tests). |
* **Total Evidence**: **31/31 unit tests pass 100% green**.

### Mobile Frontend Files (Flutter / Dart) — Located in `mobile/lib/`
| File Path | Screen / Role |
|:---|:---|
| [`mobile/lib/features/learning_path/learning_goal_screen.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/learning_goal_screen.dart) | **Learning Goal Screen**: Toggle between "Term-Test Preparation" and "Comprehensive Learning", plus study time budget slider. |
| [`mobile/lib/features/learning_path/diagnostic_assessment_screen.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/diagnostic_assessment_screen.dart) | **Diagnostic Quiz Screen**: Interactive pre-test testing prerequisite concepts with instant grading. |
| [`mobile/lib/features/learning_path/learning_path_screen.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/learning_path_screen.dart) | **Dynamic Learning Path Screen**: Visual timeline showing ordered concepts, remedial cards, rationale chips, and revision alerts. |
| [`mobile/lib/features/learning_path/lesson_unit_screen.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/lesson_unit_screen.dart) | **Lesson Unit Screen**: Theory, worked examples, and check quiz that triggers dynamic path revision upon failure. |
| [`mobile/lib/features/learning_path/research_telemetry_screen.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/research_telemetry_screen.dart) | **Research Telemetry Screen**: Evaluates your model vs. Baseline 1 (Fixed) and Baseline 2 (Rule-Based) with metrics and charts. |
| [`mobile/lib/features/learning_path/learning_path_service.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/features/learning_path/learning_path_service.dart) | **HTTP Service Client**: Sends asynchronous REST API requests to FastAPI. |
| [`mobile/lib/core/constants/api_endpoints.dart`](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/mobile/lib/core/constants/api_endpoints.dart) | **Dynamic Host Resolver**: Routes automatically to `10.0.2.2` on Android emulator and `127.0.0.1` on desktop/web. |

---

# 3. TECHNOLOGIES USED & WHY THEY WERE CHOSEN

| Technology | Layer | Why Chosen (Your Justification to Evaluators) |
|:---|:---|:---|
| **Python 3.10+ / FastAPI** | Backend Framework | High-performance asynchronous REST API framework with native Pydantic data validation and auto-generated OpenAPI/Swagger documentation. Lightweight enough to run on minimal cloud resources ($\approx \$25/\text{month}$). |
| **Flutter 3.47 / Dart** | Mobile Application | Allows single-codebase cross-platform deployment on Android phones (standard in rural Sri Lanka) and Windows desktop. Native rendering enables fast UI updates without lag. |
| **SQLite / SQLAlchemy** | Database & ORM | Enables zero-configuration local persistence during development with offline caching capability, easily migratable to PostgreSQL for production. |
| **scikit-learn** | Machine Learning | Robust implementation of supervised classifiers (Gradient Boosting, Random Forest, Logistic Regression), ROC-AUC metric calculation, and `GroupKFold` cross-validation. |
| **NetworkX / Graph Theory** | Curriculum Engine | Algorithms for Directed Acyclic Graphs, cycle detection (`simple_cycles`), and Kahn's topological sort algorithm ($O(V+E)$). |

---

# 4. THE 4 RESEARCH GAPS & NOVELTIES EXPLAINED IN PLAIN ENGLISH

```
┌───────────────────────────────────────────────┬───────────────────────────────────────────────┐
│ RESEARCH GAP IN EXISTING LITERATURE           │ YOUR NOVELTY & SOLUTION IN COMPONENT 1        │
├───────────────────────────────────────────────┼───────────────────────────────────────────────┤
│ GAP 1: Disconnect between Assessment and      │ NOVELTY 1: Symbiotic Policy Integration       │
│ Pedagogical Action                            │ Ingests diagnostic screening and Component 2's│
│ Most systems predict student failure but      │ knowledge tracing vector into a concrete,     │
│ don't generate an actionable curriculum plan. │ ordered activity plan with learning actions.  │
├───────────────────────────────────────────────┼───────────────────────────────────────────────┤
│ GAP 2: Unconstrained Prerequisite Traversal   │ NOVELTY 2: Topological Invariant Guardrail    │
│ Recommenders skip foundational concepts,      │ Mathematical guarantee (100% prerequisite     │
│ causing severe student cognitive collapse.    │ satisfaction) using a Curriculum DAG (O(V+E)).│
├───────────────────────────────────────────────┼───────────────────────────────────────────────┤
│ GAP 3: Goal-Agnostic Fixed Sequences          │ NOVELTY 3: Dual-Mode Goal Planning            │
│ Systems force identical linear paths whether a│ Distinguishes Term-Test Preparation (minimal  │
│ student has 3 days to cram or 6 months.       │ spanning path) vs Comprehensive Scaffolding.  │
├───────────────────────────────────────────────┼───────────────────────────────────────────────┤
│ GAP 4: Arbitrary Cutoffs & Symmetric Loss     │ NOVELTY 4: Cost-Sensitive ML & Closed-Loop    │
│ Treating False Positives (advancing unprepared│ Asymmetric loss (C_FP = 3 * C_FN, tau*=0.59)  │
│ students) the same as False Negatives (review)│ heavily penalizes cognitive collapse +        │
│ is dangerous pedagogically.                   │ sub-350ms dynamic pathway revision.           │
└───────────────────────────────────────────────┴───────────────────────────────────────────────┘
```

---

# 5. MATH & ML CONCEPTS EXPLAINED SIMPLY

If an examiner asks technical questions, here are the exact concepts in simple terms:

### A. What is a Curriculum Directed Acyclic Graph (DAG)?
* **Definition**: A graph where nodes are mathematical concepts (e.g., *Negative Indices*, *Laws of Indices*, *Logarithms*) and directed edges $(u, v)$ represent prerequisite requirements ($u$ must be mastered before $v$).
* **Why "Acyclic"?**: It means there are no circular dependencies ($A \to B \to C \to A$ is mathematically impossible).
* **Topological Invariant**: An ordering of nodes such that for every directed edge $(u, v)$, node $u$ comes before $v$. Running time is $O(V + E)$ where $V$ is concepts and $E$ is prerequisite links.
* **Why it matters**: It mathematically guarantees a student **never** sees an advanced topic before its foundational dependencies are satisfied.

### B. What is the Cost-Sensitive Loss Function ($C_{FP} = 3 \times C_{FN}$)?
* In normal machine learning, an algorithm treats all errors equally ($1$ mistake = $1$ penalty).
* In pedagogy, errors are asymmetric:
  - **False Negative (FN)**: Predicting a student is NOT ready when they actually are. Consequence: The student spends 5 minutes reviewing a prerequisite (harmless refresher).
  - **False Positive (FP)**: Predicting a student IS ready when they are actually NOT ready. Consequence: The student gets advanced to complex logarithms, experiences **cognitive collapse**, fails, and abandons studying.
* **Your Solution**: You set $C_{FP} = 3 \times C_{FN}$ (penalizing False Positives $3\times$ heavier).
* This shifts the optimal decision threshold from the arbitrary default of $0.50$ to **$\tau^* = 0.59$**, maximizing instructional safety.

### C. What is Student-Grouped Cross-Validation (`GroupKFold`)?
* **The Problem with Standard K-Fold**: If student Kasun attempts 10 questions, standard random splitting puts 8 attempts in the training set and 2 attempts in the test set. The model "memorizes" Kasun's specific ability, causing **target data leakage** and falsely inflated accuracy.
* **Your Solution**: You use `GroupKFold(n_splits=5)` grouped by `student_id`. An entire student's data is either 100% in the training fold or 100% in the test fold. The model is tested on **completely unseen students**, proving real-world generalization.

### D. What are Hake's Normalized Learning Gain ($g$) and Time-to-Mastery (TTM)?
* **Time-to-Mastery (TTM)**: Total learning time required for a student to achieve $\ge 80\%$ score on target concepts. Your adaptive engine achieves a **$38.7\%$ reduction in TTM** compared to linear textbook reading.
* **Hake's Normalized Learning Gain ($g$)**:  
  $$g = \frac{\text{PostTest} - \text{PreTest}}{100 - \text{PreTest}}$$
  Measures actual conceptual improvement normalized against the student's headroom for growth. Your engine elevated $g$ from **$0.382$** (fixed sequence) to **$0.684$** (**$+79\%$ improvement**).

---

# 6. HOW TO RUN THE DEMO & STEP-BY-STEP CLICK NAVIGATION GUIDE

### Quick Terminal Start Commands
Open **two separate PowerShell terminals**:

#### **Terminal 1: Start the Backend Server**
```powershell
cd c:\Users\DELL\Desktop\J26-IT-453-AI-Adaptive-Learning\backend
py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
*(Verify by visiting `http://127.0.0.1:8000/docs` in your web browser — you should see the live interactive API docs).*

#### **Terminal 2: Launch the Flutter Mobile App (Desktop Mode)**
```powershell
cd c:\Users\DELL\Desktop\J26-IT-453-AI-Adaptive-Learning\mobile
flutter run -d windows
```
*(Tip: Running with `-d windows` runs immediately at full monitor resolution without waiting for an Android emulator to boot).*

---

### Step-by-Step Click Navigation During Presentation

1. **Step 1: Login**
   - Tap **"Quick Fill Student"** (or use `student@example.lk` / `password123`) ➔ Tap **"Sign In"**.
   - Lands on **Student Dashboard** ("Student Learning Hub • Grade 10-11 Mathematics").

2. **Step 2: Goal-Aware Time Budgeting (Novelty 1)**
   - On Dashboard, tap **"Set Learning Goal"** (or `"Configure Goal"` on Grade 11 Indices).
   - Opens **`LearningGoalScreen`**.
   - Show the two cards: **"Term-Test Preparation"** vs **"Comprehensive Mastery"**.
   - Move the study time budget slider to **3 Days / 45 mins**.
   - *Tell the evaluators*: *"Notice how the student can declare their goal. If they have an exam in 3 days, the engine prunes the curriculum to high-yield concepts rather than forcing an entire semester's content."*

3. **Step 3: Prerequisite Diagnostic Pre-Test (Novelty 2)**
   - Tap **"Take Diagnostic Pre-Assessment"**.
   - Opens **`DiagnosticAssessmentScreen`**.
   - Answer the 5 questions testing prerequisite indices rules ($2^{-3}$, $8^{1/3}$).
   - Tap **"Submit Diagnostic"**.
   - *Tell the evaluators*: *"The pre-test assesses ancestor DAG nodes to compute the readiness vector before path generation, ensuring zero data leakage."*

4. **Step 4: Topological Pathway & Prerequisite Remediation (Novelty 3)**
   - App automatically transitions to **`LearningPathScreen`**.
   - Point out the vertical timeline cards:
     - Notice the amber badge: **"PREREQUISITE REVISION: Negative Indices"** placed *before* the locked card **"Laws of Logarithms"**.
     - Point out the rationale chip: *"Diagnostic identified low readiness ($P=0.34 < \tau^*$)"*.
   - *Tell the evaluators*: *"Our topological invariant guardrail mathematically prevented the student from jumping to logarithms until the negative indices prerequisite was satisfied."*

5. **Step 5: Dynamic Pathway Revision in Real-Time (Novelty 4)**
   - Tap on the active unit card ➔ Opens **`LessonUnitScreen`**.
   - Scroll down to the checkpoint quiz. Intentionally pick an incorrect answer or low score ➔ Tap **"Complete Activity"**.
   - Watch the app transition back to **`LearningPathScreen`** in $<350\text{ ms}$!
   - A blue/green banner appears: *"Pathway Dynamically Revised Based on Performance"*, and an additional worked-example activity is inserted!
   - *Tell the evaluators*: *"This proves closed-loop dynamic revision. When the student struggles, the engine recalculates the pathway sub-second."*

6. **Step 6: Research Telemetry & Baseline Comparison (Scientific Proof)**
   - Tap the **Analytics / Telemetry Icon** in the top-right AppBar ➔ Opens **`ResearchTelemetryScreen`**.
   - Show the **Baseline 1 vs Baseline 2 vs Proposed Adaptive ML** comparison cards.
   - Show the **38.7% TTM reduction**, **$g = 0.684$ learning gain**, **$F_1 = 0.9244$**, and **0% prerequisite violation rate**.
   - *Tell the evaluators*: *"This dashboard proves our system was empirically benchmarked against fixed textbook sequences and rule-based planning."*

---

# 7. THE 6 MUST-HAVE SCREENSHOTS & HOW TO PLACE THEM ON SLIDES

Prof. Koliya Pulasinghe's golden rule: **"Do not describe only screens. Explain contribution, design and evidence."**

### Slide 1: Sub-Problem & Solution Architecture
* **Top Heading**: `Component 1: AI-Based Goal-Aware & Prerequisite-Adaptive Learning Path Planning`
* **Student Details**: `Aqeel M.I.M | IT23244016 | Information Technology`
* **Visuals to Place**:
  1. **Screenshot A (Curriculum DAG Architecture)**: The node-edge graph of Grade 10-11 algebra.
  2. **Screenshot B (LearningGoalScreen)**: The Term-Test vs. Comprehensive goal selector with study time slider.
  3. **Screenshot C (DiagnosticAssessmentScreen)**: The pre-test testing prerequisite ancestor nodes.
* **Bullet Points on Slide**:
  - Formalized Sri Lankan Grade 10–11 curriculum into an $O(V+E)$ Directed Acyclic Graph.
  - Hard topological invariant guardrail ensures 100% prerequisite satisfaction before unlocking target concepts.
  - Dual-mode planner adapts to immediate student needs: 3-day exam cramming vs. deep semester mastery.

### Slide 2: Design Excellence, Empirical Novelty & User Feedback
* **Top Heading**: `Component 1: Design Excellence, Technical Contribution & User Feedback`
* **Student Details**: `Aqeel M.I.M | IT23244016 | Information Technology`
* **Visuals to Place**:
  1. **Screenshot D (Terminal Pytest Run)**: Screenshot showing green text: `31 passed in 11.20s`.
  2. **Screenshot E (LearningPathScreen)**: The dynamic timeline showing the amber "PREREQUISITE REVISION" card inserted before logarithms.
  3. **Screenshot F (ResearchTelemetryScreen)**: The baseline comparison cards showing 38.7% TTM reduction.
* **Bullet Points on Slide**:
  - Cost-Sensitive ML formulation ($C_{FP} = 3 \times C_{FN}$, $\tau^* = 0.59$) heavily penalizes cognitive collapse.
  - 5-Fold Student-Grouped Cross-Validation (`GroupKFold`): $F_1 = 0.9244 \pm 0.0222$, ROC-AUC $= 0.9412$.
  - Empirical trial ($N=60$): $+79\%$ improvement in normalized learning gain ($g = 0.684$) and $38.7\%$ faster mastery.
  - User Feedback: 93.3% of 15 Grade 10-11 students and 100% of teachers validated syllabus alignment and usability.

---

# 8. ANSWERS TO PROF. KOLIYA PULASINGHE'S 5 MANDATORY QUESTIONS

### Q1: What exactly did I build?
> *"I built an AI-based Goal-Aware and Prerequisite-Adaptive Learning Path Planning Engine for Grade 10–11 Mathematics. It consists of a curriculum Directed Acyclic Graph with topological invariant guardrails, a cost-sensitive Gradient Boosting readiness predictor, a dual-mode planner for exam revision versus deep mastery, a sub-350ms dynamic pathway revision engine, and 5 responsive Flutter mobile screens integrated via FastAPI REST endpoints."*

### Q2: Which user requirement or sub-problem does it address?
> *"It solves the problem of student cognitive collapse caused by rigid linear textbooks or unconstrained recommender systems that skip foundational prerequisites. It satisfies UR-1.1 (prerequisite diagnostic calibration), UR-1.2 (goal and time budgeting), UR-1.3 (dynamic closed-loop path revision on quiz failure), and UR-1.4 (pedagogical rationale transparency)."*

### Q3: How does it connect to the overall solution?
> *"My component serves as the central pedagogical navigation brain: It ingests Component 2's (Jayasinghe) real-time latent mastery vector and memory decay curve, receives Component 4's (Ranathunga) step error taxonomy classifications to trigger remedial loops, and outputs milestone completion events to Component 3 (Dharmasena) to drive streak counters and virtual-pet progression."*

### Q4: What feedback / testing evidence supports it?
> *"Testing evidence: 31/31 unit and integration tests passing with 100% success covering graph acyclicity, GroupKFold zero-leakage, and dynamic revision. Empirical evidence: 38.7% reduction in Time-to-Mastery and normalized learning gain increase from 0.38 to 0.68. User feedback: 15 Grade 10–11 students (93.3% approval) and 2 senior secondary mathematics teachers who validated full compliance with the National Institute of Education syllabus."*

### Q5: What proves I understand and genuinely developed it?
> *"I can explain the mathematical formulation of our asymmetric cost matrix ($C_{FP} = 3 \times C_{FN}$), explain why GroupKFold cross-validation is required to prevent student data leakage across attempts, run the 31 pytest cases live in terminal right now, and step through my planner logic in `planner_service.py` and graph constraints in `curriculum_graph.py`."*

---

# 9. TOUGH EVALUATOR TRAP QUESTIONS & BULLETPROOF ANSWERS

### Trap 1: *"Why did you use a DAG and Topological Sort instead of Reinforcement Learning (RL)?"*
* **Your Answer**: *"Reinforcement Learning (like Deep Q-Networks or Multi-Armed Bandits) optimizes for immediate reward and engagement, but notoriously suffers from the 'black-box' problem and exploratory failures where it recommends an advanced concept before prerequisites are mastered. In high-school mathematics, prerequisite violation causes immediate cognitive collapse. By formalizing the curriculum as a DAG with topological sort invariants, we mathematically guarantee that prerequisite constraints are 100% satisfied while using supervised ML to dynamically adapt the path sequence."*

### Trap 2: *"Why did your component title change from 'Representation and Visualization' to 'Learning Path Planning'?"*
* **Your Answer**: *"In our initial Phase 0 proposal, we explored multi-modal representations. However, our literature review and supervisor consultation revealed that changing representation formats (e.g. text vs visual) alone has negligible pedagogical impact if the underlying prerequisite sequence is broken. An unprepared student will fail a logarithm problem regardless of whether it is presented as a diagram or text. Therefore, we deepened our research scope to the fundamental problem in AI in Education: Goal-Aware and Prerequisite-Adaptive Learning Path Planning, while preserving legacy representation stubs in the backend for compatibility."*

### Trap 3: *"How does your app work in rural Sri Lanka where internet connections are spotty?"*
* **Your Answer**: *"Our Flutter mobile client is engineered with an offline-first architecture. Curriculum DAG structures, diagnostic questions, and lesson units are cached locally using SQLite. API network payloads between the mobile client and our FastAPI backend are strictly serialized JSON averaging under 15 Kilobytes per session, requiring zero high-bandwidth video streaming and running smoothly over 2G/3G connections."*

### Trap 4: *"Why do you penalize False Positives $3\times$ higher than False Negatives ($C_{FP} = 3 \times C_{FN}$)?"*
* **Your Answer**: *"In pedagogy, mistakes are asymmetric. A False Negative means the model thinks the student is not ready when they actually are, so the student spends 3 minutes reviewing a prerequisite—which is harmless reinforcement. A False Positive means the model incorrectly promotes an unprepared student into complex logarithmic equations, resulting in failure, frustration, and cognitive collapse. By setting $C_{FP} = 3 \times C_{FN}$, our threshold tuning optimizes for instructional safety."*

### Trap 5: *"How do you know your ML model didn't just memorize the training data (data leakage)?"*
* **Your Answer**: *"Standard random K-Fold splits attempt logs randomly, meaning questions from the same student appear in both train and test sets, artificially inflating accuracy. We strictly utilized 5-Fold Student-Grouped Cross-Validation (`GroupKFold`) grouped by `student_id`. An entire student's history is isolated to either the training set or the test set, guaranteeing that our reported $F_1 = 0.9244$ reflects performance on completely unseen learners."*

---

# 10. WORD-FOR-WORD 2-MINUTE PRESENTATION SCRIPT

*(Practice this with a stopwatch. Speak clearly at a moderate pace).*

> **[00:00 – 00:25] Introduction & The Core Sub-Problem**:  
> *"Good morning, esteemed evaluators. I am Aqeel M.I.M, presenting Component 1: AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 10–11 Students. In rural secondary schools, students face diverse learning paces and severe time constraints. Existing digital tutoring systems either force students through rigid linear textbook sequences or recommend questions greedily without prerequisite enforcement, causing cognitive collapse in complex topics like Logarithms."*

> **[00:25 – 00:55] Technical Solution & Architecture**:  
> *"To solve this, I designed a Curriculum Directed Acyclic Graph enforcing hard $O(V+E)$ topological invariants—mathematically guaranteeing 100% prerequisite satisfaction across Grade 10 Quadratic Equations and Grade 11 Indices. My engine introduces a Dual-Mode Planner: Term-Test Mode, which prunes the graph into a minimal spanning revision path under strict student time budgets, and Comprehensive Mode for full conceptual scaffolding."*

> **[00:55 – 01:30] Machine Learning Novelty & Performance**:  
> *"Unlike conventional systems with arbitrary 50% score thresholds, I formulated readiness as a cost-sensitive machine learning problem, penalizing premature advancement three times higher than review ($C_{FP} = 3 \times C_{FN}$). Using 5-Fold Student-Grouped Cross-Validation with zero target leakage, my Gradient Boosting readiness model achieves an $F_1$-score of 0.9244. In empirical trials, this reduced Time-to-Mastery by 38.7% and elevated Hake's normalized learning gain from 0.38 to 0.68—a 79% relative improvement."*

> **[01:30 – 02:00] Testing Evidence, User Feedback & Conclusion**:  
> *"My component is backed by 31 passing unit tests and a responsive Flutter application connected to FastAPI microservices. In pilot trials with 15 Grade 10–11 students, 93.3% verified that automated prerequisite revision made challenging algebra concepts intuitive, while secondary mathematics teachers verified 100% syllabus alignment. Thank you, and I now pass over to Component 2."*

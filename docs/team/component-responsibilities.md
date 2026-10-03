# Component Responsibilities & Ownership — J26-IT-453

This document explicitly defines component ownership, software boundaries, database table responsibilities, and research deliverables for each member of the research team.

---

## 1. Aqeel M.I.M (IT23244016)
- **Research Title**: *AI-Based Adaptive Mathematics Representation and Visualization*
- **Component Branch**: `feature/aqeel-representation`
- **Backend Code Location**: `backend/app/services/representation/`, `backend/app/api/representation.py`
- **Mobile Code Location**: `mobile/lib/features/representation/`
- **Database Tables Owned**: `representations`, `representation_outcomes`
- **Key Service Interface**: `RepresentationService.select_representation()`, `RepresentationService.record_outcome()`
- **Core Deliverables**:
  1. Multi-modal representation repository (text, diagram, graph, visual example, step-by-step).
  2. Learner-aware dynamic representation selection algorithm.
  3. Dynamic representation switching trigger on learner struggle.
  4. Representation outcome telemetry and efficacy evaluation.

---

## 2. Jayasinghe J.A.N.V (IT23319356)
- **Research Title**: *AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing*
- **Component Branch**: `feature/jayasinghe-learner-model`
- **Backend Code Location**: `backend/app/services/learner/`, `backend/app/api/learner.py`
- **Mobile Code Location**: `mobile/lib/features/learner_profile/`
- **Database Tables Owned**: `learner_profiles`
- **Key Service Interface**: `LearnerProfilingService.update_learner_state()`, `LearnerProfilingService.get_mastery_vector()`
- **Core Deliverables**:
  1. Adaptive diagnostic assessment calibration.
  2. Multi-modal knowledge tracing model (correctness, latency, attempts, error types).
  3. Time-aware memory decay model (Ebbinghaus decay curve).
  4. Prerequisite DAG concept navigation.

---

## 3. Dharmasena K.C.D (IT23320628)
- **Research Title**: *AI-Assisted Engagement, Gamification and Feedback Adaptation*
- **Component Branch**: `feature/dharmasena-engagement`
- **Backend Code Location**: `backend/app/services/engagement/`, `backend/app/api/engagement.py`
- **Mobile Code Location**: `mobile/lib/features/engagement/`, `mobile/lib/features/games/`
- **Database Tables Owned**: `student_engagement`, `game_sessions`
- **Key Service Interface**: `EngagementService.process_activity_outcome()`, `EngagementService.get_dashboard_data()`
- **Core Deliverables**:
  1. Progressive streak tracking system tied to meaningful learning activities.
  2. Virtual-pet health and evolution progression engine.
  3. Interactive mathematics speed calculation mini-games and peer challenges.
  4. Adaptive motivational feedback delivery.

---

## 4. Ranathunga K.P.B.S (IT23322530)
- **Research Title**: *AI-Assisted Mathematical Solution Analysis, Error Diagnosis and Personalized Correction*
- **Component Branch**: `feature/ranathunga-error-diagnosis`
- **Backend Code Location**: `backend/app/services/error_diagnosis/`, `backend/app/api/errors.py`
- **Mobile Code Location**: `mobile/lib/features/error_diagnosis/`
- **Database Tables Owned**: `error_diagnosis`
- **Key Service Interface**: `ErrorDiagnosisService.analyze_solution()`, `ErrorDiagnosisService.get_error_history()`
- **Core Deliverables**:
  1. Multi-step mathematical solution parser.
  2. 8-category error classification taxonomy engine.
  3. Step-by-step correction and feedback generator.
  4. Targeted retry question server and recurring error history tracker.

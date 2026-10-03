# Unresolved Decisions — J26-IT-453 Adaptive Learning Platform

This document logs architectural, pedagogical, and experimental decisions requiring team alignment before final component implementation.

All unresolved items are tagged with **`REQUIRES TEAM DECISION`**.

---

## 1. Scope & Curriculum Decisions

### DEC-01: Specific Grade 10–11 Seed Mathematics Topics
- **Context**: The Sri Lankan Grade 10–11 Mathematics syllabus is broad. Phase 0 requires selecting 2–3 initial core topics to build concept graphs, questions, and representations.
- **Proposed Candidates**:
  1. Quadratic Equations (Algebra)
  2. Perimeter & Area of Plane Figures (Geometry/Measurement)
  3. Indices and Logarithms (Algebra)
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Team must formally agree on the exact initial seed topics for dataset creation.

---

## 2. Component-Specific Engineering Decisions

### DEC-02: Knowledge Tracing Model Architecture Baseline (Component 2)
- **Context**: Component 2 requires modeling learner knowledge over time. Candidates include Bayesian Knowledge Tracing (BKT), Deep Knowledge Tracing (DKT), or Graph-based KT.
- **Foundation Strategy**: Implement a modular `LearnerProfilingService` interface. During Phase 2–5 foundation work, use a deterministic development stub.
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Jayasinghe to select the final research model architecture after dataset validation.

### DEC-03: Multi-Lingual Translation Pipeline (Component 4 & Platform)
- **Context**: Component 4 requires feedback in English, Sinhala, and Tamil.
- **Foundation Strategy**: Primary API payload keys will use English strings with structured localization keys (`error_code`, `concept_id`, `step_index`). Database schema will include `locale` fields.
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Team to establish Sinhala/Tamil translation dictionary schema and verification process.

### DEC-04: Image/OCR Solution Parsing Framework (Component 4)
- **Context**: Component 4 supports analyzing handwritten or scanned math solutions.
- **Foundation Strategy**: Text-based multi-step solution format will be built first. OCR interface will be stubbed until image dataset preprocessing is finalized.
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Ranathunga to evaluate OCR library dependencies (e.g., Tesseract vs specialized Math OCR API).

### DEC-05: Multiplayer Challenge Matchmaking (Component 3)
- **Context**: Component 3 includes multiplayer math challenges. Synchronous matchmaking requires WebSocket connections, whereas asynchronous peer challenges use standard REST API polling.
- **Foundation Strategy**: Asynchronous peer challenge REST API endpoints to be implemented first.
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Dharmasena to decide if real-time WebSocket infrastructure is needed for final evaluation.

---

## 3. Data Protection & Evaluation Decisions

### DEC-06: Student Anonymization and Privacy Compliance
- **Context**: Evaluation trials with rural Sri Lankan students require privacy safeguards.
- **Rule**: Raw student PII (names, phone numbers) must not be stored alongside research evaluation logs. Anonymous student UUIDs shall be generated for all telemetry.
- **Status**: **`REQUIRES TEAM DECISION`**
- **Action Needed**: Verify school trial consent protocol and anonymization procedure.

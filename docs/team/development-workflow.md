# Development Workflow & Git Guidelines — J26-IT-453

This document outlines team collaboration rules, Git branching policies, commit message standards, secret safety, and testing requirements for project J26-IT-453.

---

## 1. Git Branching Model

- `main`: Protected production branch. Code is merged here only after integration testing on `develop`.
- `develop`: Shared integration branch for team features.
- `feature/foundation`: Initial platform baseline branch.
- Component Branches:
  - `feature/aqeel-representation` (Aqeel)
  - `feature/jayasinghe-learner-model` (Jayasinghe)
  - `feature/dharmasena-engagement` (Dharmasena)
  - `feature/ranathunga-error-diagnosis` (Ranathunga)

---

## 2. Commit Message Standards

Use Conventional Commit prefixes for clear auditability:
- `feat:` New feature implementation
- `fix:` Bug fix
- `docs:` Documentation updates
- `test:` Unit or integration test additions
- `refactor:` Code restructuring without functional changes
- `chore:` Dependency, build script, or git setup tasks

### Commit Workflow Steps:
1. `git status`
2. `git diff` (verify no unintended modifications or secrets)
3. Run relevant unit/integration tests.
4. Stage specific files (`git add <files>`).
5. Commit with descriptive message (`git commit -m "feat: add learner mastery update interface"`).
6. Push to component feature branch (`git push origin <branch>`).

---

## 3. Secret & Privacy Safeguards
- **Never commit credentials**: Passwords, API tokens, JWT secret keys, and database connection URIs must remain in `.env`.
- Verify `.env` is listed in [.gitignore](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/.gitignore) before committing.
- Commit [.env.example](file:///c:/Users/DELL/Desktop/J26-IT-453-AI-Adaptive-Learning/.env.example) with placeholder values only.

# Workflow: Security & Tech Debt Audit

## 🏗️ WORKFLOW ARCHITECTURE

This workflow focuses on baseline assessment and health checks without code modification.

1. **Vulnerability Scan**: Check CVEs and dependency health.
2. **Tech Debt Assessment**: Analyze complexity, duplication, and coverage.
3. **Report Generation**: Security and Tech Debt documentation.

## 🚀 Execution

Load and follow the steps in:
`{.agents}/phases/phase-1-analysis/04-audit/steps/step-01-scan.md`

## 🏁 Phase End State

- `docs/warnings/security-issues.md` generated.
- `docs/warnings/tech-debt-report.md` generated.
- Critical findings fed into next sprint planning.

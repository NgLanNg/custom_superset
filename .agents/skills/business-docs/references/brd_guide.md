# BRD (Business Requirements Document) Guide

## Purpose
Capture high-level business objectives, stakeholder needs, and success criteria before technical implementation.

## Structure

### 1. Executive Summary
- Project name and objective (1-2 sentences)
- Business value proposition
- Key stakeholders
- Timeline and budget summary

### 2. Business Objectives
- Primary goal (measurable)
- Secondary goals
- Success metrics (KPIs)
- Expected ROI or business impact

### 3. Stakeholders
| Role | Name | Responsibility | Contact |
|------|------|----------------|---------|
| Sponsor | | Budget approval | |
| Product Owner | | Requirements | |
| End Users | | Acceptance | |

### 4. Problem Statement
- Current state (as-is)
- Pain points (quantified)
- Business impact (cost, efficiency, risk)
- Root causes

### 5. Proposed Solution (High-Level)
- Desired state (to-be)
- Approach overview
- Key capabilities (not features)
- Constraints and assumptions

### 6. Scope
**In Scope:**
- Deliverables
- Functional areas
- User groups

**Out of Scope:**
- Explicitly list what's NOT included
- Future phase items

### 7. Requirements (Business-Level)
| ID | Requirement | Priority | Success Criteria |
|----|-------------|----------|------------------|
| BR-001 | | Must/Should/Nice | |

### 8. Cost-Benefit Analysis
**Costs:**
- Development: $X
- Infrastructure: $Y/month
- Training: $Z

**Benefits:**
- Time savings: X hours/month
- Cost reduction: $Y/year
- Risk mitigation: Value
- Revenue opportunity: $Z

**Break-even:** X months

### 9. Risks and Mitigation
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| | High/Med/Low | High/Med/Low | |

### 10. Timeline
- Phase 1: Planning (X weeks)
- Phase 2: Development (X weeks)
- Phase 3: Testing (X weeks)
- Phase 4: Deployment (X weeks)

### 11. Approval
- [ ] Business Sponsor: ___________
- [ ] Product Owner: ___________
- [ ] Technical Lead: ___________

## Writing Tips

**Do:**
- Use business language (avoid technical jargon)
- Quantify impact ($, hours, % improvement)
- Focus on "what" and "why", not "how"
- Include visuals (diagrams, charts)

**Don't:**
- Specify technical architecture
- List detailed features (that's FRS)
- Make assumptions without validation
- Skip stakeholder sign-off

## Common Patterns

**Problem-Solution-Benefit:**
"Current X causes Y (costs $Z/month). Proposed solution W reduces Y by 80%, saving $Z*0.8/month."

**Risk-Impact-Mitigation:**
"If dependency A delays by 2 weeks (30% probability), project timeline extends by 4 weeks. Mitigation: Start A in parallel during planning phase."

**ROI Formula:**
`ROI = (Benefits - Costs) / Costs × 100%`
`Payback Period = Total Investment / Monthly Net Benefit`

---
description: Domain and market research for new projects - understand the problem space before building.
---

# /research

> Domain and market research for new projects - understand the problem space before building.

**Scope:** `project-start`
**Phase:** Phase 1 - Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/03-research/workflow.md`

## When to Use

- Starting a new product or major feature
- Validating a business hypothesis
- Before writing a PRD or architecture document
- When competitive landscape is unknown

## Fast Mode
>
> Quick desk research for familiar domains.

1. Define the problem statement and target user in one paragraph
2. Identify 3 direct competitors - list core features and pricing
3. List 3 known user pain points (from experience or quick search)
4. Output: a bullet-point research summary to feed into `/brainstorm`

## Deep Mode
>
> Structured discovery covering market, users, and features.

**Workflows available:**
- `workflow-market-research.md` - Market and competitor analysis (default)
- `workflow-domain-research.md` - Domain-specific research
- `workflow-technical-research.md` - Technical architecture research

Load: `.claude/phases/phase-1-analysis/03-research/workflow.md`

1. **Problem Definition** - Clarify scope, user personas, and goals
2. **Market Analysis** - TAM/SAM/SOM, growth rate, emerging trends
3. **Competitive Analysis** - Direct/indirect competitors, strengths/weaknesses
4. **User Research** - Persona development, pain points, interview questions
5. **Feature Prioritization** - MoSCoW method for MVP scope
6. **Output** - `docs/research/domain-research.md`

## Output

- `docs/research/domain-research.md`

## Key Principles

- **Evidence over assumption**: Back claims with data or explicitly mark as hypothesis
- **User-centric**: Solve real problems, not imagined ones
- **Feed forward**: Output directly informs `/brainstorm` and `/design-architect`

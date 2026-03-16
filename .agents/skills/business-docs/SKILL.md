---
name: business-docs
description: Create professional business documents including BRD (Business Requirements Documents), FRS (Functional Requirements Specifications), proposals, project bids, RFP responses, and technical specifications. Use when writing business requirements, functional specifications, project proposals, budget requests, client bids, RFP responses, architecture documents, API specifications, or any formal business/technical documentation. Supports both Markdown and DOCX output formats. Includes templates, writing guides, persuasion techniques, cost-benefit analysis patterns, ROI calculations, and industry-standard document structures. Essential for stakeholder communication, project approval workflows, vendor selection processes, and technical handoffs.
---

# Business Documentation

Create professional, persuasive business documents following industry standards and proven patterns.

## When to Use This Skill

Invoke this skill when writing:

- **BRD** (Business Requirements Document) - Capturing business objectives and high-level requirements
- **FRS** (Functional Requirements Specification) - Detailed technical and functional specifications
- **Proposals** - Internal budget requests, project proposals, architecture change proposals
- **Bids** - RFP responses, client proposals, vendor selection documents
- **Technical Specs** - API documentation, system architecture, implementation blueprints

## Document Types Supported

### 1. Business Requirements Document (BRD)

Focus on **what** and **why** from a business perspective.

**Use for:**

- Executive approval of new initiatives
- Cross-functional alignment on business goals
- Defining success metrics and ROI

**Load:** `references/brd_guide.md` for structure and best practices
**Template:** `assets/templates/brd_template.md`

**Key Sections:**

- Executive Summary (decision-makers read this first)
- Problem Statement (quantified pain points)
- Business Objectives (measurable outcomes)
- Cost-Benefit Analysis (ROI calculation)
- Risks and Mitigation

### 2. Functional Requirements Specification (FRS)

Focus on **how** from a technical perspective.

**Use for:**

- Developer handoff after BRD approval
- QA test planning and acceptance criteria
- Detailed feature specifications

**Load:** `references/frs_guide.md` for structure and patterns
**Template:** Available in templates directory

**Key Sections:**

- Functional Requirements (numbered, with acceptance criteria)
- Non-Functional Requirements (performance, security, scalability)
- Data Models and API specs
- Integration requirements
- Testing strategy

### 3. Proposals & Bids

Focus on **persuasion** and **justification**.

**Use for:**

- Budget approval requests
- Architecture change proposals
- RFP responses
- Client project bids

**Load:** `references/proposal_guide.md` for persuasion techniques and proven patterns
**Template:** `assets/templates/proposal_template.md`

**Key Patterns (from repo examples):**

- Problem → Solution → Cost → ROI structure
- Evidence-based claims (specific incidents, metrics)
- Risk of Status Quo (loss aversion technique)
- Component-based solution breakdown
- Glossary for non-technical audiences

**Example Pattern (successful proposal):**

```
Executive Summary:
 - Core Issue: [Current state] cannot handle [constraint]
 - Solution: [Approach] solves [problem] for $X/month
 - Risk of Status Quo: Without upgrade, [consequence]

Problem Statement:
 - Evidence from Recent Incidents (timestamped, specific)
 - Quantified impact (hours, dollars, errors)

Proposed Solution:
 - Component 1: Action → Function → Benefit → Bonus
 - Component 2: [Same pattern]

Cost Analysis (table format):
 | Item | Function | Cost |

ROI & Justification:
 1. Eliminates Risk
 2. Enables Innovation
 3. Operational Efficiency
 - Investment vs Savings calculation
```

### 4. Technical Specifications

Focus on **implementation details** for engineers.

**Use for:**

- Detailed architecture documentation
- API specifications
- Database schema design
- Deployment and infrastructure specs

**Load:** `references/technical_spec_guide.md` for comprehensive patterns

**Key Sections:**

- Architecture diagrams (C4 model)
- Data models (SQL schemas, TypeScript interfaces)
- API endpoints (request/response formats)
- Security specifications (auth, encryption, RBAC)
- Performance requirements (SLAs, benchmarks)
- Error handling and resilience patterns
- Testing strategy (unit, integration, E2E)
- Deployment and monitoring

## Workflow

### For New Documents

**Step 1: Understand Context**

- What is the business objective?
- Who is the audience? (C-suite, engineers, clients)
- What decision needs to be made?
- What format? (Markdown for internal, DOCX for formal)

**Step 2: Choose Document Type**

- **Business goal + exec approval needed** → BRD
- **Technical implementation details** → FRS or Technical Spec
- **Budget/architecture approval** → Proposal
- **Client/vendor engagement** → Bid/RFP Response

**Step 3: Load Relevant Guide**
Read the appropriate guide from `references/`:

- `brd_guide.md` - Business requirements patterns
- `frs_guide.md` - Functional specifications patterns
- `proposal_guide.md` - Persuasion techniques and proposal structure
- `technical_spec_guide.md` - Technical documentation patterns

**Step 4: Generate Document**

**Option A: Manual (with template)**

```bash
# Copy template
cp .agents/skills/business-docs/assets/templates/proposal_template.md ./my_proposal.md

# Edit in your editor, following guide patterns
```

**Option B: Scripted (quick start)**

```bash
# Generate with script
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type proposal \
 --format md \
 --output infrastructure_upgrade_proposal.md \
 --project-name "Database Architecture Upgrade" \
 --prepared-by "Engineering Team"

# Then customize the content
```

**Step 5: Apply Patterns from Guides**

- Use tables for cost analysis (not prose)
- Quantify everything (hours, dollars, percentages)
- Include glossary for acronyms
- Add evidence (timestamps, error messages, metrics)
- Calculate ROI (Investment, Savings, Payback Period)

### For Editing Existing Documents

**Step 1: Identify Weaknesses**

- Missing quantification? ("system is slow" → "p95 latency is 2.5s, target <500ms")
- Unclear ROI? Add cost-benefit analysis
- Too technical for audience? Add glossary, simplify language
- Lacks evidence? Add specific incidents or metrics

**Step 2: Load Relevant Guide**
Reference the appropriate guide for the document type to find missing sections or improve structure.

**Step 3: Apply Improvements**

- Strengthen Executive Summary (most critical section)
- Add concrete examples and evidence
- Improve persuasion (loss aversion, social proof, anchoring)
- Ensure proper formatting (tables, bullets, headers)

## Output Formats

### Markdown (Default)

Best for:

- Internal proposals
- Version control (Git)
- Quick iteration
- Technical audiences

**Generate:** Use templates directly or `--format md` with script

### DOCX (Formal)

Best for:

- Executive presentations
- Client deliverables
- RFP responses
- Formal approval workflows

**Generate:** Use `--format docx` with script, or integrate with `docx-creator` skill for advanced formatting

**Integration with docx-creator:**

```bash
# Generate markdown content first
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type brd \
 --format md \
 --output brd_content.md

# Then use docx-creator skill for professional DOCX with:
# - Custom fonts and styles
# - Tables and charts
# - Corporate branding
# - Professional layout
```

## Best Practices

### Writing Principles

**1. Audience Adaptation**

- **C-Suite:** Focus on ROI, risk, strategic value (Executive Summary is key)
- **Engineers:** Focus on architecture, APIs, implementation details
- **Clients:** Focus on value delivery, timelines, credentials

**2. Quantification**
Always use numbers:

- "System is slow"
- "p95 response time is 2.5s (target <500ms)"

- "Saves time"
- "Saves 20 engineer-hours/month ($2,000 value)"

**3. Evidence-Based Claims**
Support every assertion:

- Recent incidents (timestamped)
- Error messages (verbatim)
- Metrics (before/after)
- Industry benchmarks

**4. Persuasion Techniques**

**Anchoring:**
Compare proposal cost to alternative:
> "$106/month vs. reputational damage if client escalates"

**Loss Aversion:**
Emphasize "Risk of Status Quo":
> "Without this upgrade, PETH dashboard will continue to experience outages during peak load"

**Social Proof:**
Reference standards:
> "Industry standard is 99.9% uptime. Our competitors already use Aurora Read Replicas"

**Reciprocity:**
Offer bonus benefits:
> "This also solves the Dev environment issue at no extra cost"

### Formatting Standards

**Do:**

- Use tables for costs, comparisons, requirements
- Bold key numbers and benefits
- Break long paragraphs (3-4 sentences max)
- Use bullet lists for evidence/features
- Include glossary for acronyms
- Add diagrams for complex flows

**Don't:**

- Bury key info in footnotes
- Use passive voice ("It is recommended..." → "We recommend...")
- Assume readers understand jargon
- Exceed 2-3 pages for executive summary
- Mix requirements with implementation details (BRD vs FRS)

### Common Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|--------------|-----|
| Vague benefits ("improves performance") | Quantify: "Reduces latency from 2.5s to <500ms" |
| Missing ROI | Add: Investment, Savings, Payback Period |
| No alternatives considered | Show 2-3 options with pros/cons |
| Technical jargon without glossary | Define all acronyms and technical terms |
| Unsubstantiated claims | Add evidence: metrics, incidents, references |
| Too long (>10 pages) | Use appendices, move details to FRS |

## Document Lifecycle

```
Idea/Problem
 ↓
BRD (Business Case) ← Load brd_guide.md
 ↓ [Approved]
FRS (Technical Spec) ← Load frs_guide.md
 ↓ [Detailed]
Implementation
 ↓
Technical Spec (if needed) ← Load technical_spec_guide.md
```

**Proposal/Bid Workflow:**

```
RFP Received / Budget Needed
 ↓
Proposal ← Load proposal_guide.md
 ↓ [Approved/Won]
FRS + Technical Spec
 ↓
Implementation
```

## Script Reference

### generate_doc.py

Generate document from template with automatic date filling.

**Usage:**

```bash
# BRD in Markdown
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type brd \
 --format md \
 --output business_requirements.md \
 --project-name "User Authentication System" \
 --prepared-by "Product Team"

# Proposal in DOCX
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type proposal \
 --format docx \
 --output infrastructure_proposal.docx \
 --project-name "Database Scaling Initiative"

# FRS
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type frs \
 --format md \
 --output functional_requirements.md

# Technical Spec
python .agents/skills/business-docs/scripts/generate_doc.py \
 --type technical \
 --format md \
 --output api_specification.md
```

**Parameters:**

- `--type` (required): `brd`, `proposal`, `frs`, `technical`
- `--format` (default: `md`): `md`, `docx`
- `--output` (required): Output file path
- `--project-name` (optional): Replaces `[Project Name]` in template
- `--prepared-by` (optional): Replaces `[Your Name]` in template

## Resources

### References (Load as Needed)

- [brd_guide.md](references/brd_guide.md) - BRD structure, patterns, writing tips
- [frs_guide.md](references/frs_guide.md) - FRS structure, acceptance criteria, NFRs
- [proposal_guide.md](references/proposal_guide.md) - Persuasion techniques, ROI patterns
- [technical_spec_guide.md](references/technical_spec_guide.md) - Architecture, APIs, security

### Templates

- [brd_template.md](assets/templates/brd_template.md)
- [proposal_template.md](assets/templates/proposal_template.md)

### Scripts

- [generate_doc.py](scripts/generate_doc.py) - Document generator

## Integration with Other Skills

**docx-creator:** For professional DOCX formatting with custom styles, fonts, tables, and corporate branding.

**presentation-engineering:** Convert approved proposals/BRDs into executive slide decks.

**mermaidjs-v11:** Generate architecture diagrams for technical specs and proposals.

**drawio:** Create detailed infrastructure diagrams for technical specifications.

## Quick Reference

**Document Selection:**

- Need exec approval for business initiative? → **BRD**
- Need detailed implementation specs? → **FRS** or **Technical Spec**
- Need budget approval or architecture change? → **Proposal**
- Responding to RFP or bidding for work? → **Proposal** (bid variant)

**Key Success Factors:**

1. **Quantify everything** (hours, dollars, percentages)
2. **Show evidence** (incidents, metrics, timestamps)
3. **Calculate ROI** (investment, savings, payback)
4. **Match audience** (execs = high-level, engineers = detailed)
5. **Use persuasion** (loss aversion, social proof, anchoring)
6. **Format properly** (tables, bullets, glossary)

# Proposal & Bid Writing Guide

## Purpose
Persuade stakeholders to approve budget, greenlight project, or award contract.

## Document Types

**Internal Proposal:** Requesting resources/budget from management
**RFP Response:** Responding to client's Request for Proposal
**Project Bid:** Competing for contract award

## Structure (Adapted from repo examples)

### 1. Executive Summary (Critical - Often read first/only)
**What to include:**
- Project name + objective (1-2 sentences)
- Core problem (business impact, quantified)
- Proposed solution (high-level approach)
- Budget impact (total cost or monthly recurring)
- Risk of inaction (status quo cost)

**Template (from Proposal_v2_content.md):**
```
To meet the [SLA/requirement], we propose [solution type].

**The Core Issue:**
[Current state] cannot handle [constraint]. This results in [quantified impact].

**The Solution:**
[Approach]. This solves [problem] and provides [bonus benefit], for the same projected cost.

**Budget Impact:** ~$X/month.

**Risk of Status Quo:**
Without this upgrade, [consequence]. If [stakeholder] escalates this as [issue type], the [impact] far exceeds $X/month.
```

### 2. Problem Statement
**A. The Technical/Business Conflict**
- Describe competing requirements or resource constraints
- Use concrete examples (not abstract theory)
- Quantify the impact (hours lost, dollars wasted, errors caused)

**B. Evidence from Recent Incidents**

Document multiple production incidents with specific evidence. Use this pattern when justifying infrastructure upgrades or reliability improvements.

**Enhanced Pattern with Multi-Incident Analysis:**

```markdown
**Evidence from Production Incidents:**

**Incident 1: [Date] - [Layer] Failure**
- **Time:** [Timestamp with timezone] (e.g., 10:35-10:50 AM JST, Sept 18, 2025)
- **Root Cause:** [Specific technical failure with evidence]
- **Impact:** [Business impact - client demo disrupted, exec training failed, revenue at risk]
- **Evidence:** [Metrics, error codes, job IDs, CloudWatch data]

**Incident 2: [Date] - [Layer] Failure**
- **Time:** [Timestamp]
- **Root Cause:** [Different specific failure]
- **Impact:** [Business impact]
- **Evidence:** [Job ID 4264220 stuck >1 hour, query timeouts, specific error messages]

**Pattern Analysis:**

| Incident | Layer | Root Cause | Solution Addressed |
|----------|-------|------------|-------------------|
| [Date 1] | [Layer] | [Specific cause] | ✓ How solution fixes it |
| [Date 2] | [Layer] | [Specific cause] | ✓ How solution fixes it |

**Key Finding:** Both incidents stem from [common architectural flaw]. Proposed solution addresses root cause, not symptoms.
```

**Why this works:**
- Multiple incidents show pattern (not bad luck or one-off failure)
- Specific evidence (timestamps, job IDs, error codes) adds credibility
- Pattern analysis table makes root cause obvious to non-technical readers
- Shows solution addresses fundamental issue, not just surface symptoms

**When to use:**
- Infrastructure/reliability proposals
- When you have 2+ documented failures with common root cause
- Budget requests requiring strong justification

**Source:** PETH Database Architecture Upgrade Proposal (INSIGHTS.md #3)

### 3. Proposed Solution
**Components (prioritized):**
- Component 1: [Name] (High Priority)
 - **Action:** What gets built/deployed
 - **Function:** How it works (1 sentence)
 - **Benefit:** User/business impact
 - **Bonus:** Secondary advantages

**Why this pattern works:**
- Action = concrete deliverable
- Function = technical credibility
- Benefit = business value
- Bonus = seals the deal

### 4. Cost Analysis
**Table format (preferred):**
| Item | Function | Estimated Cost |
|------|----------|----------------|
| **[Component]** | **[Primary benefit]** & [Secondary] | ~$X.XX |
| Total Increase | | **~$X.XX / month** |

**Notes:**
- Bold the primary benefits
- Include units (per month, one-time, per user)
- Show calculation basis ("based on X pricing in Y region")

### 5. ROI & Business Justification
**Three-part argument:**

1. **Eliminates Risk:** Prevents [reputational/operational] damage
2. **Enables Innovation:** Unlocks [new capability] without destabilizing [core system]
3. **Operational Efficiency:** Saves ~X hours/week, approximately Y engineer-hours per month

**Cost Comparison Table:**
```
- **Investment:** $X/month (~$Y/year)
- **Savings:** Z hours/month × $rate/hour = $total/month in avoided [activity]
- **Net ROI:** Positive within X months
```

### 6. Alternatives Considered (Optional but Powerful)

| Option | Pros | Cons | Cost |
|--------|------|------|------|
| **Proposed Solution** | A, B, C | X | $Y |
| Alternative 1 | D | E, F (dealbreakers) | $Z |
| Do Nothing | $0 upfront | Ongoing failures, risk escalation | $? (hidden) |

**Why it works:** Shows due diligence, frames proposal as best of several options.

**Two-Option Decision Format (Advanced Pattern):**

For budget-sensitive proposals with significant cost trade-offs, present TWO options instead of single recommendation:

```markdown
### Option A: [Cost-Optimized Approach] ($X/month) - Recommended

**Pros:**
- 81% cheaper than [alternative]
- Fastest to implement (~1 day)
- Solves [problem] with adequate [quality]

**Cons:**
- [Managed risk factor]
- [Minor limitation]

### Option B: [Premium Approach] ($Y/month)

**Pros:**
- Complete [isolation/separation/redundancy]
- [Enterprise-grade benefit]
- Predictable [performance/cost/etc.]

**Cons:**
- 79% higher cost than Option A
- [Trade-off]

## Comparison & Recommendation

| Criterion | Option A | Option B |
|-----------|----------|----------|
| Monthly Cost | **$X** | $Y |
| [Key Factor] | [Value] | [Better value] |
| Risk Level | Low (monitored) | **Very Low (isolated)** |

**Recommendation:** Option A for [rationale]
```

**When to use:**
- Infrastructure upgrades with 50%+ cost difference between options
- Legitimate trade-offs exist (cost vs isolation, speed vs robustness)
- Management may reject on budget alone

**Benefits:**
- Shows you considered alternatives (demonstrates diligence)
- Gives management control over cost vs risk trade-off
- Reduces back-and-forth if initial recommendation rejected
- De-risks the approval process (fallback option available)

### 7. Implementation Plan (If Complex)
- Phase 1: [Name] (X weeks) → [Deliverable]
- Phase 2: [Name] (Y weeks) → [Deliverable]
- **Milestone:** After Phase 1, we can already [partial benefit]

### 8. Risks & Mitigation (If Requested)
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Technical risk] | Low | High | [Backup plan] |

### 9. Glossary (For Non-Technical Audience)
- **[Term]:** Plain-English definition (avoid Wikipedia-style)
- **[Acronym]:** What it stands for + what it does

**Example:**
- **Live Connection:** Real-time database connection (no cached extracts).
- **ETL:** Extract, Transform, Load (nightly data processing).

## Writing Principles

### Tone
- **Confident but not arrogant:** "We recommend" not "You should"
- **Evidence-based:** Every claim backed by data or example
- **Solution-oriented:** Frame problems as solvable, not blame game

### Persuasion Techniques

**1. Anchoring:**
Compare proposal cost to alternative or status quo cost.
"$106/month vs. reputational damage if client escalates"

**2. Social Proof:**
"Industry standard is X. Our competitors already use Y."

**3. Loss Aversion:**
Emphasize "Risk of Status Quo" (people fear loss more than they value gain)

**4. Reciprocity:**
Offer bonus benefits: "This also solves [unrelated problem] at no extra cost"

### Formatting

**Do:**
- Use tables for cost/comparison data
- Bold key numbers and benefits
- Break long paragraphs (3-4 sentences max)
- Use bullet lists for evidence/features
- **DOCX Icon-Free Rule:** Remove all emoji (, ) and visual markers before generating DOCX files

**Don't:**
- Bury key info in footnotes
- Use passive voice ("It is recommended..." → "We recommend...")
- Assume readers understand jargon
- Exceed 2-3 pages for executive summary
- Use emoji or visual icons in formal business documents (renders as symbols in DOCX)

**Icon-Free DOCX Pattern:**

When generating proposals in DOCX format, remove ALL visual icons/emoji before final generation:

```bash
# Remove emoji from markdown
sed -i '' 's/ //g; s/ //g; s///g; s///g' proposal.md

# For Mermaid diagrams: Use [Node] NOT [(Node)]
# Bad: Writer[(Aurora Writer)] → renders database cylinder icon
# Good: Writer[Aurora Writer] → clean rectangular box
```

**Why:** Markdown emoji (, ) and Mermaid database icons `[(` `)]` both render as visible symbols in DOCX and look unprofessional in formal business documents.

**When to apply:**
- All formal business proposals in DOCX format
- BRDs, FRSs, technical specifications for DOCX output
- Any document for executive/management review

**Source:** PETH Database Architecture Upgrade Proposal (INSIGHTS.md #1)

## RFP Response Specifics

**Compliance Matrix:**
| RFP Requirement | Section | Page | Compliant? |
|-----------------|---------|------|------------|
| [Req from RFP] | 3.2 | 5 | Yes ✓ |

**Evaluation Criteria Focus:**
If RFP weights "Technical Approach" 40%, "Cost" 30%, "Experience" 30%:
- Allocate 40% of proposal to technical depth
- Highlight past similar projects in "Experience"

## Common Patterns

### Budget Approval Pattern
1. Problem (with $$ impact)
2. Solution (with ROI calculation)
3. Comparison to do-nothing cost
4. Request: "Approve $X/month budget"

### Vendor Selection Pattern
1. Understanding of client needs
2. Proposed approach (unique differentiators)
3. Team credentials + past work
4. Pricing (competitive + transparent)

### Architecture Change Pattern
1. Current architecture limitations (bottlenecks)
2. Proposed architecture (diagrams)
3. Migration strategy (minimize disruption)
4. Performance benchmarks (before/after)

## Checklist Before Submission

- [ ] Executive summary stands alone (readable without rest of doc)
- [ ] Every problem has quantified impact
- [ ] Every solution has clear benefit
- [ ] Costs are transparent and justified
- [ ] ROI calculation is realistic
- [ ] Glossary defines all acronyms
- [ ] Formatting is consistent (table styles, headings)
- [ ] No typos (run spell check)
- [ ] Appropriate level of detail (C-suite = high-level, Engineers = technical)
- [ ] Call to action is clear ("Approve by X date", "Schedule demo")

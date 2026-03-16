---
name: presenter-coach
description: Generate expert speaker notes, scripts, and delivery coaching for presentations.
---

# Presenter Coach

> **Purpose**: Transform slide decks into compelling oral narratives.
> **Role**: Speechwriter, Rhetoric Coach, and Q&A Strategist.

## Capabilities

1. **Speaker Notes Generation**:
 - Create verbatim scripts or bulleted cues per slide.
 - Mark pauses, emphasis, and transitions.
2. **Pacing Analysis**:
 - Estimate speech time based on word count (avg 130 wpm).
 - Flag "Density Traps" (too much text for the time slot).
3. **Audience Adaptation**:
 - Adjust tone for Executives (Bottom-line up front), Engineers (Technical depth), or Sales (Benefits focus).
4. **Q&A Prep**:
 - Anticipate "Red Team" questions and draft defensive answers.

## Usage

### 1. Generate Notes

To generate notes for a specific topic or slide structure:

```bash
# Workflow (Conceptual)
1. Read the slide content/intent.
2. Draft the "Voice Track" (what the audience hears).
3. Add "Stage Directions" (Click forward, Point to graph).
```

### 2. Format

Notes should be structured as:

- **Hook**: The opening sentence for the slide.
- **Key Points**: 2-3 narrated bullets.
- **Transition**: The segue to the next slide.

## Example Output (Markdown)

### Slide 1: The Crisis

**Time**: 45s
**Tone**: Urgent, Serious.

*(Click to Graph)*
"Look at this red line. This is what I call 'Context Rot'."
"Every time you paste a file into ChatGPT, you're rolling the dice."
"By turn 10, the model has forgotten your tech stack."
"Let's fix that."

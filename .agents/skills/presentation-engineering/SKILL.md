---
name: presentation-engineering
description: Build professional, editable presentations (PPTX) using a data-driven approach.
---

# Presentation Engineering

Use this skill to generate high-quality, editable PowerPoint presentations programmatically. Instead of manual editing, define your content in JSON and use the engine to build the deck.

## 1. Init Project

Start by creating the configuration files in your workspace.

```bash
# Copy bootstrap script from skill
node .agents/skills/presentation-engineering/scripts/bootstrap_deck.js
```

This creates:

* `slides.json`: Array of slide objects.
* `theme.json`: Colors, Fonts, Defaults.
* `assets/`: Directory for images.

## 2. The Data Schema (`slides.json`)

The generic engine accepts a standard list of slide objects.

```json
{
 "title": "Slide Title",
 "module": "Section Name",
 "body": "Main content text...",
 "notes": "Speaker notes...",
 "visual": "image_filename.png",
 "shapes": [ ... ] 
}
```

## 3. Custom Shapes (LLM Offloading)

For complex diagrams (architecture charts, code windows) that native text cannot handle, use the `shapes` array. **Do not write this manually.** Ask an LLM (Claude) to generate the `pptxgenjs` shape definitions for you.

**Prompt Pattern:**
> "Generate specific `pptxgenjs` shape definitions for a 5-step process diagram.
> Output ONLY the JSON array for the `shapes` property.
> Constraint: Canvas is 10x5.625 inches.
> Theme Colors: BG (#0b0e14), Text (#e2e8f0), Accent (#6366f1)."

## 4. Build

Run the generic generator.

```bash
node .agents/skills/presentation-engineering/scripts/generate_deck.js
```

## 5. Visual Guidelines

* **Safe Zone**: Keep content within 0.5" margins.
* **Contrast**: Verify `theme.json` colors against the WCAG contrast checkers if changing defaults.
* **Images**: Ensure all assets used in `slides.json` exist in `assets/`.

---
name: doc-generator
description: Convert Markdown documents to professional DOCX format with styling. Use when you need to generate Word documents from Markdown content, apply professional formatting, or convert structured text to DOCX output.
---

# Document Generator (Markdown to DOCX)

## Purpose

Convert Markdown documents to professional Microsoft Word (DOCX) format with automatic styling and formatting. Part of the document-skills family alongside xlsx, pdf, pptx, and docx skills.

## When to Use

Use this skill when you need to:

- Convert Markdown to Word documents
- Generate professional DOCX from structured text
- Apply consistent formatting and styling
- Embed images and diagrams in Word docs
- Create publication-ready documents

**Related Skills:**

- `docx-creator` - Create/modify Word docs with Python (content-first workflow)
- `xlsx` - Excel spreadsheet manipulation
- `pdf` - PDF document processing
- `pptx` - PowerPoint presentation handling

## How It Works

### Conversion Process

1. **Parse Markdown**
 - Read Markdown content
 - Identify structure (headings, lists, tables, code blocks)
 - Extract embedded images/diagrams

2. **Apply Styling**
 - Map Markdown elements to Word styles
 - Apply consistent formatting (fonts, spacing, colors)
 - Handle tables, code blocks, quotes

3. **Embed Media**
 - Process image references
 - Embed diagrams (from mermaidjs, drawio, etc.)
 - Maintain proper sizing and positioning

4. **Generate DOCX**
 - Create Word document structure
 - Apply document properties (metadata, page setup)
 - Save to specified path

## Usage Examples

### Example 1: Convert Technical Spec

```python
# Called by tech-doc workflow
from doc_generator import markdown_to_docx

markdown_content = """
# User Management API

## Overview
REST API for user operations...

## Architecture
[Architecture diagram embedded]
"""

docx_path = markdown_to_docx(
 content=markdown_content,
 output_path="docs/tech-specs/user-api-2026-02-04.docx",
 style="technical"
)
```

### Example 2: Convert Business Proposal

```python
# Called by business-doc workflow
from doc_generator import markdown_to_docx

markdown_content = """
# Customer Portal Proposal

## Executive Summary
This proposal outlines...

## Budget
[Pie chart embedded]
"""

docx_path = markdown_to_docx(
 content=markdown_content,
 output_path="docs/business-docs/portal-proposal.docx",
 style="business"
)
```

## Styling Options

See `references/styling-guide.md` for:

- Available style presets (technical, business, academic, corporate)
- Custom styling configuration
- Font, color, and spacing options

## Integration

This skill is called by:

- `tech-doc` workflow - Convert technical Markdown to DOCX
- `business-doc` workflow - Convert business Markdown to DOCX

Works alongside:

- `docx-creator` - Alternative Word document creation method
- `mermaidjs-v11` - Generates diagrams embedded in documents
- `drawio` - Generates infrastructure diagrams

## See Also

- **Styling Guide:** `references/styling-guide.md`
- **Usage Examples:** `references/usage-examples.md`
- **Document Skills:** `../document-skills/` (xlsx, pdf, pptx, docx)

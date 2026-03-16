---
name: docx-creator
description: Create and modify Microsoft Word documents (.docx) using Python. Features a content-first workflow using Markdown for content and JSON for styling. Best for generating professional reports, BRDs, and documentation programmatically.
---

# Word Document Creator

This skill enables the programmatic creation of professional Microsoft Word documents. It promotes a **separation of concerns** workflow:

1. **Content**: Written in Markdown.
2. **Design**: Defined in JSON.
3. **Logic**: Python script using `python-docx`.

## Usage

Use this skill when:

- Converting Markdown documentation to formatted Word reports.
- Generating standardized business documents (BRDs, Invoices, SOWs, Proposals).
- Users want to "generate a report" but need to review content first.
- Applying specific branding (fonts, colors) to generated documents.

## Capabilities

- **Markdown Support**: Headers, lists, bold/italic text, tables, images.
- **Image Embedding**: `![caption](path)` syntax with centered captions.
- **Inline Formatting**: `**bold**` and `*italic*` work in paragraphs AND table cells.
- **Advanced Styling**: Hex color support, table header backgrounds, custom margins.
- **Templating**: JSON-based style configuration for easy re-branding.
- **Structure**: Automatic title pages, sections, and tables of contents.

## Quick Start

The skill provides a robust converter script.

1. **Draft Content**: Create a `content.md` file.
2. **Configure Style**: Use the provided `assets/styles.json`.
3. **Generate**:

 ```bash
 python .agents/skills/docx-creator/scripts/generate_docx.py --input content.md --style styles.json --output report.docx
 ```

## Markdown Syntax Supported

| Syntax | Example | Result |
|--------|---------|--------|
| H1 Title | `# Document Title` | Title page |
| H2 Section | `## Section Name` | Heading 1 |
| H3 Subsection | `### Subsection` | Heading 2 |
| Bold | `**text**` | **text** |
| Italic | `*text*` | *text* |
| Bullet List | `- item` | Bullet point |
| Table | `\| A \| B \|` | Formatted table |
| Image | `![caption](path.png)` | Centered image with caption |
| Metadata | `**Key:** Value` | Bold key, normal value |

## Implementation Guide

### 1. Setup

```bash
pip install python-docx
```

### 2. The Pattern

Don't hardcode text in Python. Read it from a source.

**Bad:**

```python
doc.add_paragraph("The objective of this project is...")
```

**Good:**

```python
# content.md
# The objective of this project is...

# script.py
for line in open('content.md'):
 doc.add_paragraph(line)
```

### 3. Advanced Features

Refer to `references/python-docx-guide.md` for:

- **Table Cell Backgrounds**: Requires XML manipulation (included in guide).
- **Custom Margins**: Setting page layout via JSON.
- **Font Rendering**: Handling RGB colors and font families.
- **Image Sizing**: Configure via `images.width_inches` in style JSON.

## Lessons Learned (Session Patterns)

### 1. Inline Formatting in Tables

**Problem:** Table cells showing `**$106/month**` instead of **$106/month**

**Solution:** Process `**bold**` and `*italic*` markers in table data cells, not just paragraphs.

### 2. Image Embedding with Captions

**Markdown syntax:**

```markdown
![Figure 1: Architecture Diagram](diagrams/architecture.png)
```

**Result:** Centered image with italic gray caption below.

### 3. Style JSON Configuration

Add image width to style JSON for control:

```json
{
 "images": {
 "width_inches": 5.5
 }
}
```

### 4. Business Document No-Icons Rule

When generating diagrams for business documents (Mermaid, etc.), avoid emoji icons. Use text labels instead:

- Bad: `Writer[(Writer Node )]`
- Good: `Writer[(Writer Node BOTTLENECK)]`

## Best Practices

- **Validation**: Check content files exist before processing.
- **Clean Styles**: Define styles in JSON, not Python code, to allow non-developers to tweak the look.
- **Error Handling**: Catch `PermissionError` if the output file is open in Word.
- **Image Paths**: Support both absolute and relative paths.
- **Content First**: Always draft content in Markdown, get approval, then generate DOCX.

# Document Generator - Styling Guide

## Available Style Presets

### Technical Style
- Font: Calibri
- Headings: Bold, Navy Blue
- Code blocks: Courier New, Light Gray background
- Tables: Simple grid with header row
- Spacing: 1.15 line spacing

### Business Style
- Font: Arial
- Headings: Bold, Dark Blue
- Emphasis: Professional highlight colors
- Tables: Corporate style with alternating rows
- Spacing: 1.5 line spacing

### Academic Style
- Font: Times New Roman
- Headings: Numbered, Black
- Citations: Proper formatting
- Tables: Academic style
- Spacing: Double spacing

### Corporate Style
- Font: Segoe UI
- Headings: Corporate brand colors
- Professional layout
- Tables: Modern design
- Spacing: 1.25 line spacing

## Custom Styling

```json
{
 "fonts": {
 "body": "Calibri",
 "heading": "Calibri",
 "code": "Courier New"
 },
 "colors": {
 "heading": "#1F4788",
 "accent": "#0078D4",
 "code_bg": "#F5F5F5"
 },
 "spacing": {
 "line_spacing": 1.15,
 "paragraph_spacing": 12
 }
}
```

## Element Mapping

| Markdown | Word Style |
|---|---|
| # Heading 1 | Title |
| ## Heading 2 | Heading 1 |
| ### Heading 3 | Heading 2 |
| **bold** | Strong |
| *italic* | Emphasis |
| `code` | Code (inline) |
| \`\`\`code\`\`\` | Code Block |
| > quote | Quote |
| - list | Bullet List |
| 1. list | Numbered List |
| \| table \| | Table Grid |

## Image Embedding

Images are automatically embedded and sized appropriately:
- Diagrams: Full width (6.5 inches)
- Icons: Original size (max 1 inch)
- Charts: 75% width (5 inches)

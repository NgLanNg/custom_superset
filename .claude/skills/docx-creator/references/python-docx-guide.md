# Python-Docx Reference Guide

This guide provides code snippets and patterns for common operations using the `python-docx` library.

## 1. Images

### Adding Images

```python
from docx.shared import Inches

doc.add_heading('Images', level=1)
# Add image with defined width (height is auto-scaled)
doc.add_picture('path/to/image.png', width=Inches(4.0))
```

### Centering Images

```python
from docx.enum.text import WD_ALIGN_PARAGRAPH

last_paragraph = doc.paragraphs[-1]
last_paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
```

## 2. Advanced Tables

### Table Styling and Merging

```python
table = doc.add_table(rows=3, cols=3)
table.style = 'Table Grid'

# Merging cells
a = table.cell(0, 0)
b = table.cell(0, 1)
a.merge(b)
a.text = 'Merged Header'
```

### Cell Background Color

`python-docx` doesn't support cell background colors natively in a simple way. It requires XML manipulation (OXML).

```python
from docx.oxml.ns import nsdecls
from docx.oxml import parse_xml

def set_cell_bg(cell, color_hex):
 """
 Set background color for a table cell.
 color_hex: string like "FF0000"
 """
 shading_elm = parse_xml(r'<w:shd {} w:fill="{}"/>'.format(nsdecls('w'), color_hex))
 cell._tc.get_or_add_tcPr().append(shading_elm)

# Usage
cell = table.cell(0, 0)
set_cell_bg(cell, "E0E0E0") # Light gray
```

## 3. Page Layout

### Margins

```python
from docx.shared import Inches

section = doc.sections[0]
section.top_margin = Inches(1.0)
section.bottom_margin = Inches(1.0)
section.left_margin = Inches(0.75)
section.right_margin = Inches(0.75)
```

### Orientation (Landscape)

```python
from docx.enum.section import WD_ORIENT

section = doc.sections[0]
section.orientation = WD_ORIENT.LANDSCAPE
# Swap dimensions for proper landscape size
new_width, new_height = section.page_height, section.page_width
section.page_width = new_width
section.page_height = new_height
```

## 4. Headers and Footers

```python
section = doc.sections[0]

# Header
header = section.header
paragraph = header.paragraphs[0]
paragraph.text = "Confidential Report"
paragraph.alignment = WD_ALIGN_PARAGRAPH.RIGHT

# Footer
footer = section.footer
paragraph = footer.paragraphs[0]
paragraph.text = "Page 1"
```

## 5. Styles

### Creating a New Style

```python
from docx.enum.style import WD_STYLE_TYPE

styles = doc.styles
new_style = styles.add_style('CustomStyle', WD_STYLE_TYPE.PARAGRAPH)
new_style.font.name = 'Arial'
new_style.font.size = Pt(14)
new_style.font.bold = True

doc.add_paragraph('Text with custom style', style='CustomStyle')
```

## 6. Page Breaks

```python
# Hard page break
doc.add_page_break()

# Page break before a paragraph
p = doc.add_paragraph("Start on new page")
p.paragraph_format.page_break_before = True
```

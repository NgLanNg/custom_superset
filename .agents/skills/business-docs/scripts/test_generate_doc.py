#!/usr/bin/env python3
"""
Tests for generate_doc.py script.
"""

import os
import sys
import unittest
from pathlib import Path
from datetime import datetime

# Add parent directory to path to import generate_doc
sys.path.insert(0, str(Path(__file__).parent.parent))

from generate_doc import (
 get_template_path,
 load_template,
 fill_template,
)


class TestGenerateDoc(unittest.TestCase):
 """Test suite for document generation script."""

 def setUp(self):
 """Set up test fixtures."""
 self.script_dir = Path(__file__).parent.parent
 self.template_dir = self.script_dir / "assets" / "templates"

 def test_get_template_path_brd(self):
 """Test getting BRD template path."""
 path = get_template_path("brd")
 self.assertEqual(path.name, "brd_template.md")
 self.assertTrue(path.exists())

 def test_get_template_path_proposal(self):
 """Test getting proposal template path."""
 path = get_template_path("proposal")
 self.assertEqual(path.name, "proposal_template.md")
 self.assertTrue(path.exists())

 def test_get_template_path_frs(self):
 """Test getting FRS template path."""
 path = get_template_path("frs")
 self.assertEqual(path.name, "frs_template.md")
 self.assertTrue(path.exists())

 def test_get_template_path_technical(self):
 """Test getting technical spec template path."""
 path = get_template_path("technical")
 self.assertEqual(path.name, "technical_spec_template.md")
 self.assertTrue(path.exists())

 def test_get_template_path_invalid(self):
 """Test that invalid document type raises ValueError."""
 with self.assertRaises(ValueError):
 get_template_path("invalid_type")

 def test_load_template(self):
 """Test loading template content."""
 template_path = self.template_dir / "proposal_template.md"
 content = load_template(template_path)
 self.assertIsInstance(content, str)
 self.assertGreater(len(content), 0)
 self.assertIn("Proposal:", content)

 def test_load_template_not_found(self):
 """Test that loading non-existent template raises FileNotFoundError."""
 with self.assertRaises(FileNotFoundError):
 load_template(Path("nonexistent.md"))

 def test_fill_template_date_replacement(self):
 """Test that date placeholders are replaced."""
 template = "Date: [YYYY-MM-DD]\nAnother: [Date]"
 result = fill_template(template, {})

 today = datetime.now().strftime("%Y-%m-%d")
 self.assertIn(today, result)
 self.assertNotIn("[YYYY-MM-DD]", result)
 self.assertNotIn("[Date]", result)

 def test_fill_template_custom_replacements(self):
 """Test custom placeholder replacements."""
 template = "Project: [Project Name]\nBy: [Your Name]"
 replacements = {
 "[Project Name]": "Test Project",
 "[Your Name]": "John Doe"
 }
 result = fill_template(template, replacements)

 self.assertIn("Test Project", result)
 self.assertIn("John Doe", result)
 self.assertNotIn("[Project Name]", result)
 self.assertNotIn("[Your Name]", result)

 def test_fill_template_partial_replacement(self):
 """Test that only specified placeholders are replaced."""
 template = "Project: [Project Name]\nBy: [Your Name]"
 replacements = {"[Project Name]": "Test Project"}
 result = fill_template(template, replacements)

 self.assertIn("Test Project", result)
 self.assertIn("[Your Name]", result) # Should remain unreplaced

 def test_fill_template_preserves_structure(self):
 """Test that template structure is preserved after replacement."""
 template = """# Heading

## Section

Content with [placeholder].

- List item 1
- List item 2
"""
 replacements = {"[placeholder]": "value"}
 result = fill_template(template, replacements)

 self.assertIn("# Heading", result)
 self.assertIn("## Section", result)
 self.assertIn("- List item", result)
 self.assertIn("value", result)


class TestTemplateExistence(unittest.TestCase):
 """Test that all required templates exist."""

 def setUp(self):
 """Set up test fixtures."""
 self.script_dir = Path(__file__).parent.parent
 self.template_dir = self.script_dir / "assets" / "templates"

 def test_all_templates_exist(self):
 """Test that all required templates exist."""
 required_templates = [
 "brd_template.md",
 "proposal_template.md",
 "frs_template.md",
 "technical_spec_template.md"
 ]

 for template in required_templates:
 path = self.template_dir / template
 self.assertTrue(
 path.exists(),
 f"Required template missing: {template}"
 )

 def test_templates_not_empty(self):
 """Test that all templates have content."""
 templates = list(self.template_dir.glob("*.md"))

 for template_path in templates:
 with open(template_path, 'r') as f:
 content = f.read()
 self.assertGreater(
 len(content),
 100,
 f"Template appears empty or too short: {template_path.name}"
 )


if __name__ == "__main__":
 unittest.main()

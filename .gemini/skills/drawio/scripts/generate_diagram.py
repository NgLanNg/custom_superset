#!/usr/bin/env python3
"""Generate Draw.io diagrams programmatically.

Usage:
python generate_diagram.py --nodes "API,Lambda,DynamoDB" --output arch.drawio
python generate_diagram.py --json nodes.json --output arch.drawio
python generate_diagram.py --nodes "Start,Process,End" --layout vertical --theme academic

Examples:
# Simple horizontal flow
python generate_diagram.py --nodes "Client,API,DB" -o flow.drawio

# Vertical flowchart
python generate_diagram.py --nodes "Start,Validate,Process,End" --layout vertical -o flow.drawio

# From JSON spec
echo '{"nodes":[{"id":"n1","label":"API"},{"id":"n2","label":"DB"}],"edges":[{"source":"n1","target":"n2"}]}' > spec.json
python generate_diagram.py --json spec.json -o arch.drawio
"""

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

# Theme palettes
THEMES = {
"tech-blue": {
"service": {"fill": "#DBEAFE", "stroke": "#2563EB"},
"database": {"fill": "#D1FAE5", "stroke": "#059669"},
"decision": {"fill": "#FEF3C7", "stroke": "#D97706"},
"queue": {"fill": "#E0E7FF", "stroke": "#4F46E5"},
"user": {"fill": "#FCE7F3", "stroke": "#DB2777"},
"terminal": {"fill": "#ECFDF5", "stroke": "#10B981"},
"default": {"fill": "#F1F5F9", "stroke": "#475569"},
},
"academic": {
"service": {"fill": "#F5F5F5", "stroke": "#1E1E1E"},
"database": {"fill": "#E8E8E8", "stroke": "#1E1E1E"},
"decision": {"fill": "#FFFFFF", "stroke": "#1E1E1E"},
"queue": {"fill": "#F0F0F0", "stroke": "#1E1E1E"},
"user": {"fill": "#FAFAFA", "stroke": "#1E1E1E"},
"terminal": {"fill": "#F5F5F5", "stroke": "#1E1E1E"},
"default": {"fill": "#F5F5F5", "stroke": "#1E1E1E"},
},
"dark": {
"service": {"fill": "#1E3A5F", "stroke": "#60A5FA"},
"database": {"fill": "#1E3F3A", "stroke": "#34D399"},
"decision": {"fill": "#3F3A1E", "stroke": "#FBBF24"},
"queue": {"fill": "#2E1E4F", "stroke": "#A78BFA"},
"user": {"fill": "#3F1E3A", "stroke": "#F472B6"},
"terminal": {"fill": "#1E3F2E", "stroke": "#34D399"},
"default": {"fill": "#1E293B", "stroke": "#94A3B8"},
},
}

# Keywords for semantic shape detection
SHAPE_KEYWORDS = {
"database": ["db", "database", "storage", "dynamo", "rds", "postgres", "mysql", "mongo", "redis"],
"decision": ["if", "decision", "gateway", "branch", "condition", "switch"],
"queue": ["queue", "sqs", "sns", "kafka", "pubsub", "rabbitmq", "message"],
"user": ["user", "actor", "client", "customer", "person"],
"terminal": ["start", "end", "stop", "begin", "finish"],
}

# Shape styles
SHAPE_STYLES = {
"service": "rounded=1;whiteSpace=wrap;html=1;",
"database": "shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;",
"decision": "rhombus;whiteSpace=wrap;html=1;",
"queue": "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fixedSize=1;",
"user": "ellipse;whiteSpace=wrap;html=1;",
"terminal": "rounded=1;whiteSpace=wrap;html=1;arcSize=50;",
}

# Shape dimensions
SHAPE_SIZES = {
"service": (120, 60),
"database": (60, 80),
"decision": (80, 80),
"queue": (120, 60),
"user": (80, 80),
"terminal": (100, 40),
}


def detect_shape_type(label: str) -> str:
"""Detect shape type from label keywords."""
label_lower = label.lower()
for shape_type, keywords in SHAPE_KEYWORDS.items():
if any(kw in label_lower for kw in keywords):
return shape_type
return "service"


def create_diagram(nodes: list, edges: list, theme: str = "tech-blue") -> str:
"""Generate Draw.io XML from nodes and edges."""
palette = THEMES.get(theme, THEMES["tech-blue"])

root = ET.Element("mxfile", host="app.diagrams.net", modified="2024-01-01T00:00:00.000Z")
diagram = ET.SubElement(root, "diagram", name="Page-1", id="page-1")
graph = ET.SubElement(
diagram,
"mxGraphModel",
dx="1024",
dy="768",
grid="1",
gridSize="8",
guides="1",
tooltips="1",
connect="1",
arrows="1",
fold="1",
page="1",
pageScale="1",
pageWidth="827",
pageHeight="1169",
)
cells = ET.SubElement(graph, "root")
ET.SubElement(cells, "mxCell", id="0")
ET.SubElement(cells, "mxCell", id="1", parent="0")

# Create nodes
for node in nodes:
node_id = node["id"]
label = node["label"]
shape_type = node.get("type") or detect_shape_type(label)
colors = palette.get(shape_type, palette["default"])

base_style = SHAPE_STYLES.get(shape_type, SHAPE_STYLES["service"])
style = f"{base_style}fillColor={colors['fill']};strokeColor={colors['stroke']};"

w, h = node.get("width"), node.get("height")
if not w or not h:
w, h = SHAPE_SIZES.get(shape_type, (120, 60))

cell = ET.SubElement(
cells, "mxCell", id=node_id, value=label, style=style, vertex="1", parent="1"
)
ET.SubElement(
cell,
"mxGeometry",
x=str(node.get("x", 0)),
y=str(node.get("y", 0)),
width=str(w),
height=str(h),
**{"as": "geometry"},
)

# Create edges
for i, edge in enumerate(edges):
edge_id = edge.get("id", f"e{i + 1}")
style = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;"

if edge.get("dashed"):
style += "dashed=1;dashPattern=6 4;"

cell = ET.SubElement(
cells,
"mxCell",
id=edge_id,
style=style,
edge="1",
parent="1",
source=edge["source"],
target=edge["target"],
)
ET.SubElement(cell, "mxGeometry", relative="1", **{"as": "geometry"})

return ET.tostring(root, encoding="unicode")


def layout_nodes(labels: list, layout: str = "horizontal", spacing: int = 48) -> tuple:
"""Calculate node positions based on layout."""
nodes = []
edges = []

for i, label in enumerate(labels):
shape_type = detect_shape_type(label)
w, h = SHAPE_SIZES.get(shape_type, (120, 60))

if layout == "vertical":
x = 100
y = 100 + i * (h + spacing)
else: # horizontal
x = 100 + i * (w + spacing)
y = 100

nodes.append({"id": f"n{i + 1}", "label": label, "x": x, "y": y, "width": w, "height": h})

# Create edge to next node
if i > 0:
edges.append({"source": f"n{i}", "target": f"n{i + 1}"})

return nodes, edges


def main():
parser = argparse.ArgumentParser(description="Generate Draw.io diagrams")
parser.add_argument("--nodes", "-n", help="Comma-separated node labels")
parser.add_argument("--json", "-j", help="JSON file with nodes and edges spec")
parser.add_argument("--output", "-o", required=True, help="Output .drawio file")
parser.add_argument(
"--layout", "-l", choices=["horizontal", "vertical"], default="horizontal", help="Layout direction"
)
parser.add_argument(
"--theme", "-t", choices=list(THEMES.keys()), default="tech-blue", help="Color theme"
)
parser.add_argument("--spacing", "-s", type=int, default=48, help="Spacing between nodes (px)")

args = parser.parse_args()

if args.json:
with open(args.json) as f:
spec = json.load(f)
nodes = spec.get("nodes", [])
edges = spec.get("edges", [])
elif args.nodes:
labels = [l.strip() for l in args.nodes.split(",")]
nodes, edges = layout_nodes(labels, args.layout, args.spacing)
else:
print("Error: Provide --nodes or --json", file=sys.stderr)
sys.exit(1)

xml = create_diagram(nodes, edges, args.theme)

output_path = Path(args.output)
output_path.write_text(xml)
print(f"Created: {output_path}")


if __name__ == "__main__":
main()

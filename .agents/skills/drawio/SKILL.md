---
name: drawio
description: Create and edit Draw.io diagrams programmatically via XML manipulation and CLI export. Use when generating .drawio files, architecture diagrams, flowcharts, sequence diagrams, ER diagrams, network topologies, or cloud infrastructure diagrams (AWS/GCP/Azure). Supports semantic shapes, typed connectors, cloud provider icons, theming (Tech Blue, Academic, Dark), and batch export to PNG/SVG/PDF. Essential for automated documentation pipelines and CI/CD diagram generation.
---

# Draw.io Diagrams

Create professional diagrams via XML manipulation and CLI export.

## When to Load References

| Need | Load |
| ---- | ---- |
| Shape styles, connectors, themes | `references/design-system.md` |
| AWS/GCP/Azure icon paths | `references/icons.md` |
| XML attributes, mxCell structure | `references/xml-format.md` |
| Flowchart/architecture patterns | `references/examples.md` |

## Quick Start

**File formats**: `.drawio` (compressed), `.drawio.xml` (editable), `.drawio.png/.svg` (embedded)

**Generate diagram**:

```bash
python scripts/generate_diagram.py --nodes "API,Lambda,DynamoDB" --output arch.drawio
```

**Export to image**:

```bash
# macOS
/Applications/draw.io.app/Contents/MacOS/draw.io -x -f png -o out.png in.drawio

# Linux/Windows (if in PATH)
draw.io -x -f png -o out.png in.drawio
draw.io -x -f svg -b transparent -o out.svg in.drawio # transparent bg
draw.io -x -f pdf -o out.pdf in.drawio
draw.io -x -f png -p 0 -s 2 -o out@2x.png in.drawio # page 0, 2x scale
```

## Design System

**Grid**: 8px alignment for all elements.

**Semantic shapes** (inferred from labels):

| Type | Shape | Trigger words |
| ---- | ----- | ------------- |
| service | Rounded rect | api, service, app, lambda, function |
| database | Cylinder | db, database, storage, dynamo, rds, postgres |
| decision | Diamond | if, gateway, branch, condition |
| queue | Parallelogram | queue, sqs, sns, kafka, pubsub |
| user | Ellipse | user, actor, client, customer |
| terminal | Stadium | start, end, stop, begin |

**Connectors**:

| Type | Style | Use |
| ---- | ----- | --- |
| primary | Solid 2px → | Main flow |
| data | Dashed 2px → | Async, API |
| optional | Dotted 1px → | Fallback |
| dependency | Solid 1px ◆ | Composition |

## XML Structure

```xml
<mxfile host="app.diagrams.net">
 <diagram name="Page-1" id="p1">
 <mxGraphModel dx="1024" dy="768" grid="1" gridSize="8">
 <root>
 <mxCell id="0"/>
 <mxCell id="1" parent="0"/>
 <!-- nodes/edges start at id="2" -->
 </root>
 </mxGraphModel>
 </diagram>
</mxfile>
```

**Node**:

```xml
<mxCell id="2" value="Label" style="rounded=1;fillColor=#DBEAFE;strokeColor=#2563EB;"
 vertex="1" parent="1">
 <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

**Edge**:

```xml
<mxCell id="3" style="edgeStyle=orthogonalEdgeStyle;strokeWidth=2;"
 edge="1" parent="1" source="2" target="4">
 <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

## Cloud Icons

```yaml
AWS: shape=mxgraph.aws4.{lambda,s3,dynamodb,api_gateway,sqs,sns,...}
GCP: shape=mxgraph.gcp2.{cloud_run,bigquery,cloud_storage,pubsub,...}
Azure: shape=mxgraph.azure.{functions,cosmos_db,service_bus,...}
```

See `references/icons.md` for complete paths.

## Themes

| Theme | Primary | Use |
| ----- | ------- | --- |
| Tech Blue | #2563EB | Architecture |
| Academic | #1E1E1E | Print/papers |
| Dark | #1E293B | Presentations |

## Resources

- `scripts/generate_diagram.py` - Programmatic diagram generation
- `assets/template.drawio` - Starter template with grid configured
- `references/design-system.md` - Complete shape/connector/theme specs
- `references/icons.md` - Cloud provider icon paths
- `references/xml-format.md` - Full XML attribute reference
- `references/examples.md` - Flowchart, architecture, ER patterns

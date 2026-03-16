# Design System

Unified visual language for Draw.io diagrams using 8px grid, semantic shapes, and typed connectors.

## Grid System

- **Base unit**: 8px
- **Spacing scale**: xs(8), sm(16), md(24), lg(32), xl(48), 2xl(64)
- **Node alignment**: Snap to grid for consistent layouts

## Semantic Shapes

Shapes auto-select based on node type or label keywords.

### Shape Mapping

```yaml
service:
 shape: rounded rectangle
 style: "rounded=1;whiteSpace=wrap;html=1;"
 keywords: [api, service, app, server, microservice]
 size: 120x60

database:
 shape: cylinder
 style: "shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;"
 keywords: [db, database, storage, redis, dynamo, postgres, mysql, mongo]
 size: 60x80

decision:
 shape: diamond/rhombus
 style: "rhombus;whiteSpace=wrap;html=1;"
 keywords: [if, decision, gateway, branch, condition, switch]
 size: 80x80

queue:
 shape: parallelogram
 style: "shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;"
 keywords: [queue, sqs, kafka, rabbitmq, pubsub, message]
 size: 120x60

user:
 shape: ellipse
 style: "ellipse;whiteSpace=wrap;html=1;"
 keywords: [user, actor, client, person, customer]
 size: 80x80

terminal:
 shape: stadium/pill
 style: "shape=process;whiteSpace=wrap;html=1;backgroundOutline=1;"
 keywords: [start, end, stop, begin, finish]
 size: 100x40

document:
 shape: document
 style: "shape=document;whiteSpace=wrap;html=1;boundedLbl=1;"
 keywords: [doc, document, file, report]
 size: 100x70

cloud:
 shape: cloud
 style: "ellipse;shape=cloud;whiteSpace=wrap;html=1;"
 keywords: [cloud, external, internet, third-party]
 size: 120x80

container:
 shape: swimlane
 style: "swimlane;whiteSpace=wrap;html=1;"
 keywords: [group, zone, vpc, subnet, module]
 size: 200x150
```

### Size Presets

| Size | Dimensions | Use Case |
| ---- | ---------- | -------- |
| sm | 80x40 | Labels, small nodes |
| md | 120x60 | Default services |
| lg | 160x80 | Major components |
| xl | 200x100 | Containers, groups |

## Typed Connectors

### Connector Styles

```yaml
primary:
 style: "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;endArrow=blockThin;endFill=1;"
 use: Main process flow, critical paths
 color: "#1E293B"

data:
 style: "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;dashed=1;dashPattern=6 4;endArrow=blockThin;endFill=1;"
 use: Data transmission, async communication, API calls
 color: "#64748B"

optional:
 style: "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1;dashed=1;dashPattern=2 2;endArrow=open;endFill=0;"
 use: Weak relationships, fallbacks, optional paths
 color: "#94A3B8"

dependency:
 style: "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1;endArrow=diamond;endFill=1;"
 use: Technical dependencies, composition
 color: "#475569"

bidirectional:
 style: "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1.5;endArrow=none;"
 use: Mutual associations, two-way communication
 color: "#64748B"
```

### Routing Modes

| Mode | Style | Use Case |
| ---- | ----- | -------- |
| orthogonal | Right angles | Technical diagrams (default) |
| rounded | Soft corners | Flowcharts, process flows |
| curved | Bezier curves | Organic layouts, mind maps |

### Edge Labels

```xml
<mxCell style="edgeLabel;html=1;align=center;verticalAlign=middle;fontSize=10;"
 vertex="1" connectable="0" parent="edge-id">
 <mxGeometry x="0.5" relative="1" as="geometry"/>
</mxCell>
```

## Theme Palettes

### Tech Blue (Default)

```yaml
primary: "#2563EB"
secondary: "#059669"
accent: "#7C3AED"
background: "#FFFFFF"
text: "#1E293B"
muted: "#64748B"

nodes:
 service: { fill: "#DBEAFE", stroke: "#2563EB" }
 database: { fill: "#D1FAE5", stroke: "#059669" }
 decision: { fill: "#FEF3C7", stroke: "#D97706" }
 queue: { fill: "#E0E7FF", stroke: "#4F46E5" }
 user: { fill: "#FCE7F3", stroke: "#DB2777" }
 terminal: { fill: "#ECFDF5", stroke: "#10B981" }
```

### Academic (Print-friendly)

```yaml
primary: "#1E1E1E"
secondary: "#4A4A4A"
background: "#FFFFFF"
text: "#1E1E1E"

nodes:
 service: { fill: "#F5F5F5", stroke: "#1E1E1E" }
 database: { fill: "#E8E8E8", stroke: "#1E1E1E" }
 decision: { fill: "#FFFFFF", stroke: "#1E1E1E" }
```

### Dark Mode

```yaml
primary: "#60A5FA"
secondary: "#34D399"
background: "#1E293B"
text: "#F1F5F9"

nodes:
 service: { fill: "#1E3A5F", stroke: "#60A5FA" }
 database: { fill: "#1E3F3A", stroke: "#34D399" }
 decision: { fill: "#3F3A1E", stroke: "#FBBF24" }
```

## Style String Reference

Common style properties for `mxCell style` attribute:

```yaml
# Shape
rounded: "0|1" # Rounded corners
whiteSpace: "wrap" # Text wrapping
html: "1" # Enable HTML labels

# Colors
fillColor: "#DBEAFE" # Background
strokeColor: "#2563EB" # Border
fontColor: "#1E293B" # Text

# Text
fontSize: "12" # Font size (px)
fontFamily: "Inter" # Font family
fontStyle: "0|1|2|3" # 0=normal, 1=bold, 2=italic, 3=both
align: "left|center|right"
verticalAlign: "top|middle|bottom"

# Border
strokeWidth: "1|2|3" # Border thickness
dashed: "0|1" # Dashed border
dashPattern: "6 4" # Dash pattern

# Effects
shadow: "0|1" # Drop shadow
glass: "0|1" # Glass effect
opacity: "100" # 0-100
```

## Layout Guidelines

1. **Horizontal spacing**: 32-48px between nodes
2. **Vertical spacing**: 48-64px between rows
3. **Label max width**: 14 characters (wrap longer text)
4. **Group padding**: 16px inside containers
5. **Edge crossings**: Minimize; use line jumps if unavoidable

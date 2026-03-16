# XML Format Reference

Complete Draw.io XML structure and attributes.

## Document Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" version="24.0.0">
 <diagram name="Page-1" id="unique-diagram-id">
 <mxGraphModel dx="1024" dy="768" grid="1" gridSize="8"
 guides="1" tooltips="1" connect="1" arrows="1"
 fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169">
 <root>
 <mxCell id="0"/> <!-- Root cell (required) -->
 <mxCell id="1" parent="0"/> <!-- Default parent (required) -->
 <!-- User content starts at id="2" -->
 </root>
 </mxGraphModel>
 </diagram>
</mxfile>
```

## mxGraphModel Attributes

| Attribute | Description | Default |
| --------- | ----------- | ------- |
| dx | Canvas width | 1024 |
| dy | Canvas height | 768 |
| grid | Show grid | 1 |
| gridSize | Grid spacing (px) | 10 |
| guides | Show guides | 1 |
| tooltips | Enable tooltips | 1 |
| connect | Enable connections | 1 |
| arrows | Show arrows | 1 |
| fold | Enable folding | 1 |
| page | Show page | 1 |
| pageScale | Page zoom | 1 |
| pageWidth | Page width | 827 |
| pageHeight | Page height | 1169 |
| background | Background color | none |

## Vertex (Node) Structure

```xml
<mxCell id="node-1"
 value="Node Label"
 style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#2563EB;"
 vertex="1"
 parent="1">
 <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

### Vertex Attributes

| Attribute | Description | Required |
| --------- | ----------- | -------- |
| id | Unique identifier | Yes |
| value | Display text (supports HTML) | No |
| style | Semicolon-separated style string | No |
| vertex | Must be "1" for nodes | Yes |
| parent | Parent cell ID (usually "1") | Yes |
| connectable | Allow connections | No |

### mxGeometry for Vertices

| Attribute | Description |
| --------- | ----------- |
| x | X position (px) |
| y | Y position (px) |
| width | Node width (px) |
| height | Node height (px) |
| as | Must be "geometry" |

## Edge (Connection) Structure

```xml
<mxCell id="edge-1"
 value="Label"
 style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
 edge="1"
 parent="1"
 source="node-1"
 target="node-2">
 <mxGeometry relative="1" as="geometry">
 <mxPoint x="200" y="150" as="sourcePoint"/>
 <mxPoint x="300" y="150" as="targetPoint"/>
 <Array as="points">
 <mxPoint x="250" y="100"/>
 </Array>
 </mxGeometry>
</mxCell>
```

### Edge Attributes

| Attribute | Description | Required |
| --------- | ----------- | -------- |
| id | Unique identifier | Yes |
| value | Edge label | No |
| style | Style string | No |
| edge | Must be "1" for edges | Yes |
| parent | Parent cell ID | Yes |
| source | Source vertex ID | No* |
| target | Target vertex ID | No* |

*Can use sourcePoint/targetPoint in geometry instead

### mxGeometry for Edges

| Attribute | Description |
| --------- | ----------- |
| relative | "1" for relative positioning |
| as | Must be "geometry" |
| sourcePoint | Manual source point |
| targetPoint | Manual target point |
| points | Array of waypoints |

## Style String Properties

### Shape Properties

```yaml
# Basic shapes
shape: "rectangle|ellipse|rhombus|hexagon|triangle|cylinder3|cloud|document|parallelogram|process"

# Rounded corners
rounded: "0|1"
arcSize: "10" # Corner radius when rounded=1

# Size constraints
whiteSpace: "wrap" # Enable text wrapping
html: "1" # Enable HTML in labels
resizable: "0|1" # Allow resizing
rotatable: "0|1" # Allow rotation
```

### Color Properties

```yaml
fillColor: "#DBEAFE" # Background color
strokeColor: "#2563EB" # Border color
fontColor: "#1E293B" # Text color
gradientColor: "#FFFFFF" # Gradient end color
gradientDirection: "south" # north|south|east|west
opacity: "100" # 0-100
```

### Border Properties

```yaml
strokeWidth: "2" # Border thickness
dashed: "1" # Enable dashed border
dashPattern: "6 4" # Dash pattern
```

### Text Properties

```yaml
fontSize: "12"
fontFamily: "Inter"
fontStyle: "0" # 0=normal, 1=bold, 2=italic, 3=bold+italic
align: "center" # left|center|right
verticalAlign: "middle" # top|middle|bottom
labelPosition: "center" # left|center|right
verticalLabelPosition: "middle" # top|middle|bottom
labelBackgroundColor: "#FFFFFF"
labelBorderColor: "#000000"
```

### Edge Properties

```yaml
edgeStyle: "orthogonalEdgeStyle|elbowEdgeStyle|entityRelationEdgeStyle"
curved: "1" # Curved edges
rounded: "1" # Rounded corners at bends
orthogonalLoop: "1" # Orthogonal self-loops
jettySize: "auto" # Connection point offset

# Arrows
startArrow: "none|classic|block|open|oval|diamond"
endArrow: "none|classic|block|open|oval|diamond|blockThin"
startFill: "0|1" # Fill start arrow
endFill: "0|1" # Fill end arrow
startSize: "6" # Start arrow size
endSize: "6" # End arrow size

# Animation
flowAnimation: "1" # Animated flow
```

### Effect Properties

```yaml
shadow: "1" # Drop shadow
glass: "1" # Glass effect
sketch: "1" # Hand-drawn style
comic: "1" # Comic style
jiggle: "2" # Jiggle amount for sketch
```

## Container (Group) Structure

```xml
<mxCell id="group-1"
 value="VPC"
 style="swimlane;whiteSpace=wrap;html=1;startSize=23;"
 vertex="1"
 parent="1">
 <mxGeometry x="50" y="50" width="300" height="200" as="geometry"/>
</mxCell>

<!-- Child nodes use group-1 as parent -->
<mxCell id="child-1"
 value="Service"
 style="rounded=1;"
 vertex="1"
 parent="group-1">
 <mxGeometry x="20" y="40" width="100" height="50" as="geometry"/>
</mxCell>
```

## Complete Example

```xml
<mxfile host="app.diagrams.net">
 <diagram name="API Flow" id="api-flow">
 <mxGraphModel dx="1024" dy="768" grid="1" gridSize="8">
 <root>
 <mxCell id="0"/>
 <mxCell id="1" parent="0"/>

 <!-- Client -->
 <mxCell id="2" value="Client" style="ellipse;whiteSpace=wrap;html=1;fillColor=#FCE7F3;strokeColor=#DB2777;" vertex="1" parent="1">
 <mxGeometry x="40" y="100" width="80" height="80" as="geometry"/>
 </mxCell>

 <!-- API Gateway -->
 <mxCell id="3" value="API Gateway" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#2563EB;" vertex="1" parent="1">
 <mxGeometry x="200" y="110" width="120" height="60" as="geometry"/>
 </mxCell>

 <!-- Lambda -->
 <mxCell id="4" value="Lambda" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FEF3C7;strokeColor=#D97706;" vertex="1" parent="1">
 <mxGeometry x="400" y="110" width="120" height="60" as="geometry"/>
 </mxCell>

 <!-- DynamoDB -->
 <mxCell id="5" value="DynamoDB" style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#D1FAE5;strokeColor=#059669;" vertex="1" parent="1">
 <mxGeometry x="600" y="100" width="60" height="80" as="geometry"/>
 </mxCell>

 <!-- Edges -->
 <mxCell id="6" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;" edge="1" parent="1" source="2" target="3">
 <mxGeometry relative="1" as="geometry"/>
 </mxCell>

 <mxCell id="7" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;" edge="1" parent="1" source="3" target="4">
 <mxGeometry relative="1" as="geometry"/>
 </mxCell>

 <mxCell id="8" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=2;dashed=1;" edge="1" parent="1" source="4" target="5">
 <mxGeometry relative="1" as="geometry"/>
 </mxCell>
 </root>
 </mxGraphModel>
 </diagram>
</mxfile>
```

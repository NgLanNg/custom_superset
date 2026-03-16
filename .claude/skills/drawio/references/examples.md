# Diagram Examples

Practical patterns for common diagram types.

## Flowcharts

### Basic Process Flow

```xml
<!-- Start -->
<mxCell id="start" value="Start" style="ellipse;whiteSpace=wrap;html=1;fillColor=#D1FAE5;strokeColor=#059669;" vertex="1" parent="1">
 <mxGeometry x="140" y="40" width="80" height="40" as="geometry"/>
</mxCell>

<!-- Process -->
<mxCell id="process1" value="Process Data" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DBEAFE;strokeColor=#2563EB;" vertex="1" parent="1">
 <mxGeometry x="120" y="120" width="120" height="60" as="geometry"/>
</mxCell>

<!-- Decision -->
<mxCell id="decision" value="Valid?" style="rhombus;whiteSpace=wrap;html=1;fillColor=#FEF3C7;strokeColor=#D97706;" vertex="1" parent="1">
 <mxGeometry x="130" y="220" width="100" height="80" as="geometry"/>
</mxCell>

<!-- End -->
<mxCell id="end" value="End" style="ellipse;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#DC2626;" vertex="1" parent="1">
 <mxGeometry x="140" y="340" width="80" height="40" as="geometry"/>
</mxCell>

<!-- Edges -->
<mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="start" target="process1" parent="1"/>
<mxCell id="e2" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="process1" target="decision" parent="1"/>
<mxCell id="e3" value="Yes" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="decision" target="end" parent="1"/>
```

### Decision Flow Pattern

```
┌─────────┐
│ Start │
└────┬────┘
 ▼
┌─────────┐
│ Process │
└────┬────┘
 ▼
 ◇───────────┐
 Valid? │ No
 │Yes ▼
 ▼ ┌────────┐
┌─────┐ │ Retry │
│ End │ └────────┘
└─────┘
```

## Architecture Diagrams

### Three-Tier Web App

```xml
<!-- Presentation Tier -->
<mxCell id="vpc" value="VPC" style="swimlane;startSize=23;" vertex="1" parent="1">
 <mxGeometry x="40" y="40" width="600" height="300" as="geometry"/>
</mxCell>

<mxCell id="alb" value="ALB" style="rounded=1;fillColor=#DBEAFE;strokeColor=#2563EB;" vertex="1" parent="vpc">
 <mxGeometry x="240" y="40" width="120" height="60" as="geometry"/>
</mxCell>

<!-- Application Tier -->
<mxCell id="ecs1" value="ECS Task 1" style="rounded=1;fillColor=#E0E7FF;strokeColor=#4F46E5;" vertex="1" parent="vpc">
 <mxGeometry x="80" y="140" width="120" height="60" as="geometry"/>
</mxCell>

<mxCell id="ecs2" value="ECS Task 2" style="rounded=1;fillColor=#E0E7FF;strokeColor=#4F46E5;" vertex="1" parent="vpc">
 <mxGeometry x="400" y="140" width="120" height="60" as="geometry"/>
</mxCell>

<!-- Data Tier -->
<mxCell id="rds" value="RDS" style="shape=cylinder3;fillColor=#D1FAE5;strokeColor=#059669;" vertex="1" parent="vpc">
 <mxGeometry x="270" y="220" width="60" height="80" as="geometry"/>
</mxCell>
```

### Serverless Architecture

```yaml
Layout:
 Row 1: Client → API Gateway → Lambda
 Row 2: Lambda → DynamoDB, S3, SQS

Node styles:
 Client: ellipse, pink
 API Gateway: rounded, blue
 Lambda: rounded, orange
 DynamoDB: cylinder, green
 S3: rounded, green
 SQS: parallelogram, purple
```

## Sequence Diagrams

### OAuth 2.0 Flow

```xml
<!-- Participants (vertical swimlanes) -->
<mxCell id="user" value="User" style="swimlane;horizontal=0;startSize=30;" vertex="1" parent="1">
 <mxGeometry x="40" width="100" height="400" as="geometry"/>
</mxCell>

<mxCell id="app" value="App" style="swimlane;horizontal=0;startSize=30;" vertex="1" parent="1">
 <mxGeometry x="160" width="100" height="400" as="geometry"/>
</mxCell>

<mxCell id="auth" value="Auth Server" style="swimlane;horizontal=0;startSize=30;" vertex="1" parent="1">
 <mxGeometry x="280" width="100" height="400" as="geometry"/>
</mxCell>

<!-- Messages (horizontal arrows between lifelines) -->
<!-- 1. User clicks login -->
<mxCell id="m1" value="1. Login" style="edgeStyle=orthogonalEdgeStyle;endArrow=block;" edge="1" parent="1">
 <mxGeometry relative="1" as="geometry">
 <mxPoint x="90" y="80" as="sourcePoint"/>
 <mxPoint x="210" y="80" as="targetPoint"/>
 </mxGeometry>
</mxCell>

<!-- 2. Redirect to auth -->
<mxCell id="m2" value="2. Redirect" style="edgeStyle=orthogonalEdgeStyle;endArrow=block;dashed=1;" edge="1" parent="1">
 <mxGeometry relative="1" as="geometry">
 <mxPoint x="210" y="120" as="sourcePoint"/>
 <mxPoint x="330" y="120" as="targetPoint"/>
 </mxGeometry>
</mxCell>
```

## Microservices

### Event-Driven Architecture

```yaml
Components:
 - API Gateway (entry point)
 - Order Service
 - Payment Service
 - Notification Service
 - Event Bus (EventBridge/Kafka)

Connections:
 - API Gateway → Order Service (sync, REST)
 - Order Service → Event Bus (async, events)
 - Event Bus → Payment Service (async)
 - Event Bus → Notification Service (async)

Style:
 - Sync calls: solid arrows
 - Async events: dashed arrows
 - Services: rounded rectangles
 - Event bus: parallelogram
```

## Database Schemas (ER Diagrams)

### Entity Relationship

```xml
<!-- Users table -->
<mxCell id="users" value="users" style="swimlane;fontStyle=1;childLayout=stackLayout;horizontal=1;startSize=26;" vertex="1" parent="1">
 <mxGeometry x="40" y="40" width="160" height="104" as="geometry"/>
</mxCell>
<mxCell id="users_id" value="id: uuid PK" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;" vertex="1" parent="users">
 <mxGeometry y="26" width="160" height="26" as="geometry"/>
</mxCell>
<mxCell id="users_email" value="email: varchar(255)" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;" vertex="1" parent="users">
 <mxGeometry y="52" width="160" height="26" as="geometry"/>
</mxCell>
<mxCell id="users_created" value="created_at: timestamp" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;" vertex="1" parent="users">
 <mxGeometry y="78" width="160" height="26" as="geometry"/>
</mxCell>

<!-- Orders table -->
<mxCell id="orders" value="orders" style="swimlane;fontStyle=1;childLayout=stackLayout;horizontal=1;startSize=26;" vertex="1" parent="1">
 <mxGeometry x="280" y="40" width="160" height="130" as="geometry"/>
</mxCell>
<mxCell id="orders_id" value="id: uuid PK" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;" vertex="1" parent="orders">
 <mxGeometry y="26" width="160" height="26" as="geometry"/>
</mxCell>
<mxCell id="orders_user" value="user_id: uuid FK" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;" vertex="1" parent="orders">
 <mxGeometry y="52" width="160" height="26" as="geometry"/>
</mxCell>

<!-- Relationship -->
<mxCell id="rel1" value="1:N" style="edgeStyle=entityRelationEdgeStyle;endArrow=ERmany;startArrow=ERone;" edge="1" source="users" target="orders" parent="1"/>
```

## CI/CD Pipeline

```yaml
Stages:
 1. Source (GitHub)
 2. Build (CodeBuild)
 3. Test (pytest)
 4. Deploy Dev (ECS)
 5. Approval Gate
 6. Deploy Prod (ECS)

Layout: Horizontal flow, left to right
Spacing: 120px between stages
Style:
 - Source: rounded, gray
 - Build/Test: rounded, blue
 - Deploy: rounded, green
 - Approval: diamond, yellow
```

## Layout Tips

### Horizontal Flow (Left to Right)

```
┌────┐ ┌────┐ ┌────┐ ┌────┐
│ A │ → │ B │ → │ C │ → │ D │
└────┘ └────┘ └────┘ └────┘

Spacing: 32-48px between nodes
Alignment: Vertical center
```

### Vertical Flow (Top to Bottom)

```
 ┌────┐
 │ A │
 └──┬─┘
 ▼
 ┌────┐
 │ B │
 └──┬─┘
 ▼
 ┌────┐
 │ C │
 └────┘

Spacing: 48-64px between nodes
Alignment: Horizontal center
```

### Grid Layout

```
┌────┐ ┌────┐ ┌────┐
│ A │ │ B │ │ C │
└────┘ └────┘ └────┘

┌────┐ ┌────┐ ┌────┐
│ D │ │ E │ │ F │
└────┘ └────┘ └────┘

Cell size: 120x60 nodes in 160x100 cells
```

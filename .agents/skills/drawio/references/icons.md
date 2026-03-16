# Cloud Provider Icons

Icon paths for AWS, GCP, Azure, and DevOps tools in Draw.io.

## AWS Icons (mxgraph.aws4.*)

### Compute

```yaml
lambda: "shape=mxgraph.aws4.lambda;"
ec2: "shape=mxgraph.aws4.ec2;"
ecs: "shape=mxgraph.aws4.ecs;"
eks: "shape=mxgraph.aws4.eks;"
fargate: "shape=mxgraph.aws4.fargate;"
batch: "shape=mxgraph.aws4.batch;"
```

### Storage & Database

```yaml
s3: "shape=mxgraph.aws4.s3;"
dynamodb: "shape=mxgraph.aws4.dynamodb;"
rds: "shape=mxgraph.aws4.rds;"
aurora: "shape=mxgraph.aws4.aurora;"
elasticache: "shape=mxgraph.aws4.elasticache;"
redshift: "shape=mxgraph.aws4.redshift;"
```

### Networking

```yaml
api_gateway: "shape=mxgraph.aws4.api_gateway;"
cloudfront: "shape=mxgraph.aws4.cloudfront;"
route53: "shape=mxgraph.aws4.route_53;"
vpc: "shape=mxgraph.aws4.vpc;"
elb: "shape=mxgraph.aws4.elastic_load_balancing;"
alb: "shape=mxgraph.aws4.application_load_balancer;"
```

### Integration

```yaml
sqs: "shape=mxgraph.aws4.sqs;"
sns: "shape=mxgraph.aws4.sns;"
eventbridge: "shape=mxgraph.aws4.eventbridge;"
step_functions: "shape=mxgraph.aws4.step_functions;"
kinesis: "shape=mxgraph.aws4.kinesis;"
```

### Security

```yaml
iam: "shape=mxgraph.aws4.identity_and_access_management;"
cognito: "shape=mxgraph.aws4.cognito;"
secrets_manager: "shape=mxgraph.aws4.secrets_manager;"
kms: "shape=mxgraph.aws4.key_management_service;"
waf: "shape=mxgraph.aws4.waf;"
```

### Full AWS Icon Example

```xml
<mxCell id="aws-lambda" value="Lambda"
 style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;"
 vertex="1" parent="1">
 <mxGeometry x="100" y="100" width="60" height="60" as="geometry"/>
</mxCell>
```

## GCP Icons (mxgraph.gcp2.*)

### Compute

```yaml
cloud_run: "shape=mxgraph.gcp2.cloud_run;"
cloud_functions: "shape=mxgraph.gcp2.cloud_functions;"
compute_engine: "shape=mxgraph.gcp2.compute_engine;"
gke: "shape=mxgraph.gcp2.google_kubernetes_engine;"
app_engine: "shape=mxgraph.gcp2.app_engine;"
```

### Storage & Database

```yaml
cloud_storage: "shape=mxgraph.gcp2.cloud_storage;"
bigquery: "shape=mxgraph.gcp2.bigquery;"
cloud_sql: "shape=mxgraph.gcp2.cloud_sql;"
firestore: "shape=mxgraph.gcp2.cloud_firestore;"
spanner: "shape=mxgraph.gcp2.cloud_spanner;"
bigtable: "shape=mxgraph.gcp2.cloud_bigtable;"
```

### Networking

```yaml
cloud_load_balancing: "shape=mxgraph.gcp2.cloud_load_balancing;"
cloud_cdn: "shape=mxgraph.gcp2.cloud_cdn;"
cloud_dns: "shape=mxgraph.gcp2.cloud_dns;"
vpc: "shape=mxgraph.gcp2.virtual_private_cloud;"
```

### Integration

```yaml
pubsub: "shape=mxgraph.gcp2.cloud_pubsub;"
cloud_tasks: "shape=mxgraph.gcp2.cloud_tasks;"
cloud_scheduler: "shape=mxgraph.gcp2.cloud_scheduler;"
workflows: "shape=mxgraph.gcp2.workflows;"
```

## Azure Icons (mxgraph.azure.*)

### Compute

```yaml
functions: "shape=mxgraph.azure.functions;"
app_service: "shape=mxgraph.azure.app_services;"
aks: "shape=mxgraph.azure.kubernetes_services;"
vm: "shape=mxgraph.azure.virtual_machine;"
container_instances: "shape=mxgraph.azure.container_instances;"
```

### Storage & Database

```yaml
blob_storage: "shape=mxgraph.azure.storage_blob;"
cosmos_db: "shape=mxgraph.azure.cosmos_db;"
sql_database: "shape=mxgraph.azure.sql_database;"
redis_cache: "shape=mxgraph.azure.redis_cache;"
```

### Networking

```yaml
api_management: "shape=mxgraph.azure.api_management;"
front_door: "shape=mxgraph.azure.front_door;"
application_gateway: "shape=mxgraph.azure.application_gateway;"
cdn: "shape=mxgraph.azure.cdn_profiles;"
```

### Integration

```yaml
service_bus: "shape=mxgraph.azure.service_bus;"
event_grid: "shape=mxgraph.azure.event_grid_topics;"
event_hubs: "shape=mxgraph.azure.event_hubs;"
logic_apps: "shape=mxgraph.azure.logic_apps;"
```

## DevOps Icons

### Containers & Orchestration

```yaml
docker: "shape=mxgraph.docker.docker;"
kubernetes: "shape=mxgraph.kubernetes.kubernetes;"
helm: "shape=mxgraph.kubernetes.helm;"
```

### CI/CD

```yaml
github_actions: "shape=mxgraph.github.actions;"
jenkins: "shape=mxgraph.jenkins.jenkins;"
gitlab: "shape=mxgraph.gitlab.gitlab;"
circleci: "shape=mxgraph.circleci.circleci;"
```

## ML/AI Icons

```yaml
# Neural Network Components
input_layer: "shape=mxgraph.neural_network.input_layer;"
hidden_layer: "shape=mxgraph.neural_network.hidden_layer;"
output_layer: "shape=mxgraph.neural_network.output_layer;"
convolution: "shape=mxgraph.neural_network.convolution;"
pooling: "shape=mxgraph.neural_network.pooling;"

# AWS ML
sagemaker: "shape=mxgraph.aws4.sagemaker;"
bedrock: "shape=mxgraph.aws4.bedrock;"

# GCP ML
vertex_ai: "shape=mxgraph.gcp2.vertex_ai;"
```

## Icon Best Practices

1. **Size**: Standard icons are 60x60px; with labels, total height ~90px
2. **Consistency**: Use icons from one cloud provider per diagram
3. **Labels**: Position below icon, keep brief (≤14 chars)
4. **Spacing**: 32px between related icons
5. **Groups**: Use containers (VPC shapes) to group related services
6. **Colors**: Use official AWS orange (#ED7100), GCP blue (#4285F4), Azure blue (#0078D4)

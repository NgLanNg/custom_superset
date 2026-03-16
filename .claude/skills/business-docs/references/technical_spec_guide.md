# Technical Specification Guide

## Purpose
Detailed implementation blueprint for engineers. Answers "how exactly do we build this?"

## Structure

### 1. Overview
- System name and version
- Related documents (BRD, FRS, ADR)
- Target audience (backend/frontend/devops)
- Last updated date

### 2. Architecture

**System Context Diagram (C4 Level 1):**
```
[User] --> [System] --> [External API]
 \--> [Database]
```

**Container Diagram (C4 Level 2):**
```
[Web App] --HTTP--> [API Gateway] ---> [Lambda Functions]
 \--> [RDS Postgres]
 \--> [S3 Bucket]
```

**Technology Stack:**
- **Frontend:** React 18, TypeScript, Tailwind CSS
- **Backend:** Node.js 20 (Lambda), Python 3.11 (ETL)
- **Database:** PostgreSQL 15 (Aurora Serverless v2)
- **Infrastructure:** AWS SAM, CloudFormation
- **CI/CD:** GitHub Actions, AWS CodePipeline

### 3. Data Models

**Database Schema:**
```sql
CREATE TABLE users (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 email VARCHAR(255) UNIQUE NOT NULL,
 role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'user', 'viewer')),
 created_at TIMESTAMPTZ DEFAULT NOW(),
 updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

**Domain Models (Code):**
```typescript
interface User {
 id: string;
 email: string;
 role: 'admin' | 'user' | 'viewer';
 createdAt: Date;
 updatedAt: Date;
}
```

**Data Flow:**
```
S3 Upload --> EventBridge --> Step Function --> Lambda (Extract)
 --> Lambda (Transform)
 --> Lambda (Load to RDS)
```

### 4. API Specification

**REST Endpoints:**

```
POST /api/v1/users
Auth: Bearer token (JWT)
Request:
{
 "email": "user@example.com",
 "role": "user"
}
Response (201 Created):
{
 "id": "uuid-here",
 "email": "user@example.com",
 "role": "user",
 "createdAt": "2024-01-15T10:30:00Z"
}
Error (400 Bad Request):
{
 "error": {
 "code": "INVALID_EMAIL",
 "message": "Email format is invalid",
 "field": "email"
 }
}
```

**GraphQL Schema (if applicable):**
```graphql
type Query {
 user(id: ID!): User
 users(filter: UserFilter, limit: Int, offset: Int): [User!]!
}

type Mutation {
 createUser(input: CreateUserInput!): User!
 updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

### 5. Component Specifications

**Per Component:**

**Component Name:** UserService

**Responsibility:** Manages user CRUD operations, enforces RBAC

**Dependencies:**
- Database: PostgreSQL (users table)
- Auth: JWT validation middleware
- Logger: Winston (structured logging)

**Public Interface:**
```typescript
class UserService {
 async createUser(email: string, role: Role): Promise<User>
 async getUserById(id: string): Promise<User | null>
 async updateUser(id: string, updates: Partial<User>): Promise<User>
 async deleteUser(id: string): Promise<void>
}
```

**Error Handling:**
- Throws `UserNotFoundError` if user ID doesn't exist
- Throws `DuplicateEmailError` if email already registered
- All DB errors wrapped in `DatabaseError`

**Performance:**
- `getUserById`: < 50ms (indexed lookup)
- `createUser`: < 200ms (includes password hash)

### 6. Algorithms & Business Logic

**Example: Discount Calculation**

```python
def calculate_discount(order_total: Decimal, user: User) -> Decimal:
 """
 Apply tiered discounts based on order total and user loyalty tier.

 Rules:
 - Gold tier: 20% if order > $100, else 10%
 - Silver tier: 10% if order > $100, else 5%
 - Bronze tier: 5% if order > $50, else 0%

 Returns discount amount (not percentage).
 """
 tier_rules = {
 'gold': [(100, 0.20), (0, 0.10)],
 'silver': [(100, 0.10), (0, 0.05)],
 'bronze': [(50, 0.05), (0, 0)]
 }

 rules = tier_rules.get(user.loyalty_tier, [(0, 0)])

 for threshold, rate in rules:
 if order_total > threshold:
 return order_total * Decimal(rate)

 return Decimal(0)
```

### 7. Security Specifications

**Authentication:**
- OAuth 2.0 + PKCE for web apps
- JWT tokens (15 min expiry, refresh tokens 7 days)
- Token storage: HttpOnly cookies (not localStorage)

**Authorization:**
- RBAC: Admin > User > Viewer
- Endpoint permissions: `@RequireRole('admin')`
- Row-level security (RLS) in PostgreSQL:
 ```sql
 CREATE POLICY user_isolation ON data
 FOR ALL TO app_user
 USING (owner_id = current_user_id());
 ```

**Data Protection:**
- PII encrypted at rest: AES-256-GCM
- TLS 1.3 for all HTTPS traffic
- Secrets: AWS Secrets Manager (rotated every 90 days)
- SQL injection prevention: Parameterized queries only

**Audit Logging:**
```json
{
 "timestamp": "2024-01-15T10:30:00Z",
 "user_id": "uuid",
 "action": "DELETE_USER",
 "resource": "users/123",
 "ip_address": "192.168.1.1",
 "user_agent": "Mozilla/5.0..."
}
```

### 8. Performance Requirements

**Response Time:**
- API endpoints: p50 < 200ms, p95 < 500ms, p99 < 1s
- Database queries: < 100ms (simple), < 500ms (complex aggregations)
- Page load: First Contentful Paint < 1.5s

**Throughput:**
- 1000 requests/second (peak load)
- 10,000 concurrent WebSocket connections

**Optimization Strategies:**
- Database indexing on high-cardinality columns
- Redis caching (TTL 5 min for user sessions)
- CDN for static assets (CloudFront)
- Lazy loading for non-critical components

### 9. Error Handling & Resilience

**Retry Strategy:**
```typescript
async function retryWithBackoff<T>(
 fn: () => Promise<T>,
 maxRetries = 3,
 baseDelay = 1000
): Promise<T> {
 for (let i = 0; i < maxRetries; i++) {
 try {
 return await fn();
 } catch (error) {
 if (i === maxRetries - 1 || !isRetryable(error)) throw error;
 await sleep(baseDelay * Math.pow(2, i) + Math.random() * 1000);
 }
 }
 throw new Error('Unreachable');
}
```

**Circuit Breaker:**
- Threshold: 5 failures in 10 seconds → Open
- Timeout: 60 seconds → Half-Open (try 1 request)
- Success → Closed (normal operation)

**Fallback:**
```typescript
async function getUserProfile(id: string): Promise<UserProfile> {
 try {
 return await primaryDB.getUser(id);
 } catch (error) {
 logger.warn('Primary DB failed, using cache', { error });
 return await cache.getUser(id); // Stale data acceptable
 }
}
```

### 10. Testing Strategy

**Unit Tests:**
```typescript
describe('UserService', () => {
 it('should create user with valid email', async () => {
 const user = await userService.createUser('test@example.com', 'user');
 expect(user.email).toBe('test@example.com');
 expect(user.role).toBe('user');
 });

 it('should throw DuplicateEmailError for existing email', async () => {
 await userService.createUser('test@example.com', 'user');
 await expect(
 userService.createUser('test@example.com', 'admin')
 ).rejects.toThrow(DuplicateEmailError);
 });
});
```

**Integration Tests:**
```python
def test_api_create_user(client, auth_headers):
 response = client.post('/api/v1/users', json={
 'email': 'new@example.com',
 'role': 'user'
 }, headers=auth_headers)

 assert response.status_code == 201
 assert response.json['email'] == 'new@example.com'

 # Verify database persistence
 user = db.query(User).filter_by(email='new@example.com').first()
 assert user is not None
```

**Load Tests (k6):**
```javascript
import http from 'k6/http';
import { check } from 'k6';

export let options = {
 stages: [
 { duration: '2m', target: 100 }, // Ramp up
 { duration: '5m', target: 1000 }, // Peak load
 { duration: '2m', target: 0 }, // Ramp down
 ],
 thresholds: {
 http_req_duration: ['p(95)<500'], // 95% under 500ms
 },
};

export default function () {
 let res = http.get('https://api.example.com/users');
 check(res, { 'status is 200': (r) => r.status === 200 });
}
```

### 11. Deployment Specification

**Infrastructure as Code (SAM):**
```yaml
Resources:
 UserFunction:
 Type: AWS::Serverless::Function
 Properties:
 Runtime: nodejs20.x
 Handler: index.handler
 Environment:
 Variables:
 DB_SECRET_ARN: !Ref DatabaseSecret
 LOG_LEVEL: info
 Policies:
 - AWSSecretsManagerGetSecretValuePolicy:
 SecretArn: !Ref DatabaseSecret
```

**CI/CD Pipeline:**
```yaml
# .github/workflows/deploy.yml
on: push
jobs:
 test:
 runs-on: ubuntu-latest
 steps:
 - run: npm test
 deploy:
 needs: test
 if: github.ref == 'refs/heads/main'
 steps:
 - run: sam build --use-container
 - run: sam deploy --no-confirm-changeset
```

**Rollback Plan:**
- Blue-green deployment (zero downtime)
- Previous version kept for 24 hours
- Manual rollback: `sam deploy --parameter-overrides Version=previous`

### 12. Monitoring & Observability

**Metrics (CloudWatch):**
- `APILatency` (p50, p95, p99)
- `ErrorRate` (4xx, 5xx)
- `DatabaseConnections` (active, idle)
- `LambdaConcurrentExecutions`

**Alerts:**
```yaml
HighErrorRateAlarm:
 Type: AWS::CloudWatch::Alarm
 Properties:
 MetricName: 4XXError
 Threshold: 100
 EvaluationPeriods: 2
 AlarmActions:
 - !Ref SNSTopic
```

**Structured Logging:**
```typescript
logger.info('User created', {
 userId: user.id,
 email: user.email,
 requestId: context.requestId,
 duration: Date.now() - startTime
});
```

**Tracing (X-Ray):**
- Instrument Lambda functions
- Track downstream calls (DB, external APIs)
- Visualize service map

### 13. Migration Plan (If Applicable)

**Data Migration:**
1. Export from legacy system (CSV)
2. Transform (Python script: `scripts/migrate.py`)
3. Validate schema compatibility
4. Load to staging DB
5. Run validation queries (row counts, checksums)
6. Load to production (off-peak hours)
7. Verify and cutover DNS

**Code Migration:**
- Feature flags for gradual rollout
- Parallel run (old + new) for 1 week
- Monitor error rates
- Full cutover after validation

## Glossary

- **ADR:** Architecture Decision Record (why we chose X over Y)
- **RBAC:** Role-Based Access Control
- **RLS:** Row-Level Security (PostgreSQL feature)
- **PKCE:** Proof Key for Code Exchange (OAuth security extension)
- **p50/p95/p99:** 50th/95th/99th percentile (performance metrics)

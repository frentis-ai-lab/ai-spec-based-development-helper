# [API Name] Specification

**Author**: [Your Name]
**Date**: [YYYY-MM-DD]
**Status**: Draft
**Version**: 1.0
**API Version**: v1

---

## 1. Overview

### Purpose
[What does this API do? What problem does it solve?]

### Scope
- [In scope: Feature 1]
- [In scope: Feature 2]
- [Out of scope: Feature 3]

### Key Features
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

---

## 2. Architecture

### System Components

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│  Client  │─────▶│ API Gateway│────▶│ Service  │
└──────────┘      └──────────┘      └──────────┘
                         │
                         ▼
                  ┌──────────┐
                  │ Database │
                  └──────────┘
```

### Technology Stack
- **API Framework**: [e.g., Express, FastAPI, Spring Boot]
- **Authentication**: [e.g., JWT, OAuth 2.0]
- **Database**: [e.g., PostgreSQL, MongoDB]
- **Cache**: [e.g., Redis]
- **Documentation**: [e.g., OpenAPI/Swagger]

### Base URL
```
Production:  https://api.example.com/v1
Staging:     https://staging-api.example.com/v1
Development: http://localhost:3000/v1
```

---

## 3. Authentication & Authorization

### Authentication Method
[Describe: API Key, OAuth 2.0, JWT, etc.]

```http
Authorization: Bearer {token}
```

### Authorization Levels
| Role | Permissions |
|------|-------------|
| Admin | Full access |
| User | Read/Write own resources |
| Guest | Read-only public resources |

---

## 4. API Endpoints

### 4.1 [Resource Name] Endpoints

#### List Resources
```http
GET /api/v1/resources
```

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number |
| limit | integer | No | 20 | Items per page |
| sort | string | No | created_at | Sort field |
| order | string | No | desc | Sort order (asc/desc) |
| filter | string | No | - | Filter expression |

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "createdAt": "2025-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or missing token
- `403 Forbidden`: Insufficient permissions
- `429 Too Many Requests`: Rate limit exceeded

---

#### Get Resource by ID
```http
GET /api/v1/resources/{id}
```

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| id | uuid | Resource identifier |

**Response (200 OK):**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "status": "active",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

**Error Responses:**
- `404 Not Found`: Resource does not exist

---

#### Create Resource
```http
POST /api/v1/resources
```

**Request Body:**
```json
{
  "name": "string (required, 1-255 chars)",
  "description": "string (optional, max 1000 chars)",
  "type": "enum (required: typeA | typeB)",
  "config": {
    "option1": "value",
    "option2": 42
  }
}
```

**Validation Rules:**
- `name`: Required, 1-255 characters, unique
- `type`: Required, must be one of predefined types
- `config`: Optional, must match schema for given type

**Response (201 Created):**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "type": "typeA",
  "config": {},
  "createdAt": "2025-01-15T10:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request`: Validation error
  ```json
  {
    "error": "Validation failed",
    "details": [
      {
        "field": "name",
        "message": "Name is required",
        "code": "REQUIRED_FIELD"
      }
    ]
  }
  ```
- `409 Conflict`: Resource already exists

---

#### Update Resource
```http
PATCH /api/v1/resources/{id}
```

**Request Body:**
```json
{
  "name": "string (optional)",
  "description": "string (optional)",
  "status": "enum (optional: active | inactive)"
}
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "status": "active",
  "updatedAt": "2025-01-15T11:00:00Z"
}
```

---

#### Delete Resource
```http
DELETE /api/v1/resources/{id}
```

**Response (204 No Content):**
[Empty body]

**Error Responses:**
- `404 Not Found`: Resource does not exist
- `409 Conflict`: Resource cannot be deleted (has dependencies)

---

## 5. Data Models

### Resource Model

```typescript
interface Resource {
  id: string;              // UUID v4
  name: string;            // 1-255 chars, unique
  description?: string;    // Optional, max 1000 chars
  type: ResourceType;      // Enum
  status: Status;          // Enum: active | inactive | deleted
  config: Record<string, any>;
  createdAt: Date;         // ISO 8601
  updatedAt: Date;         // ISO 8601
  deletedAt?: Date;        // Soft delete timestamp
}

enum ResourceType {
  TYPE_A = 'typeA',
  TYPE_B = 'typeB'
}

enum Status {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  DELETED = 'deleted'
}
```

---

## 6. Error Handling

### Error Response Format

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": [],
  "timestamp": "2025-01-15T10:00:00Z",
  "path": "/api/v1/resources",
  "requestId": "uuid"
}
```

### Error Codes

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Authentication required |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict |
| 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |

---

## 7. Rate Limiting

### Limits
- **Authenticated Users**: 1000 requests/hour
- **Unauthenticated**: 100 requests/hour

### Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642248000
```

### Rate Limit Response (429)
```json
{
  "error": "Rate limit exceeded",
  "code": "RATE_LIMIT_EXCEEDED",
  "retryAfter": 3600
}
```

---

## 8. Versioning

### Strategy
[Describe: URL versioning, Header versioning, etc.]

### Deprecation Policy
- Minimum 6 months notice before deprecation
- Deprecation warnings in response headers:
  ```http
  Sunset: Sat, 31 Dec 2025 23:59:59 GMT
  Deprecation: true
  Link: <https://docs.example.com/migration>; rel="sunset"
  ```

---

## 9. Testing

### Test Cases

#### TC-1: Create Resource Successfully
```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Resource",
    "type": "typeA"
  }'
```
**Expected**: 201 Created with resource object

#### TC-2: Create Resource with Invalid Data
```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": ""
  }'
```
**Expected**: 400 Bad Request with validation errors

---

## 10. Performance Requirements

| Metric | Target |
|--------|--------|
| Response Time (p95) | < 200ms |
| Response Time (p99) | < 500ms |
| Throughput | > 1000 req/s |
| Availability | 99.9% |
| Error Rate | < 0.1% |

---

## 11. Security

### Security Measures
- [ ] HTTPS only (TLS 1.2+)
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Rate limiting
- [ ] API key rotation policy
- [ ] Audit logging

### Sensitive Data Handling
- Passwords: Bcrypt with salt rounds ≥ 12
- PII: Encrypted at rest (AES-256)
- Tokens: Short-lived (1 hour), refresh tokens (7 days)

---

## 12. Monitoring & Logging

### Metrics
- Request count by endpoint
- Response time percentiles
- Error rate
- Active connections
- Cache hit rate

### Logging
```json
{
  "timestamp": "2025-01-15T10:00:00Z",
  "level": "info",
  "method": "POST",
  "path": "/api/v1/resources",
  "statusCode": 201,
  "duration": 45,
  "userId": "uuid",
  "requestId": "uuid"
}
```

---

## 13. Documentation

### OpenAPI Specification
[Link to swagger.yml or OpenAPI spec file]

### Interactive Docs
- Swagger UI: https://api.example.com/docs
- ReDoc: https://api.example.com/redoc

### Examples
[Link to Postman collection or example repository]

---

## Appendix

### Changelog
| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-15 | Initial release |

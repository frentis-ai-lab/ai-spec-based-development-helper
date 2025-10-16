# API Specification

> **역할**: 백엔드 API의 엔드포인트, 데이터 스키마, 인증 방식을 정의하는 기술 문서
> **독자**: 백엔드 개발자, 프론트엔드 개발자, API 사용자
> **관련 문서**: 시스템 아키텍처는 `program-spec.md`, UI 사용 방식은 `ui-ux-spec.md` 참조

**Status**: Draft
**Version**: 1.0
**API Version**: v1
**Last Updated**: [YYYY-MM-DD]

---

## 1. Overview

### 1.1 Purpose
- **문제**: 이 API가 해결하는 문제
- **솔루션**: 제공하는 기능
- **전체 맥락**: `program-spec.md#개요` 참조

### 1.2 Key Features
1. [Feature 1] - `program-spec.md#기능1` 참조
2. [Feature 2] - `program-spec.md#기능2` 참조
3. [Feature 3] - `program-spec.md#기능3` 참조

---

## 2. API Configuration

### 2.1 Base URL
```
Production:  https://api.example.com/v1
Staging:     https://staging-api.example.com/v1
Development: http://localhost:3000/v1
```

### 2.2 Technology Stack
> 전체 기술 스택과 아키텍처 패턴은 `program-spec.md#기술스택` 참조

- **API Framework**: [e.g., Express, FastAPI]
- **Authentication**: JWT
- **Documentation**: OpenAPI/Swagger

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

## Appendix A: Cross-Reference

### 다른 스펙과의 관계
- **Program Spec**: 전체 시스템 아키텍처, 데이터 모델, 비기능 요구사항 참조
- **UI/UX Spec**: 각 API가 어떤 화면에서 사용되는지 확인

### 주요 API와 UI 매핑
| API Endpoint | UI Screen | 설명 |
|--------------|-----------|------|
| POST /auth/login | `ui-ux-spec.md#로그인화면` | 로그인 처리 |
| GET /users/:id | `ui-ux-spec.md#프로필화면` | 사용자 정보 표시 |
| POST /contents | `ui-ux-spec.md#편집기` | 콘텐츠 생성 |

---

## Appendix B: Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-15 | Initial release |

---

## Review Checklist

- [ ] 모든 엔드포인트가 명확히 정의됨
- [ ] Request/Response 스키마가 완전함
- [ ] 에러 케이스가 모두 정의됨
- [ ] 인증/권한 검증 로직이 명확함
- [ ] `program-spec.md`와 데이터 모델이 일치함
- [ ] `ui-ux-spec.md`와 API 사용 방식이 일치함
- [ ] 성능 요구사항이 측정 가능함
- [ ] `/spec-review --file api-spec.md` 실행 (목표: 90점 이상)

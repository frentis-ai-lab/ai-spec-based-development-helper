# 3-File Spec 구조 가이드

## 왜 3개 파일인가?

**문제**: 단일 스펙 파일은 프로젝트가 커지면 관리 어려움
**해결**: 관심사 분리 (Separation of Concerns)

| 파일 | 담당 영역 | 누가 주로 보나? |
|------|----------|----------------|
| `program-spec.md` | 시스템 전체 (아키텍처, 데이터) | Backend + Frontend |
| `api-spec.md` | API 엔드포인트, 데이터 스키마 | Backend |
| `ui-ux-spec.md` | UI 컴포넌트, 사용자 플로우 | Frontend |

## 프로젝트 타입별 필요 파일

### Backend 프로젝트
```
.specs/
├── program-spec.md ✅ (필수)
└── api-spec.md ✅ (필수)
```

### Frontend 프로젝트
```
.specs/
├── program-spec.md ✅ (필수)
└── ui-ux-spec.md ✅ (필수)
```

### Fullstack 프로젝트
```
.specs/
├── program-spec.md ✅ (필수)
├── api-spec.md ✅
└── ui-ux-spec.md ✅
```

## 각 파일의 역할

### 1. program-spec.md (마스터 스펙)

**역할**: 프로젝트 전체의 청사진

**주요 섹션**:
```markdown
## 1. 개요
- 문제 정의
- 목표
- 범위

## 2. 시스템 아키텍처
- 전체 구조도
- 기술 스택 (TypeScript? Python?)
- 아키텍처 패턴 (MVC? Clean Architecture?)

## 3. 데이터 모델
- ERD (Entity-Relationship Diagram)
- 주요 엔티티
- 관계

## 4. 핵심 기능 목록
FR-1: 사용자 등록 → 참조: api-spec.md#회원가입API
FR-2: 로그인 → 참조: ui-ux-spec.md#로그인화면

## 5. 비기능 요구사항
- 성능 (p95 < 200ms)
- 보안 (JWT, bcrypt)
- 확장성

## 6. 배포 전략
- 환경 (dev/staging/prod)
- CI/CD
```

**언제 수정?**
- 새 기능 추가 시 (기능 목록 업데이트)
- 아키텍처 변경 시
- 데이터 모델 변경 시

---

### 2. api-spec.md (API 상세)

**역할**: API 엔드포인트 상세 정의

**주요 섹션**:
```markdown
## 1. API Configuration
- Base URL: https://api.example.com/v1
- 인증: JWT (Bearer token)
- Rate limiting: 100 req/min

## 2. Authentication
- POST /auth/register
- POST /auth/login
- POST /auth/refresh

## 3. Endpoints

### POST /users
**Request**:
{
  "email": "user@example.com",
  "password": "SecurePass123"
}

**Response 201**:
{
  "id": "uuid",
  "email": "user@example.com",
  "createdAt": "2025-01-01T00:00:00Z"
}

**Response 400**: { error: "VALIDATION_ERROR", ... }
**Response 409**: { error: "EMAIL_EXISTS", ... }

**Validation**:
- email: RFC 5322 형식
- password: 최소 8자, 대소문자+숫자

## 4. Data Models (TypeScript)
interface User {
  id: string;
  email: string;
  passwordHash: string; // bcrypt
  createdAt: Date;
}

## 5. Error Handling
모든 에러는 표준 형식:
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { ... }
  }
}
```

**program-spec.md와 연동**:
```markdown
# program-spec.md
## 데이터 모델
- User 엔티티 → 참조: api-spec.md#User

# api-spec.md
## Data Models
### User
참조: program-spec.md의 User 엔티티 정의
```

---

### 3. ui-ux-spec.md (UI 상세)

**역할**: 화면별 UI/UX 정의

**주요 섹션**:
```markdown
## 1. Design System
### Colors
- Primary: #3B82F6
- Secondary: #10B981
- Error: #EF4444

### Typography
- Heading: Inter Bold 24px
- Body: Inter Regular 16px

### Components
- Button (Primary, Secondary, Danger)
- Input (Text, Password, Email)
- Modal

## 2. Screen Specifications

### 로그인 화면 (/login)

**Wireframe**:
┌─────────────────────────┐
│   Logo                  │
│   ─────────────────     │
│   [Email Input]         │
│   [Password Input]      │
│   [Login Button]        │
│   Don't have account?   │
└─────────────────────────┘

**Elements**:
1. Logo (center, 120x40px)
2. Email input
   - Type: email
   - Validation: RFC 5322
   - Error: "Invalid email format"
3. Password input
   - Type: password
   - Show/Hide toggle
4. Login button
   - Disabled if validation fails
   - Loading state on submit

**Interactions**:
- Submit → API 호출: api-spec.md#POST /auth/login
- Success → Navigate to /dashboard
- Error → Show toast notification (Design System#Toast)

**States**:
- Idle
- Loading (button disabled, spinner)
- Error (red border on input, error message)
- Success (redirect)

## 3. User Flows

### 회원가입 플로우
1. / (Landing) → Click "Sign Up"
2. /register → Fill form → Submit
3. API: POST /auth/register (api-spec.md)
4. Success → Email verification screen
5. /verify-email → Enter code → Submit
6. Success → /dashboard
```

**program-spec.md와 연동**:
```markdown
# program-spec.md
FR-1: 사용자 등록
→ API: api-spec.md#POST /auth/register
→ UI: ui-ux-spec.md#회원가입화면

# ui-ux-spec.md
### 회원가입 화면
Submit 버튼 클릭 시:
→ API 호출: api-spec.md#POST /auth/register
→ 성공 시 프로그램 플로우: program-spec.md#FR-1
```

---

## Cross-Validation (AI가 자동 검증)

spec-analyzer가 3개 파일 간 일관성을 검증합니다:

### 1. 데이터 모델 일관성

```markdown
# program-spec.md
User 엔티티:
- id: UUID
- email: string

# api-spec.md
interface User {
  id: string;  // ✅ 일치
  email: string;  // ✅ 일치
  username: string;  // ❌ program-spec에 없음!
}
```

spec-analyzer 결과:
```
❌ Inconsistency detected:
- api-spec.md defines `username` field
- program-spec.md does not mention it
→ Add to program-spec.md or remove from api-spec.md
```

### 2. API-UI 매핑 검증

```markdown
# ui-ux-spec.md
로그인 버튼 클릭 → POST /auth/login

# api-spec.md
(POST /auth/login 정의 없음)  // ❌
```

spec-analyzer 결과:
```
❌ Missing API endpoint:
- ui-ux-spec.md references POST /auth/login
- api-spec.md does not define this endpoint
→ Add endpoint definition to api-spec.md
```

### 3. 기술 스택 정합성

```markdown
# program-spec.md
기술 스택: PostgreSQL

# api-spec.md
ORM: Prisma (PostgreSQL)  // ✅ 일치

# ui-ux-spec.md
State: Redux Toolkit  // ⚠️ program-spec에 언급 없음
```

spec-analyzer 결과:
```
⚠️ Warning:
- ui-ux-spec.md mentions Redux Toolkit
- program-spec.md does not list it in tech stack
→ Add to program-spec.md#기술스택
```

---

## 실전 예제: TODO 앱

### program-spec.md (간략)
```markdown
# TODO App Specification

## 1. 개요
간단한 TODO 관리 앱 (CRUD)

## 2. 시스템 아키텍처
- Backend: Node.js + Express + TypeScript
- Database: PostgreSQL (Prisma ORM)
- Frontend: React + TypeScript

## 3. 데이터 모델
- Todo 엔티티
  - id: UUID
  - title: string
  - completed: boolean
  - createdAt: Date

## 4. 핵심 기능
- FR-1: TODO 생성 → api-spec.md#POST /todos, ui-ux-spec.md#생성폼
- FR-2: TODO 목록 조회 → api-spec.md#GET /todos, ui-ux-spec.md#목록화면
- FR-3: TODO 완료 토글 → api-spec.md#PATCH /todos/:id, ui-ux-spec.md#체크박스
```

### api-spec.md (간략)
```markdown
# TODO API Specification

## Endpoints

### POST /todos
참조: program-spec.md#FR-1
Request: { title: string }
Response 201: { id, title, completed: false, createdAt }

### GET /todos
참조: program-spec.md#FR-2
Response 200: [ { id, title, completed, createdAt }, ... ]

### PATCH /todos/:id
참조: program-spec.md#FR-3
Request: { completed: boolean }
Response 200: { id, title, completed, updatedAt }
```

### ui-ux-spec.md (간략)
```markdown
# TODO UI/UX Specification

## 화면

### TODO 목록 화면 (/)
참조: program-spec.md#FR-2

Elements:
1. 입력 폼
   - Input: title (text)
   - Button: "Add" → API: api-spec.md#POST /todos
2. TODO 목록
   - Checkbox → API: api-spec.md#PATCH /todos/:id
   - Title (completed면 strikethrough)

Interactions:
- Load on mount → API: api-spec.md#GET /todos
- Add click → POST → Refresh list
- Checkbox click → PATCH → Update UI
```

---

## 작성 순서 (권장)

1. **program-spec.md 먼저** (30분)
   - 전체 그림 그리기
   - 아키텍처, 데이터 모델, 기능 목록

2. **Backend: api-spec.md** (20분)
   - API 엔드포인트 상세 정의
   - program-spec의 기능을 API로 변환

3. **Frontend: ui-ux-spec.md** (20분)
   - 화면 설계
   - API와 연결점 명시

4. **/spec-review 실행** (5분)
   - AI가 3개 파일 일관성 검증
   - 90+ 점수까지 반복

---

## 다음 단계

- [Constitution 시스템](constitution-system.md) - 프로젝트 코딩 표준 설정
- [Sub-Agents 레퍼런스](../reference/sub-agents.md) - spec-analyzer 상세
- [예제: TODO API](../examples/todo-api.md) - 실제 프로젝트 예제

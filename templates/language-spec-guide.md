# Language Specification Guide

> **목적**: 모든 언어/프레임워크에 공통적으로 적용되는 스펙 작성 가이드
> **대상**: Specification-First 방법론을 사용하는 개발자
> **관련 문서**: Context7 Integration Spec (`.specs/context7-integration-spec.md`)

---

## 1. Context7 활용 가이드

### 1.1 Context7란?

Context7은 MCP를 통해 최신 라이브러리/프레임워크 공식 문서를 제공하는 서비스입니다.

**장점**:
- ✅ 항상 최신 문서
- ✅ 공식 소스 기반 (Trust Score)
- ✅ 자동 업데이트 (유지보수 불필요)

### 1.2 어떻게 라이브러리 찾기?

#### 자동 감지 (권장)

`/spec-init` 실행 시 자동으로:
1. 프로젝트 파일 스캔 (package.json, pyproject.toml, pom.xml)
2. 언어 및 프레임워크 감지
3. Context7 library ID 매핑
4. 최신 문서 조회

#### 수동 검색

특정 라이브러리를 수동으로 찾으려면:

```typescript
// Step 1: Resolve library name to ID
const result = await mcp__context7__resolve_library_id({
  libraryName: "TypeScript"
});
// Returns: { id: "/microsoft/TypeScript", versions: [...] }

// Step 2: Get documentation
const docs = await mcp__context7__get_library_docs({
  context7CompatibleLibraryID: "/microsoft/TypeScript/v5.4",
  topic: "strict mode, type inference",
  tokens: 5000
});
```

### 1.3 최신 버전 확인 방법

**Version Matrix에서 확인**:

| 기술 | 현재 버전 | 권장 버전 | Context7 링크 | Status |
|------|-----------|-----------|--------------|--------|
| TypeScript | 5.3.3 | 5.4+ | `/microsoft/TypeScript/v5.4` | ⚠️  Update |

- ✅ OK: 현재 버전 ≥ 권장 버전
- ⚠️ Update: 업그레이드 권장
- ❌ EOL: End-of-Life, 즉시 업그레이드 필수

**EOL 체크**:
```python
EOL_VERSIONS = {
    "node": ["14.x", "16.x"],      # EOL 2023
    "python": ["3.7", "3.8"],      # EOL 2023
    "java": ["8"],                 # Non-LTS
    "typescript": ["4.x"],         # < 5.0
}
```

### 1.4 Topic 키워드 작성 팁

**언어별 추천 Topic**:

| 언어 | 추천 Topic |
|------|-----------|
| TypeScript | "strict mode, type inference, utility types" |
| Python | "type hints, async/await, context managers" |
| Java | "records, sealed classes, pattern matching" |

**프레임워크별 추천 Topic**:

| 프레임워크 | 추천 Topic |
|-----------|-----------|
| Express | "middleware composition, async handlers, error handling" |
| FastAPI | "dependency injection, async routes, pydantic models" |
| Spring Boot | "autoconfiguration, actuator, testing" |

**팁**:
- 3-5개 키워드 사용
- "best practices" 포함 권장
- "common pitfalls", "anti-patterns" 추가 가능

---

## 2. 스펙 작성 체크리스트

### 2.1 필수 섹션 (모든 언어 공통)

#### § 0. Technology References (NEW - Context7 Integration)

```markdown
## 0. Technology References

### Context7 Documentation

- **[Technology 1]**: `/org/repo/version`
  - [Key topics from Context7]
  - [Best practices]
  - [Latest features]

### Version Matrix

| 기술 | 현재 버전 | 권장 버전 | Context7 링크 | Status |
|------|-----------|-----------|--------------|--------|
| [Tech] | [current] | [recommended] | `/org/repo/version` | [✅/⚠️/❌] |

**Version Recommendations**:
[If current < recommended]
- [ ] [Tech] upgrade from [current] to [recommended]
  - Estimated effort: [hours]
  - Breaking changes: [link or "none"]
```

**체크리스트**:
- [ ] Technology References 섹션 존재
- [ ] 3개 이상 Context7 링크 포함
- [ ] Version Matrix 테이블 작성
- [ ] EOL 버전 체크 완료
- [ ] 업그레이드 계획 (필요 시)

#### § 1. Overview
- [ ] 문제 정의
- [ ] 목표 및 성공 기준
- [ ] 범위 (포함/제외)

#### § 2. Architecture
- [ ] 시스템 구조도
- [ ] 데이터 플로우
- [ ] 기술 스택 (Context7 참조와 일치)

#### § 3-10. [나머지 섹션]
- 표준 템플릿 참조 (program-spec-template.md)

### 2.2 코드 예제 작성 규칙

**모든 코드 예제에 Context7 주석 추가**:

```typescript
// Reference: TypeScript 5.4 - Strict Null Checks
// Context7: /microsoft/TypeScript/v5.4#strict-mode
interface User {
  id: string;
  email: string;
  createdAt: Date;
}
```

**체크리스트**:
- [ ] 코드 예제에 "Reference" 주석
- [ ] "Context7" 주석 with library ID
- [ ] 코드가 최신 패턴 사용 (Deprecated 회피)

### 2.3 엣지케이스 문서화

**최소 5개 엣지케이스 + 처리 방법**:

```markdown
## 5. Edge Cases

1. **[Case Name]**
   - **Scenario**: [When does this happen?]
   - **Context7 Reference**: `/org/repo#relevant-topic`
   - **Handling**:
     ```language
     // Best practice from Context7
     [code]
     ```
```

---

## 3. 언어별 고려사항

### 3.1 TypeScript

#### 필수 체크리스트

- [ ] **Strict Mode 활성화**
  - Context7: `/microsoft/TypeScript/v5.4#strict-mode`
  - `tsconfig.json`: `strict: true`

- [ ] **타입 안정성**
  - ❌ `any` 타입 사용 금지
  - ✅ `unknown` 또는 명시적 타입 정의
  - Context7: `/microsoft/TypeScript/v5.4#type-inference`

- [ ] **최신 기능 활용**
  - TypeScript 5.4+: const type parameters
  - TypeScript 5.3+: import attributes
  - Context7: `/microsoft/TypeScript/v5.4#latest-features`

#### 스펙 템플릿 예시

```markdown
## 2. Architecture

### Technology Stack
- **TypeScript**: 5.4+ (Context7: `/microsoft/TypeScript/v5.4`)
  - Strict mode enabled
  - No `any` types
  - Utility types for type transformations

### Data Models

```typescript
// Reference: TypeScript 5.4 - Strict Null Checks
// Context7: /microsoft/TypeScript/v5.4#strict-mode
interface User {
  id: string;          // UUID v4
  email: string;       // Unique, validated
  role: 'user' | 'admin'; // Literal union type
  createdAt: Date;
}
```

**타입 안정성 체크**:
- [x] Context7 참조: TypeScript strict mode
- [x] 모든 필드 명시적 타입
- [ ] Zod schema 정의 (Context7: `/colinhacks/zod`)
```

### 3.2 Python

#### 필수 체크리스트

- [ ] **Type Hints 사용**
  - Context7: `/python/cpython/v3.12#type-hints`
  - Python 3.9+: `list[str]` (not `typing.List`)
  - Python 3.10+: `X | Y` (not `Union[X, Y]`)

- [ ] **Virtual Environment 전략**
  - `uv` (권장, 빠름) 또는 `venv`
  - `pyproject.toml` 사용 (not `requirements.txt` alone)

- [ ] **Async/Await 활용**
  - Context7: `/python/cpython/v3.12#asyncio`
  - FastAPI: 모든 핸들러 `async def`

#### 스펙 템플릿 예시

```markdown
## 2. Architecture

### Technology Stack
- **Python**: 3.12+ (Context7: `/python/cpython/v3.12`)
  - Type hints enabled
  - `uv` for dependency management
  - `ruff` for linting/formatting

### Data Models

```python
# Reference: Python 3.12 - Type Hints
# Context7: /python/cpython/v3.12#type-hints
from typing import Literal

class User:
    id: str              # UUID
    email: str           # Unique, validated
    role: Literal['user', 'admin']
    created_at: datetime
```

**타입 체크**:
- [x] Context7 참조: Python type hints
- [x] 모든 필드 타입 정의
- [ ] Pydantic model 정의 (Context7: `/pydantic/pydantic`)
```

### 3.3 Java

#### 필수 체크리스트

- [ ] **Java 21+ 사용 (LTS)**
  - Context7: `/openjdk/jdk/v21`
  - Records, Sealed Classes, Pattern Matching

- [ ] **Maven/Gradle 표준**
  - `pom.xml` 또는 `build.gradle.kts`
  - Dependency management 명확

- [ ] **Modern Date/Time API**
  - ❌ `new Date()` 금지
  - ✅ `LocalDateTime`, `ZonedDateTime`
  - Context7: `/openjdk/jdk/v21#datetime-api`

#### 스펙 템플릿 예시

```markdown
## 2. Architecture

### Technology Stack
- **Java**: 21 LTS (Context7: `/openjdk/jdk/v21`)
  - Records for DTOs
  - Sealed classes for type hierarchies
  - Virtual threads for concurrency

### Data Models

```java
// Reference: Java 21 - Records
// Context7: /openjdk/jdk/v21#records
public record User(
    String id,              // UUID
    String email,           // Unique, validated
    UserRole role,          // Enum
    LocalDateTime createdAt // Java Time API
) {}
```

**Modern Java 체크**:
- [x] Context7 참조: Java 21 records
- [x] Modern Date/Time API
- [ ] Spring Data JPA entity (Context7: `/spring-projects/spring-boot`)
```

---

## 4. 프레임워크별 고려사항

### 4.1 Express (TypeScript/JavaScript)

#### 필수 체크리스트

- [ ] **Middleware 구성**
  - Context7: `/expressjs/express#middleware`
  - Error handling middleware
  - Async wrapper for error propagation

- [ ] **라우터 구조**
  - Feature-based routing
  - RESTful conventions

#### 스펙 예시

```markdown
## 3. API Design

### Middleware Stack
```typescript
// Reference: Express 4.19 - Middleware Composition
// Context7: /expressjs/express#middleware
app.use(helmet());
app.use(cors(corsOptions));
app.use(express.json());
app.use(asyncErrorHandler); // Catch async errors
```

**Middleware 체크**:
- [x] Security headers (helmet)
- [x] CORS configuration
- [x] Error handling middleware
```

### 4.2 FastAPI (Python)

#### 필수 체크리스트

- [ ] **Dependency Injection**
  - Context7: `/tiangolo/fastapi#dependencies`
  - DB session, Auth, Config injection

- [ ] **Pydantic Models**
  - Request/Response validation
  - Automatic OpenAPI generation

#### 스펙 예시

```markdown
## 3. API Design

### Dependency Injection
```python
# Reference: FastAPI - Dependency Injection
# Context7: /tiangolo/fastapi#dependencies
from fastapi import Depends

async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session

@app.post("/users")
async def create_user(
    user: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    ...
```

**DI 체크**:
- [x] DB session injection
- [x] Auth dependency
- [x] Config dependency
```

### 4.3 Spring Boot (Java)

#### 필수 체크리스트

- [ ] **Autoconfiguration**
  - Context7: `/spring-projects/spring-boot#autoconfiguration`
  - `@SpringBootApplication`
  - `application.yml` configuration

- [ ] **Dependency Injection**
  - Constructor injection (권장)
  - `@Service`, `@Repository` layers

#### 스펙 예시

```markdown
## 3. Architecture

### Spring Layers
```java
// Reference: Spring Boot - Dependency Injection
// Context7: /spring-projects/spring-boot#dependency-injection
@Service
public class UserService {
    private final UserRepository repo;

    // Constructor injection (recommended)
    public UserService(UserRepository repo) {
        this.repo = repo;
    }
}
```

**Spring 체크**:
- [x] Constructor injection
- [x] Layer separation
- [x] Exception handling (@ControllerAdvice)
```

---

## 5. 품질 기준

### 5.1 spec-analyzer 평가 항목

**/spec-review 실행 시 평가되는 항목**:

| 항목 | 점수 | 체크리스트 |
|------|------|-----------|
| **Modern Best Practices** | 10점 | |
| - Context7 References | 3점 | § 0 섹션, 3+ 링크 |
| - Latest Patterns | 4점 | Deprecated 패턴 회피 |
| - Version Compliance | 3점 | Version Matrix, EOL 체크, 업그레이드 계획 |

**목표**: 90점 이상 (Modern Best Practices 포함 시 100점 만점)

### 5.2 Context7 통합 품질 기준

#### ✅ 우수한 예시

```markdown
## 0. Technology References

### Context7 Documentation
- **TypeScript**: `/microsoft/TypeScript/v5.4`
  - Strict mode configuration
  - Type inference best practices
  - Const type parameters (new in 5.4)

- **Express**: `/expressjs/express/v4.19`
  - Async error handling
  - Middleware composition patterns

- **Prisma**: `/prisma/prisma/v5.9`
  - Query optimization
  - Transaction handling

### Version Matrix
| 기술 | 현재 | 권장 | Context7 | Status |
|------|------|------|----------|--------|
| TypeScript | 5.4.0 | 5.4+ | `/microsoft/TypeScript/v5.4` | ✅ OK |
| Node.js | 20.11.0 | 20.11+ (LTS) | `/nodejs/node` | ✅ OK |
| Express | 4.19.0 | 4.19+ | `/expressjs/express` | ✅ OK |

**평가**: 10/10 점
```

#### ⚠️ 개선 필요한 예시

```markdown
## 0. Technology References

### Context7 Documentation
- **TypeScript**: `/microsoft/TypeScript`
  - (내용 없음)

### Version Matrix
(누락)

**평가**: 2/10 점
- Context7 링크 1개 (2점 미만)
- Version Matrix 없음 (0점)
- 업그레이드 계획 없음 (0점)
```

---

## 6. 자주 묻는 질문 (FAQ)

### Q1: Context7에 없는 라이브러리는 어떻게 하나요?

**A**: 수동으로 GitHub/공식 문서 링크 추가:

```markdown
## 0. Technology References
- **internal-auth-lib**: [GitHub](https://github.com/company/auth)
  - v2.3.1 (internal docs)
  - No Context7 equivalent
```

### Q2: 여러 언어 혼합 프로젝트는?

**A**: 각 언어별로 섹션 분리:

```markdown
## 0. Technology References

### Frontend (TypeScript)
- **React**: `/facebook/react/v18.2`
- **TypeScript**: `/microsoft/TypeScript/v5.4`

### Backend (Python)
- **Python**: `/python/cpython/v3.12`
- **FastAPI**: `/tiangolo/fastapi`
```

### Q3: Context7 Trust Score가 낮은 문서는?

**A**: Trust Score < 7은 수동 검증 필요:

```markdown
⚠️  Trust Score: 5/10 for `/some/library`
Manual verification recommended before use.
```

### Q4: EOL 버전을 사용 중이라면?

**A**: 즉시 업그레이드 계획 작성:

```markdown
❌ **Security Alert**: Node.js 16.x is End-of-Life

**즉시 조치 필요**:
- [ ] Node.js 20 LTS로 업그레이드 (우선순위: P0)
- Estimated effort: 4 hours
- Breaking changes: [Migration guide](...)
- Security patches 받을 수 없음
```

### Q5: Deprecated 패턴을 반드시 피해야 하나요?

**A**: 예외 상황:

- ❌ 프로덕션 코드: 반드시 최신 패턴 사용
- ✅ 교육/문서화: "avoid" 컨텍스트에서 언급 가능
- ✅ 마이그레이션 전: 기존 패턴 문서화 → 새 패턴 계획

---

## 7. 추가 리소스

### 관련 문서

- **Context7 Integration Spec**: `.specs/context7-integration-spec.md`
- **Context7 Query Guide**: `.claude/lib/context7-query.md`
- **Project Analyzer**: `.claude/lib/project-analyzer.sh`

### 템플릿 파일

- **Program Spec Template**: `templates/program-spec-template.md`
- **API Spec Template**: `templates/api-spec-template.md`
- **UI/UX Spec Template**: `templates/ui-ux-spec-template.md`
- **Constitution Template**: `templates/constitution-template.md`

### 예시 스펙

- **TypeScript Backend**: `templates/examples/typescript-backend-example.md` (TODO)
- **Python FastAPI**: `templates/examples/python-fastapi-example.md` (TODO)
- **Java Spring**: `templates/examples/java-spring-example.md` (TODO)

---

## 8. 체크리스트 요약

### 스펙 작성 전

- [ ] `/spec-init` 실행
- [ ] 프로젝트 자동 분석 확인
- [ ] Context7 링크 자동 조회 완료
- [ ] EOL 버전 경고 확인

### 스펙 작성 중

- [ ] § 0. Technology References 섹션 작성
- [ ] Version Matrix 테이블 작성
- [ ] 모든 코드 예제에 Context7 주석
- [ ] 최신 패턴 사용 (Deprecated 회피)
- [ ] 엣지케이스 5개 이상

### 스펙 작성 후

- [ ] `/spec-review` 실행
- [ ] Modern Best Practices 항목 확인
- [ ] 90점 이상 달성
- [ ] 승인 마커 생성 (`.specs/*.approved.md`)
- [ ] 구현 시작

---

**Document Version**: 1.0.0
**Last Updated**: 2025-10-20
**Maintained by**: Frentis AI Lab

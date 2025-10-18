# Project Constitution

**Version**: 1.0.0
**Project**: [프로젝트 이름]
**Last Updated**: [날짜]
**Maintainer**: [담당자]

---

## 사용 안내

이 Constitution 파일은 **프로젝트별 개발 표준과 코딩 규칙**을 정의합니다.

- **[AUTO-CHECK]** 표시가 있는 섹션은 `spec-analyzer`가 자동으로 검증합니다
- 스펙 작성 시 이 규칙들을 준수해야 하며, `/spec-review` 실행 시 검증됩니다
- 프로젝트 초기에 팀과 함께 작성하고, 진화하는 문서로 관리하세요

---

## 1. 금지 사항 [AUTO-CHECK]

### 1.1 언어별 금지 패턴

#### TypeScript/JavaScript
- ❌ `any` 타입 사용
  - **이유**: 타입 안정성 상실
  - **대안**: `unknown` 또는 명시적 타입 정의
  - **예외**: Third-party 라이브러리 타입 정의 불가능한 경우

- ❌ `console.log`, `console.error` 직접 사용
  - **이유**: 프로덕션 로깅 표준 부재
  - **대안**: 구조화된 로거 (`winston`, `pino` 등)
  - **예외**: 개발 환경 임시 디버깅 (커밋 전 제거)

- ❌ `eval()` 사용
  - **이유**: 보안 위험, 성능 저하
  - **대안**: `Function()` 또는 안전한 파싱

#### Python
- ❌ `import *` (wildcard import)
  - **이유**: 네임스페이스 오염, 의존성 불명확
  - **대안**: 명시적 import (`from module import SpecificClass`)

- ❌ Bare `except:` clause
  - **이유**: 모든 예외 무시 (시스템 종료 신호까지)
  - **대안**: `except Exception as e:` 또는 구체적 예외 타입

#### SQL
- ❌ String concatenation으로 쿼리 생성
  - **이유**: SQL Injection 취약점
  - **대안**: Prepared statements / Parameterized queries

### 1.2 아키텍처 금지 패턴

- ❌ Circular dependencies (순환 의존성)
  - **감지**: 모듈 A → B → A
  - **대안**: 의존성 역전 (Dependency Inversion), 중간 인터페이스

- ❌ God objects (1000+ 줄 클래스)
  - **기준**: 단일 클래스가 5개 이상의 책임
  - **대안**: SOLID 원칙 준수, 책임 분리

- ❌ Hard-coded credentials/secrets
  - **금지**: API keys, passwords, tokens in code
  - **대안**: 환경 변수 (`.env`), Secret manager (AWS Secrets Manager, Vault)

---

## 2. 기술 스택 표준 [AUTO-CHECK]

### 2.1 언어 및 런타임

- **언어**: [TypeScript 5.3+ / Python 3.12+ / Go 1.22+ 등]
- **런타임**: [Node.js 20 LTS / Python uv / 등]
- **패키지 매니저**: [pnpm / uv / 등]

### 2.2 필수 라이브러리

#### 로깅
- **사용**: `winston` (TypeScript) / `structlog` (Python)
- **금지**: `console.log`, `print()` for production logging

#### 데이터베이스 ORM
- **사용**: `Prisma` (TypeScript) / `SQLAlchemy` (Python)
- **금지**: Raw SQL strings (Prepared statements 예외)

#### 테스트 프레임워크
- **사용**: `Vitest` (TypeScript) / `pytest` (Python)
- **커버리지 목표**: 80% 이상

#### HTTP 클라이언트
- **사용**: `axios` with interceptors / `httpx` (Python)
- **금지**: `fetch` without error handling / `requests` (Python, 동기만 지원)

### 2.3 버전 정책

- **LTS 버전 사용**: Node.js, Python 등 안정 LTS만 사용
- **의존성 업데이트**: 월 1회 `dependabot` PR 검토
- **Breaking change**: Major 버전 업그레이드 시 ADR 문서화

---

## 3. 코딩 스타일 [AUTO-CHECK]

### 3.1 네이밍 규칙

#### 함수명
- **패턴**: 동사 + 명사 (`getUserById`, `calculateTotal`)
- **금지**: 모호한 동사 (`handle`, `process`, `manage` 단독 사용)
- **예시**:
  ```typescript
  // ❌ Bad
  function handle(data) { ... }

  // ✅ Good
  function handleUserRegistration(userData: UserInput) { ... }
  ```

#### 변수명
- **Boolean**: `is`, `has`, `should` 접두사 (`isActive`, `hasPermission`)
- **컬렉션**: 복수형 (`users`, `orders`)
- **상수**: `UPPER_SNAKE_CASE` (`MAX_RETRY_COUNT`)

#### 클래스/타입명
- **PascalCase**: `UserService`, `OrderProcessor`
- **인터페이스**: `I` 접두사 없이 (`User`, not `IUser`)

### 3.2 주석 규칙

- **필수 주석**:
  - Public API 함수 (JSDoc/docstring)
  - 복잡한 알고리즘 (시간복잡도 O(n) 언급)
  - 비즈니스 로직 예외 처리 (왜 이 에러를 무시하는지)

- **금지 주석**:
  - 자명한 코드 설명 (`// increment i`)
  - 주석 처리된 코드 (Git history 사용)
  - TODO without ticket (`// TODO fix this` → `// TODO(#123): Refactor to async`)

### 3.3 파일 구조

```
src/
├── domain/         # 비즈니스 로직 (프레임워크 독립)
│   ├── entities/
│   ├── usecases/
│   └── interfaces/
├── infrastructure/ # 외부 의존성 (DB, API)
│   ├── database/
│   ├── http/
│   └── cache/
├── presentation/   # API 라우터, 컨트롤러
└── shared/         # 공통 유틸리티
```

**금지**: `utils/` 디렉토리에 모든 것 넣기 → 도메인별 분리

---

## 4. 에러 처리 표준

### 4.1 에러 타입 정의

```typescript
// TypeScript 예시
export class DomainError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class ValidationError extends DomainError {
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}
```

### 4.2 에러 처리 패턴

- **Try-Catch 범위**: 최소한으로 (전체 함수 감싸지 말 것)
- **에러 전파**: 의미 있는 컨텍스트 추가
  ```typescript
  try {
    await fetchUserData(userId);
  } catch (error) {
    throw new DomainError(
      `Failed to fetch user ${userId}: ${error.message}`,
      'USER_FETCH_ERROR'
    );
  }
  ```

- **Silent failure 금지**: 에러를 잡았으면 로깅 또는 재전파 필수

### 4.3 에러 응답 형식

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "invalid-email"
    },
    "timestamp": "2025-10-18T12:34:56Z",
    "requestId": "req-123456"
  }
}
```

---

## 5. 보안 요구사항

### 5.1 인증/인가

- **인증 방식**: JWT (15분 access token + 7일 refresh token)
- **비밀번호**: bcrypt (cost factor 12)
- **API Key**: 환경 변수 저장, 절대 코드에 포함 금지

### 5.2 입력 검증

- **모든 사용자 입력 검증**: `zod` (TypeScript) / `pydantic` (Python)
- **SQL Injection 방지**: ORM 사용 또는 Prepared statements
- **XSS 방지**: 출력 시 HTML escape (프레임워크 기본 기능 사용)

### 5.3 민감 데이터 처리

- **로깅 시 마스킹**: 비밀번호, 카드번호, 주민번호
  ```typescript
  logger.info('User login', {
    email: user.email,
    password: '[REDACTED]'
  });
  ```

- **데이터베이스 암호화**: PII (개인식별정보) 필드 암호화
- **HTTPS 강제**: Production 환경 HTTP 비활성화

---

## 6. 테스트 요구사항

### 6.1 테스트 레벨

- **Unit Test**: 모든 비즈니스 로직 (80% 커버리지)
- **Integration Test**: API 엔드포인트 (주요 플로우)
- **E2E Test**: Critical user journeys (회원가입, 결제 등)

### 6.2 테스트 작성 규칙

- **AAA 패턴**: Arrange - Act - Assert
  ```typescript
  test('should calculate discount correctly', () => {
    // Arrange
    const order = { total: 100, items: [...] };

    // Act
    const discount = calculateDiscount(order);

    // Assert
    expect(discount).toBe(10);
  });
  ```

- **테스트 이름**: `should [expected behavior] when [condition]`
- **Mocking**: 외부 의존성만 (DB, API), 비즈니스 로직 mocking 금지

### 6.3 테스트 커버리지

- **최소 목표**: 80% statement coverage
- **필수 테스트**: Edge cases (빈 배열, null, 경계값)
- **금지**: Coverage 숫자 올리기 위한 무의미한 테스트

---

## 7. 성능 요구사항

### 7.1 응답 시간

- **API 응답**: p95 < 200ms
- **데이터베이스 쿼리**: 단일 쿼리 < 50ms
- **페이지 로드**: LCP (Largest Contentful Paint) < 2.5s

### 7.2 최적화 기법

- **데이터베이스**:
  - 인덱스 생성 (WHERE, JOIN 컬럼)
  - N+1 쿼리 방지 (eager loading)
  - Connection pooling

- **캐싱**:
  - Redis 사용 (세션, 자주 읽는 데이터)
  - TTL 설정 (기본 5분)

- **API**:
  - Rate limiting (100 req/min per user)
  - Pagination (기본 20개, 최대 100개)

---

## 8. 문서화 요구사항

### 8.1 코드 문서

- **Public API**: JSDoc/docstring 필수
  ```typescript
  /**
   * Retrieves user by ID
   * @param userId - Unique user identifier
   * @returns User object or null if not found
   * @throws {ValidationError} If userId is invalid
   */
  async function getUserById(userId: string): Promise<User | null>
  ```

- **복잡한 로직**: 인라인 주석으로 의도 설명
- **ADR (Architecture Decision Record)**: 중요한 기술 선택 문서화

### 8.2 API 문서

- **OpenAPI 3.0 스펙**: `swagger.yml` 또는 코드 어노테이션
- **예시 요청/응답**: 모든 엔드포인트
- **에러 시나리오**: 가능한 4xx, 5xx 응답

---

## 9. Git 워크플로우

### 9.1 브랜치 전략

- **Main**: 프로덕션 배포용 (항상 안정 상태)
- **Feature**: `feature/issue-123-add-user-api`
- **Hotfix**: `hotfix/fix-login-bug`

### 9.2 커밋 메시지

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
**예시**:
```
feat(auth): Add JWT refresh token rotation

- Implement refresh token in Redis
- Add /auth/refresh endpoint
- Expire old refresh tokens after use

Closes #123
```

### 9.3 Pull Request 규칙

- **리뷰어**: 최소 1명 승인 필요
- **CI 통과**: 테스트, 린트, 빌드 성공
- **스펙 참조**: PR 설명에 관련 스펙 파일 링크

---

## 10. 배포 및 모니터링

### 10.1 배포 전 체크리스트

- [ ] 모든 테스트 통과 (Unit, Integration, E2E)
- [ ] 환경 변수 설정 확인 (`.env.example` 업데이트)
- [ ] 데이터베이스 마이그레이션 스크립트 준비
- [ ] 롤백 계획 문서화

### 10.2 모니터링

- **필수 메트릭**:
  - Error rate (< 1%)
  - Response time (p95, p99)
  - Throughput (requests/sec)

- **알림 조건**:
  - Error rate > 5% (5분 지속)
  - p95 response time > 500ms
  - 서버 다운 (healthcheck 실패)

### 10.3 로깅

- **구조화된 로그**: JSON 형식
  ```json
  {
    "timestamp": "2025-10-18T12:34:56Z",
    "level": "ERROR",
    "service": "user-api",
    "requestId": "req-123",
    "message": "Failed to create user",
    "error": {
      "code": "DB_CONNECTION_ERROR",
      "stack": "..."
    }
  }
  ```

- **로그 레벨**:
  - `ERROR`: 즉각 대응 필요
  - `WARN`: 모니터링 필요
  - `INFO`: 비즈니스 이벤트
  - `DEBUG`: 개발 환경만

---

## 11. 프로젝트별 커스텀 규칙

### 11.1 도메인 특화 규칙

<!--
  이 섹션은 프로젝트별로 커스터마이징하세요.

  예시 (E-Commerce):
  - 주문 금액은 항상 Decimal 타입 사용 (부동소수점 금지)
  - 재고 차감은 트랜잭션 내에서 Lock 필수
  - 결제 실패 시 자동 재시도 3회 (exponential backoff)
-->

**TODO**: 프로젝트 특성에 맞게 작성

### 11.2 팀 협업 규칙

<!--
  예시:
  - 코드 리뷰 응답 시간: 24시간 이내
  - 페어 프로그래밍: 복잡한 기능 (예상 시간 > 2일)
  - 기술 공유: 주 1회 팀 세션 (금요일 15:00)
-->

**TODO**: 팀 규칙 작성

---

## 12. 예외 처리 프로세스

### 12.1 Constitution 규칙 위반 시

이 Constitution에 명시된 규칙을 위반하는 코드는 `/spec-review` 시 감점됩니다.

**예외 승인 프로세스**:
1. 위반이 불가피한 이유를 문서화
2. 대안 검토 내역 기록
3. 팀 리드 승인 (Slack/이슈 트래커)
4. 코드에 주석 추가:
   ```typescript
   // CONSTITUTION_EXCEPTION: Approved by @tech-lead on 2025-10-18
   // Reason: Third-party library requires `any` type
   // See: https://github.com/org/repo/issues/456
   const config: any = externalLib.getConfig();
   ```

### 12.2 긴급 상황 (Hotfix)

프로덕션 장애 등 긴급 상황에서는:
- Constitution 검증 우회 가능 (`CLAUDE_MODE=prototype` 환경 변수)
- 24시간 내 사후 스펙 작성 필수
- 사후 검토 회의 (근본 원인 분석)

---

## 13. Constitution 변경 이력

| 버전 | 날짜 | 변경 사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-10-18 | 초기 버전 작성 | [이름] |

---

## 14. 참고 자료

- **코딩 스타일 가이드**: [링크]
- **아키텍처 문서**: [링크]
- **보안 가이드라인**: [링크]
- **성능 최적화 가이드**: [링크]

---

## 부록: Constitution 사용 예시

### 스펙 작성 시

```markdown
# User Registration API Specification

## 3. Implementation Details

### 3.1 Password Hashing
- Use `bcrypt` with cost factor 12 (per PROJECT-CONSTITUTION.md §5.1)
- Store hash in `users.password_hash` column
- ❌ Never store plain text passwords (Constitution violation)

### 3.2 Validation
- Email format: `zod.string().email()` (per Constitution §5.2)
- Password strength: min 8 chars, 1 uppercase, 1 number
```

### 코드 리뷰 시

```
리뷰어: ❌ `console.log` 사용 감지 (Constitution §1.1 위반)
→ `winston` logger로 교체 필요

작성자: 수정했습니다. `logger.info()` 사용으로 변경
```

---

**이 Constitution은 살아있는 문서입니다. 팀과 함께 지속적으로 개선하세요!**

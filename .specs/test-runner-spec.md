# Test-Runner Sub-Agent Specification

**Author**: Claude + User
**Date**: 2025-10-17
**Status**: Draft
**Version**: 1.0
**Type**: Sub-Agent (Claude Code)

---

## 1. Overview

### Problem Statement

현재 Specification-First 개발 프로세스에서 구현 후 검증(`/validate`)은 있지만, **테스트 생성 및 실행**이 수동으로 이루어져 다음 문제가 발생합니다:

1. **테스트 커버리지 부족**: 개발자가 주요 경로만 테스트, 엣지케이스 누락
2. **스펙-테스트 불일치**: 스펙에 명시된 요구사항이 테스트로 검증되지 않음
3. **반복 작업**: 비슷한 패턴의 테스트를 매번 작성
4. **검증 지연**: 구현 후 한참 뒤에 테스트 → 버그 발견 시 수정 비용 증가

### Goals

1. **자동화된 테스트 생성**: 스펙 기반으로 누락된 테스트 자동 생성
2. **높은 커버리지 달성**: 85% 이상 커버리지 목표
3. **스펙 준수 검증**: 모든 요구사항, 엣지케이스가 테스트로 커버됨
4. **빠른 피드백**: 구현 직후 테스트 실행 → 즉시 문제 발견
5. **비용 효율성**: Haiku 4.5 모델 사용으로 비용 1/10 절감

### Success Criteria

- 스펙에 명시된 요구사항의 95% 이상이 테스트로 커버됨
- 엣지케이스 100% 테스트 생성
- 평균 커버리지 85% 이상 달성
- 테스트 생성 시간 < 2분 (중간 크기 모듈 기준)
- 사용자 만족도: "테스트 작성 시간 50% 이상 절감" 피드백

### Non-Goals

- **테스트 자동 수정**: 실패한 테스트를 자동으로 고치지 않음 (리포트만 제공)
- **E2E 테스트 시나리오**: Phase 1에서는 유닛/API 테스트만, E2E는 향후
- **성능 테스트**: 로드 테스트, 스트레스 테스트는 범위 외
- **다른 언어 (Go, Rust 등)**: Phase 1은 TypeScript/Python만

---

## 2. System Architecture

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                    Main Conversation                     │
│                  (Claude Sonnet 4.5)                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ /test 명령
                     ↓
┌─────────────────────────────────────────────────────────┐
│              test-runner Sub-Agent                       │
│               (Claude Haiku 4.5)                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Phase 1: Analysis                                │  │
│  │  - 프로젝트 타입 감지 (package.json, pyproject)  │  │
│  │  - 스펙 파일 참조 (.specs/*.md)                  │  │
│  │  - 기존 테스트 커버리지 분석                     │  │
│  └───────────────────────────────────────────────────┘  │
│                     ↓                                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Phase 2: Test Generation                         │  │
│  │  - 누락된 테스트 식별                            │  │
│  │  - 테스트 코드 생성 (spec 기반)                  │  │
│  │  - 엣지케이스, 에러 핸들링 테스트                │  │
│  └───────────────────────────────────────────────────┘  │
│                     ↓                                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Phase 3: Execution                               │  │
│  │  - npm/pnpm test 또는 pytest 실행                │  │
│  │  - 커버리지 수집                                  │  │
│  └───────────────────────────────────────────────────┘  │
│                     ↓                                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Phase 4: Reporting                               │  │
│  │  - summary.md 생성                                │  │
│  │  - 콘솔 출력 (간결한 요약)                        │  │
│  │  - 상세 로그 파일 저장                            │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                     │
                     │ 리포트 반환
                     ↓
┌─────────────────────────────────────────────────────────┐
│              implementation-validator                    │
│  (테스트 리포트를 참조하여 점수 계산)                   │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
1. User → /test src/services/todo.ts

2. test-runner receives:
   - target_path: src/services/todo.ts
   - spec_path: .specs/todo-api-spec.md (자동 탐지)

3. test-runner reads:
   - Target file
   - Spec files (.specs/*.md)
   - Existing test files (*.test.ts, test_*.py)
   - Coverage report (if exists)

4. test-runner generates:
   - New test files (if needed)
   - Missing test cases (append to existing)

5. test-runner executes:
   - pnpm test --coverage (or pytest --cov)

6. test-runner writes:
   - .test-reports/YYYY-MM-DD-HHmmss/summary.md
   - .test-reports/YYYY-MM-DD-HHmmss/unit-test.log
   - .test-reports/YYYY-MM-DD-HHmmss/api-test.log (if applicable)
   - .test-reports/YYYY-MM-DD-HHmmss/coverage/ (HTML report)

7. test-runner outputs to console:
   - ✅/❌ Summary table
   - Top 3 issues
   - File paths to detailed reports
```

### Technology Stack

**Sub-Agent Configuration**:
- **Model**: `haiku` (Claude Haiku 4.5 - 비용 효율)
- **Tools**: `Read, Write, Edit, Bash, Glob, Grep`
- **Color**: `cyan` (테스트 = 청록색, 잘 보이면서 차분함)

**Test Frameworks**:
- **JavaScript/TypeScript**:
  - Unit: Vitest (빠름, 현대적)
  - API: Supertest (Express/Fastify 호환)
  - UI: Playwright (크로스 브라우저)
- **Python**:
  - Unit: PyTest (사실상 표준)
  - API: httpx + pytest-asyncio
  - UI: Playwright Python

**Output Storage**:
- Directory: `.test-reports/`
- Format: Markdown (summary), Plain text (logs), HTML (coverage)

### Dependencies

**Internal Dependencies**:
- `.specs/*.md` files (필수)
- `implementation-validator` (선택, 연동 시 점수 반영)

**External Dependencies**:
- Node.js/pnpm (JavaScript 프로젝트)
- Python/uv (Python 프로젝트)
- Test framework packages (자동 설치)

---

## 3. Detailed Requirements

### Functional Requirements

#### FR1: 프로젝트 타입 자동 감지

- **Input**: 대상 파일 경로 또는 디렉토리
- **Process**:
  1. `package.json` 존재 → JavaScript/TypeScript
  2. `pyproject.toml` 또는 `requirements.txt` → Python
  3. 파일 확장자 확인 (`.ts`, `.py` 등)
  4. 스펙 파일 확인 (`api-spec.md`, `ui-ux-spec.md`)
- **Output**: 프로젝트 타입 (backend, frontend, fullstack)

#### FR2: 스펙 기반 테스트 생성

- **Input**:
  - 대상 코드 파일
  - 관련 스펙 파일 (`.specs/*.md`)
- **Process**:
  1. 스펙에서 요구사항 추출
  2. 스펙에서 엣지케이스 추출 (최소 5개)
  3. 기존 테스트 파일 분석
  4. 누락된 테스트 케이스 식별
  5. 테스트 코드 생성 (Given-When-Then 패턴)
- **Output**: 테스트 파일 (새로 생성 or 기존에 추가)

**테스트 생성 알고리즘** (구체적 프롬프트 템플릿):

```markdown
### 프롬프트 템플릿 (Haiku 4.5에 전달):

"""
Given this code:
{code_content}

And this specification:
Functional Requirements:
{functional_requirements_from_spec}

Edge Cases:
{edge_cases_from_spec}

Error Codes:
{error_codes_from_spec}

Generate {framework} tests using Given-When-Then pattern:
- Given: Test setup (mocks, test data, preconditions)
- When: Execute the function/API call
- Then: Assert expected behavior (toEqual, toThrow, toMatchObject)

Focus on:
1. Edge cases from spec: {edge_case_list}
2. Error handling: {error_scenarios}
3. Happy path: {main_functional_flow}

Format each test with:
- Comment: // Spec: {spec_file}#{section} - {description}
- Descriptive test name: it('should {expected_behavior}', ...)
- Clear arrange-act-assert structure

Framework-specific requirements:
- TypeScript/Vitest: Use vi.spyOn for mocks, async/await for promises
- Python/PyTest: Use pytest.raises for errors, fixtures for setup
"""
```

**생성 규칙**:
- 각 테스트 케이스에 스펙 참조 주석 포함
  ```typescript
  // Spec: api-spec.md#EdgeCase3 - Empty title validation
  it('should reject empty title', () => { ... })
  ```
- 우선순위:
  1. Critical path (인증, 결제 등)
  2. 스펙의 기능 요구사항 (Functional Requirements)
  3. 스펙의 엣지케이스 (Edge Cases)
  4. 에러 핸들링
  5. 경계값 테스트

#### FR3: 기존 테스트 분석

- **Input**: 기존 테스트 파일
- **Process**:
  1. 테스트 케이스 개수 세기
  2. 커버리지 리포트 파싱 (coverage/coverage-summary.json)
  3. 누락된 함수/메서드 식별
  4. 스펙과 비교하여 미구현 요구사항 찾기
- **Output**: 누락된 테스트 목록

**스펙-코드 불일치 감지 알고리즘**:

```markdown
### 불일치 감지 프로세스:

1. **스펙에서 요구사항 함수 추출**:
   - Grep으로 "### FR\d+" 또는 "#### Function:" 패턴 찾기
   - 함수명, 파라미터, 반환 타입 추출

2. **코드에서 실제 구현된 함수 추출**:
   - TypeScript: AST 파싱 (export된 함수/클래스 메서드)
     - Tools: @babel/parser 또는 ts-morph
   - Python: ast 모듈 사용 (def, async def)

3. **차집합 계산**:
   - 스펙 함수 - 코드 함수 = 미구현 함수 (경고)
   - 코드 함수 - 스펙 함수 = 스펙 미기재 (정보)

4. **시그니처 비교** (같은 이름 함수):
   - 파라미터 개수 일치?
   - 파라미터 타입 일치? (TypeScript만)
   - 반환 타입 일치? (TypeScript만)

5. **출력**:
   ⚠️  Spec-Code Mismatch Detected:
   - Missing implementation: calculateTotal(items: Item[], tax: number)
   - Signature mismatch: createUser(name, email) vs spec expects (name, email, role)
   - Recommend: Update spec or implement missing functions
```

#### FR4: 테스트 실행

- **JavaScript/TypeScript**:
  ```bash
  pnpm test --coverage --run
  # or
  npm test -- --coverage
  ```
- **Python**:
  ```bash
  uv run pytest --cov=src --cov-report=html --cov-report=json
  ```
- **Output**: 테스트 결과 + 커버리지 데이터

#### FR5: 리포트 생성

**"Top 3 Issues" 선정 알고리즘**:

```markdown
### Priority Score 계산:

각 실패한 테스트에 대해 점수 부여:
- Critical path (인증, 결제, 데이터 손실 위험): +10점
- 스펙에 명시된 기능 요구사항: +5점
- 엣지케이스: +3점
- 단순 helper 함수: +1점

실패 테스트를 Priority Score 내림차순 정렬 → 상위 3개 선택

예:
1. AuthService.login 실패 (Critical +10) = 10점
2. TodoService.createTodo 실패 (FR +5) = 5점
3. formatDate 실패 (Helper +1) = 1점

→ Top 3: AuthService.login, TodoService.createTodo, formatDate
```

**콘솔 출력 (간결)**:
```
🧪 Test Report - 2025-10-17 14:30:22

┌──────────┬────────┬────────┬────────┬──────────┐
│ Type     │ Passed │ Failed │ Skip   │ Coverage │
├──────────┼────────┼────────┼────────┼──────────┤
│ Unit     │ 45/50  │ 5      │ 0      │ 82%      │
│ API      │ 12/15  │ 3      │ 0      │ 75%      │
│ Total    │ 57/65  │ 8      │ 0      │ 80%      │
└──────────┴────────┴────────┴────────┴──────────┘

⚠️  Failed Tests (Top 3):
1. TodoService.createTodo - Empty title validation
   → Spec: api-spec.md#EdgeCase3
2. POST /api/todos - Invalid userId error
   → Spec: api-spec.md#Authentication
3. DELETE /api/todos/:id - Unauthorized access
   → Spec: api-spec.md#Authorization

📄 Full Report: .test-reports/2025-10-17-143022/summary.md
🌐 Coverage: .test-reports/2025-10-17-143022/coverage/index.html
```

**파일 출력 (상세)**:
- `summary.md`: 위 내용 + 권장사항 + 다음 단계
- `unit-test.log`: 전체 유닛 테스트 로그
- `api-test.log`: 전체 API 테스트 로그
- `coverage/`: HTML 커버리지 리포트

#### FR6: 슬래시 커맨드 제공

- `/test [path]`: 자동 감지 후 모든 테스트
- `/test unit [path]`: 유닛 테스트만
- `/test api [path]`: API 테스트만
- `/test ui [path]`: UI 테스트만 (Phase 2)

### Non-Functional Requirements

#### NFR1: Performance

- **테스트 생성 시간**: < 2분 (중간 크기 모듈, 10개 함수 기준)
- **테스트 실행 시간**: 프레임워크 의존 (측정만, 최적화 안 함)
- **리포트 생성 시간**: < 5초

#### NFR2: Cost Efficiency

- **모델**: Haiku 4.5 사용
- **예상 비용**: 일반적인 모듈 테스트 생성 시 $0.05 미만
- **비교**: Sonnet 4.5 대비 1/10 비용

#### NFR3: Usability

- **에러 메시지**: 명확하고 실행 가능한 가이드 제공
- **콘솔 출력**: 터미널에서 읽기 쉬운 테이블 형식
- **색상**: Cyan 색상으로 다른 에이전트와 구분

#### NFR4: Reliability

- **테스트 프레임워크 없을 시**: 자동 설치 제안 (강제 설치 안 함)
- **스펙 없을 시**: 경고 + 기본 테스트만 생성
- **실행 실패 시**: 에러 로그 상세히 기록

#### NFR5: Maintainability

- **확장성**: 새 언어 추가 쉬움 (Phase별 구조)
- **버전 관리**: `.claude/agents/test-runner.md` 파일로 관리
- **문서화**: 각 Phase마다 명확한 주석

---

## 4. Implementation Plan

### Phase 1: MVP (Unit + API Tests)

**목표**: TypeScript/Python 유닛 테스트 + API 테스트

**Task 의존성 그래프**:
```
1.1 (Sub-agent 파일) ─┬─→ 1.3 (Analysis 로직)
                      │
1.2 (슬래시 커맨드) ───┴─→ 1.4 (Generation 로직)
                          │
1.3 ──────────────────────┤
                          ↓
                       1.5 (Execution 로직)
                          ↓
                       1.6 (Reporting 로직)
                          ↓
1.1 ~ 1.6 ───────────→ 1.7 (메타 테스트)

병렬 가능: 1.1과 1.2
순차 필수: 1.3 → 1.4 → 1.5 → 1.6
```

- [ ] Task 1.1: Sub-agent 파일 생성 (`.claude/agents/test-runner.md`)
  - Model: haiku
  - Color: cyan
  - Tools: Read, Write, Edit, Bash, Glob, Grep
  - 기본 프롬프트 작성

- [ ] Task 1.2: 슬래시 커맨드 생성
  - `.claude/commands/test.md`
  - `.claude/commands/test-unit.md`
  - `.claude/commands/test-api.md`

- [ ] Task 1.3: Phase 1 - Analysis 로직 구현
  - 프로젝트 타입 감지 (package.json, pyproject.toml)
  - 스펙 파일 자동 탐지 (`.specs/*.md`)
  - 기존 테스트 파일 찾기 (Glob)
  - 기존 커버리지 파싱 (coverage-summary.json)

- [ ] Task 1.4: Phase 2 - Test Generation 로직
  - 스펙 요구사항 추출 (Grep + Read)
  - 누락된 테스트 식별
  - Vitest 테스트 생성 (TypeScript)
  - PyTest 테스트 생성 (Python)
  - Supertest API 테스트 생성

- [ ] Task 1.5: Phase 3 - Execution 로직
  - `pnpm test --coverage --run` 실행
  - `uv run pytest --cov` 실행
  - 출력 파싱 (통과/실패 개수)

- [ ] Task 1.6: Phase 4 - Reporting 로직
  - `.test-reports/` 디렉토리 생성
  - `summary.md` 생성 (템플릿 기반)
  - 콘솔 출력 (테이블 형식)
  - 로그 파일 저장

- [ ] Task 1.7: 테스트 (메타) - 부트스트래핑 전략

  **Phase 0: 수동 샘플 프로젝트 준비**
  - `.test-samples/typescript-basic/` 생성
    - src/calculator.ts (5개 함수: add, subtract, multiply, divide, power)
    - src/calculator.test.ts (2개 테스트만 - add, subtract)
    - .specs/calculator-spec.md (5개 함수 명세 + 엣지케이스 5개)
    - package.json (vitest 설정)

  - `.test-samples/python-basic/` 생성
    - src/calculator.py (5개 함수 동일)
    - tests/test_calculator.py (2개 테스트만)
    - .specs/calculator-spec.md (동일)
    - pyproject.toml (pytest 설정)

  - `.test-samples/typescript-api/` 생성
    - src/routes/todos.ts (CRUD 엔드포인트 5개)
    - src/routes/todos.test.ts (2개 테스트만)
    - .specs/todo-api-spec.md (엔드포인트 명세)
    - package.json (supertest 설정)

  **Phase 1: 수동 검증 (test-runner 없이)**
  - 샘플 프로젝트에서 `pnpm test` 실행
  - 기존 커버리지 측정 (예상: ~40%)
  - 누락된 테스트 수동 확인 (3개 함수)

  **Phase 2: test-runner 자가 테스트**
  - test-runner 완성 후:
    ```bash
    /test .test-samples/typescript-basic/
    ```
  - 검증 항목:
    - 누락된 3개 함수 테스트 생성됨
    - 엣지케이스 5개 테스트 생성됨
    - 커버리지 85% 이상 달성
    - .test-reports/ 디렉토리 생성됨
    - summary.md 형식 정확

  **Phase 3: 다양한 시나리오 검증**
  - Python 프로젝트 테스트
  - API 테스트 생성 검증
  - 스펙 없는 프로젝트 (경고 메시지 확인)
  - 프레임워크 없는 프로젝트 (설치 안내 확인)

### Phase 2: UI Tests (향후)

- [ ] Task 2.1: Playwright 통합
- [ ] Task 2.2: `/test ui` 커맨드
- [ ] Task 2.3: `ui-ux-spec.md` 기반 테스트 생성

### Phase 3: Advanced Features (향후)

- [ ] Task 3.1: 실패 자동 수정 (1회 시도)
- [ ] Task 3.2: CI/CD 통합 (GitHub Actions)
- [ ] Task 3.3: 다른 언어 지원 (Go, Rust)
- [ ] Task 3.4: 성능 테스트 (k6, Locust)

### Rollback Strategy

**Sub-agent 제거**:
```bash
rm .claude/agents/test-runner.md
rm .claude/commands/test*.md
```

**테스트 리포트 정리**:
```bash
rm -rf .test-reports
```

**생성된 테스트 파일 식별**:
- 각 테스트 파일 상단에 주석 추가:
  ```typescript
  // Generated by test-runner sub-agent on 2025-10-17
  ```
- 필요 시 수동 삭제

---

## 5. Edge Cases & Risks

### Known Edge Cases

#### EC1: 스펙 파일이 없는 경우
- **처리**: 경고 출력 + 기본 테스트만 생성 (함수 시그니처 기반)
- **메시지**: "⚠️  No spec files found. Generating basic tests only. Run /spec-init for better test coverage."

#### EC2: 테스트 프레임워크가 설치되지 않은 경우
- **처리**:
  ```
  ⚠️  Vitest not found. Install with:
      pnpm add -D vitest @vitest/ui

  Proceed with installation? [y/N]
  ```
- **자동 설치 안 함** (사용자 동의 필요)

#### EC3: 기존 테스트 파일 충돌
- **처리**: 기존 파일에 append (덮어쓰기 안 함)
- **주석**: `// Added by test-runner - 2025-10-17`

**Append 알고리즘** (구체적 구현):

```markdown
### TypeScript/JavaScript (Vitest):

1. **기존 파일 AST 파싱**:
   - @babel/parser 또는 acorn 사용
   - 마지막 describe 블록 찾기

2. **삽입 위치 결정**:
   - 같은 클래스/모듈의 describe 블록 존재?
     → Yes: 해당 describe 블록 내 마지막 it() 뒤에 삽입
     → No: 파일 끝에 새 describe 블록 추가

3. **코드 생성**:
   ```typescript
   // 기존:
   describe('TodoService', () => {
     it('existing test', () => { ... })
   })

   // 추가 후:
   describe('TodoService', () => {
     it('existing test', () => { ... })

     // Added by test-runner - 2025-10-17
     it('should reject empty title', () => { ... })
   })
   ```

4. **실패 시 폴백**:
   - AST 파싱 실패 → 파일 끝에 텍스트 추가
   - 경고: "⚠️  Could not parse existing test file. Appended to end."

### Python (PyTest):

1. **기존 파일 파싱**:
   - ast 모듈 사용
   - 마지막 class 또는 top-level 함수 찾기

2. **삽입 위치**:
   - class TestXxx 존재? → class 내 마지막 메서드 뒤
   - 없음? → 파일 끝에 새 함수 추가

3. **인덴테이션 유지**:
   - 기존 파일의 인덴트 스타일 감지 (4 spaces vs tab)
   - 같은 스타일 적용
```

#### EC4: 대상 파일이 디렉토리인 경우
- **처리**: 재귀적으로 모든 파일 테스트
- **제한**: 최대 50개 파일 (초과 시 경고)

#### EC5: 멀티모듈 프로젝트 (monorepo)
- **처리**: workspace 감지 → 각 패키지별 독립 테스트
- **리포트**: 패키지별 서브 디렉토리 생성

#### EC6: 비동기 테스트 (async/await)
- **처리**: 자동으로 `async` 키워드 추가
- **검증**: Timeout 설정 확인

#### EC7: 외부 의존성 (DB, API)
- **처리**: Mock/Stub 자동 생성 권장
- **주석**: `// TODO: Replace with actual mock`

#### EC8: 테스트 실행 실패 (구문 오류)
- **처리**:
  1. 에러 로그 상세 기록
  2. 실패한 테스트 파일 경로 표시
  3. 수정 가이드 제공 (리포트에)

#### EC9: 커버리지 리포트 파싱 실패
- **처리**: Coverage "N/A" 표시 + 경고
- **대안**: 수동으로 `coverage/index.html` 확인 안내

#### EC10: 매우 큰 파일 (1000줄 이상)
- **처리**: 함수/클래스 단위로 분할하여 테스트 생성
- **제한**: 한 번에 최대 10개 함수 (Haiku context 제한)

### Potential Blockers

#### B1: Haiku 모델 성능 부족
- **가능성**: Medium
- **영향**: 복잡한 로직의 테스트 생성 품질 저하
- **완화**:
  - 복잡도 임계값 설정 (다차원 기준)
  - 임계값 초과 시 사용자에게 Sonnet 사용 제안
  - 또는 사용자가 `/test --model sonnet` 옵션 제공

**복잡도 임계값 (Haiku → Sonnet 폴백 기준)**:

```markdown
### 복잡도 점수 계산:

각 함수에 대해 점수 부여:
- 함수 길이 > 100줄: +5점
- 재귀 함수 (재귀 깊이 > 2): +4점
- 제네릭 타입 파라미터 > 2: +3점
- 중첩 깊이 (if/for/while) > 4: +3점
- async/await + Promise 체이닝 복합: +2점
- 외부 API 호출 > 3개: +2점
- 비즈니스 로직 복잡도 (switch > 5 cases): +2점

합계 >= 10점 → Sonnet 권장

### 사용자 인터랙션:

⚠️  Complex function detected: calculateTaxWithDiscounts()
    Complexity score: 12 (length: 120 lines, nested depth: 5)

    Haiku may struggle with this complexity.
    Use Sonnet for better quality? (cost 10x, ~$0.50)

    [y] Yes, use Sonnet for this function
    [a] Yes, use Sonnet for ALL complex functions
    [n] No, try with Haiku (may have issues)

    Choice:

### 폴백 전략:
- 사용자 선택 'y' → 해당 함수만 Sonnet
- 사용자 선택 'a' → 세션 동안 모든 복잡 함수 Sonnet
- 사용자 선택 'n' → Haiku 시도 + 결과에 경고 추가
```

#### B2: 테스트 프레임워크 버전 충돌
- **가능성**: Low
- **영향**: 생성된 테스트 구문 오류
- **완화**:
  - package.json에서 버전 확인
  - 주요 버전별 템플릿 분리 (Vitest v1 vs v2)

#### B3: 스펙-코드 불일치
- **가능성**: High (스펙이 오래됨)
- **영향**: 잘못된 테스트 생성
- **완화**:
  - 불일치 감지 시 경고
  - 사용자에게 스펙 업데이트 권장

#### B4: 긴 실행 시간 (UI 테스트)
- **가능성**: High (Playwright는 느림)
- **영향**: 사용자 대기 시간 증가
- **완화**:
  - Phase 1에서 UI 테스트 제외
  - Phase 2에서 백그라운드 실행 옵션 제공

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Haiku 성능 부족 | Medium | Medium | Sonnet 폴백 옵션 |
| 스펙 파일 없음 | High | Low | 기본 테스트 생성 + 경고 |
| 테스트 실행 실패 | Medium | High | 상세 에러 로그 + 가이드 |
| 커버리지 85% 미달 | High | Medium | 누락 테스트 명확히 표시 |
| 기존 테스트 충돌 | Low | Medium | Append 전략 + 주석 |
| 프레임워크 미설치 | Medium | High | 설치 가이드 + 사용자 확인 |

---

## 6. Testing Strategy

### Unit Tests (메타 테스트)

test-runner 자체를 테스트하기 위한 샘플 프로젝트:

**샘플 프로젝트 구조**:
```
.test-samples/
  typescript-basic/
    src/calculator.ts
    src/calculator.test.ts (기존 일부만)
    .specs/calculator-spec.md
  python-basic/
    src/calculator.py
    tests/test_calculator.py (기존 일부만)
    .specs/calculator-spec.md
```

**테스트 케이스**:

#### TC1: 프로젝트 타입 감지
- **Input**: `.test-samples/typescript-basic/`
- **Expected**: "TypeScript project detected"

#### TC2: 누락 테스트 생성
- **Input**: `calculator.ts` (5개 함수), `calculator.test.ts` (2개만 테스트)
- **Expected**: 3개 테스트 추가

#### TC3: 스펙 기반 엣지케이스 생성
- **Input**: `calculator-spec.md` (엣지케이스 5개 명시)
- **Expected**: 5개 엣지케이스 테스트 생성

#### TC4: 커버리지 85% 달성
- **Input**: 기존 커버리지 60%
- **Expected**: 테스트 추가 후 85% 이상

#### TC5: 리포트 생성
- **Input**: 테스트 실행 결과
- **Expected**: `.test-reports/*/summary.md` 파일 존재

#### TC6: 콘솔 출력 형식
- **Input**: 테스트 결과
- **Expected**: 테이블 형식, 색상 포함 (cyan)

#### TC7: 스펙 없을 때 경고
- **Input**: 스펙 파일 없는 프로젝트
- **Expected**: "⚠️  No spec files found" 메시지

#### TC8: 프레임워크 없을 때 안내
- **Input**: Vitest 미설치 프로젝트
- **Expected**: 설치 가이드 출력

### Integration Tests

#### IT1: /validate 연동
- **Scenario**: test-runner 실행 → /validate 실행
- **Expected**: /validate가 test-report 참조하여 점수 계산

#### IT2: 멀티파일 테스트
- **Scenario**: `/test src/` (10개 파일)
- **Expected**: 10개 파일 모두 테스트 생성/실행

#### IT3: Monorepo 지원
- **Scenario**: `packages/api/`, `packages/web/` 구조
- **Expected**: 각 패키지별 독립 리포트

### Test Coverage Target

- **Phase 1 기능**: 90% 이상
- **Edge Cases**: 100% (10개 모두 테스트)
- **Error Handling**: 100%

---

## 7. Examples

### Example 1: 테스트 생성 (Vitest)

**Input**: `src/services/todo.ts`
```typescript
export class TodoService {
  async createTodo(title: string, userId: number) {
    if (!title) throw new Error('Title required')
    if (userId <= 0) throw new Error('Invalid userId')
    return db.todos.create({ title, userId })
  }
}
```

**Spec**: `.specs/api-spec.md`
```markdown
### Edge Cases
1. Empty title → 400 error
2. Invalid userId (0, negative) → 400 error
3. DB connection failure → 500 error
```

**Generated Test**: `src/services/todo.test.ts`
```typescript
import { describe, it, expect, vi } from 'vitest'
import { TodoService } from './todo'

describe('TodoService', () => {
  describe('createTodo', () => {
    // Spec: api-spec.md#EdgeCase1 - Empty title validation
    it('should reject empty title', async () => {
      const service = new TodoService()
      await expect(service.createTodo('', 1))
        .rejects.toThrow('Title required')
    })

    // Spec: api-spec.md#EdgeCase2 - Invalid userId
    it('should reject userId <= 0', async () => {
      const service = new TodoService()
      await expect(service.createTodo('Test', 0))
        .rejects.toThrow('Invalid userId')
      await expect(service.createTodo('Test', -1))
        .rejects.toThrow('Invalid userId')
    })

    // Spec: api-spec.md#EdgeCase3 - DB failure handling
    it('should handle DB connection failure', async () => {
      const service = new TodoService()
      vi.spyOn(db.todos, 'create').mockRejectedValue(new Error('DB error'))
      await expect(service.createTodo('Test', 1))
        .rejects.toThrow('DB error')
    })

    // Happy path
    it('should create valid todo', async () => {
      const service = new TodoService()
      const result = await service.createTodo('Test Todo', 1)
      expect(result).toMatchObject({
        id: expect.any(Number),
        title: 'Test Todo',
        userId: 1
      })
    })
  })
})
```

### Example 2: API 테스트 (Supertest)

**Input**: `src/routes/todos.ts`
```typescript
router.post('/todos', async (req, res) => {
  const { title, userId } = req.body
  const todo = await todoService.createTodo(title, userId)
  res.status(201).json(todo)
})
```

**Generated Test**: `src/routes/todos.test.ts`
```typescript
import request from 'supertest'
import { app } from '../app'

describe('POST /api/todos', () => {
  // Spec: api-spec.md#TodoAPI - Success case
  it('should return 201 with valid payload', async () => {
    const response = await request(app)
      .post('/api/todos')
      .send({ title: 'Test', userId: 1 })
      .expect(201)

    expect(response.body).toMatchObject({
      id: expect.any(Number),
      title: 'Test'
    })
  })

  // Spec: api-spec.md#ErrorCodes - Missing title
  it('should return 400 for missing title', async () => {
    await request(app)
      .post('/api/todos')
      .send({ userId: 1 })
      .expect(400)
  })

  // Spec: api-spec.md#Authentication
  it('should return 401 without auth token', async () => {
    await request(app)
      .post('/api/todos')
      .send({ title: 'Test', userId: 1 })
      .expect(401)
  })
})
```

### Example 3: 콘솔 출력

```
🧪 Test Report - 2025-10-17 14:30:22

┌──────────┬────────┬────────┬────────┬──────────┐
│ Type     │ Passed │ Failed │ Skip   │ Coverage │
├──────────┼────────┼────────┼────────┼──────────┤
│ Unit     │ 45/50  │ 5      │ 0      │ 82%      │
│ API      │ 12/15  │ 3      │ 0      │ 75%      │
│ Total    │ 57/65  │ 8      │ 0      │ 80%      │
└──────────┴────────┴────────┴────────┴──────────┘

⚠️  Failed Tests (Top 3):
1. TodoService.createTodo - Empty title validation
   → File: src/services/todo.test.ts:12
   → Spec: api-spec.md#EdgeCase3

2. POST /api/todos - Invalid userId error
   → File: src/routes/todos.test.ts:28
   → Spec: api-spec.md#Authentication

3. DELETE /api/todos/:id - Unauthorized access
   → File: src/routes/todos.test.ts:45
   → Spec: api-spec.md#Authorization

💡 Recommendations:
- Fix validation in TodoService (2 tests)
- Add error handling for authentication (1 test)
- Increase coverage by 5% to reach 85% target

📄 Full Report: .test-reports/2025-10-17-143022/summary.md
🌐 Coverage HTML: .test-reports/2025-10-17-143022/coverage/index.html

Next: Fix failing tests and run /validate
```

### Example 4: Python 테스트 생성 (PyTest)

**Input**: `src/services/todo.py`
```python
class TodoService:
    def create_todo(self, title: str, user_id: int) -> dict:
        if not title:
            raise ValueError("Title required")
        if user_id <= 0:
            raise ValueError("Invalid userId")
        return {"id": 1, "title": title, "userId": user_id}

    async def fetch_todos(self, user_id: int) -> list[dict]:
        if user_id <= 0:
            raise ValueError("Invalid userId")
        # DB call
        return []
```

**Spec**: `.specs/api-spec.md`
```markdown
### Edge Cases
1. Empty title → ValueError
2. Invalid userId (0, negative) → ValueError
3. DB connection failure → RuntimeError
4. Async timeout → TimeoutError
```

**Generated Test**: `tests/test_todo.py`
```python
import pytest
from src.services.todo import TodoService

class TestTodoService:
    """Test suite for TodoService"""

    def setup_method(self):
        self.service = TodoService()

    # Spec: api-spec.md#EdgeCase1 - Empty title validation
    def test_reject_empty_title(self):
        with pytest.raises(ValueError, match="Title required"):
            self.service.create_todo("", 1)

    # Spec: api-spec.md#EdgeCase2 - Invalid userId
    def test_reject_invalid_user_id(self):
        with pytest.raises(ValueError, match="Invalid userId"):
            self.service.create_todo("Test", 0)

        with pytest.raises(ValueError, match="Invalid userId"):
            self.service.create_todo("Test", -1)

    # Spec: api-spec.md#EdgeCase3 - DB failure handling
    def test_handle_db_connection_failure(self, mocker):
        mocker.patch.object(
            self.service, '_db_connection',
            side_effect=RuntimeError("DB error")
        )
        with pytest.raises(RuntimeError, match="DB error"):
            self.service.create_todo("Test", 1)

    # Happy path
    def test_create_valid_todo(self):
        result = self.service.create_todo("Test Todo", 1)
        assert result["title"] == "Test Todo"
        assert result["userId"] == 1
        assert "id" in result

    # Spec: api-spec.md#EdgeCase4 - Async timeout
    @pytest.mark.asyncio
    async def test_fetch_todos_timeout(self, mocker):
        mocker.patch.object(
            self.service, 'fetch_todos',
            side_effect=TimeoutError("Request timeout")
        )
        with pytest.raises(TimeoutError):
            await self.service.fetch_todos(1)

    # Async happy path
    @pytest.mark.asyncio
    async def test_fetch_todos_success(self):
        result = await self.service.fetch_todos(1)
        assert isinstance(result, list)
```

### Example 5: summary.md (상세 리포트)

```markdown
# Test Report - 2025-10-17 14:30:22

## Summary

| Type | Passed | Failed | Skipped | Coverage |
|------|--------|--------|---------|----------|
| Unit | 45/50  | 5      | 0       | 82%      |
| API  | 12/15  | 3      | 0       | 75%      |
| **Total** | **57/65** | **8** | **0** | **80%** |

## Failed Tests

### Unit Tests (5 failures)

#### 1. ❌ TodoService.createTodo - should reject empty title
- **File**: src/services/todo.test.ts:12
- **Error**: Expected ValidationError, got 500 Internal Server Error
- **Spec Reference**: .specs/api-spec.md#EdgeCase3
- **Suggestion**: Add input validation before DB call

#### 2. ❌ TodoService.updateTodo - should reject non-existent todo
- **File**: src/services/todo.test.ts:34
- **Error**: Expected 404, got unhandled exception
- **Spec Reference**: .specs/api-spec.md#EdgeCase5
- **Suggestion**: Add existence check with try-catch

### API Tests (3 failures)

#### 1. ❌ POST /api/todos - should return 400 for invalid userId
- **File**: src/routes/todos.test.ts:28
- **Error**: Expected 400, got 500
- **Spec Reference**: .specs/api-spec.md#Authentication
- **Suggestion**: Add userId validation middleware

## Coverage Analysis

### Overall: 80% (Target: 85%)

### By File:
| File | Coverage | Missing Lines |
|------|----------|---------------|
| src/services/todo.ts | 78% | 45-52, 67-70 (error handling) |
| src/routes/todos.ts | 85% | 23-25 (auth check) |
| src/models/todo.ts | 90% | ✅ Meets target |

### Recommendations:
1. **Priority 1**: Add error handling in TodoService (lines 45-52, 67-70)
2. **Priority 2**: Add auth check in todos route (lines 23-25)
3. **Estimated Impact**: +7% coverage → 87% total

## Spec Compliance

### Requirements Coverage: 18/20 (90%)

✅ Covered:
- Create todo
- Update todo
- Delete todo
- List todos with pagination
- ... (14 more)

❌ Missing:
1. Bulk delete (spec: api-spec.md#BulkOperations)
2. Export todos as CSV (spec: api-spec.md#Export)

### Edge Cases Coverage: 8/10 (80%)

✅ Covered:
- Empty title validation
- Invalid userId
- ... (6 more)

❌ Missing:
1. Concurrent update conflict (spec: api-spec.md#EdgeCase9)
2. Title length > 1000 chars (spec: api-spec.md#EdgeCase10)

## Next Steps

1. **Fix Failing Tests** (8 tests)
   - Estimated time: 30 minutes
   - Focus on validation and error handling

2. **Add Missing Tests** (4 tests)
   - 2 requirements + 2 edge cases
   - Estimated time: 20 minutes

3. **Increase Coverage** (80% → 85%+)
   - Add 5-7 test cases
   - Focus on error handling paths

4. **Run /validate**
   - After all tests pass and coverage ≥ 85%
   - Expected score: 88-92/100

## Generated Test Files

- ✅ src/services/todo.test.ts (15 tests added)
- ✅ src/routes/todos.test.ts (8 tests added)
- ⚠️  src/models/todo.test.ts (not generated - already 90% coverage)

---

*Generated by test-runner sub-agent (Haiku 4.5)*
*Spec files referenced: program-spec.md, api-spec.md*
```

---

## 8. API Contract (Slash Commands)

### /test [path] [options]

**Description**: 자동으로 프로젝트 타입을 감지하고 적절한 테스트 생성/실행

**Parameters**:
- `path` (optional): 대상 파일 또는 디렉토리 (기본값: 현재 디렉토리)
- `--model` (optional): 모델 선택 (`haiku` | `sonnet`, 기본값: haiku)
- `--coverage` (optional): 커버리지 목표 (기본값: 85)

**Examples**:
```bash
/test                          # 전체 프로젝트 테스트
/test src/services/todo.ts     # 특정 파일만
/test src/services/            # 특정 디렉토리만
/test --model sonnet           # Sonnet 모델 사용
/test --coverage 90            # 커버리지 목표 90%
```

**Output**:
- 콘솔: 요약 테이블 + Top 3 실패 + 파일 경로
- 파일: `.test-reports/YYYY-MM-DD-HHmmss/summary.md`

---

### /test unit [path]

**Description**: 유닛 테스트만 생성/실행

**Use Case**: API/UI 테스트는 느리므로, 빠른 피드백 원할 때

**Examples**:
```bash
/test unit                     # 전체 유닛 테스트
/test unit src/utils/          # 특정 디렉토리 유닛 테스트
```

---

### /test api [path]

**Description**: API 테스트만 생성/실행

**Use Case**: API 엔드포인트 변경 후 검증

**Examples**:
```bash
/test api                      # 전체 API 테스트
/test api src/routes/todos.ts  # 특정 라우트만
```

---

### /test ui [path] (Phase 2)

**Description**: UI 테스트 생성/실행

**Use Case**: 프론트엔드 컴포넌트 검증

---

## 9. Documentation & Migration

### Documentation Updates

#### README.md 추가 섹션:

```markdown
## Testing with test-runner

이 프로젝트는 `test-runner` 서브에이전트를 사용하여 자동화된 테스트를 생성합니다.

### Usage

```bash
# 전체 테스트
/test

# 특정 파일만
/test src/services/todo.ts

# 유닛 테스트만 (빠름)
/test unit
```

### Test Reports

테스트 리포트는 `.test-reports/` 디렉토리에 저장됩니다:
- `summary.md`: 요약 + 권장사항
- `unit-test.log`: 상세 로그
- `coverage/index.html`: 커버리지 시각화

### Requirements

- **JavaScript/TypeScript**: Vitest 필요
  ```bash
  pnpm add -D vitest @vitest/ui
  ```
- **Python**: PyTest 필요
  ```bash
  uv add --dev pytest pytest-cov
  ```
```

#### CLAUDE.md 업데이트:

```markdown
### test-runner (테스트 실행자)

**실행 시점**: 구현 완료 후, /validate 전

```bash
/test
```

**역할**:
- 스펙 기반 테스트 자동 생성
- 테스트 실행 및 커버리지 분석
- 상세 리포트 제공

**목표**:
- 커버리지 85% 이상
- 스펙의 모든 엣지케이스 테스트
```

### Migration Path

**기존 프로젝트에 test-runner 도입**:

1. **스펙 작성** (없는 경우):
   ```bash
   /spec-init
   ```

2. **test-runner 설치** (이미 `.claude/agents/` 에 있음):
   - 추가 설정 불필요

3. **첫 테스트 실행**:
   ```bash
   /test
   ```

4. **기존 테스트와 병합**:
   - test-runner는 기존 테스트에 append (덮어쓰기 안 함)
   - 중복 확인 후 수동 정리

5. **CI/CD 통합** (선택):
   ```yaml
   # .github/workflows/test.yml
   - name: Run tests
     run: pnpm test --coverage
   ```

---

## 10. Success Metrics

### Definition of Done

- [ ] `.claude/agents/test-runner.md` 파일 생성 (Haiku 4.5, cyan color)
- [ ] `/test`, `/test unit`, `/test api` 커맨드 동작
- [ ] TypeScript 프로젝트에서 테스트 생성/실행 성공
- [ ] Python 프로젝트에서 테스트 생성/실행 성공
- [ ] 스펙 기반 엣지케이스 테스트 생성 확인
- [ ] 커버리지 85% 이상 달성 (샘플 프로젝트)
- [ ] `.test-reports/` 에 summary.md 생성
- [ ] 콘솔 출력이 터미널에서 읽기 쉬움
- [ ] 메타 테스트 8개 이상 통과
- [ ] 문서 업데이트 (README, CLAUDE.md)

### KPIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| 테스트 생성 시간 | < 2분 | 중간 크기 모듈 (10 함수) |
| 커버리지 달성률 | 85%+ | 샘플 프로젝트 평균 |
| 스펙 요구사항 커버 | 95%+ | 생성된 테스트 / 스펙 요구사항 |
| 엣지케이스 커버 | 100% | 생성된 테스트 / 스펙 엣지케이스 |
| 사용자 만족도 | "시간 50%+ 절감" | 사용 후 피드백 |
| 비용 절감 | Sonnet 대비 90% | Haiku 4.5 사용 |

### Monitoring

- **테스트 실행 횟수**: `.test-reports/` 디렉토리 개수
- **평균 커버리지**: 모든 리포트의 커버리지 평균
- **실패율**: 실패 테스트 개수 / 전체 테스트 개수
- **비용**: Haiku 4.5 토큰 사용량

---

## 11. Open Questions

- [ ] **Q1**: Haiku 4.5가 복잡한 엣지케이스를 잘 추론할까?
  - **Deadline**: Phase 1 구현 중 평가
  - **Fallback**: 복잡도 임계값 초과 시 Sonnet 사용

- [ ] **Q2**: Monorepo (pnpm workspace)에서 잘 동작할까?
  - **Deadline**: Phase 1 테스트 시 검증
  - **Risk**: Medium (workspace 감지 로직 필요)

- [ ] **Q3**: 기존 테스트와 생성된 테스트가 충돌하지 않을까?
  - **Deadline**: Phase 1 구현 전 결정
  - **Proposal**: Append 전략 + 주석으로 구분

- [ ] **Q4**: UI 테스트 (Playwright)가 너무 느리면?
  - **Deadline**: Phase 2 설계 시
  - **Proposal**: 백그라운드 실행 옵션

- [ ] **Q5**: 사용자가 테스트 프레임워크 선택하고 싶으면?
  - **Deadline**: Phase 1 피드백 후
  - **Proposal**: 설정 파일 (`.test-runner.config.json`)

- [ ] **Q6**: 다른 개발자와 협업 시 충돌 방지?
  - **Deadline**: Phase 1 완료 후
  - **Proposal**: Git ignore 권장 (`.test-reports/`)

---

## 12. Appendix

### A. Color Reference (Sub-Agent)

**test-runner**: `cyan` (청록색)
- **이유**: 테스트 = 물(water) = 청색 계열, 차분하면서 눈에 잘 띔
- **대비**: spec-analyzer (blue), implementation-validator (green)

### B. File Structure

```
.claude/
  agents/
    test-runner.md              # Sub-agent configuration (Haiku 4.5, cyan)
  commands/
    test.md                     # /test command
    test-unit.md                # /test unit command
    test-api.md                 # /test api command
    test-ui.md                  # /test ui command (Phase 2)

.test-reports/                  # Generated reports (add to .gitignore)
  2025-10-17-143022/
    summary.md
    unit-test.log
    api-test.log
    coverage/
      index.html

.test-samples/                  # Sample projects for testing (meta)
  typescript-basic/
  python-basic/

.specs/                         # Spec files (referenced by test-runner)
  program-spec.md
  api-spec.md
  ui-ux-spec.md
```

### C. Related Documents

- `.specs/spec-analyzer-spec.md` (스펙 검토자)
- `.specs/implementation-validator-spec.md` (구현 검증자)
- `.specs/architecture-reviewer-spec.md` (아키텍처 검토자)

### D. References

- [Vitest Documentation](https://vitest.dev/)
- [PyTest Documentation](https://docs.pytest.org/)
- [Supertest Documentation](https://github.com/ladjs/supertest)
- [Playwright Documentation](https://playwright.dev/)
- [Claude Code Sub-Agents](https://docs.claude.com/en/docs/claude-code/sub-agents)

---

**End of Specification**

*Next Step: Run `/spec-review` to get this spec approved (target: 90+ score)*

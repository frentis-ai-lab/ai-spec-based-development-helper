# AI Specification-Based Development Helper

## 프로젝트 개요

이 프로젝트는 **Specification-First 개발 방법론**을 강제하는 Claude Code 통합 시스템입니다.

**핵심 철학**: "Reason before you type" 🧠 → ⌨️

### 3-File Spec Structure

**NEW**: 프로젝트는 3개의 독립적이면서 연결된 스펙 파일로 관리됩니다:

| 파일 | 역할 | 프로젝트 타입 |
|------|------|--------------|
| **program-spec.md** | 시스템 아키텍처, 데이터 모델, 전체 요구사항 | 모든 프로젝트 (필수) |
| **api-spec.md** | API 엔드포인트, 인증, 데이터 스키마 | Backend, Fullstack |
| **ui-ux-spec.md** | UI 컴포넌트, 사용자 플로우, 상호작용 | Frontend, Fullstack |

**구조별 스펙 파일**:
- Backend: program-spec + api-spec
- Frontend: program-spec + ui-ux-spec
- Fullstack: program-spec + api-spec + ui-ux-spec (완전체)

## 개발 규칙 (MUST FOLLOW)

### 1. Specification-First 원칙

#### 모든 구현 작업은 반드시 다음 순서를 따릅니다:

```
1. 요구사항 받음
   ↓
2. /spec-init 실행 → 상세 스펙 작성 (3-file 구조)
   ↓
3. /spec-review 실행 → 90점 이상 확보
   (90점 미만이면 피드백 반영 후 재검토)
   ↓
4. 구현 시작
   (pre-implementation-check hook이 스펙 확인)
   ↓
5. /test 실행 (NEW) → 자동 테스트 생성 및 실행
   (커버리지 85%+ 목표)
   ↓
6. /validate 실행 → 85점 이상 확보
   (85점 미만이면 수정 후 재검증)
   ↓
7. 배포
```

#### 예외 사항

다음의 경우에만 스펙 없이 진행 가능:
- 변수명 변경, 포맷팅 같은 trivial한 작업
- 명확한 한 줄 버그 픽스
- 문서 오타 수정

**복잡도 판단 기준**: 20단어 이상 설명 필요 → 스펙 필수

---

### 2. Sub-Agents 사용 규칙

#### spec-analyzer (스펙 분석가)

**실행 시점**: 스펙 작성 완료 후, 구현 전

```bash
/spec-review
```

**역할**:
- 스펙 문서 품질 평가 (100점 만점)
- 90점 이상만 구현 승인

**평가 기준**:
- 아키텍처 이해도: 25점
  - 시스템 컴포넌트 명확히 정의
  - 데이터 플로우 다이어그램
  - 기술 스택 선택 근거
- 요구사항 완성도: 25점
  - 기능 요구사항 구체적
  - 비기능 요구사항 (성능, 보안, 확장성)
  - 성공 기준 명확
- 구현 계획: 20점
  - 단계별 구현 계획
  - 의존성 식별
  - 롤백 전략
- 엣지케이스 & 리스크: 20점
  - 엣지케이스 5개 이상
  - 각 케이스별 처리 방법
  - 리스크 평가 및 완화 전략
- 예제 & 문서: 10점
  - 코드 예제
  - API 계약 (해당 시)
  - 테스트 케이스

**사용 방법**:
```
User: /spec-review

AI: [Task tool로 spec-analyzer 실행]

    점수 85/100이면:
    → "Critical Gaps" 섹션의 3가지 보완 필요
    → 피드백 반영 후 재검토

    점수 92/100이면:
    → ✅ APPROVED
    → .specs/[name].approved.md 생성
    → 구현 진행 가능
```

#### architecture-reviewer (아키텍처 검토자)

**실행 시점**: 복잡한 시스템 설계 시 (선택사항)

```bash
/arch-review
```

**역할**:
- 시스템 설계 원칙 검증
- 확장성, 보안, 유지보수성 평가
- 리스크 레벨 판단

**검토 항목**:
1. **설계 원칙**
   - SOLID 원칙 준수 여부
   - DRY, KISS, YAGNI
   - Separation of Concerns

2. **확장성**
   - Horizontal vs Vertical scaling 전략
   - 병목 지점 식별
   - 캐싱 전략

3. **보안**
   - 인증/인가 메커니즘
   - 데이터 암호화
   - 공격 벡터 분석

4. **유지보수성**
   - 모듈 구조
   - 테스트 전략
   - 모니터링 계획

**출력**:
- 리스크 레벨: LOW / MEDIUM / HIGH
- 권장사항
- 결정: APPROVED / APPROVED WITH CONDITIONS / REQUIRES REDESIGN

#### implementation-validator (구현 검증자)

**실행 시점**: 구현 완료 후

```bash
/validate
```

**역할**:
- 구현이 스펙을 정확히 따르는지 검증
- 85점 이상만 배포 승인

**검증 기준**:
- 스펙 준수 (40점)
  - 모든 요구사항 구현
  - 스펙에 명시된 패턴 사용
  - 엣지케이스 처리
- 코드 품질 (30점)
  - 언어 베스트 프랙티스
  - 에러 핸들링
  - 명명 규칙 일관성
- 테스트 커버리지 (20점)
  - 유닛 테스트 > 80%
  - 엣지케이스 테스트
  - 통합 테스트
- 완성도 (10점)
  - 문서 업데이트
  - 마이그레이션 스크립트
  - 설정 예시

**"Should Work" 신호 감지**:
- ❌ 테스트되지 않은 코드 경로
- ❌ TODO 주석
- ❌ 하드코딩된 값
- ❌ 누락된 에러 핸들링
- ❌ 검증되지 않은 가정

#### test-runner (테스트 자동화) (NEW)

**실행 시점**: 구현 완료 후, /validate 전

```bash
/test [path] [--model haiku|sonnet] [--coverage N]
```

**역할**:
- 스펙 기반 자동 테스트 생성 및 실행
- 85%+ 커버리지 목표

**주요 기능**:
1. **Spec-Code Mismatch 감지**
   - 스펙에 정의된 함수 vs 실제 구현 비교
   - 시그니처 불일치 경고
   - 누락된 구현 알림

2. **자동 테스트 생성**
   - .specs/*.md 파일 기반
   - 엣지케이스 테스트 (스펙 참조)
   - 에러 핸들링 테스트
   - API 엔드포인트 테스트 (api-spec.md)
   - UI 상호작용 테스트 (ui-ux-spec.md)

3. **테스트 실행 및 리포트**
   - 유닛/통합/E2E 테스트 실행
   - 커버리지 분석
   - `.test-reports/` 에 상세 리포트 생성
   - 실패한 테스트 우선순위 정렬

4. **비용 최적화**
   - 기본: Haiku 모델 사용
   - 복잡도 10+ 함수: Sonnet 권장
   - 기존 테스트 보존 (append only)

**사용 방법**:
```
User: /test src/services/todo.ts

AI: [Task tool로 test-runner 실행]

    Phase 1: Analysis
    - TypeScript backend 감지
    - program-spec.md, api-spec.md 발견
    - 기존 테스트 2개, 커버리지 60%

    Phase 2: Generation
    - 5개 요구사항, 3개 엣지케이스 추출
    - 6개 누락 테스트 생성 중...

    Phase 3: Execution
    - 테스트 실행 중...
    - 8 passed, 0 failed
    - 새 커버리지: 88%

    Phase 4: Report
    - .test-reports/2025-10-17-143022/summary.md

    ✅ All tests passing!
    ✅ Coverage target exceeded (88% > 85%)

    Next: Run /validate
```

**추가 명령어**:
- `/test-unit`: 유닛 테스트만
- `/test-api`: API 테스트만 (api-spec.md 기반)

---

### 3. Hooks 동작 방식 (Updated)

#### Relaxed Mode 지원 (NEW)

**모든 Hook은 환경 변수로 우회 가능**:

```bash
# Prototype 개발 시 Hook 비활성화
export CLAUDE_MODE=prototype

# 또는
export CLAUDE_MODE=relaxed

# 원복
unset CLAUDE_MODE
```

**사용 시나리오**:
- **Prototype**: 빠른 MVP 개발, 스펙 없이 실험
- **Exploration**: 코드베이스 탐색, 리팩토링 실험
- **Demo**: 데모 준비 중 빠른 수정
- **Learning**: 튜토리얼 진행, 학습 목적

**주의**: Relaxed mode는 임시 우회용입니다. 정식 개발은 Specification-First를 따라야 합니다.

---

#### pre-implementation-check (PreToolUse - Blocking)

**트리거**: Edit 또는 Write tool 사용 전

**동작**:
```bash
# Relaxed mode 체크 (NEW)
if [[ "$CLAUDE_MODE" == "prototype" || "$CLAUDE_MODE" == "relaxed" ]]; then
  echo "ℹ️  Relaxed mode enabled (CLAUDE_MODE=$CLAUDE_MODE)"
  echo "   Skipping spec validation checks."
  exit 0
fi

# 기존 검증 로직
if [ ! -d ".specs" ]; then
  echo "⚠️  .specs 디렉토리 없음"
  echo "먼저 /spec-init 실행하세요"
  exit 1  # 차단
fi

if [ $(find .specs -name "*.approved.md" | wc -l) -eq 0 ]; then
  echo "⚠️  승인된 스펙 없음"
  echo "/spec-review로 스펙 승인 받으세요"
  # 경고만, 차단 안 함
fi
```

**우회 방법**:

1. **권장 (환경 변수)**:
   ```bash
   export CLAUDE_MODE=prototype
   # 작업...
   unset CLAUDE_MODE
   ```

2. **레거시 (긴급 상황만)**:
   ```bash
   mkdir -p .specs
   touch .specs/.bypass
   # 작업 후 반드시 삭제
   rm .specs/.bypass
   ```

#### post-edit-validation (PostToolUse - Non-blocking)

**트리거**: Edit 또는 Write tool 사용 후

**동작**:
```bash
# Relaxed mode 체크 (NEW)
if [[ "$CLAUDE_MODE" == "prototype" || "$CLAUDE_MODE" == "relaxed" ]]; then
  exit 0
fi

# .specs/.last-validation 타임스탬프 확인
# 5분 이상 경과 시:
echo "📋 Reminder: 구현 완료 후 /validate 실행하세요"
```

#### quality-reminder (UserPromptSubmit - Non-blocking)

**트리거**: 사용자 프롬프트 제출 시

**동작**:
```bash
# Relaxed mode 체크 (NEW)
if [[ "$CLAUDE_MODE" == "prototype" || "$CLAUDE_MODE" == "relaxed" ]]; then
  exit 0
fi

# 단어 수 > 20 && 구현 키워드 포함?
if complex_request; then
  echo "💡 Specification-First 추천"
  echo "복잡한 요청은 /spec-init로 시작하면"
  echo "반복 작업 61% 감소, 성공률 89%"
fi
```

---

### 4. 슬래시 커맨드 가이드

#### /spec-init (스펙 초기화)

**사용 시점**: 새 기능 개발 시작

**프로세스**:
1. 요구사항 이해
2. 명확화 질문 (5-10개)
3. 템플릿 선택 (feature-spec / api-spec)
4. 컨텍스트 분석 (기존 코드베이스)
5. 스펙 문서 생성

**출력**: `.specs/[feature-name]-spec.md`

**예시**:
```
User: /spec-init
      할일 목록 CRUD API 만들고 싶어요

AI: 명확화 질문입니다:
    1. 인증 필요한가요? (JWT? Session?)
    2. 필터링/정렬 기능은?
    3. 페이지네이션 방식? (offset? cursor?)
    4. 실시간 업데이트 필요? (WebSocket?)
    5. 데이터베이스는? (PostgreSQL 추천)

    [답변 후 스펙 생성]
    ✅ .specs/todo-crud-api-spec.md
```

#### /spec-review (스펙 검토)

**사용 시점**: 스펙 작성 완료 후

**프로세스**:
1. .specs/ 에서 스펙 파일 찾기
2. spec-analyzer agent 실행
3. 100점 만점 평가
4. 90점 이상 → 승인 마커 생성
5. 90점 미만 → 피드백 + 재작성 요청

**예시**:
```
User: /spec-review

AI: [spec-analyzer 실행]

    점수: 85/100

    Critical Gaps:
    - Refresh token 전략 미정의
    - 엣지케이스 3개 누락
    - 롤백 전략 없음

    → REQUEST REVISION

    보완 후 다시 /spec-review 실행하세요
```

#### /arch-review (아키텍처 검토)

**사용 시점**: 복잡한 시스템 설계 시

**예시**:
```
User: /arch-review

AI: [architecture-reviewer 실행]

    Concerns:
    - 단일 DB 병목 가능성
    - 캐싱 레이어 없음
    - 보안: API rate limiting 미정의

    Recommendations:
    1. Read replica 추가 고려
    2. Redis 캐싱 레이어
    3. Rate limiter 명세 추가

    Risk Level: MEDIUM
    Decision: APPROVED WITH CONDITIONS
```

#### /validate (구현 검증)

**사용 시점**: 구현 완료 후

**예시**:
```
User: /validate

AI: [implementation-validator 실행]

    Compliance Score: 88/100

    ✅ Correctly Implemented:
    - 모든 CRUD 엔드포인트
    - JWT 인증 미들웨어
    - 페이지네이션 (cursor-based)

    ⚠️  Test Coverage: 78% (목표 80%)
    - Missing: 동시 수정 충돌 테스트

    Recommendation: REQUEST REVISION
    테스트 2개 추가 후 재검증
```

#### /test (테스트 자동화) (NEW)

**사용 시점**: 구현 완료 후, /validate 전

**프로세스**:
1. 프로젝트 타입 감지 (TypeScript/Python)
2. .specs/*.md 파일에서 요구사항 추출
3. 누락된 테스트 식별
4. 자동 테스트 코드 생성 (스펙 기반)
5. 테스트 실행 및 커버리지 측정
6. 상세 리포트 생성

**출력**: `.test-reports/YYYY-MM-DD-HHmmss/summary.md`

**예시**:
```
User: /test src/services/

AI: [test-runner 실행]

    Phase 1: Analysis
    - Detected: TypeScript backend
    - Found specs: program-spec.md, api-spec.md
    - Existing: 5 tests (60% coverage)

    Phase 2: Generation
    - Extracted 8 requirements from specs
    - Missing: 6 tests
    - Generating with Haiku...

    Phase 3: Execution
    - Running: pnpm test --coverage
    - 11 passed, 0 failed
    - New coverage: 87%

    Phase 4: Report
    - .test-reports/2025-10-17-143022/summary.md

    ✅ All tests passing!
    ✅ Coverage: 87% (목표 85% 초과)

    Next: Run /validate
```

#### /spec-status (상태 확인)

**사용 시점**: 현재 진행 상황 확인

**예시**:
```
User: /spec-status

AI:
    # Specification Status Report

    | Spec | Status | Score | Implementation |
    |------|--------|-------|----------------|
    | todo-api | ✅ Approved | 92/100 | ✅ Complete (88/100) |
    | auth-api | ⚠️  Draft | N/A | ❌ Not Started |

    Recommendations:
    - auth-api: Run /spec-review
    - todo-api: Ready for deployment
```

---

### 5. 템플릿 사용법

#### program-spec-template.md (NEW)

**사용 대상**: 모든 프로젝트 (마스터 스펙)

**핵심 섹션**:
1. 개요 (문제 정의, 목표, 타겟 사용자, 범위)
2. 시스템 아키텍처 (전체 구조도, 기술 스택, 아키텍처 패턴, ADR)
3. 핵심 기능 목록 (각 기능마다 API/UI 스펙 참조)
4. 데이터 모델 (ERD, 주요 엔티티, 관계)
5. 비기능 요구사항 (성능, 보안, 확장성, 가용성)
6. 외부 연동 (Third-party 서비스, 연동 전략)
7. 배포 전략 (환경 구성, CI/CD, 롤백)
8. 테스트 전략 (레벨별 테스트, 커버리지 목표)
9. 프로젝트 일정 (마일스톤, 위험 요소)
10. 개방된 질문 (미결정 사항, 해결 기한)

**참조 형식**: `api-spec.md#인증API`, `ui-ux-spec.md#로그인화면`

#### api-spec-template.md (Updated)

**사용 대상**: Backend/Fullstack 프로젝트

**특화 섹션**:
1. API Configuration (Base URL, 인증 방식, Rate limiting)
2. Authentication & Authorization (인증 방법, 권한 레벨)
3. API Endpoints (각 엔드포인트별 상세 스펙)
   - HTTP method, path, parameters
   - Request/Response schemas
   - Validation rules
   - Error responses
4. Data Models (TypeScript interfaces, validation)
5. Error Handling (표준 에러 형식, 에러 코드)
6. Rate Limiting (제한 정책, 헤더)
7. Versioning (버전 전략, Deprecation 정책)
8. Performance Requirements (응답 시간 목표, 처리량)
9. Security (보안 조치, 민감 데이터 처리)
10. Cross-Reference (program-spec 데이터 모델 참조, UI 매핑 테이블)

#### ui-ux-spec-template.md (NEW)

**사용 대상**: Frontend/Fullstack 프로젝트

**특화 섹션**:
1. Design Philosophy (핵심 원칙, 디자인 가치)
2. Design System (Color palette, Typography, Spacing, Shadows)
3. Component Library (Button, Input, Modal, Toast 등 변형과 상태)
4. Screen Layouts (전체 레이아웃, Container, Breakpoints)
5. User Flows (사용자 여정 맵, 화면 전환)
6. Screen Specifications (각 화면별 상세 스펙)
   - Wireframe
   - Elements 목록
   - Interactions (클릭, 호버, 폼 제출)
   - Validation rules
   - Error states
   - API 호출 (`api-spec.md#endpoint` 참조)
7. Interaction Patterns (폼 제출, 삭제 확인, 무한 스크롤 등)
8. Animation & Transitions (Duration, Easing, 공통 애니메이션)
9. Accessibility (WCAG 준수, Keyboard navigation, Screen reader)
10. Cross-Reference (API 매핑 테이블, 기능 매핑)

#### constitution-template.md (NEW)

**사용 대상**: 모든 프로젝트 (프로젝트별 개발 표준)

**특징**:
- 프로젝트별 코딩 규칙 및 금지 사항 정의
- `[AUTO-CHECK]` 섹션은 spec-analyzer가 자동 검증
- /spec-review 시 Constitution 준수 여부 확인 (+5 보너스 점수)

**핵심 섹션** (14개):
1. **금지 사항** [AUTO-CHECK]
   - 언어별 금지 패턴 (`any` 타입, `console.log` 등)
   - 아키텍처 금지 패턴 (순환 의존성, God objects)
   - Hard-coded credentials 금지

2. **기술 스택 표준** [AUTO-CHECK]
   - 언어 및 런타임 (TypeScript 5.3+, Python 3.12+ 등)
   - 필수 라이브러리 (로깅, ORM, 테스트 프레임워크)
   - 버전 정책 (LTS 우선, 의존성 업데이트 주기)

3. **코딩 스타일** [AUTO-CHECK]
   - 네이밍 규칙 (함수명, 변수명, 클래스명)
   - 주석 규칙 (필수/금지 주석)
   - 파일 구조 (도메인 기반 분리)

4. 에러 처리 표준
5. 보안 요구사항
6. 테스트 요구사항
7. 성능 요구사항
8. 문서화 요구사항
9. Git 워크플로우
10. 배포 및 모니터링
11. 프로젝트별 커스텀 규칙
12. 예외 처리 프로세스
13. Constitution 변경 이력
14. 참고 자료

**사용 방법**:
```bash
# 1. 프로젝트 시작 시 Constitution 생성
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 2. 프로젝트 특성에 맞게 커스터마이징
# 3. /spec-review 시 자동으로 검증됨

# 예: 금지 사항 추가
## 1. 금지 사항 [AUTO-CHECK]
- ❌ `any` 타입 사용
  - **이유**: 타입 안정성 상실
  - **대안**: `unknown` 또는 명시적 타입 정의
```

**예외 승인 프로세스**:
```typescript
// CONSTITUTION_EXCEPTION: Approved by @tech-lead on 2025-10-18
// Reason: Third-party library requires `any` type
// See: https://github.com/org/repo/issues/456
const config: any = externalLib.getConfig();
```

#### 레거시 템플릿 (Optional)

- **feature-spec-template.md**: 단일 기능 스펙 (소규모 프로젝트용)
- 3-파일 구조를 선호하지만, 간단한 기능은 단일 파일도 가능

---

### 6. Constitution 시스템 (NEW)

**목적**: 프로젝트별 개발 표준을 정의하고 자동으로 검증

#### 6.1 Constitution 파일 생성

```bash
# 템플릿 복사
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 프로젝트에 맞게 수정
# - 기술 스택 (TypeScript? Python? Go?)
# - 금지 패턴 (프로젝트 특화)
# - 코딩 스타일 (팀 합의)
```

#### 6.2 spec-analyzer 자동 검증

Constitution이 존재하면 `/spec-review` 시 자동으로 검증됩니다:

**검증 항목**:
1. **금지 패턴 검사** (3점)
   - 스펙 내 코드 예제가 금지된 패턴 포함 여부
   - 7가지 예외 패턴 자동 인식 (`avoid`, `대안`, `instead of`, `금지`, `❌`, code blocks, negations)

2. **기술 스택 준수** (1점)
   - 스펙의 기술 선택이 Constitution과 일치
   - 필수 라이브러리 사용 (예: `winston` logger)

3. **코딩 스타일 일관성** (1점)
   - 네이밍 규칙 준수
   - 에러 처리 패턴 일치

**점수 계산**:
- Constitution 없음: 기본 점수 (패널티 없음)
- Constitution 완벽 준수: +5 보너스 점수
- 위반 발견: 위반당 -1점 (최대 -5점)

#### 6.3 검증 예시

```markdown
User: /spec-review

AI: [spec-analyzer 실행]

    Constitution Compliance: 2/5 points

    **Constitution File**: PROJECT-CONSTITUTION.md v1.0.0

    ✅ Compliant:
    - Uses winston logger (matches Constitution §2.2)
    - Naming follows PascalCase (matches §3.1)

    ❌ Violations:
    1. Forbidden Pattern 'any'
       - Location: program-spec.md:145
       - Rule: Constitution §1.1 (금지 사항 - TypeScript)
       - Found: `const config: any = externalLib.getConfig();`
       - Fix: Use `unknown` or define explicit interface

    2. Wrong Logger
       - Location: api-spec.md:78
       - Rule: Constitution §2.2 (기술 스택 표준)
       - Found: `console.log('User created')`
       - Fix: `logger.info('User created', { userId })`

    Impact: -3 points (3 violations)

    Total Score: 87/100 → REQUEST REVISION
```

#### 6.4 예외 처리

Constitution 규칙을 위반해야 하는 경우:

```typescript
// CONSTITUTION_EXCEPTION: Approved by @tech-lead on 2025-10-18
// Reason: Third-party library requires `any` type
// See: https://github.com/org/repo/issues/456
const config: any = externalLib.getConfig();
```

코드에 주석으로 예외 사유를 명시하면 spec-analyzer가 인식합니다.

---

### 7. 품질 기준

#### 스펙 품질 (90점 목표)

**필수 요소**:
- [ ] 아키텍처 다이어그램
- [ ] 기능 요구사항 5개 이상
- [ ] 비기능 요구사항 (성능, 보안, 확장성)
- [ ] 엣지케이스 5개 이상 + 처리 방법
- [ ] 테스트 케이스 10개 이상
- [ ] 롤백 전략
- [ ] 코드 예제
- [ ] 성공 메트릭

**흔한 누락 사항** (자동 감점):
- 추상적인 요구사항 ("좋은 성능" → "p95 < 200ms"로 구체화)
- 엣지케이스 부족 (최소 5개)
- 롤백 전략 없음
- 테스트 전략 없음

#### 구현 품질 (85점 목표)

**필수 요소**:
- [ ] 모든 스펙 요구사항 구현
- [ ] 테스트 커버리지 > 80%
- [ ] 모든 엣지케이스 테스트
- [ ] 에러 핸들링 완전
- [ ] 문서 업데이트
- [ ] 코드 리뷰 가능 품질 (명명, 구조)

**자동 거부 사유**:
- 테스트되지 않은 critical path
- TODO 주석 남아있음 (critical section)
- 하드코딩된 credential/secret
- 명백한 보안 취약점
- 스펙과 다른 구현

---

### 7. 이 프로젝트 자체 개발 시

**메타 규칙**: 이 프로젝트는 자신의 방법론을 사용합니다.

모든 기능 추가/변경은:
1. `.specs/` 에 스펙 작성
2. `/spec-review` 로 90+ 점수
3. 구현
4. `/validate` 로 85+ 점수

**예시**:
```
새 Sub-agent 추가 (예: security-auditor):

1. .specs/security-auditor-spec.md 작성
   - 역할: 보안 취약점 스캔
   - 평가 기준: OWASP Top 10
   - 출력 형식: 취약점 리스트 + 심각도

2. /spec-review → 90+ 점수 확보

3. .claude/agents/security-auditor.md 작성

4. /validate → 85+ 점수 확보
```

---

### 8. 예외 처리 가이드

#### Hook 우회가 필요한 경우

**긴급 핫픽스**:
```bash
# 1. 우회 플래그 생성
mkdir -p .specs
touch .specs/.bypass

# 2. 긴급 수정

# 3. 즉시 삭제
rm .specs/.bypass

# 4. 사후 스펙 작성 (24시간 내)
/spec-init  # 수정 내역을 스펙으로 문서화
```

**레거시 코드 수정**:
- 스펙 없는 기존 코드 수정 시
- 먼저 현재 상태를 스펙으로 문서화
- 그 다음 변경사항 반영

---

## 성공 메트릭

이 시스템 사용 시 기대 효과 (논문 데이터):

| 메트릭 | 개선 |
|--------|------|
| 배포 성공률 | 65% → 89% (+24%p) |
| 반복 작업 | -61% |
| 프로덕션 버그 | -82% |
| 평균 배송 시간 | 4배 빠름 |
| 테스트 커버리지 | +30%p |

---

## 추가 지침

### 커뮤니케이션 스타일

- 스펙 점수 발표 시: 명확한 숫자 + 구체적 피드백
- 거부 시: "왜 안 되는지" + "어떻게 고칠지"
- 승인 시: 축하 + 다음 단계 안내

### 에러 메시지

```
❌ Bad:
"스펙이 충분하지 않습니다"

✅ Good:
"스펙 점수: 75/100 (목표 90+)

 누락된 항목:
 1. 엣지케이스 2개만 있음 (최소 5개 필요)
 2. 롤백 전략 미정의
 3. 성능 요구사항 추상적 ("빠르게" → "p95 < 200ms"로 구체화)

 위 3개 보완 후 /spec-review 재실행하세요"
```

---

## 요약: 개발 플로우차트

```
User Request
    ↓
[질문] 복잡한가? (20단어+)
    ├─ No → 바로 구현
    └─ Yes → /spec-init
                ↓
            명확화 질문
                ↓
            스펙 작성 (3-file)
                ↓
            /spec-review
                ↓
            [평가] 90점 이상?
                ├─ No → 피드백 반영 → 재검토
                └─ Yes → ✅ approved.md
                            ↓
                        [Hook] 스펙 존재?
                            ↓
                        구현
                            ↓
                        /test (NEW)
                            ↓
                        [커버리지] 85% 이상?
                            ├─ No → 테스트 추가
                            └─ Yes → /validate
                                        ↓
                                    [평가] 85점 이상?
                                        ├─ No → 수정 → 재검증
                                        └─ Yes → 🚀 배포
```

---

**Remember**: "Reason before you type" 🧠 → ⌨️

이 규칙들을 엄격히 따르면:
- 초기 속도는 -20%
- 전체 속도는 +400%
- 버그는 -82%
- 성공률은 +24%p

**Slow is smooth, smooth is fast.**

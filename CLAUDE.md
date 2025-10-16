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
2. /spec-init 실행 → 상세 스펙 작성
   ↓
3. /spec-review 실행 → 90점 이상 확보
   (90점 미만이면 피드백 반영 후 재검토)
   ↓
4. 구현 시작
   (pre-implementation-check hook이 스펙 확인)
   ↓
5. /validate 실행 → 85점 이상 확보
   (85점 미만이면 수정 후 재검증)
   ↓
6. 배포
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

---

### 3. Hooks 동작 방식

#### pre-implementation-check (PreToolUse - Blocking)

**트리거**: Edit 또는 Write tool 사용 전

**동작**:
```bash
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

**우회 방법** (긴급 상황만):
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
# .specs/.last-validation 타임스탬프 확인
# 5분 이상 경과 시:
echo "📋 Reminder: 구현 완료 후 /validate 실행하세요"
```

#### quality-reminder (UserPromptSubmit - Non-blocking)

**트리거**: 사용자 프롬프트 제출 시

**동작**:
```bash
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

#### 레거시 템플릿 (Optional)

- **feature-spec-template.md**: 단일 기능 스펙 (소규모 프로젝트용)
- 3-파일 구조를 선호하지만, 간단한 기능은 단일 파일도 가능

---

### 6. 품질 기준

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
            스펙 작성
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
                        /validate
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

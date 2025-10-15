# AI Specification-Based Development Helper

> **"Reason before you type"** - A Claude Code toolkit that enforces specification-first development methodology to dramatically improve AI-assisted software engineering outcomes.

## 문제 인식

전통적인 task 기반 AI 개발 접근 방식의 문제점:
- AI가 시스템 아키텍처를 깊이 이해하지 못하고 빠른 수정을 생성
- "작동할 것" vs "작동할 것이다"의 차이
- 반복 작업 증가 및 프로덕션 인시던트 발생
- 표면적인 문제 해결

## 솔루션

**Specification-First** 방법론을 강제하는 Claude Code 통합 시스템:

### 핵심 원칙
1. **구조화된 계획**: 구현 전 상세한 마크다운 스펙 작성
2. **Ultrathink 트리거**: 코딩 전 깊은 분석 강제
3. **책임성 피드백 루프**: 불완전한 솔루션 거부 및 포괄적인 추론 요구

### 입증된 결과
- 80% 애플리케이션이 수동 구현 없이 배포
- 89% 복잡한 기능 성공률
- 61% 적은 반복 작업
- 4배 빠른 평균 배송 시간
- 프로덕션 인시던트 11건 → 2건으로 감소

---

## 기능

### 1. Specialized Sub-Agents

전문화된 AI 에이전트가 각 단계를 검증:

#### 📋 **spec-analyzer**
- 스펙 문서의 품질과 완성도를 100점 만점으로 평가
- 아키텍처 이해도, 요구사항 완성도, 구현 계획, 엣지케이스, 문서화 검증
- 90점 이상만 구현 승인

#### 🏗️ **architecture-reviewer**
- 시스템 설계 원칙 평가 (SOLID, DRY, KISS, YAGNI)
- 확장성, 보안, 유지보수성 검토
- 기술 선택 근거 검증
- 리스크 레벨 평가

#### ✅ **implementation-validator**
- 구현이 스펙을 정확히 따르는지 검증
- 코드 품질, 테스트 커버리지, 완성도 평가
- "작동할 것" 신호 포착 (테스트되지 않은 코드, TODO 주석 등)
- 85점 이상만 승인

### 2. Intelligent Hooks

개발 워크플로우의 특정 시점에 자동 실행:

#### 🔒 **pre-implementation-check** (PreToolUse)
- 코드 편집 전 스펙 파일 존재 확인
- 승인된 스펙 없이 구현 차단
- Specification-First 원칙 강제

#### 📝 **post-edit-validation** (PostToolUse)
- 코드 변경 후 검증 리마인더
- 스펙 준수 확인 유도

#### 💡 **quality-reminder** (UserPromptSubmit)
- 복잡한 구현 요청 시 스펙 작성 권장
- 방법론 지속적 상기

### 3. Slash Commands

개발 프로세스를 안내하는 커스텀 명령어:

| 명령어 | 설명 |
|--------|------|
| `/spec-init` | 새 기능 스펙 생성 (포괄적 템플릿 사용) |
| `/spec-review` | spec-analyzer로 스펙 분석 및 점수 부여 |
| `/arch-review` | architecture-reviewer로 아키텍처 검토 |
| `/validate` | implementation-validator로 구현 검증 |
| `/spec-status` | 현재 스펙 상태 및 진행 상황 확인 |

### 4. Comprehensive Templates

다양한 개발 시나리오를 위한 템플릿:

- **feature-spec-template.md**: 일반 기능 개발
- **api-spec-template.md**: API 엔드포인트 설계

각 템플릿 포함 사항:
- 아키텍처 다이어그램
- 요구사항 명세
- 구현 단계
- 엣지케이스 및 리스크 분석
- 테스트 전략
- 성공 메트릭

---

## 🔧 작동 원리 상세

### 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Code                          │
│  ┌───────────┐  ┌───────────┐  ┌──────────────┐       │
│  │  Hooks    │  │Sub-agents │  │   Commands   │       │
│  │  (자동)   │  │  (검증)   │  │  (워크플로)  │       │
│  └───────────┘  └───────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────┘
         ↓                ↓                ↓
┌─────────────────────────────────────────────────────────┐
│               Specification-First Enforcement            │
│                                                          │
│  Think → Spec → Review → Implement → Validate           │
└─────────────────────────────────────────────────────────┘
```

### 컴포넌트별 상세 설명

#### 1. Sub-Agents: 독립적 전문가

각 Sub-agent는 **별도의 컨텍스트**에서 실행되어 메인 대화를 방해하지 않습니다:

```yaml
spec-analyzer:
  역할: 스펙 품질 평가자
  입력: .specs/*.md 파일
  출력: 점수 (0-100) + 상세 피드백
  통과 기준: 90점 이상
  평가 항목:
    - 아키텍처 이해도 (25점)
    - 요구사항 완성도 (25점)
    - 구현 계획 (20점)
    - 엣지케이스 (20점)
    - 문서화 (10점)

architecture-reviewer:
  역할: 시스템 설계 검토자
  입력: 아키텍처 섹션
  출력: 리스크 레벨 + 개선 권장사항
  검증 항목:
    - SOLID 원칙 준수
    - 확장성 전략
    - 보안 고려사항
    - 기술 선택 근거

implementation-validator:
  역할: 구현 품질 검증자
  입력: 스펙 + 구현 코드
  출력: 준수도 점수 (0-100)
  통과 기준: 85점 이상
  검증 항목:
    - 스펙 준수 (40점)
    - 코드 품질 (30점)
    - 테스트 커버리지 (20점)
    - 완성도 (10점)
```

#### 2. Hooks: 자동화된 품질 게이트

```bash
# Pre-Implementation Hook (Blocking)
PreToolUse → Edit/Write 시도
    ↓
[Check] .specs/ 디렉토리 존재?
    ├─ No → ⛔ 차단 + "스펙 먼저 작성하세요"
    └─ Yes → [Check] *.approved.md 존재?
            ├─ No → ⚠️  경고 + 진행
            └─ Yes → ✅ 승인된 스펙 확인됨

# Post-Edit Hook (Non-blocking)
PostToolUse → Edit/Write 완료
    ↓
[Check] .specs/.last-validation 확인
    ↓
5분 이상 경과? → 💡 "검증 실행 권장"

# Quality Reminder Hook (Non-blocking)
UserPromptSubmit → 요청 받음
    ↓
[Analyze] 단어 수 > 20 && 구현 키워드 포함?
    ↓
Yes → 💡 "스펙 작성 추천 (61% 재작업 감소)"
```

#### 3. 워크플로우 엔진: 슬래시 커맨드

```python
# /spec-init의 내부 동작
def spec_init(user_request):
    # 1. 요구사항 명확화
    questions = generate_clarifying_questions(user_request)
    answers = await ask_user(questions)

    # 2. 템플릿 선택
    template = select_template(user_request)
    # feature-spec-template.md or api-spec-template.md

    # 3. 컨텍스트 분석
    existing_code = analyze_codebase()
    dependencies = identify_dependencies()

    # 4. 스펙 생성
    spec = populate_template(
        template=template,
        answers=answers,
        context=existing_code,
        dependencies=dependencies
    )

    # 5. 저장
    save_to(".specs/{feature-name}-spec.md")

    return "스펙 초안 완성. /spec-review로 검토하세요."

# /spec-review의 내부 동작
def spec_review():
    # 1. 스펙 파일 찾기
    spec_files = find_specs(".specs/")
    if multiple: ask_which_one()

    # 2. Sub-agent 실행
    result = Task(
        agent="spec-analyzer",
        prompt=f"Review {spec_file} with strict standards"
    )

    # 3. 점수 파싱
    score = parse_score(result)

    # 4. 결과 처리
    if score >= 90:
        create_approval_marker(spec_file)
        return "✅ APPROVED"
    else:
        return "⚠️  NEEDS REVISION" + result.feedback

# /validate의 내부 동작
def validate():
    # 1. 스펙과 구현 매핑
    spec = find_approved_spec()
    impl_files = identify_implementation_files()

    # 2. Sub-agent 실행
    result = Task(
        agent="implementation-validator",
        prompt=f"""
        Spec: {spec}
        Implementation: {impl_files}

        Check:
        - All requirements implemented?
        - Tests cover edge cases?
        - Code quality meets standards?
        """
    )

    # 3. 검증 결과
    score = parse_compliance_score(result)
    timestamp(".specs/.last-validation")

    return result.detailed_report
```

### 실제 실행 흐름 예시

#### 시나리오: 사용자 인증 API 개발

```
┌──────────────────────────── STEP 1: 요청 ─────────────────────────────┐
│ User: JWT 로그인 API 만들어줘                                          │
│                                                                        │
│ [quality-reminder hook 트리거]                                        │
│ 💡 복잡한 요청 감지 (20단어 이상)                                     │
│    → "스펙 작성 권장 (성공률 89% vs 65%)"                             │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 2: /spec-init ───────────────────────┐
│ User: /spec-init                                                       │
│                                                                        │
│ AI: "명확화를 위한 질문입니다"                                        │
│                                                                        │
│ Questions Generated:                                                   │
│  1. 토큰 만료 시간은? (기본: access 15분, refresh 7일)               │
│  2. 소셜 로그인 (Google/GitHub) 포함?                                 │
│  3. 다중 기기 로그인 정책은?                                          │
│  4. 비밀번호 재설정 이메일 발송?                                      │
│  5. Rate limiting 필요? (기본: 분당 5회)                              │
│                                                                        │
│ [User 답변]                                                            │
│  1. 기본값 사용                                                        │
│  2. Google만                                                           │
│  3. 최대 3개 기기                                                      │
│  4. Yes                                                                │
│  5. Yes                                                                │
│                                                                        │
│ [AI: 스펙 생성 중...]                                                  │
│  ✅ .specs/jwt-auth-api-spec.md 생성 완료                             │
│                                                                        │
│  포함 내용:                                                            │
│   - JWT 생성/검증 플로우 다이어그램                                   │
│   - Google OAuth 통합 플로우                                          │
│   - 3-device 세션 관리 전략                                           │
│   - Rate limiter 아키텍처                                             │
│   - 엣지케이스 12개 (동시 로그인, 토큰 탈취, 네트워크 실패 등)       │
│   - 테스트 케이스 23개                                                │
│   - 보안 체크리스트 (OWASP Top 10)                                    │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 3: /spec-review (1차) ───────────────┐
│ User: /spec-review                                                     │
│                                                                        │
│ [Task tool: spec-analyzer agent 실행]                                 │
│                                                                        │
│ Analysis in Progress...                                                │
│  ✓ 아키텍처 다이어그램 확인                                           │
│  ✓ OAuth 플로우 검증                                                  │
│  ✗ Refresh token rotation 상세 미흡                                   │
│  ✗ 3-device 충돌 시나리오 2개 누락                                    │
│  ✓ 보안 체크리스트 완전                                               │
│  ✗ 롤백 전략 없음                                                     │
│                                                                        │
│ ──────────────── Specification Analysis Report ────────────────        │
│                                                                        │
│ 📊 Overall Score: 82/100                                               │
│                                                                        │
│ ✅ Strengths:                                                          │
│  • JWT 구현 플로우 명확 (HS256 vs RS256 비교 포함)                    │
│  • Google OAuth 통합 상세함                                            │
│  • OWASP 보안 고려 우수                                                │
│  • Rate limiter 설계 견고 (Redis 기반 Token Bucket)                   │
│                                                                        │
│ ❌ Critical Gaps:                                                      │
│  • Refresh token rotation 메커니즘 불명확                             │
│    → "어떻게" 회전하는지 단계별 명세 필요                             │
│  • 3-device 시나리오 불완전                                            │
│    → Case: 3개 초과 시 가장 오래된 것 삭제?                           │
│    → Case: 동시에 4번째 로그인 시도 race condition?                   │
│  • 배포 롤백 전략 없음                                                │
│    → DB 마이그레이션 롤백 스크립트                                    │
│    → 이전 버전 토큰 호환성                                            │
│                                                                        │
│ 🔧 Required Improvements (3개 필수):                                   │
│  1. Refresh token rotation 6단계 명세 추가                            │
│  2. 3-device 엣지케이스 2개 + 처리 로직                               │
│  3. 롤백 체크리스트 (DB, 토큰 호환성, 환경변수)                      │
│                                                                        │
│ ⚠️  Recommendation: REQUEST REVISION                                   │
│                                                                        │
│ 점수 90+ 필요. 현재 82/100.                                            │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 4: 보완 ─────────────────────────────┐
│ User: 피드백 3개 항목 반영해줘                                         │
│                                                                        │
│ AI: [스펙 업데이트 중...]                                              │
│                                                                        │
│  Added:                                                                │
│   ✅ Section 3.2.4: Refresh Token Rotation                            │
│      1. 클라이언트가 refresh token 제출                               │
│      2. 서버 유효성 검증                                              │
│      3. 새 access + refresh token 쌍 생성                             │
│      4. 구 refresh token 무효화 (DB blacklist)                        │
│      5. 새 토큰 반환                                                  │
│      6. Rotation 실패 시 모든 세션 무효화 (보안)                      │
│                                                                        │
│   ✅ Section 5.3: 3-Device Edge Cases                                 │
│      Case 1: 4번째 로그인 → 가장 오래된 세션 auto-logout             │
│      Case 2: 동시 4개 시도 → Redis WATCH로 race condition 방지        │
│                                                                        │
│   ✅ Section 4.8: Rollback Strategy                                   │
│      Checklist:                                                        │
│       □ DB down migration 스크립트 준비                               │
│       □ V2 토큰이 V1 검증 통과하도록 호환 레이어                      │
│       □ Feature flag로 점진적 롤아웃                                  │
│       □ 24시간 이내 롤백 가능 (토큰 TTL 내)                           │
│                                                                        │
│  ✅ 업데이트 완료: .specs/jwt-auth-api-spec.md                        │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 5: /spec-review (2차) ───────────────┐
│ User: /spec-review                                                     │
│                                                                        │
│ [spec-analyzer agent 재실행]                                          │
│                                                                        │
│ 📊 Overall Score: 94/100                                               │
│                                                                        │
│ ✅ All Critical Gaps Resolved                                          │
│                                                                        │
│ Minor Suggestion (선택):                                               │
│  • 성능 벤치마크 목표 추가하면 완벽 (+3점)                            │
│    → 예: "로그인 API p95 latency < 200ms"                             │
│                                                                        │
│ ✅ Recommendation: APPROVED FOR IMPLEMENTATION                         │
│                                                                        │
│ 🎉 승인 마커 생성됨:                                                   │
│    .specs/jwt-auth-api-spec.approved.md                               │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 6: 구현 ─────────────────────────────┐
│ User: 이제 구현해줘                                                    │
│                                                                        │
│ [pre-implementation-check hook 실행]                                   │
│  ✓ .specs/ 디렉토리 존재                                              │
│  ✓ jwt-auth-api-spec.approved.md 발견                                 │
│  ✅ 구현 허가                                                          │
│                                                                        │
│ AI: [스펙 기반 구현 시작]                                              │
│                                                                        │
│  Created Files:                                                        │
│   📄 src/auth/jwt.service.ts          (토큰 생성/검증)                │
│   📄 src/auth/oauth.service.ts        (Google OAuth)                  │
│   📄 src/auth/session.service.ts      (3-device 관리)                 │
│   📄 src/auth/rate-limiter.middleware.ts                               │
│   📄 src/auth/auth.controller.ts                                       │
│   📄 tests/auth/jwt.test.ts           (23개 테스트)                   │
│   📄 tests/auth/edge-cases.test.ts    (12개 엣지케이스)               │
│   📄 migrations/001-auth-tables.sql                                    │
│   📄 migrations/rollback/001-down.sql (롤백용)                         │
│                                                                        │
│ [post-edit-validation hook 실행]                                      │
│  📋 Reminder: 구현 완료 후 /validate 실행 필수                        │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 7: /validate ────────────────────────┐
│ User: /validate                                                        │
│                                                                        │
│ [implementation-validator agent 실행]                                  │
│                                                                        │
│ Comparing:                                                             │
│  Spec: .specs/jwt-auth-api-spec.approved.md                           │
│  Impl: src/auth/*.ts, tests/auth/*.test.ts                            │
│                                                                        │
│ ──────────── Implementation Validation Report ─────────────            │
│                                                                        │
│ 📊 Compliance Score: 91/100                                            │
│                                                                        │
│ ✅ Correctly Implemented (37/40 points):                               │
│  • JWT 생성/검증 (HS256, 15min expiry)                                 │
│  • Refresh token rotation (6단계 플로우 정확)                         │
│  • Google OAuth integration                                            │
│  • 3-device session management                                         │
│  • Redis rate limiter (Token Bucket)                                   │
│  • OWASP 보안 체크리스트 10/10 항목                                   │
│  • 롤백 마이그레이션 스크립트                                         │
│                                                                        │
│ ✅ Code Quality (28/30 points):                                        │
│  • TypeScript strict mode ✓                                            │
│  • 에러 핸들링 완전 ✓                                                  │
│  • 명명 규칙 일관성 ✓                                                  │
│  • 주석 적절 ✓                                                         │
│  ⚠️  jwt.service.ts:45 함수 길이 50줄 (권장 30줄) → 리팩토링 고려     │
│                                                                        │
│ ✅ Testing (19/20 points):                                             │
│  • Unit test coverage: 92% (23/25 functions)                           │
│  • Edge cases: 12/12 tested ✓                                          │
│  • Integration tests: 5/5 critical paths ✓                             │
│  ⚠️  Missing: Performance test (p95 latency validation)                │
│                                                                        │
│ ✅ Completeness (10/10 points):                                        │
│  • README 업데이트 ✓                                                   │
│  • API 문서 (Swagger) ✓                                                │
│  • 환경변수 예시 (.env.example) ✓                                     │
│  • 마이그레이션 가이드 ✓                                              │
│                                                                        │
│ 🔧 Recommended Improvements (비차단):                                  │
│  1. jwt.service.ts:45 함수 분리 (가독성)                              │
│  2. 성능 테스트 추가 (스펙에 명시된 < 200ms)                          │
│                                                                        │
│ ✅ Recommendation: ACCEPT                                              │
│                                                                        │
│ 91/100 → 배포 가능 (85+ 기준 통과)                                     │
│ 권장 개선사항은 다음 스프린트에서 처리 가능                            │
│                                                                        │
│ [Timestamp updated: .specs/.last-validation]                           │
└────────────────────────────────────────────────────────────────────────┘
                                ↓
┌──────────────────────────── STEP 8: 배포 준비 완료 ───────────────────┐
│                                                                        │
│  ✅ 스펙 승인 (94/100)                                                 │
│  ✅ 구현 검증 (91/100)                                                 │
│  ✅ 테스트 커버리지 92%                                                │
│  ✅ 보안 체크리스트 완료                                               │
│  ✅ 롤백 전략 준비                                                     │
│                                                                        │
│  🚀 Production Deployment Ready                                        │
│                                                                        │
│  예상 결과 (논문 데이터 기반):                                         │
│   • 첫 배포 성공률: 89%                                                │
│   • 프로덕션 버그 발생률: < 2%                                         │
│   • 이후 수정 필요 확률: 12% (vs 일반 AI 73%)                         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 핵심 차별점 요약

| 측면 | 일반 AI 개발 | Spec-First System |
|------|--------------|-------------------|
| **사고 시간** | 5초 | 10분 (Ultrathink) |
| **초기 속도** | 빠름 (1분) | 느림 (11분) |
| **첫 구현 품질** | 65% 성공 | 89% 성공 |
| **반복 횟수** | 평균 3.2회 | 평균 1.2회 (-61%) |
| **전체 시간** | 1분 + 30분 수정 = 31분 | 11분 + 5분 수정 = 16분 |
| **프로덕션 버그** | 많음 | 82% 감소 |
| **검증 방식** | 수동 (개발자) | 자동 (3-agent) |
| **표준** | "Should work" | "Will work" |

### 방법론적 혁신: "Ultrathink" 강제

```python
# 기존: 빠른 코딩
def quick_code(request):
    understand()  # 5초
    code()        # 1분
    # = 65초
    # 하지만 이후 3번 수정 (30분)

# Spec-First: 깊은 사고
def deep_think_then_code(request):
    understand()                # 5초
    ask_clarifying_questions()  # 2분  ← Ultrathink
    analyze_architecture()      # 3분  ← Ultrathink
    identify_edge_cases()       # 2분  ← Ultrathink
    plan_testing()              # 1분  ← Ultrathink
    document()                  # 2분  ← Ultrathink
    # ← 10분 Ultrathink Zone

    review(min_score=90)        # 자동
    code()                      # 1분
    validate(min_score=85)      # 자동
    # = 11분
    # 이후 1번만 수정 (5분)

# 총 시간: 31분 vs 16분 (48% 절감)
# 품질: 65% vs 89% (+24%p)
```

---

## 설치 및 설정

### 1. 프로젝트에 적용

```bash
# 이 레포지토리를 프로젝트에 복사하거나 클론
cp -r .claude your-project/.claude
cp -r templates your-project/templates

# 또는 프로젝트 내에서 직접 사용
cd your-project
git clone https://github.com/yourusername/ai-spec-based-development-helper.git .ai-spec-helper
ln -s .ai-spec-helper/.claude .claude
ln -s .ai-spec-helper/templates templates
```

### 2. Hooks 실행 권한 부여

```bash
chmod +x .claude/hooks/*.sh
```

### 3. Claude Code에서 확인

```bash
# Hooks 확인
claude # Claude Code 실행 후
# 자동으로 hooks.json이 로드됨

# Sub-agents 확인
/agents
# spec-analyzer, architecture-reviewer, implementation-validator가 표시되어야 함

# Commands 확인
/spec-<TAB>
# spec-init, spec-review, spec-status 자동완성 확인
```

### 4. 새 프로젝트 시작 (workspaces/)

이 레포지토리를 직접 사용하여 새 프로젝트 개발:

#### CLI 사용 (추천 ⭐)

```bash
# Node.js 프로젝트
pnpm run new my-app

# Python 프로젝트
pnpm run new ml-service --type python

# Rust 프로젝트
pnpm run new game-engine --type rust

# 프로젝트로 이동
cd workspaces/my-app

# Claude Code 실행
claude

# 스펙 작성
/spec-init
```

**자동으로 생성되는 것**:
- ✅ `.claude/` → 심볼릭 링크 (Sub-agents, Hooks, Commands)
- ✅ `templates/` → 심볼릭 링크
- ✅ `.specs/` → 독립 디렉토리
- ✅ `README.md`, `.gitignore`
- ✅ `package.json/pyproject.toml/Cargo.toml` (타입별 자동 초기화)

#### 수동 설정

```bash
# 1. 프로젝트 디렉토리 생성
mkdir -p workspaces/my-project
cd workspaces/my-project

# 2. 심볼릭 링크 생성 (중요!)
ln -s ../../.claude .claude
ln -s ../../templates templates
mkdir .specs

# 3. Claude Code 실행
claude

# 4. 스펙 작성
/spec-init
```

**중요**: Claude Code는 **상위 디렉토리를 자동 탐색하지 않습니다**. 반드시 **심볼릭 링크**를 생성해야 합니다!

**참고**:
- CLI 도움말: `pnpm run new --help`
- 전역 설치: `pnpm link` → 어디서든 `spec-init-project` 사용
- 상세 가이드: [workspaces/README.md](workspaces/README.md)

---

## 사용 워크플로우

### 완전한 개발 사이클

```
1. 기능 요청 받음
   ↓
2. /spec-init 실행
   → 포괄적인 스펙 문서 작성
   → 아키텍처 다이어그램, 요구사항, 엣지케이스 등 포함
   ↓
3. /spec-review 실행
   → spec-analyzer가 점수 부여 (90점 이상 목표)
   → 부족한 부분 피드백 받고 보완
   ↓
4. /arch-review 실행 (선택사항, 복잡한 시스템)
   → architecture-reviewer가 설계 검토
   → 리스크 및 개선사항 확인
   ↓
5. 구현 시작
   → pre-implementation-check hook이 스펙 존재 확인
   → 승인된 스펙 있으면 진행
   ↓
6. /validate 실행
   → implementation-validator가 스펙 준수 검증
   → 테스트 커버리지 및 코드 품질 확인
   ↓
7. 85점 이상이면 배포 준비 완료
```

---

## 예제

### 시나리오: 사용자 인증 기능 개발

#### 1단계: 스펙 초기화

```
User: 사용자 로그인/로그아웃 기능을 추가하고 싶어요

Claude: /spec-init를 실행하겠습니다.

[spec-analyzer가 질문 시작]
- 어떤 인증 방식을 사용하시나요? (JWT, Session, OAuth?)
- 소셜 로그인이 필요하나요?
- 비밀번호 재설정 기능도 포함하나요?
- 다중 기기 로그인을 허용하나요?

[사용자 답변 후 .specs/user-authentication-spec.md 생성]
```

#### 2단계: 스펙 리뷰

```
User: /spec-review

Claude: [spec-analyzer 에이전트 실행]

## Specification Analysis Report

**Overall Score**: 85/100

### Strengths
- 명확한 JWT 인증 플로우
- 보안 고려사항 잘 정의됨
- 테스트 케이스 포괄적

### Critical Gaps
- 토큰 갱신 전략 미정의
- 동시 로그인 처리 엣지케이스 누락
- 에러 핸들링 시나리오 불충분

### Required Improvements
1. Refresh token 전략 추가 (만료 시간, 저장 위치)
2. 동시 로그인 시나리오 3가지 추가
3. 네트워크 실패 시 재시도 로직 명세

### Recommendation
REQUEST REVISION - 위 항목 보완 후 재검토
```

#### 3단계: 스펙 보완 및 재검토

```
User: [피드백 반영하여 스펙 업데이트]

User: /spec-review

Claude: [spec-analyzer 재실행]

**Overall Score**: 93/100

### Recommendation
APPROVE for implementation ✅

.specs/user-authentication-spec.approved.md 생성됨
```

#### 4단계: 구현

```
User: 이제 구현해줘

Claude: [pre-implementation-check hook 통과]
✅ 승인된 스펙 발견: user-authentication-spec.approved.md

[구현 진행...]

[post-edit-validation hook]
📋 Reminder: 구현 완료 후 /validate 실행하세요
```

#### 5단계: 검증

```
User: /validate

Claude: [implementation-validator 실행]

## Implementation Validation Report

**Compliance Score**: 88/100

### ✅ Correctly Implemented
- JWT 생성 및 검증 로직
- 비밀번호 해싱 (bcrypt)
- 토큰 갱신 엔드포인트
- 에러 핸들링

### ⚠️ Test Coverage Analysis
- Unit tests: 18/20 requirements covered (90%)
- Edge cases: 5/7 scenarios tested (71%)
- Missing tests for:
  - 동시 로그인 충돌
  - 만료된 refresh token 처리

### Required Fixes
1. [Priority 2] 누락된 테스트 케이스 2개 추가

### Recommendation
REQUEST REVISION - 테스트 추가 후 재검증
```

---

## 프로젝트 구조

```
.
├── .claude/
│   ├── agents/                    # Sub-agents 정의
│   │   ├── spec-analyzer.md
│   │   ├── architecture-reviewer.md
│   │   └── implementation-validator.md
│   ├── commands/                  # 슬래시 커맨드
│   │   ├── spec-init.md
│   │   ├── spec-review.md
│   │   ├── arch-review.md
│   │   ├── validate.md
│   │   └── spec-status.md
│   ├── hooks/                     # 훅 스크립트
│   │   ├── pre-implementation-check.sh
│   │   ├── post-edit-validation.sh
│   │   └── quality-reminder.sh
│   └── hooks.json                 # 훅 설정
├── templates/                     # 스펙 템플릿
│   ├── feature-spec-template.md
│   └── api-spec-template.md
└── README.md                      # 이 파일
```

### 런타임 생성 파일 (프로젝트별)

```
your-project/
├── .specs/                        # 스펙 저장소
│   ├── feature-name-spec.md       # Draft 스펙
│   ├── feature-name-spec.approved.md  # 승인된 스펙 (90+점)
│   ├── .last-validation           # 마지막 검증 타임스탬프
│   └── .bypass                    # 임시 우회 플래그 (비권장)
└── [구현 파일들]
```

---

## 설정 커스터마이징

### Hooks 활성화/비활성화

`.claude/hooks.json` 편집:

```json
{
  "hooks": [
    {
      "name": "pre-implementation-check",
      "enabled": true,        // false로 변경하여 비활성화
      "blocking": true        // false면 경고만, true면 차단
    }
  ]
}
```

### 스펙 점수 임계값 조정

Sub-agents 파일 편집 (예: `.claude/agents/spec-analyzer.md`):

```markdown
## Scoring System
- **85-100**: Excellent - Ready for implementation  # 90에서 85로 낮춤
- **70-84**: Good - Minor improvements needed
- **50-69**: Fair - Significant gaps exist
- **Below 50**: Incomplete - Requires major revision
```

### 템플릿 커스터마이징

`templates/` 디렉토리에 팀/프로젝트 특화 템플릿 추가:

```bash
cp templates/feature-spec-template.md templates/microservice-spec-template.md
# 마이크로서비스용 섹션 추가 (서비스 디스커버리, API Gateway 등)
```

---

## 고급 활용

### Headless 모드로 자동화

CI/CD 파이프라인에 스펙 검증 통합:

```bash
# 스펙 자동 검증
claude -p "/spec-review" --output-format json > spec-report.json

# 점수 파싱 및 실패 조건 체크
SCORE=$(jq '.score' spec-report.json)
if [ "$SCORE" -lt 90 ]; then
  echo "Spec quality insufficient: $SCORE/100"
  exit 1
fi
```

### MCP Server 통합

스펙 저장소를 데이터베이스에 연결:

```json
// .claude/mcp-servers.json
{
  "mcpServers": {
    "spec-storage": {
      "command": "npx",
      "args": ["-y", "@your-org/spec-storage-mcp-server"],
      "env": {
        "DATABASE_URL": "postgresql://..."
      }
    }
  }
}
```

### 플러그인으로 패키징

팀 전체 배포를 위한 플러그인 생성:

```json
// .claude-plugin/plugin.json
{
  "name": "spec-first-dev",
  "version": "1.0.0",
  "description": "Specification-First Development Toolkit",
  "commands": [
    ".claude/commands/spec-init.md",
    ".claude/commands/spec-review.md"
  ],
  "agents": [
    ".claude/agents/spec-analyzer.md",
    ".claude/agents/architecture-reviewer.md"
  ],
  "hooks": ".claude/hooks.json"
}
```

---

## 모범 사례

### ✅ DO

1. **항상 스펙부터 시작**: 복잡한 기능은 반드시 `/spec-init`
2. **Ultrathink 강제**: 빠른 코딩보다 깊은 사고 우선
3. **엄격한 리뷰**: 90점 이상만 승인
4. **검증 습관화**: 모든 구현 후 `/validate` 실행
5. **엣지케이스 문서화**: "이럴 리 없어"는 금물
6. **근거 요구**: 기술 선택, 아키텍처 결정에 "왜?"

### ❌ DON'T

1. **스펙 건너뛰기**: "간단해 보여서" 바로 코딩
2. **낮은 점수 무시**: 70점대도 "괜찮다"고 넘어가기
3. **피드백 일부만 반영**: 모든 Critical Gaps 해결 필수
4. **테스트 생략**: "나중에 추가"는 거의 안 함
5. **Bypass 남발**: `.specs/.bypass`는 긴급 상황만
6. **"작동할 것" 수용**: "작동할 것이다" 수준만 승인

---

## FAQ

### Q: 모든 기능에 스펙이 필요한가요?

**A**: 아니요. 가이드라인:
- **스펙 필요**: 20단어 이상 설명 필요, 여러 파일 수정, 아키텍처 영향
- **스펙 선택**: 중간 복잡도, 엣지케이스 많음
- **스펙 불필요**: 한 줄 버그 픽스, 변수명 변경, 포맷팅

### Q: AI가 스펙 작성을 거부하면?

**A**: `quality-reminder` hook이 비차단 모드이므로 경고만 표시됩니다. 하지만 나중에 문제가 생기면:
1. 반복 작업 증가 (61% more iterations without spec)
2. 프로덕션 인시던트 리스크 증가
3. 근본 원인: 깊은 이해 부족

### Q: 레거시 프로젝트에도 적용 가능한가요?

**A**: 네, 점진적 도입 권장:
1. **Week 1**: Hooks만 활성화 (경고 모드)
2. **Week 2**: 새 기능만 `/spec-init` 사용
3. **Week 3**: 리팩토링 작업에도 스펙 적용
4. **Week 4+**: 모든 작업에 Specification-First

### Q: 팀원들이 "너무 느리다"고 하면?

**A**: 데이터로 설득:
- **초기**: 20% 더 느림 (스펙 작성 시간)
- **중기**: 40% 빠름 (재작업 감소)
- **장기**: 4배 빠름 (반복 작업 61% 감소)

"Slow is smooth, smooth is fast"

### Q: 점수가 항상 60점대에 머물러요

**A**: 흔한 누락 사항 체크리스트:
- [ ] 아키텍처 다이어그램 있나요?
- [ ] 엣지케이스 5개 이상 나열했나요?
- [ ] 각 요구사항에 테스트 케이스가 있나요?
- [ ] 롤백 전략을 정의했나요?
- [ ] 코드 예제를 포함했나요?
- [ ] 성공 메트릭을 지정했나요?

---

## 기여하기

이 프로젝트를 개선하고 싶으신가요?

1. Fork 후 브랜치 생성
2. **중요**: 변경 사항에 대한 스펙 작성 (`/spec-init`)
3. 스펙 리뷰 통과 (`/spec-review` → 90+)
4. 구현 후 검증 (`/validate` → 85+)
5. Pull Request 제출

**메타**: 이 프로젝트는 자기 자신의 방법론을 사용합니다!

---

## 라이선스

MIT License

---

## 참고 자료

- [원본 논문: Supervising an AI Engineer](https://techtrenches.substack.com/p/supervising-an-ai-engineer-lessons)
- [Claude Code 문서](https://docs.claude.com/en/docs/claude-code)
  - [Sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents)
  - [Hooks](https://docs.claude.com/en/docs/claude-code/hooks-guide)
  - [Headless Mode](https://docs.claude.com/en/docs/claude-code/headless)
  - [MCP](https://docs.claude.com/en/docs/claude-code/mcp)
  - [Plugins](https://docs.claude.com/en/docs/claude-code/plugins)

---

## 연락처

문제 발생 시 Issue 생성하거나 Discussions에 질문해주세요.

**Remember**: "Reason before you type" 🧠 → ⌨️

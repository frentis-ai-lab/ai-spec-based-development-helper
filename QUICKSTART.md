# 빠른 시작 가이드 - AI Specification-Based Development Helper

> **"Reason before you type"** - 코드 작성 전에 깊이 생각하라

AI가 무작정 코딩하는 것을 막고, **스펙 작성 → 검토 → 구현 → 테스트 → 검증** 순서를 강제하는 개발 도구입니다.

---

## 📦 설치 (3가지 방법)

### 방법 1: 기존 프로젝트에 적용 ⭐ 추천

**원격 설치 (한 줄)**:
```bash
cd your-project
curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash
```

**로컬 설치**:
```bash
# 1. 레포지토리 클론
git clone https://github.com/frentis-ai-lab/ai-spec-based-development-helper.git

# 2. 설치 스크립트 실행
cd ai-spec-based-development-helper
./scripts/install.sh /path/to/your-project

# 3. Claude Code 실행
cd /path/to/your-project
claude
```

**설치 스크립트가 하는 일**:
- ✅ `.claude/` 디렉토리 복사 (실제 파일, 심볼릭 링크 아님)
- ✅ `templates/` 디렉토리 복사
- ✅ `.specs/` 디렉토리 생성
- ✅ Hook 실행 권한 설정
- ✅ `.gitignore` 자동 업데이트

**기존 프로젝트 업데이트**:
```bash
# 이미 설치된 프로젝트를 최신 버전으로 업데이트
cd your-project
curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash -s -- --update

# 또는 로컬에서
./scripts/install.sh /path/to/your-project --update
```

**--update 플래그 특징**:
- ✅ `.claude/`, `templates/` 자동 덮어쓰기 (확인 없음)
- ✅ `.specs/` 디렉토리 보존 (작업물 안전)
- ✅ 빠른 업데이트 (프롬프트 없음)

### 방법 2: 새 프로젝트 (workspaces 사용)

이 레포지토리를 직접 사용하여 새 프로젝트 개발:

```bash
cd ai-spec-based-development-helper

# Fullstack 프로젝트
pnpm run new my-app

# Backend만
pnpm run new my-api --structure backend

# Frontend만
pnpm run new my-web --structure frontend

# 프로젝트로 이동
cd workspaces/my-app
claude
```

**자동으로 생성되는 것**:
- ✅ `.claude/` → 심볼릭 링크 (이 레포 개발 시 유용)
- ✅ `templates/` → 심볼릭 링크
- ✅ `.specs/` → 독립 디렉토리 + 3개 스펙 템플릿
- ✅ `README.md`, `.gitignore`, `package.json`

### 방법 3: 수동 설치 (고급)

```bash
# .claude/, templates/ 파일을 직접 복사
cp -r /path/to/repo/.claude your-project/.claude
cp -r /path/to/repo/templates your-project/templates
mkdir your-project/.specs
chmod +x your-project/.claude/hooks/*.sh
```

---

## 🚀 기본 워크플로우 (6단계)

```
┌─────────────────────────────────────────────┐
│ 1. 요구사항 받기                             │
├─────────────────────────────────────────────┤
│ User: "사용자 로그인 API 만들어줘"           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. /spec-init - 스펙 작성                   │
├─────────────────────────────────────────────┤
│ AI가 5-10개 질문 → 답변                     │
│ 3개 파일 생성:                              │
│  - program-spec.md (시스템 전체)            │
│  - api-spec.md (API 설계)                   │
│  - ui-ux-spec.md (UI/UX) *frontend만*       │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. /spec-review - 스펙 검증 (90점 목표)     │
├─────────────────────────────────────────────┤
│ 점수 < 90 → 피드백 반영 → 재검토            │
│ 점수 ≥ 90 → ✅ .approved.md 생성            │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 4. 구현 - AI가 코드 작성                     │
├─────────────────────────────────────────────┤
│ Hook이 자동으로 스펙 확인                    │
│ 승인된 스펙 있어야 진행 가능                 │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 5. /test - 자동 테스트 (85% 커버리지 목표)  │
├─────────────────────────────────────────────┤
│ 스펙 기반 테스트 자동 생성                   │
│ 실행 후 리포트 생성                          │
│ 커버리지 < 85% → 테스트 추가                 │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 6. /validate - 최종 검증 (85점 목표)         │
├─────────────────────────────────────────────┤
│ 스펙 준수 여부 검증                          │
│ 점수 < 85 → 수정 → 재검증                   │
│ 점수 ≥ 85 → 🚀 배포 준비 완료               │
└─────────────────────────────────────────────┘
```

---

## 💬 실전 대화 예시

### 1단계: 요구사항 전달

```
You: JWT 로그인 API 만들어줘
```

### 2단계: 스펙 초기화

```
You: /spec-init

AI: 명확화 질문입니다:
    1. 토큰 만료 시간? (기본: 15분/7일)
    2. 소셜 로그인 포함? (Google/GitHub?)
    3. 다중 기기 로그인 정책?
    4. 비밀번호 재설정 이메일?
    5. Rate limiting? (기본: 분당 5회)

You: 1. 기본값, 2. Google만, 3. 최대 3개 기기, 4. Yes, 5. Yes

AI: ✅ 스펙 생성 완료:
    - .specs/program-spec.md
    - .specs/api-spec.md

    다음: /spec-review로 검토하세요
```

### 3단계: 스펙 검토

```
You: /spec-review

AI: 📊 분석 결과:

    Overall Score: 85/100

    Critical Gaps:
    - Refresh token rotation 전략 미정의
    - 3-device 엣지케이스 2개 누락
    - 롤백 전략 없음

    ⚠️  REQUEST REVISION

    위 3개 보완 후 재검토하세요

You: 피드백 반영해줘

AI: [스펙 업데이트...]
    ✅ 완료

You: /spec-review

AI: 📊 Overall Score: 93/100

    ✅ APPROVED
    .specs/api-spec.approved.md 생성

    다음: 구현을 시작하세요
```

### 4단계: 구현

```
You: 이제 구현해줘

AI: [Hook 확인: ✅ 승인된 스펙 발견]

    [구현 중...]

    ✅ 생성된 파일:
    - src/auth/jwt.service.ts
    - src/auth/oauth.service.ts
    - src/auth/session.service.ts
    - tests/auth/jwt.test.ts (10개 테스트)

    다음: /test로 테스트 실행하세요
```

### 5단계: 테스트

```
You: /test

AI: Phase 1: Analysis
    - TypeScript backend 감지
    - 기존 테스트 10개 (커버리지 65%)

    Phase 2: Generation
    - 5개 엣지케이스 누락 감지
    - 테스트 생성 중...

    Phase 3: Execution
    - 15 passed, 0 failed
    - 새 커버리지: 88%

    ✅ All tests passing!
    ✅ Coverage: 88% (목표 85% 초과)

    다음: /validate 실행하세요
```

### 6단계: 최종 검증

```
You: /validate

AI: Compliance Score: 91/100

    ✅ Correctly Implemented:
    - JWT 생성/검증 ✓
    - Google OAuth ✓
    - 3-device 관리 ✓
    - Rate limiting ✓

    ✅ Code Quality: 28/30
    ✅ Test Coverage: 88% (19/20)
    ✅ Completeness: 10/10

    ✅ ACCEPT - 배포 준비 완료

    🚀 Production Deployment Ready
```

---

## 🛠️ 주요 명령어

| 명령어 | 사용 시점 | 목적 |
|--------|----------|------|
| `/spec-init` | 새 기능 시작 | 3-file 스펙 생성 |
| `/spec-review` | 스펙 작성 후 | 90점+ 점수 확보 |
| `/arch-review` | 복잡한 설계 시 | 아키텍처 검토 (선택) |
| **구현** | 스펙 승인 후 | AI가 코드 작성 |
| `/test` | 구현 후 | 자동 테스트 + 커버리지 |
| `/validate` | 테스트 후 | 85점+ 최종 검증 |
| `/spec-status` | 언제든 | 현재 상태 확인 |

---

## 📋 3-File Spec 구조

프로젝트 타입별로 필요한 스펙 파일:

| 프로젝트 타입 | 필요한 스펙 파일 |
|--------------|-----------------|
| **Backend** | program-spec.md + api-spec.md |
| **Frontend** | program-spec.md + ui-ux-spec.md |
| **Fullstack** | program-spec.md + api-spec.md + ui-ux-spec.md |

**각 파일 역할**:
- `program-spec.md`: 시스템 전체 아키텍처, 데이터 모델
- `api-spec.md`: API 엔드포인트, 인증, 데이터 스키마
- `ui-ux-spec.md`: UI 컴포넌트, 사용자 플로우, 디자인

---

## ⚡ 빠른 팁

### ✅ DO

1. **항상 스펙부터 시작** - 복잡한 기능은 `/spec-init`
2. **90점 이상 확보** - 스펙 품질 타협 금지
3. **테스트 자동화 활용** - `/test`로 커버리지 85%+
4. **검증 필수** - `/validate`로 최종 확인

### ❌ DON'T

1. **스펙 건너뛰기** - Hook이 차단함
2. **낮은 점수 무시** - 70점대는 재작성
3. **테스트 생략** - 프로덕션 버그 위험 82% 증가
4. **긴급 우회 남발** - `.bypass` 플래그는 비상용만

---

## 🎓 20초 요약

```bash
# 1. 프로젝트 생성
pnpm run new my-app

# 2. Claude Code 실행
cd workspaces/my-app
claude

# 3. 개발 시작
/spec-init           # 스펙 작성
/spec-review         # 검토 (90+ 목표)
"구현해줘"           # 코드 작성
/test                # 테스트 (85%+ 목표)
/validate            # 검증 (85+ 목표)
# 🚀 배포!
```

**핵심**: Think 10분 → Code 5분 = 반복 작업 -61%, 버그 -82% 🎯

---

## 💡 문제 해결

### "스펙 없이 코딩하고 싶어요"

→ Trivial한 작업(변수명, 포맷팅)만 가능. 20단어 이상 설명 필요하면 스펙 필수.

### "Hook이 차단해요"

→ `.specs/` 디렉토리 없음. `/spec-init` 먼저 실행.

### "점수가 계속 낮아요"

→ 체크리스트:
- [ ] 아키텍처 다이어그램 있나요?
- [ ] 엣지케이스 5개 이상 나열했나요?
- [ ] 롤백 전략을 정의했나요?
- [ ] 테스트 케이스 10개 이상 있나요?
- [ ] 성능 요구사항이 구체적인가요? (예: "p95 < 200ms")

### "테스트 커버리지가 안 올라가요"

→ `.test-reports/*/summary.md` 확인 → 누락된 엣지케이스 테스트 추가

### "AI가 스펙 작성을 거부해요"

→ 경고만 표시되고 진행은 가능. 하지만 나중에:
- 반복 작업 61% 증가
- 프로덕션 버그 발생률 증가
- 근본 원인: 깊은 이해 부족

### "팀원들이 '너무 느리다'고 해요"

→ 데이터로 설득:
- **초기**: 20% 더 느림 (스펙 작성 시간)
- **중기**: 40% 빠름 (재작업 감소)
- **장기**: 4배 빠름 (반복 작업 61% 감소)

"Slow is smooth, smooth is fast"

---

## 📊 기대 효과

| 메트릭 | 개선 |
|--------|------|
| 배포 성공률 | 65% → 89% (+24%p) |
| 반복 작업 | -61% |
| 프로덕션 버그 | -82% |
| 평균 배송 시간 | 4배 빠름 |
| 테스트 커버리지 | +30%p |

---

## 📚 더 알아보기

- **전체 문서**: [README.md](README.md)
- **개발 규칙 상세**: [CLAUDE.md](CLAUDE.md)
- **워크스페이스 가이드**: [workspaces/README.md](workspaces/README.md)
- **템플릿 예시**: `templates/` 디렉토리

---

## 🆘 도움말

문제가 발생하면:
1. [GitHub Issues](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/issues)
2. [Discussions](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/discussions)

---

**Remember**: "Reason before you type" 🧠 → ⌨️

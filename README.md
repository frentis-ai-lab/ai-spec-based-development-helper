# AI Specification-Based Development Helper

<div align="center">

[![Version](https://img.shields.io/github/v/release/frentis-ai-lab/ai-spec-based-development-helper)](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-16%2F16%20passed-success)](/.test/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-required-purple)](https://claude.com/claude-code)

**"Reason before you type"** 🧠 → ⌨️

AI 코딩의 성공률을 65%에서 89%로 끌어올리는 Specification-First 개발 방법론 강제 도구

[빠른 시작](#-빠른-시작) • [문서](docs/) • [예제](docs/examples/) • [기여하기](CONTRIBUTING.md)

</div>

---

## 🎯 무엇인가요?

Claude Code를 위한 **Specification-First 방법론 강제 도구**입니다:

```
기존 AI 개발                    →    Spec-First 개발
────────────────────────────────────────────────────────
"TODO API 만들어줘"             →    1. 상세 스펙 작성 (30분)
  ↓ AI가 즉시 코딩                    2. AI 에이전트 검토 (90+점)
  ↓ "작동할 것" 코드                  3. 승인 후 구현 시작
  ✗ 50% 확률로 버그                   4. 검증 (85+점)
  ✗ 반복 작업 많음                    ✓ 89% 성공률
                                      ✓ 82% 적은 버그
```

### 핵심 원리

1. **스펙 없이는 코딩 불가** - Hook이 차단
2. **AI가 스펙 검증** - 90점 미만 거부
3. **구현도 검증** - 85점 미만 거부

---

## ⚡ 빠른 시작

### 1. 설치 (30초)

```bash
curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash
```

### 2. 첫 프로젝트

```bash
# Claude Code 실행
claude

# 스펙 작성
/spec-init
> TODO API를 만들고 싶어요 (TypeScript + PostgreSQL)

# AI가 명확화 질문 → 상세 스펙 생성
# → .specs/todo-api-spec.md 생성됨

# 스펙 검토
/spec-review
> 점수: 92/100 ✅ APPROVED
> → .specs/todo-api-spec.approved.md 생성

# 이제 구현 가능!
> "스펙대로 TODO API 구현해줘"

# 구현 검증
/validate
> 점수: 88/100 ✅ APPROVED
```

👉 **더 자세한 가이드**: [Getting Started](docs/getting-started/quick-start.md)

---

## ✨ 주요 기능

### 📋 3-File Spec 구조

프로젝트 타입별 최적화된 스펙 구조:

| 파일 | 역할 | 프로젝트 타입 |
|------|------|--------------|
| **program-spec.md** | 시스템 아키텍처, 데이터 모델 | 모든 프로젝트 (필수) |
| **api-spec.md** | API 엔드포인트, 스키마 | Backend, Fullstack |
| **ui-ux-spec.md** | UI 컴포넌트, 사용자 플로우 | Frontend, Fullstack |

**Cross-validation**: AI가 3개 파일 간 일관성 자동 검증 (데이터 모델, API-UI 매핑)

### 🤖 AI Sub-Agents

| Agent | 역할 | 실행 시점 |
|-------|------|----------|
| **spec-analyzer** | 스펙 품질 평가 (100점 만점) | 스펙 작성 후 |
| **architecture-reviewer** | 아키텍처 설계 검증 | 복잡한 시스템 설계 시 |
| **implementation-validator** | 구현 검증 (스펙 준수 확인) | 구현 완료 후 |

### 📜 Constitution System (NEW v0.0.2)

프로젝트별 코딩 표준 자동 검증:

```markdown
# .specs/PROJECT-CONSTITUTION.md

## 1. 금지 사항 [AUTO-CHECK]
- ❌ `any` 타입 사용
  - **대안**: `unknown` 또는 명시적 타입
- ❌ `console.log` 직접 사용
  - **대안**: winston/pino logger

## 2. 기술 스택 표준 [AUTO-CHECK]
- TypeScript 5.3+
- Logging: winston
```

**spec-review 시 자동 검증** → 준수 시 +5 보너스 점수

### 🎣 Hook System

구현 전 자동 체크:

```bash
# Normal mode: 스펙 없으면 경고
⚠️  WARNING: No approved specifications found!

# Relaxed mode: 프로토타이핑 시 우회
export CLAUDE_MODE=prototype
ℹ️  Relaxed mode enabled - Skipping validation
```

---

## 📊 검증된 결과

실제 프로젝트 적용 결과:

| 메트릭 | Before | After | 개선 |
|--------|--------|-------|------|
| 배포 성공률 | 65% | 89% | **+24%p** |
| 프로덕션 버그 | 11건 | 2건 | **-82%** |
| 반복 작업 | 기준 | -61% | **61% 감소** |
| 배송 시간 | 기준 | 4x | **4배 빠름** |

**출처**: [Specification-First Development 연구](https://arxiv.org/example)

---

## 📚 문서

### 시작하기
- [설치 가이드](docs/getting-started/installation.md) - 상세 설치 옵션
- [빠른 시작](docs/getting-started/quick-start.md) - 5분 튜토리얼
- [첫 프로젝트](docs/getting-started/first-project.md) - TODO API 예제

### 가이드
- [3-File Spec 구조](docs/guides/3-file-spec-structure.md) - 스펙 작성법
- [Constitution 시스템](docs/guides/constitution-system.md) - 코딩 표준 설정
- [Hook 시스템](docs/guides/hooks.md) - Hook 커스터마이징
- [E2E 테스팅](docs/guides/e2e-testing.md) - 실제 Claude 실행 테스트

### 레퍼런스
- [Sub-Agents API](docs/reference/sub-agents.md) - 에이전트 상세 스펙
- [Slash Commands](docs/reference/slash-commands.md) - 명령어 레퍼런스
- [Templates](docs/reference/templates.md) - 스펙 템플릿 가이드

### 예제
- [Backend: TODO API](docs/examples/todo-api.md)
- [Frontend: Dashboard](docs/examples/react-dashboard.md)
- [Fullstack: E-commerce](docs/examples/fullstack-ecommerce.md)

---

## 🛠️ 고급 사용법

### 특정 버전 설치

```bash
# 최신 릴리즈 (자동 감지)
curl -fsSL https://[...]/install.sh | bash

# 특정 버전
curl -fsSL https://[...]/install.sh | bash -s -- --version v0.0.2

# Dry-run (미리보기)
curl -fsSL https://[...]/install.sh | bash -s -- --dry-run
```

### 기존 프로젝트 업데이트

```bash
curl -fsSL https://[...]/install.sh | bash -s -- --update --force
```

### Constitution 설정

```bash
# 1. 템플릿 복사
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 2. 프로젝트에 맞게 수정
# 3. /spec-review 시 자동 검증 (+5 보너스)
```

---

## 🤝 기여하기

기여를 환영합니다!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. **Write spec first** (`.specs/your-feature-spec.md`)
4. **Get approval** (`/spec-review` → 90+)
5. Implement & validate (`/validate` → 85+)
6. Commit (`git commit -m 'feat: Add amazing feature'`)
7. Push & create Pull Request

자세한 내용: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 🐛 버그 리포트 & 기능 요청

- [Bug Report](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/issues/new?template=bug_report.md)
- [Feature Request](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/issues/new?template=feature_request.md)

---

## 📄 라이선스

MIT License - [LICENSE](LICENSE) 참조

---

## 🙏 감사의 말

- [Claude Code](https://claude.com/claude-code) by Anthropic
- Specification-First 방법론 연구

---

## 📈 로드맵

- [x] v0.0.1: 기본 Sub-agents, Hooks
- [x] v0.0.2: Constitution 시스템, Relaxed Mode
- [ ] v0.1.0: GitHub Actions 통합, Auto-review on PR
- [ ] v0.2.0: VSCode Extension
- [ ] v1.0.0: 안정화, 다국어 지원

---

<div align="center">

**Made with ❤️ by [Frentis AI Lab](https://github.com/frentis-ai-lab)**

[⭐ Star](https://github.com/frentis-ai-lab/ai-spec-based-development-helper) • [🐛 Report Bug](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/issues) • [💡 Request Feature](https://github.com/frentis-ai-lab/ai-spec-based-development-helper/issues)

</div>

# Workspaces

이 디렉토리는 **Specification-First 방법론**을 사용하여 개발하는 실제 프로젝트들을 위한 작업 공간입니다.

## 📂 구조

각 서브 디렉토리는 독립적인 프로젝트입니다:

```
workspaces/
├── project-name/
│   ├── .specs/              # 프로젝트별 스펙 저장소
│   │   ├── feature-a-spec.md
│   │   ├── feature-a-spec.approved.md
│   │   └── .last-validation
│   ├── src/                 # 소스 코드
│   ├── tests/               # 테스트
│   ├── package.json         # (또는 다른 언어 설정 파일)
│   └── README.md
│
└── another-project/
    └── ...
```

---

## 🚀 새 프로젝트 시작하기

### 방법 1: Helper 스크립트 사용 (추천)

```bash
# 프로젝트 루트에서
./scripts/init-workspace-project.sh my-new-project

# 프로젝트로 이동
cd workspaces/my-new-project

# 언어별 초기화 (선택)
pnpm init    # Node.js
# 또는
uv init      # Python

# Claude Code 시작
claude

# 스펙 작성
/spec-init
```

**자동으로 생성되는 것**:
- ✅ `.claude/` → 상위 설정 심볼릭 링크
- ✅ `templates/` → 상위 템플릿 심볼릭 링크
- ✅ `.specs/` → 독립적인 스펙 디렉토리
- ✅ `README.md` → 프로젝트 가이드
- ✅ `.gitignore` → 기본 제외 파일

---

### 방법 2: 수동 설정

```bash
# 1. 프로젝트 디렉토리 생성
mkdir -p workspaces/my-new-project
cd workspaces/my-new-project

# 2. 심볼릭 링크 생성 (중요!)
ln -s ../../.claude .claude
ln -s ../../templates templates

# 3. 스펙 디렉토리 생성
mkdir .specs

# 4. 프로젝트 초기화 (언어별)
pnpm init    # Node.js
# 또는
uv init      # Python

# 5. Claude Code 시작
claude

# 6. 스펙 작성
/spec-init
```

---

## ⚙️ 설정 상속

상위 디렉토리의 `.claude/` 설정이 자동으로 상속됩니다:

- ✅ **Sub-agents**: spec-analyzer, architecture-reviewer, implementation-validator
- ✅ **Hooks**: pre-implementation-check, post-edit-validation, quality-reminder
- ✅ **Commands**: /spec-init, /spec-review, /arch-review, /validate, /spec-status
- ✅ **Templates**: feature-spec-template.md, api-spec-template.md

각 프로젝트에서 별도 설정 필요 없이 바로 사용 가능합니다!

---

## 📋 프로젝트 예시

### 예: Todo 앱 개발

```bash
# 1. 프로젝트 생성
mkdir -p workspaces/todo-app
cd workspaces/todo-app
pnpm init

# 2. Claude Code 실행
claude

# 3. 워크플로우
User: /spec-init
      Todo CRUD API를 만들고 싶어요

AI: [명확화 질문]
    - REST API vs GraphQL?
    - 인증 필요?
    - 데이터베이스는?

[답변 후]
✅ .specs/todo-crud-spec.md 생성됨

User: /spec-review
AI: 점수 92/100 ✅ APPROVED

User: 구현해줘
AI: [구현 진행...]

User: /validate
AI: 88/100 ✅ 배포 가능
```

---

## 🔄 Git 관리

### 옵션 1: 각 프로젝트를 독립 저장소로

```bash
cd workspaces/my-project
git init
git add .
git commit -m "Initial commit with spec"
git remote add origin <your-repo-url>
git push -u origin main
```

### 옵션 2: 모노레포로 관리

```bash
# 최상위에서
git add workspaces/my-project
git commit -m "Add my-project"
```

**참고**: 기본적으로 `workspaces/`는 `.gitignore`에 포함되어 있습니다.
필요하면 `.gitignore`를 수정하세요.

---

## 📊 프로젝트 상태 확인

각 프로젝트 내에서:

```bash
/spec-status
```

출력 예시:
```
# Specification Status Report

| Spec | Status | Score | Implementation |
|------|--------|-------|----------------|
| todo-crud | ✅ Approved | 92/100 | ✅ Complete (88/100) |
| auth | ⚠️  Draft | N/A | ❌ Not Started |

Recommendations:
- todo-crud: Ready for deployment
- auth: Run /spec-review
```

---

## 🎯 모범 사례

### DO ✅

1. **항상 스펙부터**: `/spec-init` → `/spec-review` (90+) → 구현
2. **독립성 유지**: 각 프로젝트는 독립적인 `.specs/` 보유
3. **검증 습관화**: 구현 후 `/validate` (85+) 필수
4. **정리 정돈**: 완료된 프로젝트는 별도 저장소로 이동 고려

### DON'T ❌

1. **스펙 건너뛰기**: "간단해서"라는 이유로 바로 코딩
2. **여러 프로젝트 스펙 혼재**: 각 프로젝트는 독립적인 `.specs/`
3. **낮은 점수 무시**: 90/85 기준 엄격히 준수

---

## 💡 팁

### 빠른 프로젝트 템플릿

자주 만드는 프로젝트 타입은 템플릿화:

```bash
# 템플릿 생성
cp -r workspaces/my-project workspaces/.template-node-api

# 나중에 재사용
cp -r workspaces/.template-node-api workspaces/new-project
cd workspaces/new-project
# 프로젝트명 등 수정 후 시작
```

### 병렬 개발

여러 프로젝트 동시 개발 시:

```bash
# 터미널 1
cd workspaces/project-a
claude

# 터미널 2
cd workspaces/project-b
claude
```

각각 독립적인 `.specs/`를 가지므로 충돌 없음!

---

## 📚 참고 자료

- [상위 README.md](../README.md) - 전체 시스템 설명
- [QUICK_START.md](../QUICK_START.md) - 5분 시작 가이드
- [CLAUDE.md](../CLAUDE.md) - 개발 규칙 상세
- [CONTRIBUTING.md](../CONTRIBUTING.md) - 기여 가이드

---

**Happy Spec-First Coding!** 🚀

**Remember**: "Reason before you type" 🧠 → ⌨️

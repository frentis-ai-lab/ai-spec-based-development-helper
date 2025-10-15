# CLI 사용 가이드

## spec-init-project CLI

Specification-First 프로젝트를 빠르게 생성하는 CLI 도구입니다.

---

## 📦 사용 방법

### 방법 1: npm scripts (추천)

```bash
# 프로젝트 루트에서
pnpm run new <project-name> [--type <type>]

# 예시
pnpm run new my-app                    # Node.js (기본)
pnpm run new my-api --type node        # Node.js
pnpm run new ml-service --type python  # Python
pnpm run new game --type rust          # Rust
```

### 방법 2: 직접 실행

```bash
node bin/spec-init-project.js <project-name> [--type <type>]

# 예시
node bin/spec-init-project.js my-app
node bin/spec-init-project.js my-api --type python
```

### 방법 3: 전역 설치

```bash
# 이 프로젝트에서 한 번만 실행
pnpm link

# 이제 어디서든 사용 가능!
spec-init-project my-app
spec-init-project my-api --type python
spec-init-project game --type rust

# 전역 설치 해제
pnpm unlink --global
```

---

## 🎯 옵션

### 프로젝트 타입

| 타입 | 명령어 | 초기화 |
|------|--------|--------|
| `node` | `--type node` | `pnpm init` (기본) |
| `python` | `--type python` | `uv init` |
| `rust` | `--type rust` | `cargo init` |

### 도움말

```bash
pnpm run new --help

# 또는
node bin/spec-init-project.js --help
```

---

## 🎨 출력 예시

```
ℹ Creating Spec-First project: my-app

▸ Creating project directory...
✓ Created workspaces/my-app/
▸ Setting up symlinks...
✓ .claude/ → ../../.claude (symlink)
✓ templates/ → ../../templates (symlink)
▸ Creating .specs directory...
✓ .specs/ directory created
▸ Generating README.md...
✓ README.md generated
▸ Generating .gitignore...
✓ .gitignore generated

ℹ Project type: node
▸ Initializing Node.js project...
✓ package.json created

✓ Project created successfully!

Next steps:
  1. cd workspaces/my-app
  2. claude
  3. /spec-init

Available commands in Claude Code:
  • /spec-init    - Create specification
  • /spec-review  - Review spec (90+ score target)
  • /arch-review  - Review architecture
  • /validate     - Validate implementation (85+ score)
  • /spec-status  - Check project status
```

---

## 📁 생성되는 구조

```
workspaces/my-app/
├── .claude/              → ../../.claude (symlink)
├── templates/            → ../../templates (symlink)
├── .specs/               # 독립 디렉토리
├── .gitignore            # 타입별 자동 생성
├── README.md             # 프로젝트 가이드
└── package.json          # Node.js인 경우
    pyproject.toml        # Python인 경우
    Cargo.toml            # Rust인 경우
```

---

## 💡 사용 예시

### 1. Node.js 웹 애플리케이션

```bash
pnpm run new todo-app

cd workspaces/todo-app

# 의존성 추가
pnpm add express

# Claude Code 시작
claude

# 워크플로우
User: /spec-init
      Express REST API for Todo CRUD

AI: [질문 시작...]
    ✅ .specs/todo-api-spec.md 생성

User: /spec-review
AI: 점수 92/100 ✅ APPROVED

User: 구현해줘
AI: [구현...]

User: /validate
AI: 88/100 ✅ 배포 가능
```

### 2. Python 머신러닝 프로젝트

```bash
pnpm run new ml-classifier --type python

cd workspaces/ml-classifier

# 의존성 추가
uv add scikit-learn pandas numpy

# Claude Code 시작
claude

# 워크플로우
User: /spec-init
      Image classifier using CNN

AI: [상세 스펙 작성...]
```

### 3. Rust CLI 도구

```bash
pnpm run new cli-tool --type rust

cd workspaces/cli-tool

# 의존성 추가
cargo add clap serde

# Claude Code 시작
claude

# 워크플로우
User: /spec-init
      CLI tool for file processing
```

---

## ⚙️ 타입별 .gitignore

### Node.js

```gitignore
node_modules/
dist/
.env
```

### Python

```gitignore
__pycache__/
*.pyc
.venv/
.env
```

### Rust

```gitignore
target/
Cargo.lock
.env
```

---

## 🚨 에러 처리

### 이미 존재하는 프로젝트

```bash
pnpm run new my-app

# 출력:
# ✗ Project "my-app" already exists in workspaces/
```

### 잘못된 프로젝트 타입

```bash
pnpm run new my-app --type java

# 출력:
# ✗ Invalid project type: java
# ℹ Valid types: node, python, rust
```

### 초기화 명령 없음

```bash
# uv가 설치되지 않은 상태에서
pnpm run new ml-app --type python

# 출력:
# ⚠ Could not initialize python project (command not found)
# ℹ You can initialize it manually later
# ✓ Project created successfully!
```

---

## 🔮 향후 추가 기능

CLI는 쉽게 확장 가능합니다:

### Interactive Mode

```bash
spec-init-project

# 출력:
? Project name: my-app
? Project type: (Use arrow keys)
  ❯ Node.js
    Python
    Rust
? Add Git repository? (Y/n)
? Initialize with example spec? (Y/n)
```

### Template Selection

```bash
spec-init-project my-api --template api
spec-init-project my-lib --template library
spec-init-project my-app --template fullstack
```

### Remote Repository

```bash
spec-init-project my-app --git --remote github.com/user/repo
```

---

## 🤝 기여하기

새로운 프로젝트 타입 추가:

```javascript
// bin/spec-init-project.js

// 새 타입 추가
const validTypes = ['node', 'python', 'rust', 'go']; // <- 'go' 추가

// 초기화 명령 추가
case 'go':
  log.step('Initializing Go module...');
  execSync('go mod init', { stdio: 'inherit' });
  log.success('Go module initialized');
  break;

// .gitignore 템플릿 추가
const typeSpecific = {
  // ...
  go: `
# Go
/bin/
*.exe
*.test
go.sum
`,
};
```

---

## 📚 관련 문서

- [README.md](README.md) - 전체 시스템 설명
- [workspaces/README.md](workspaces/README.md) - workspaces 가이드
- [QUICK_START.md](QUICK_START.md) - 5분 시작 가이드

---

**Happy Spec-First Coding!** 🚀

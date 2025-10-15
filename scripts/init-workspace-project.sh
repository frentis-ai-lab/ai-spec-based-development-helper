#!/bin/bash

# Workspace 프로젝트 초기화 스크립트
# 사용법: ./scripts/init-workspace-project.sh <project-name>

set -e

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project-name>"
  echo "Example: $0 my-todo-app"
  exit 1
fi

PROJECT_DIR="workspaces/$PROJECT_NAME"

# 프로젝트 디렉토리 생성
echo "📁 Creating project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# .claude 심볼릭 링크 생성
echo "🔗 Creating symlink to .claude/"
ln -sf ../../.claude .claude

# templates 심볼릭 링크 생성
echo "🔗 Creating symlink to templates/"
ln -sf ../../templates templates

# .specs 디렉토리 생성
echo "📋 Creating .specs directory"
mkdir -p .specs

# README 생성
echo "📄 Creating README.md"
cat > README.md << EOF
# $PROJECT_NAME

이 프로젝트는 **Specification-First** 방법론을 사용합니다.

## 시작하기

\`\`\`bash
# Claude Code 실행
claude

# 스펙 작성부터 시작
/spec-init
\`\`\`

## 워크플로우

1. \`/spec-init\` - 스펙 작성
2. \`/spec-review\` - 90점 이상 확보
3. 구현
4. \`/validate\` - 85점 이상 확보
5. 배포

## 설정

- ✅ Sub-agents: \`../../.claude/agents/\` (symlink)
- ✅ Commands: \`../../.claude/commands/\` (symlink)
- ✅ Hooks: \`../../.claude/hooks/\` (symlink)
- ✅ Templates: \`../../templates/\` (symlink)
- ✅ Specs: \`./.specs/\` (독립적)

## 구조

\`\`\`
$PROJECT_NAME/
├── .claude/           -> ../../.claude (symlink)
├── templates/         -> ../../templates (symlink)
├── .specs/            # 이 프로젝트만의 스펙
├── src/               # 소스 코드
├── tests/             # 테스트
└── README.md
\`\`\`
EOF

# .gitignore 생성
echo "🚫 Creating .gitignore"
cat > .gitignore << EOF
# Dependencies
node_modules/
.pnpm-store/
__pycache__/
*.pyc

# Build
dist/
build/
*.o
*.so

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp

# Specs runtime
.specs/.last-validation
.specs/.bypass

# OS
.DS_Store
Thumbs.db
EOF

echo ""
echo "✅ 프로젝트 초기화 완료!"
echo ""
echo "다음 단계:"
echo "  cd $PROJECT_DIR"
echo ""
echo "  # 프로젝트 초기화 (선택)"
echo "  pnpm init          # Node.js"
echo "  uv init            # Python"
echo "  cargo init         # Rust"
echo ""
echo "  # Claude Code 시작"
echo "  claude"
echo ""
echo "  # 스펙 작성"
echo "  /spec-init"
echo ""

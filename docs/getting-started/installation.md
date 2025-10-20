# 설치 가이드

## 빠른 설치 (추천)

```bash
# 현재 디렉토리에 설치
curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash

# 특정 디렉토리에 설치
curl -fsSL https://[...]/install.sh | bash -s /path/to/project
```

## 요구사항

- **Claude Code** (필수): https://claude.com/claude-code
- **Git** (선택): 버전 관리용
- **Node.js/Python/Go** 등: 실제 프로젝트 언어

## 설치 옵션

### 1. 최신 버전 (자동 감지)

```bash
curl -fsSL https://[...]/install.sh | bash
```

GitHub API로 최신 릴리즈를 자동 확인합니다 (현재: v0.0.2)

### 2. 특정 버전

```bash
# v0.0.2 설치
curl -fsSL https://[...]/install.sh | bash -s -- --version v0.0.2

# 최신 개발 버전 (main 브랜치)
curl -fsSL https://[...]/install.sh | bash -s -- --version main
```

### 3. Dry-run (미리보기)

실제로 파일을 수정하지 않고 어떤 작업이 수행될지 확인:

```bash
curl -fsSL https://[...]/install.sh | bash -s -- --dry-run
```

출력 예시:
```
Dry run summary:
  - Would install version: v0.0.2
  - Target directory: /Users/you/project
  - Files would be copied: .claude/, templates/
```

### 4. Force 모드 (자동 설치)

모든 확인 프롬프트 없이 자동 설치 (CI/CD용):

```bash
curl -fsSL https://[...]/install.sh | bash -s -- --force
```

## 업데이트

기존 설치를 최신 버전으로 업데이트:

```bash
cd your-project
curl -fsSL https://[...]/install.sh | bash -s -- --update
```

**업데이트 동작**:
- ✅ `.claude/` 자동 덮어쓰기
- ✅ `templates/` 자동 덮어쓰기
- ✅ `.specs/` 보존 (작업물 안전)
- ✅ 버전 추적 (`.claude/.version` 업데이트)

## 설치 확인

```bash
# 1. 파일 확인
ls -la .claude/
ls -la templates/
ls -la .specs/

# 2. 버전 확인
cat .claude/.version
# v0.0.2

# 3. Claude Code 실행
claude

# 4. 명령어 테스트
/spec-init
```

## 설치 위치

설치 스크립트가 생성/복사하는 파일들:

```
your-project/
├── .claude/
│   ├── agents/           # Sub-agents (spec-analyzer 등)
│   ├── hooks/            # Pre/Post hooks
│   ├── commands/         # Slash commands
│   └── .version          # 설치된 버전
├── templates/
│   ├── program-spec-template.md
│   ├── api-spec-template.md
│   ├── ui-ux-spec-template.md
│   └── constitution-template.md
└── .specs/               # 여기에 스펙 작성
```

## 트러블슈팅

### "claude: command not found"

Claude Code가 설치되지 않았습니다:

```bash
# macOS/Linux: PATH 확인
which claude

# 없다면 https://claude.com/claude-code 에서 설치
```

설치 스크립트는 `--skip-claude` 옵션으로 이 체크를 건너뛸 수 있습니다 (CI/CD용).

### "Permission denied"

Hook 스크립트 실행 권한 문제:

```bash
chmod +x .claude/hooks/*.sh
```

설치 스크립트가 자동으로 설정하지만, 수동으로 복사한 경우 필요할 수 있습니다.

### "Download failed"

네트워크 문제. 설치 스크립트는 자동으로 3회 재시도하지만, 수동으로 재시도:

```bash
# 로컬 설치 방식 사용
git clone https://github.com/frentis-ai-lab/ai-spec-based-development-helper.git
cd ai-spec-based-development-helper
./scripts/install.sh /path/to/project
```

## 언인스톨

```bash
# 설치된 파일 제거
rm -rf .claude/
rm -rf templates/

# .specs는 작업물이므로 수동으로 확인 후 삭제
# rm -rf .specs/
```

## 다음 단계

설치가 완료되었다면:

1. [빠른 시작 가이드](quick-start.md) - 5분 튜토리얼
2. [첫 프로젝트](first-project.md) - TODO API 예제
3. [3-File Spec 구조](../guides/3-file-spec-structure.md) - 스펙 작성법

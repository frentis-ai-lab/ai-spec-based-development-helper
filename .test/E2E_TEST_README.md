# Constitution System E2E Tests

## 개요

실제 Claude Code를 실행하여 Constitution 시스템이 의도대로 작동하는지 검증하는 End-to-End 테스트입니다.

## 테스트 시나리오

### Scenario 1: Constitution 위반 감지
- **목적**: spec-analyzer가 실제로 Constitution 위반을 감지하는지 확인
- **테스트**: `any` 타입 2개, `console.log` 1개 포함된 스펙
- **기대 결과**: 위반 감지 및 점수 감점 (-3점)

### Scenario 2a: Normal Mode Hook
- **목적**: 승인되지 않은 스펙으로 코드 작성 시 Hook이 경고하는지 확인
- **테스트**: pre-implementation-check Hook 실행 (normal mode)
- **기대 결과**: "WARNING: No approved specifications found" 표시

### Scenario 2b: Relaxed Mode Hook Bypass
- **목적**: `CLAUDE_MODE=prototype` 환경 변수로 Hook 우회 확인
- **테스트**: pre-implementation-check Hook 실행 (relaxed mode)
- **기대 결과**: "Relaxed mode enabled" + "Skipping spec validation" 표시

### Scenario 3: 예외 패턴 인식
- **목적**: 안티패턴 문서화 시 false positive 발생하지 않는지 확인
- **테스트**: ❌ 마커, "대안", "avoid" 키워드 포함된 Best Practices 문서
- **기대 결과**: 높은 점수 (90+ 점) + APPROVED

---

## 실행 방법

### 0. 사전 준비 (Claude 경로 확인)

스크립트는 `~/.claude/local/claude`를 자동으로 사용합니다.

```bash
# Claude 실행 파일 확인
ls -lh ~/.claude/local/claude

# 또는 환경 변수로 설정 (선택사항)
export CLAUDE_CMD="$HOME/.claude/local/claude"
```

### 1. 기본 실행 (전체 E2E 테스트)

```bash
cd /Users/existmaster/ai-spec-based-development-helper

# 전체 E2E 테스트 실행
./.test/run-e2e-tests.sh
```

**실행 시간**: 약 2-5분 (Claude Code 실행 속도에 따라)

### 2. 수동 실행 (단계별)

Claude Code headless 모드를 이해하고 싶다면 수동으로 실행:

```bash
# Claude 경로 설정
CLAUDE_CMD="$HOME/.claude/local/claude"

# 1. 테스트 프로젝트 생성
cd workspaces/e2e-constitution-test

# 2. Scenario 1: spec-review 실행
"$CLAUDE_CMD" -p "/spec-review user-api-spec.md" \
  --dangerously-skip-permissions

# 3. Scenario 2a: Normal mode hook
bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts"

# 4. Scenario 2b: Relaxed mode hook
CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts"

# 5. Scenario 3: Exception patterns
"$CLAUDE_CMD" -p "/spec-review best-practices-spec.md" \
  --dangerously-skip-permissions
```

### 3. 개별 시나리오 실행

```bash
CLAUDE_CMD="$HOME/.claude/local/claude"
cd workspaces/e2e-constitution-test

# Scenario 1만 실행
"$CLAUDE_CMD" -p "/spec-review user-api-spec.md" --dangerously-skip-permissions

# Scenario 2a만 실행
bash .claude/hooks/pre-implementation-check.sh Edit "test.ts"

# Scenario 2b만 실행
CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "test.ts"

# Scenario 3만 실행
"$CLAUDE_CMD" -p "/spec-review best-practices-spec.md" --dangerously-skip-permissions
```

---

## 결과 확인

### 자동화 스크립트 실행 후

```bash
# 결과 디렉토리 (타임스탬프)
ls .test/results/e2e-*

# 최신 결과 보기
cat .test/results/e2e-*/summary.txt

# 개별 시나리오 출력 확인
cat .test/results/e2e-*/scenario1-output.txt  # Constitution 위반 감지
cat .test/results/e2e-*/scenario2a-hook-output.txt  # Normal mode hook
cat .test/results/e2e-*/scenario2b-hook-output.txt  # Relaxed mode hook
cat .test/results/e2e-*/scenario3-output.txt  # Exception patterns
```

### 성공 기준

✅ **모든 테스트 통과 조건**:

1. **Scenario 1**: 출력에 "Constitution" 또는 "violation" 포함
2. **Scenario 2a**: 출력에 "WARNING" 포함
3. **Scenario 2b**: 출력에 "Relaxed mode enabled" + "Skipping" 포함
4. **Scenario 3**: 출력에 "APPROVED" 또는 90+ 점수

---

## 트러블슈팅

### 문제 1: `claude` command not found

```bash
# Claude Code 설치 확인
which claude

# 없다면 설치: https://claude.com/claude-code
```

### 문제 2: Claude 실행 타임아웃

```bash
# Timeout 늘리기
timeout 300 claude -p "/spec-review ..."

# 또는 interactive mode로 테스트
claude
# 그 다음 채팅에서: /spec-review user-api-spec.md
```

### 문제 3: Hook이 실행되지 않음

```bash
# Hook 실행 권한 확인
ls -la workspaces/e2e-constitution-test/.claude/hooks/

# 권한 부여
chmod +x workspaces/e2e-constitution-test/.claude/hooks/*.sh

# 수동으로 Hook 직접 실행
bash workspaces/e2e-constitution-test/.claude/hooks/pre-implementation-check.sh Edit "test.ts"
```

### 문제 4: spec-analyzer agent가 실행되지 않음

```bash
# .claude/agents/ 디렉토리 확인
ls -la workspaces/e2e-constitution-test/.claude/agents/

# spec-analyzer.md 존재 확인
cat workspaces/e2e-constitution-test/.claude/agents/spec-analyzer.md | head -20

# /spec-review 슬래시 커맨드 확인
ls -la workspaces/e2e-constitution-test/.claude/commands/spec-review.md
```

---

## Claude Code Headless 모드 옵션

### 기본 옵션

```bash
claude -p "YOUR PROMPT"
  -p, --print: Non-interactive mode (headless)
```

### 권한 관련

```bash
--dangerously-skip-permissions
  # 모든 권한 프롬프트 자동 승인 (테스트용)
  # 주의: 프로덕션에서는 사용 금지

--permission-mode acceptEdits
  # Edit/Write tool만 자동 승인
```

### Tool 제한

```bash
--allowedTools "Read,Grep,Glob,Task"
  # 특정 tool만 허용
  # 예: spec-review는 Read, Grep, Glob, Task만 필요
```

### 출력 형식

```bash
--output-format json
  # JSON 형식으로 출력 (파싱 용이)

--output-format stream-json
  # Streaming JSON (실시간 출력)
```

### 예제

```bash
# spec-review (Read only)
claude -p "/spec-review my-spec.md" \
  --allowedTools "Read,Grep,Glob,Task" \
  --dangerously-skip-permissions

# 구현 (Edit/Write 포함)
claude -p "Implement the TODO API from spec" \
  --allowedTools "Read,Write,Edit,Bash" \
  --permission-mode acceptEdits

# JSON 출력
claude -p "/spec-review my-spec.md" \
  --output-format json \
  --dangerously-skip-permissions \
  > output.json
```

---

## 기대 출력 예시

### Scenario 1: Constitution 위반 감지

```
Analyzing specification: user-api-spec.md

Step 1: Architecture Review - 20/25
Step 2: Requirements Completeness - 18/25
Step 3: Implementation Plan - 15/20
Step 4: Constitution Compliance - 0/5
  ❌ Violations found:
    - any type usage (2 occurrences)
    - console.log usage (1 occurrence)
  Penalty: -3 points

Total Score: 53/100

Critical Gaps:
- Remove any types, use explicit types
- Replace console.log with winston/pino logger

Recommendation: REQUEST REVISION
```

### Scenario 2a: Normal Mode Hook

```
⚠️ WARNING: No approved specifications found!

Your specifications need to be reviewed and approved.
Run: /spec-review to analyze your specification

Proceeding with caution...
```

### Scenario 2b: Relaxed Mode Hook

```
ℹ️ Relaxed mode enabled (CLAUDE_MODE=prototype)
   Skipping spec validation checks.
```

### Scenario 3: Exception Patterns

```
Analyzing specification: best-practices-spec.md

Step 1: Architecture Review - 23/25
Step 2: Requirements Completeness - 22/25
Step 3: Implementation Plan - 18/20
Step 4: Constitution Compliance - 5/5
  ✅ Perfect compliance
  ✅ Exception patterns correctly recognized
  Bonus: +5 points

Total Score: 95/100

Recommendation: APPROVED ✅
```

---

## 추가 테스트 아이디어

### Advanced Scenario: 전체 워크플로우

```bash
# 1. spec-init
claude -p "/spec-init

Create a TODO API with TypeScript, Express, PostgreSQL.
Features: Create, Read, Update, Delete todos.
" --dangerously-skip-permissions

# 2. spec-review
claude -p "/spec-review" --dangerously-skip-permissions

# 3. Implementation (if approved)
claude -p "Implement the TODO API according to spec" \
  --permission-mode acceptEdits

# 4. Validation
claude -p "/validate" --dangerously-skip-permissions
```

### Performance Test

```bash
# 여러 스펙 동시 테스트
for spec in spec1.md spec2.md spec3.md; do
  claude -p "/spec-review $spec" --dangerously-skip-permissions &
done
wait

# 모든 spec-review 완료 후 결과 분석
```

---

## 문서

- **시나리오 상세**: `.test/e2e-test-scenarios.md`
- **TESTING_GUIDE**: `.test/TESTING_GUIDE.md` (수동 테스트 체크리스트)
- **테스트 결과**: `.test/results/manual-test-20251018/TEST_RESULTS.md`

---

**작성일**: 2025-10-18
**목적**: Claude Code 실행 환경에서 Constitution 시스템 E2E 검증
**실행 시간**: 약 2-5분

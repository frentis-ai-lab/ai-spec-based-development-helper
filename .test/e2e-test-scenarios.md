# Constitution System E2E Test Scenarios

## 목적
Claude Code를 실제로 실행하여 Constitution 시스템이 의도대로 작동하는지 검증

## 테스트 환경 설정

```bash
# 1. Workspace 내 테스트 프로젝트 생성
TEST_PROJECT="workspaces/e2e-constitution-test"
mkdir -p "$TEST_PROJECT"

# 2. 프로젝트 초기화
cd "$TEST_PROJECT"
npm init -y

# 3. AI Spec Helper 설치
../../scripts/install.sh . --update

# 또는 로컬 복사 (네트워크 없이)
cp -r ../../.claude .
cp -r ../../templates .
mkdir -p .specs
```

---

## Scenario 1: Constitution 위반 감지 (E2E)

### 1.1 Setup

```bash
# Constitution 파일 생성
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 위반이 포함된 스펙 작성
cat > .specs/user-api-spec.md <<'EOF'
# User API Specification

## Implementation

```typescript
// Violation 1: any type
const config: any = getConfig();

// Violation 2: console.log
console.log('User created');
```
EOF
```

### 1.2 Test Execution

```bash
# Claude Code headless 모드로 spec-review 실행
claude -p "/spec-review user-api-spec.md" \
  --allowedTools "Read,Grep,Glob,Task" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/scenario1-output.json
```

### 1.3 Expected Result

```json
{
  "score": 85,  // 90점 - 5점(2개 위반 × -1점, Constitution bonus 없음)
  "violations": [
    "any type usage",
    "console.log usage"
  ],
  "recommendation": "REQUEST REVISION"
}
```

### 1.4 Validation

```bash
# JSON 파싱해서 점수 확인
SCORE=$(jq '.score' test-results/scenario1-output.json)
if [ "$SCORE" -lt 90 ]; then
  echo "✅ PASS: Constitution violations detected and penalized"
else
  echo "❌ FAIL: Violations not penalized"
fi
```

---

## Scenario 2: Relaxed Mode Hook Bypass (E2E)

### 2.1 Setup

```bash
# 스펙 없이 코드 작성 시도 (정상적으로는 Hook이 차단)
cat > .specs/empty-spec.md <<'EOF'
# Empty Spec (not approved)
EOF

# 테스트 코드 파일
mkdir -p src
cat > src/test.ts <<'EOF'
export function hello() {
  return "world";
}
EOF
```

### 2.2 Test Execution (Normal Mode)

```bash
# Normal mode: Hook should block
claude -p "Edit src/test.ts to add a new function" \
  --allowedTools "Edit,Read" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/scenario2-normal.json 2>&1
```

### 2.3 Expected Result (Normal)

Hook이 실행되어 경고 또는 차단:
```
⚠️ WARNING: No approved specifications found!
```

### 2.4 Test Execution (Relaxed Mode)

```bash
# Relaxed mode: Hook should bypass
CLAUDE_MODE=prototype claude -p "Edit src/test.ts to add a new function" \
  --allowedTools "Edit,Read" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/scenario2-relaxed.json 2>&1
```

### 2.5 Expected Result (Relaxed)

Hook 우회 메시지:
```
ℹ️ Relaxed mode enabled (CLAUDE_MODE=prototype)
   Skipping spec validation checks.
```

### 2.6 Validation

```bash
# Normal mode: 경고 있어야 함
if grep -q "WARNING" test-results/scenario2-normal.json; then
  echo "✅ PASS: Normal mode shows warning"
else
  echo "❌ FAIL: Normal mode should warn"
fi

# Relaxed mode: 우회 메시지 있어야 함
if grep -q "Relaxed mode enabled" test-results/scenario2-relaxed.json; then
  echo "✅ PASS: Relaxed mode bypassed hook"
else
  echo "❌ FAIL: Relaxed mode should bypass"
fi
```

---

## Scenario 3: 예외 패턴 인식 (E2E)

### 3.1 Setup

```bash
# 예외 패턴이 포함된 Best Practices 문서
cat > .specs/best-practices-spec.md <<'EOF'
# Best Practices Guide

**Complies with**: PROJECT-CONSTITUTION.md v1.0.0

## Anti-patterns to Avoid

- ❌ `any` 타입 사용 (avoid this pattern)
  - **대안**: `unknown` 사용
- ❌ `console.log` 직접 사용
  - Use logger instead of console.log

## Correct Examples

```typescript
// ✅ Good: unknown instead of any
const config: unknown = getConfig();

// ✅ Good: logger instead of console.log
logger.info('Message');
```
EOF
```

### 3.2 Test Execution

```bash
# spec-review 실행
claude -p "/spec-review best-practices-spec.md" \
  --allowedTools "Read,Grep,Glob,Task" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/scenario3-output.json
```

### 3.3 Expected Result

예외 패턴이 인식되어 위반으로 카운트되지 않음:
```json
{
  "score": 95,  // +5 bonus (Constitution 준수)
  "violations": [],
  "recommendation": "APPROVED"
}
```

### 3.4 Validation

```bash
SCORE=$(jq '.score' test-results/scenario3-output.json)
if [ "$SCORE" -ge 90 ]; then
  echo "✅ PASS: Exception patterns correctly ignored"
else
  echo "❌ FAIL: False positives detected"
fi
```

---

## Scenario 4: 완전한 워크플로우 (E2E)

### 4.1 Setup

```bash
# 새 프로젝트 시작
mkdir -p workspaces/full-workflow-test
cd workspaces/full-workflow-test

# AI Spec Helper 설치
../../scripts/install.sh . --update

# Constitution 설정
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md
```

### 4.2 Step 1: Spec 작성

```bash
# /spec-init 실행
claude -p "/spec-init

I want to create a simple TODO API with:
- POST /todos (create)
- GET /todos (list)
- GET /todos/:id (get one)
- DELETE /todos/:id (delete)

Use TypeScript, Express, and PostgreSQL.
" \
  --allowedTools "Read,Write,Grep,Glob,Task" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/step1-spec-init.json
```

### 4.3 Step 2: Spec Review

```bash
# /spec-review 실행
claude -p "/spec-review" \
  --allowedTools "Read,Grep,Glob,Task" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/step2-spec-review.json

# 점수 확인
SCORE=$(jq '.score' test-results/step2-spec-review.json)
echo "Spec review score: $SCORE"
```

### 4.4 Step 3: Implementation

```bash
# 90+ 점수 받았다면 구현 시작
if [ "$SCORE" -ge 90 ]; then
  claude -p "Implement the TODO API according to the spec" \
    --allowedTools "Read,Write,Edit,Bash" \
    --output-format json \
    --dangerously-skip-permissions \
    > test-results/step3-implementation.json
fi
```

### 4.5 Step 4: Validation

```bash
# /validate 실행
claude -p "/validate" \
  --allowedTools "Read,Grep,Glob,Bash,Task" \
  --output-format json \
  --dangerously-skip-permissions \
  > test-results/step4-validate.json

# 점수 확인
VALIDATION_SCORE=$(jq '.score' test-results/step4-validate.json)
echo "Implementation validation score: $VALIDATION_SCORE"
```

### 4.6 Success Criteria

```bash
# 전체 워크플로우 성공 조건
if [ "$SCORE" -ge 90 ] && [ "$VALIDATION_SCORE" -ge 85 ]; then
  echo "✅ PASS: Full workflow completed successfully"
  echo "  - Spec approved: $SCORE/100"
  echo "  - Implementation validated: $VALIDATION_SCORE/100"
else
  echo "❌ FAIL: Workflow did not meet quality gates"
fi
```

---

## 자동화 스크립트

```bash
#!/bin/bash
# .test/run-e2e-tests.sh

set -e

RESULTS_DIR=".test/results/e2e-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

echo "🧪 Running E2E Constitution System Tests"
echo "Results: $RESULTS_DIR"
echo ""

# Scenario 1: Violation Detection
echo "📋 Scenario 1: Constitution Violation Detection"
# ... (scenario 1 코드)

# Scenario 2: Relaxed Mode
echo "🚀 Scenario 2: Relaxed Mode Bypass"
# ... (scenario 2 코드)

# Scenario 3: Exception Patterns
echo "✅ Scenario 3: Exception Pattern Recognition"
# ... (scenario 3 코드)

# Scenario 4: Full Workflow
echo "🔄 Scenario 4: Complete Workflow"
# ... (scenario 4 코드)

# Summary
echo ""
echo "📊 E2E Test Summary"
echo "===================="
cat "$RESULTS_DIR/summary.txt"
```

---

## 실행 방법

```bash
# 1. 전체 E2E 테스트 실행
.test/run-e2e-tests.sh

# 2. 개별 시나리오 실행
cd workspaces/e2e-constitution-test

# Scenario 1
claude -p "/spec-review user-api-spec.md" > scenario1.json

# Scenario 2 (Normal)
claude -p "Edit src/test.ts" > scenario2-normal.json

# Scenario 2 (Relaxed)
CLAUDE_MODE=prototype claude -p "Edit src/test.ts" > scenario2-relaxed.json
```

---

## 기대 결과 체크리스트

- [ ] Scenario 1: Constitution 위반 2개 감지, 점수 85점 이하
- [ ] Scenario 2a: Normal mode에서 Hook 경고 표시
- [ ] Scenario 2b: Relaxed mode에서 Hook 우회
- [ ] Scenario 3: 예외 패턴 인식, false positive 없음
- [ ] Scenario 4: 전체 워크플로우 90+ → 85+ 점수

---

## 주의사항

### Claude Code headless 모드 제약사항

1. **Interactive prompts 불가**: `/spec-init`의 명확화 질문을 미리 프롬프트에 포함
2. **Task agent 실행 제한**: `--allowedTools`에 Task 포함 필요
3. **Hook 실행**: PreToolUse, PostToolUse hooks는 headless에서도 실행됨
4. **Output parsing**: `--output-format json`으로 structured output 받기

### Fallback Plan

Claude Code headless 모드가 Hook을 제대로 실행하지 않는다면:

```bash
# Alternative: Shell에서 Hook 직접 호출
TEST_DIR="workspaces/e2e-test"
cd "$TEST_DIR"

# Pre-implementation check 수동 실행
bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts"

# Relaxed mode 테스트
CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts"
```

---

**작성일**: 2025-10-18
**목적**: Claude Code 실제 실행 환경에서 Constitution 시스템 E2E 검증

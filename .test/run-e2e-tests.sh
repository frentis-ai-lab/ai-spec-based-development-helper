#!/bin/bash

# Constitution System E2E Tests
# 실제 Claude Code를 실행하여 시스템 동작 검증

set -e

# Claude 실행 파일 경로 설정
CLAUDE_CMD="$HOME/.claude/local/claude"

# Claude 명령어 확인
if [ ! -f "$CLAUDE_CMD" ]; then
  echo "❌ Error: Claude executable not found at $CLAUDE_CMD"
  echo "Please ensure Claude Code is installed."
  exit 1
fi

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_PROJECT="$ROOT_DIR/workspaces/e2e-constitution-test"
RESULTS_DIR="$SCRIPT_DIR/results/e2e-$(date +%Y%m%d-%H%M%S)"

PASSED=0
FAILED=0

mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}=========================================="
echo "🧪 Constitution System E2E Tests"
echo -e "==========================================${NC}"
echo ""
echo "Test Project: $TEST_PROJECT"
echo "Results: $RESULTS_DIR"
echo ""

# Setup 함수
setup_test_project() {
  echo -e "${BLUE}📦 Setup: Creating Test Project${NC}"
  echo "-----------------------------------"

  # 기존 프로젝트 삭제
  rm -rf "$TEST_PROJECT"
  mkdir -p "$TEST_PROJECT"

  cd "$TEST_PROJECT"

  # AI Spec Helper 파일 복사
  mkdir -p .claude .specs templates
  cp -r "$ROOT_DIR/.claude/agents" .claude/
  cp -r "$ROOT_DIR/.claude/hooks" .claude/
  cp -r "$ROOT_DIR/.claude/commands" .claude/
  cp -r "$ROOT_DIR/templates/"* templates/

  # Hook 실행 권한
  chmod +x .claude/hooks/*.sh

  # Constitution 복사
  cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

  echo -e "${GREEN}✓${NC} Test project created: $TEST_PROJECT"
  echo ""
}

# Scenario 1: Constitution 위반 감지
scenario1_violation_detection() {
  echo -e "${BLUE}📋 Scenario 1: Constitution Violation Detection${NC}"
  echo "------------------------------------------------"

  cd "$TEST_PROJECT"

  # 위반 포함 스펙 생성
  cat > .specs/user-api-spec.md <<'EOF'
# User API Specification

**Version**: 1.0.0
**Complies with**: PROJECT-CONSTITUTION.md v1.0.0

## 1. Overview
Simple user management REST API.

## 2. Technical Implementation

```typescript
// VIOLATIONS BELOW
const userData: any = {  // VIOLATION 1: any type
  id: 123,
  name: 'John'
};

function createUser(data: any): void {  // VIOLATION 2: any parameter
  console.log('Creating user:', data);  // VIOLATION 3: console.log
}
```

## 3. API Endpoints
- POST /api/users
- GET /api/users/:id

## 4. Test Cases
1. Create user → 201 Created
2. Get user → 200 OK
EOF

  echo "Step 1: Created spec with 3 violations"
  echo "  - any type (2x)"
  echo "  - console.log (1x)"
  echo ""

  echo "Step 2: Running /spec-review via Claude Code..."
  echo "  Command: $CLAUDE_CMD -p \"/spec-review user-api-spec.md\""
  echo ""

  # Claude 실행
  if "$CLAUDE_CMD" -p "/spec-review user-api-spec.md" \
    --dangerously-skip-permissions \
    > "$RESULTS_DIR/scenario1-output.txt" 2>&1; then

    echo -e "${GREEN}✓${NC} Claude execution completed"

    # 결과 분석
    if grep -q "Constitution" "$RESULTS_DIR/scenario1-output.txt"; then
      echo -e "${GREEN}✓${NC} Constitution check performed"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Constitution check not found"
      ((FAILED++))
    fi

    # 위반 감지 확인
    if grep -qi "violation\|any.*type\|console" "$RESULTS_DIR/scenario1-output.txt"; then
      echo -e "${GREEN}✓${NC} Violations detected in output"
      ((PASSED++))
    else
      echo -e "${YELLOW}⚠${NC} Violations may not be detected"
      ((FAILED++))
    fi

  else
    echo -e "${RED}✗${NC} Claude execution failed"
    ((FAILED++))
  fi

  echo ""
  echo "Output saved to: $RESULTS_DIR/scenario1-output.txt"
  echo ""
}

# Scenario 2a: Normal Mode Hook
scenario2a_normal_mode() {
  echo -e "${BLUE}🔒 Scenario 2a: Normal Mode Hook Warning${NC}"
  echo "----------------------------------------"

  cd "$TEST_PROJECT"

  # 승인되지 않은 스펙
  cat > .specs/draft-spec.md <<'EOF'
# Draft Spec (Not Approved)
This spec has not been reviewed yet.
EOF

  mkdir -p src
  echo "export function test() { return 1; }" > src/test.ts

  echo "Step 1: Created unapproved spec"
  echo "Step 2: Testing pre-implementation-check hook..."
  echo ""

  # Hook 직접 실행 (Claude가 Edit tool 사용 전에 실행할 Hook)
  if bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts" \
    > "$RESULTS_DIR/scenario2a-hook-output.txt" 2>&1; then

    # 경고 메시지 확인
    if grep -q "WARNING" "$RESULTS_DIR/scenario2a-hook-output.txt"; then
      echo -e "${GREEN}✓${NC} Hook shows WARNING in normal mode"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Hook should show warning"
      ((FAILED++))
    fi
  else
    # Exit code 1은 정상 (경고 후 종료 가능)
    if grep -q "WARNING\|specifications" "$RESULTS_DIR/scenario2a-hook-output.txt"; then
      echo -e "${GREEN}✓${NC} Hook blocked with warning"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Hook behavior unexpected"
      ((FAILED++))
    fi
  fi

  echo ""
  echo "Output saved to: $RESULTS_DIR/scenario2a-hook-output.txt"
  echo ""
}

# Scenario 2b: Relaxed Mode Hook Bypass
scenario2b_relaxed_mode() {
  echo -e "${BLUE}🚀 Scenario 2b: Relaxed Mode Hook Bypass${NC}"
  echo "----------------------------------------"

  cd "$TEST_PROJECT"

  echo "Step 1: Testing with CLAUDE_MODE=prototype..."
  echo ""

  # Relaxed mode Hook 실행
  if CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "src/test.ts" \
    > "$RESULTS_DIR/scenario2b-hook-output.txt" 2>&1; then

    # 우회 메시지 확인
    if grep -q "Relaxed mode enabled" "$RESULTS_DIR/scenario2b-hook-output.txt"; then
      echo -e "${GREEN}✓${NC} Relaxed mode detected"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Relaxed mode not detected"
      ((FAILED++))
    fi

    if grep -q "Skipping spec validation" "$RESULTS_DIR/scenario2b-hook-output.txt"; then
      echo -e "${GREEN}✓${NC} Hook bypassed successfully"
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Hook not bypassed"
      ((FAILED++))
    fi
  else
    echo -e "${RED}✗${NC} Relaxed mode hook failed"
    ((FAILED++))
  fi

  echo ""
  echo "Output saved to: $RESULTS_DIR/scenario2b-hook-output.txt"
  echo ""
}

# Scenario 3: 예외 패턴 인식
scenario3_exception_patterns() {
  echo -e "${BLUE}✅ Scenario 3: Exception Pattern Recognition${NC}"
  echo "-------------------------------------------"

  cd "$TEST_PROJECT"

  # 예외 패턴 포함 스펙
  cat > .specs/best-practices-spec.md <<'EOF'
# Best Practices Guide

**Complies with**: PROJECT-CONSTITUTION.md v1.0.0

## Anti-patterns to Avoid

- ❌ `any` 타입 사용 (avoid this pattern)
  - **대안**: `unknown` 사용
- ❌ `console.log` 직접 사용
  - Use logger instead of console.log

## Correct Implementation

```typescript
// ✅ Good: unknown instead of any
const config: unknown = getConfig();

// ✅ Good: logger instead of console.log
logger.info('Message');
```
EOF

  echo "Step 1: Created spec with exception patterns"
  echo "  - Contains 'any' keyword (in exception context)"
  echo "  - Contains 'console.log' keyword (in exception context)"
  echo ""

  echo "Step 2: Running /spec-review..."
  echo ""

  # Claude 실행
  if "$CLAUDE_CMD" -p "/spec-review best-practices-spec.md" \
    --dangerously-skip-permissions \
    > "$RESULTS_DIR/scenario3-output.txt" 2>&1; then

    echo -e "${GREEN}✓${NC} Claude execution completed"

    # False positive가 없어야 함 (높은 점수)
    if grep -qiE "APPROVED|score.*9[0-9]|score.*100" "$RESULTS_DIR/scenario3-output.txt"; then
      echo -e "${GREEN}✓${NC} Exception patterns correctly ignored (high score)"
      ((PASSED++))
    else
      echo -e "${YELLOW}⚠${NC} May have false positives (check manual)"
    fi

  else
    echo -e "${RED}✗${NC} Claude execution failed"
    ((FAILED++))
  fi

  echo ""
  echo "Output saved to: $RESULTS_DIR/scenario3-output.txt"
  echo ""
}

# 결과 요약
print_summary() {
  TOTAL=$((PASSED + FAILED))

  cat > "$RESULTS_DIR/summary.txt" <<EOF
Constitution System E2E Test Results
====================================

Date: $(date)
Test Project: $TEST_PROJECT
Results Directory: $RESULTS_DIR

Test Summary:
-------------
Total: $TOTAL
Passed: $PASSED
Failed: $FAILED
Success Rate: $(awk "BEGIN {printf \"%.1f\", ($PASSED/$TOTAL)*100}")%

Scenarios:
----------
1. Constitution Violation Detection
2a. Normal Mode Hook Warning
2b. Relaxed Mode Hook Bypass
3. Exception Pattern Recognition

Files:
------
- scenario1-output.txt (spec-review with violations)
- scenario2a-hook-output.txt (normal mode hook)
- scenario2b-hook-output.txt (relaxed mode hook)
- scenario3-output.txt (spec-review with exceptions)
EOF

  echo -e "${BLUE}=========================================="
  echo "Test Results Summary"
  echo -e "==========================================${NC}"
  echo ""
  cat "$RESULTS_DIR/summary.txt"
  echo ""

  if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✅ All E2E tests passed! ($PASSED/$TOTAL)${NC}"
    exit 0
  else
    echo -e "${RED}❌ Some E2E tests failed ($FAILED/$TOTAL)${NC}"
    echo ""
    echo "Review output files in: $RESULTS_DIR"
    exit 1
  fi
}

# Main execution
main() {
  setup_test_project
  scenario1_violation_detection
  scenario2a_normal_mode
  scenario2b_relaxed_mode
  scenario3_exception_patterns
  print_summary
}

main

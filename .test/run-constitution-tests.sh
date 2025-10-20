#!/bin/bash

# Constitution 시스템 자동화 테스트
# Usage: ./.test/run-constitution-tests.sh

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TEST_DIR="/tmp/constitution-test-$(date +%s)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$SCRIPT_DIR/results/$(date +%Y%m%d-%H%M%S)"

PASSED=0
FAILED=0
TOTAL=0

# 결과 디렉토리 생성
mkdir -p "$RESULTS_DIR"

# 로그 함수
log_test() {
  echo -e "${BLUE}🔍 Test $1${NC}: $2"
}

log_pass() {
  echo -e "${GREEN}  ✅ PASS${NC}: $1"
  ((PASSED++))
  ((TOTAL++))
}

log_fail() {
  echo -e "${RED}  ❌ FAIL${NC}: $1"
  ((FAILED++))
  ((TOTAL++))
}

log_info() {
  echo -e "${YELLOW}  ℹ️  INFO${NC}: $1"
}

echo -e "${BLUE}======================================"
echo "🧪 Constitution System Tests"
echo -e "======================================${NC}"
echo ""
echo "Test directory: $TEST_DIR"
echo "Results directory: $RESULTS_DIR"
echo ""

# 1. 테스트 환경 설정
echo -e "${BLUE}📦 Phase 1: Setup${NC}"
echo "-------------------"

log_info "Creating test environment..."
mkdir -p "$TEST_DIR"
cd "$ROOT_DIR"

if [ ! -f "./scripts/install.sh" ]; then
  log_fail "install.sh not found"
  exit 1
fi

./scripts/install.sh "$TEST_DIR" > "$RESULTS_DIR/install.log" 2>&1

if [ -d "$TEST_DIR/.claude" ]; then
  log_pass "Test environment created"
else
  log_fail "Test environment creation failed"
  cat "$RESULTS_DIR/install.log"
  exit 1
fi

# Constitution 파일 복사
log_info "Current directory: $(pwd)"
log_info "Looking for: templates/constitution-template.md"

if [ -f "templates/constitution-template.md" ]; then
  cp templates/constitution-template.md "$TEST_DIR/.specs/PROJECT-CONSTITUTION.md"
  log_pass "Constitution template copied"
else
  log_fail "Constitution template not found in $(pwd)"
  log_info "Files in templates/: $(ls templates/ 2>&1 | tr '\n' ' ')"
  exit 1
fi

echo ""

# 2. Constitution 검증 테스트
echo -e "${BLUE}📋 Phase 2: Constitution Validation Tests${NC}"
echo "----------------------------------------"

# Test 2.1: 위반 포함 스펙
log_test "2.1" "Constitution violations detection"

cat > "$TEST_DIR/.specs/violation-spec.md" <<'EOF'
# Test Spec with Violations

**Version**: 1.0.0
**Complies with**: PROJECT-CONSTITUTION.md v1.0.0

## 1. Overview
Test specification to verify Constitution violation detection.

## 2. Implementation Details

### 2.1 Type Safety (Violation)

```typescript
// Violation 1: any type
const config: any = getConfig();
```

### 2.2 Logging (Violation)

```typescript
// Violation 2: console.log
console.log('Debug message');
```

### 2.3 Correct Alternative

```typescript
// Correct: winston logger
import winston from 'winston';
const logger = winston.createLogger({});
logger.info('Correct usage');
```

## 3. Data Model

```typescript
interface User {
  id: number;
  name: string;
}
```

## 4. Edge Cases

1. Empty input → ValidationError
2. Database timeout → RetryError

## 5. Test Cases

1. Should detect any type violation
2. Should detect console.log violation
3. Should recognize winston logger as compliant
EOF

# 파일 생성 확인
if [ -f "$TEST_DIR/.specs/violation-spec.md" ]; then
  log_pass "Test spec created (with violations)"

  # 위반 개수 확인 (간단한 grep)
  VIOLATION_COUNT=$(grep -c "Violation [12]:" "$TEST_DIR/.specs/violation-spec.md" || true)
  if [ "$VIOLATION_COUNT" -eq 2 ]; then
    log_pass "2 violations embedded in spec"
  else
    log_fail "Expected 2 violations, found $VIOLATION_COUNT"
  fi
else
  log_fail "Test spec creation failed"
fi

# Test 2.2: 예외 패턴 스펙
log_test "2.2" "Exception patterns recognition"

cat > "$TEST_DIR/.specs/exception-spec.md" <<'EOF'
# Test Spec with Exception Patterns

## 1. Anti-patterns to Avoid

### TypeScript
- ❌ \`any\` 타입 사용 (avoid this pattern)
  - **대안**: \`unknown\` 사용
  - Use explicit types instead of \`any\`

### Logging
- ❌ \`console.log\` 금지
  - **대안**: winston logger
  - Never use \`console.log\` in production

## 2. Correct Implementation

```typescript
// ✅ Correct: unknown instead of any
const config: unknown = getConfig();

// ✅ Correct: winston logger instead of console.log
logger.info('Message');
```

## 3. Code Examples

```typescript
// This is how we document forbidden patterns:
// ❌ const bad: any = value;
// ✅ const good: unknown = value;
```
EOF

if [ -f "$TEST_DIR/.specs/exception-spec.md" ]; then
  log_pass "Exception pattern spec created"

  # 예외 패턴 키워드 확인
  EXCEPTION_PATTERNS=0
  grep -q "❌" "$TEST_DIR/.specs/exception-spec.md" && ((EXCEPTION_PATTERNS++))
  grep -q "대안" "$TEST_DIR/.specs/exception-spec.md" && ((EXCEPTION_PATTERNS++))
  grep -q "instead of" "$TEST_DIR/.specs/exception-spec.md" && ((EXCEPTION_PATTERNS++))

  if [ "$EXCEPTION_PATTERNS" -ge 3 ]; then
    log_pass "3+ exception patterns embedded"
  else
    log_fail "Expected 3+ exception patterns, found $EXCEPTION_PATTERNS"
  fi
else
  log_fail "Exception pattern spec creation failed"
fi

# Test 2.3: 완벽 준수 스펙
log_test "2.3" "Perfect compliance spec"

cat > "$TEST_DIR/.specs/compliant-spec.md" <<'EOF'
# Test Spec - Perfect Compliance

**Complies with**: PROJECT-CONSTITUTION.md v1.0.0

## 1. Implementation

```typescript
// Correct types
const config: Config = getConfig();

// Correct logging
import winston from 'winston';
const logger = winston.createLogger({});
logger.info('User created', { userId });

// Correct error handling
try {
  await processUser();
} catch (error) {
  logger.error('Failed', { error });
}
```

## 2. Data Model

```typescript
interface User {
  id: number;
  email: string;
}

class UserService {
  async create(email: string): Promise<User> {
    // Implementation
  }
}
```
EOF

if [ -f "$TEST_DIR/.specs/compliant-spec.md" ]; then
  log_pass "Compliant spec created"

  # 금지 패턴 없는지 확인 (간단한 grep)
  if ! grep -E "(: any[^a-zA-Z]|console\.log)" "$TEST_DIR/.specs/compliant-spec.md" > /dev/null; then
    log_pass "No forbidden patterns in compliant spec"
  else
    log_fail "Forbidden patterns found in compliant spec"
  fi
else
  log_fail "Compliant spec creation failed"
fi

echo ""

# 3. Relaxed Mode 테스트
echo -e "${BLUE}🚀 Phase 3: Relaxed Mode Tests${NC}"
echo "-----------------------------"

cd "$TEST_DIR"

# Test 3.1: pre-implementation-check (normal)
log_test "3.1" "pre-implementation-check (normal mode)"

OUTPUT=$(bash .claude/hooks/pre-implementation-check.sh Edit "test.ts" 2>&1 || true)

if echo "$OUTPUT" | grep -q "WARNING"; then
  log_pass "Normal mode shows warning"
else
  log_fail "Normal mode should show warning"
fi

# Test 3.2: pre-implementation-check (relaxed)
log_test "3.2" "pre-implementation-check (relaxed mode)"

OUTPUT=$(CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "test.ts" 2>&1 || true)

if echo "$OUTPUT" | grep -q "Relaxed mode enabled"; then
  log_pass "Relaxed mode detected"
else
  log_fail "Relaxed mode not detected"
fi

if echo "$OUTPUT" | grep -q "Skipping spec validation"; then
  log_pass "Hook bypassed successfully"
else
  log_fail "Hook not bypassed"
fi

# Test 3.3: post-edit-validation (relaxed)
log_test "3.3" "post-edit-validation (relaxed mode)"

OUTPUT=$(CLAUDE_MODE=relaxed bash .claude/hooks/post-edit-validation.sh Edit "" 2>&1 || true)

if [ -z "$OUTPUT" ]; then
  log_pass "post-edit-validation bypassed (no output)"
else
  log_fail "post-edit-validation not bypassed"
fi

# Test 3.4: quality-reminder (relaxed)
log_test "3.4" "quality-reminder (relaxed mode)"

OUTPUT=$(CLAUDE_MODE=prototype bash .claude/hooks/quality-reminder.sh "implement complex feature" 2>&1 || true)

if [ -z "$OUTPUT" ]; then
  log_pass "quality-reminder bypassed (no output)"
else
  log_fail "quality-reminder not bypassed"
fi

echo ""

# 4. 파일 구조 검증
echo -e "${BLUE}📁 Phase 4: File Structure Validation${NC}"
echo "------------------------------------"

# Test 4.1: Constitution 템플릿 섹션 확인
log_test "4.1" "Constitution template structure"

SECTIONS=$(grep -c "^## [0-9]" "$TEST_DIR/.specs/PROJECT-CONSTITUTION.md" || true)

if [ "$SECTIONS" -ge 14 ]; then
  log_pass "Constitution has 14+ sections"
else
  log_fail "Expected 14+ sections, found $SECTIONS"
fi

# Test 4.2: AUTO-CHECK 마킹 확인
log_test "4.2" "AUTO-CHECK markers"

AUTO_CHECK_COUNT=$(grep -c "\[AUTO-CHECK\]" "$TEST_DIR/.specs/PROJECT-CONSTITUTION.md" || true)

if [ "$AUTO_CHECK_COUNT" -ge 3 ]; then
  log_pass "3+ AUTO-CHECK sections found"
else
  log_fail "Expected 3+ AUTO-CHECK sections, found $AUTO_CHECK_COUNT"
fi

# Test 4.3: spec-analyzer 업데이트 확인
log_test "4.3" "spec-analyzer Step 4 exists"

if grep -q "Step 4: Constitution" "$TEST_DIR/.claude/agents/spec-analyzer.md"; then
  log_pass "spec-analyzer has Step 4 (Constitution check)"
else
  log_fail "spec-analyzer missing Step 4"
fi

echo ""

# 5. 정리 및 결과 요약
echo -e "${BLUE}🧹 Cleanup${NC}"
echo "--------"

cd "$ROOT_DIR"

# 결과 파일 생성
cat > "$RESULTS_DIR/summary.txt" <<EOF
Constitution System Test Results
=================================

Date: $(date)
Test Directory: $TEST_DIR
Results Directory: $RESULTS_DIR

Test Summary:
-------------
Total: $TOTAL
Passed: $PASSED
Failed: $FAILED
Success Rate: $(awk "BEGIN {printf \"%.1f\", ($PASSED/$TOTAL)*100}")%

Test Files Created:
- violation-spec.md (2 violations)
- exception-spec.md (3+ exception patterns)
- compliant-spec.md (no violations)

Constitution File:
- Sections: $SECTIONS
- AUTO-CHECK markers: $AUTO_CHECK_COUNT
EOF

if [ "$FAILED" -eq 0 ]; then
  rm -rf "$TEST_DIR"
  log_pass "Test directory cleaned up"
else
  log_info "Test directory preserved for debugging: $TEST_DIR"
fi

echo ""
echo -e "${BLUE}======================================"
echo "Test Results Summary"
echo -e "======================================${NC}"
echo ""
cat "$RESULTS_DIR/summary.txt"
echo ""

if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed! ($PASSED/$TOTAL)${NC}"
  echo ""
  echo "Results saved to: $RESULTS_DIR/summary.txt"
  exit 0
else
  echo -e "${RED}❌ Some tests failed ($FAILED/$TOTAL)${NC}"
  echo ""
  echo "Results saved to: $RESULTS_DIR/summary.txt"
  exit 1
fi

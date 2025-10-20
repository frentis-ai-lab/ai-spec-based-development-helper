# Constitution System Testing Guide

> **목적**: Constitution 시스템과 Relaxed Mode가 의도한 대로 작동하는지 체계적으로 검증

## 테스트 환경 설정

### 1. 테스트 프로젝트 생성

```bash
# 방법 1: workspaces 사용
cd ai-spec-based-development-helper
pnpm run new constitution-test --structure backend

# 방법 2: 설치 스크립트 사용
mkdir -p /tmp/constitution-test
./scripts/install.sh /tmp/constitution-test
cd /tmp/constitution-test
```

### 2. Constitution 파일 준비

```bash
# Constitution 템플릿 복사
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 또는 커스텀 Constitution 생성
cat > .specs/PROJECT-CONSTITUTION.md <<'EOF'
# Project Constitution
**Version**: 1.0.0

## 1. 금지 사항 [AUTO-CHECK]
- ❌ \`any\` 타입 사용
  - **대안**: \`unknown\` 또는 명시적 타입 정의
- ❌ \`console.log\` 사용
  - **대안**: \`winston\` logger 사용

## 2. 기술 스택 표준 [AUTO-CHECK]
- **언어**: TypeScript 5.3+
- **로깅**: winston
EOF
```

---

## 테스트 시트

### Test Suite 1: Constitution 검증 기능

| # | 테스트 케이스 | 입력 | 예상 결과 | 실제 결과 | 상태 |
|---|-------------|------|----------|----------|------|
| 1.1 | Constitution 파일 없을 때 | 스펙 작성 (Constitution 없음) | 기본 점수, 패널티 없음 | | ⬜ |
| 1.2 | 금지 패턴 감지 (any) | 스펙에 \`any\` 타입 포함 | 위반 감지, -1점 | | ⬜ |
| 1.3 | 금지 패턴 감지 (console.log) | 스펙에 \`console.log\` 포함 | 위반 감지, -1점 | | ⬜ |
| 1.4 | 예외 패턴: ❌ 마커 | \`// ❌ any 타입 사용\` | 위반 아님 (예외 인식) | | ⬜ |
| 1.5 | 예외 패턴: "대안" | \`대안: unknown 사용\` | 위반 아님 (예외 인식) | | ⬜ |
| 1.6 | 예외 패턴: "instead of" | \`Use logger instead of console.log\` | 위반 아님 (예외 인식) | | ⬜ |
| 1.7 | 예외 패턴: "금지" | \`console.log 금지\` | 위반 아님 (예외 인식) | | ⬜ |
| 1.8 | 준수 항목 인식 | \`winston\` logger 사용 | Compliant 목록에 포함 | | ⬜ |
| 1.9 | 점수 계산 (완벽) | 위반 없음 | 5/5 점수 | | ⬜ |
| 1.10 | 점수 계산 (위반 2개) | \`any\` + \`console.log\` | 3/5 점수 (-2점) | | ⬜ |

### Test Suite 2: Relaxed Mode 기능

| # | 테스트 케이스 | 입력 | 예상 결과 | 실제 결과 | 상태 |
|---|-------------|------|----------|----------|------|
| 2.1 | 일반 모드 (환경변수 없음) | Hook 실행 | 스펙 검증 경고 출력 | | ⬜ |
| 2.2 | Relaxed Mode (prototype) | \`CLAUDE_MODE=prototype\` | "Skipping spec validation" | | ⬜ |
| 2.3 | Relaxed Mode (relaxed) | \`CLAUDE_MODE=relaxed\` | "Skipping spec validation" | | ⬜ |
| 2.4 | pre-implementation-check | \`CLAUDE_MODE=prototype\` | Hook 우회, exit 0 | | ⬜ |
| 2.5 | post-edit-validation | \`CLAUDE_MODE=prototype\` | Hook 우회, exit 0 | | ⬜ |
| 2.6 | quality-reminder | \`CLAUDE_MODE=prototype\` | Hook 우회, exit 0 | | ⬜ |
| 2.7 | 환경변수 원복 | \`unset CLAUDE_MODE\` | 일반 모드로 복귀 | | ⬜ |

### Test Suite 3: End-to-End 워크플로우

| # | 테스트 케이스 | 단계 | 예상 결과 | 실제 결과 | 상태 |
|---|-------------|------|----------|----------|------|
| 3.1 | 전체 플로우 (위반 있음) | 1. 스펙 작성 (위반 포함)<br>2. /spec-review<br>3. 피드백 반영<br>4. 재검토 | 1차: 위반 감지, 낮은 점수<br>2차: 90+ 점수 | | ⬜ |
| 3.2 | 전체 플로우 (완벽) | 1. Constitution 준수 스펙<br>2. /spec-review | 95+ 점수 (기본 90 + 보너스 5) | | ⬜ |
| 3.3 | Relaxed Mode 플로우 | 1. \`export CLAUDE_MODE=prototype\`<br>2. 스펙 없이 구현<br>3. Hook 우회 확인 | 경고 없이 진행 | | ⬜ |

### Test Suite 4: 의도 검증 (AI 행동)

| # | 테스트 케이스 | AI 의도 | 검증 방법 | 실제 결과 | 상태 |
|---|-------------|---------|----------|----------|------|
| 4.1 | Constitution 위반 시 명확한 피드백 | 위반 위치, 규칙, 대안 제시 | 피드백에 3가지 모두 포함되는지 확인 | | ⬜ |
| 4.2 | 예외 패턴 오인식 방지 | "avoid any"를 위반으로 간주 안 함 | False positive 없음 | | ⬜ |
| 4.3 | Constitution 참조 형식 | 피드백에 Constitution §1.1 형식 포함 | 참조 형식 정확성 | | ⬜ |
| 4.4 | 보너스 점수 계산 | 완벽 준수 시 +5점 | 점수 정확성 | | ⬜ |
| 4.5 | Relaxed Mode 메시지 | 환경변수 감지 시 친절한 안내 | 메시지 출력 확인 | | ⬜ |

---

## 자동화 테스트 스크립트

### 수동 테스트 (Interactive)

```bash
# 1. 테스트 프로젝트 생성
./scripts/install.sh /tmp/constitution-test
cd /tmp/constitution-test

# 2. Constitution 파일 생성
cp ../templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 3. 위반 포함 스펙 작성
cat > .specs/test-spec.md <<'EOF'
# Test Spec

## Implementation
\`\`\`typescript
const config: any = getConfig();  // 위반 1
console.log('test');              // 위반 2
\`\`\`
EOF

# 4. Claude Code 실행 (Interactive)
claude

# 5. Claude에게 테스트 요청
/spec-review
```

### 자동화 테스트 (Headless)

**테스트 스크립트**: `.test/run-constitution-tests.sh`

```bash
#!/bin/bash

# Constitution 시스템 자동화 테스트
# Usage: ./run-constitution-tests.sh

set -e

TEST_DIR="/tmp/constitution-test-$(date +%s)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 Constitution System Automated Tests"
echo "======================================"
echo ""

# 1. 테스트 환경 설정
echo "📦 Setting up test environment..."
mkdir -p "$TEST_DIR"
cd "$ROOT_DIR"
./scripts/install.sh "$TEST_DIR" > /dev/null 2>&1

# 2. Constitution 파일 복사
echo "📋 Copying Constitution template..."
cp templates/constitution-template.md "$TEST_DIR/.specs/PROJECT-CONSTITUTION.md"

# 3. 테스트 케이스 1: 위반 포함 스펙
echo ""
echo "🔍 Test 1: Constitution Violations Detection"
echo "-------------------------------------------"

cat > "$TEST_DIR/.specs/violation-spec.md" <<'EOF'
# Test Spec with Violations

## Implementation
\`\`\`typescript
// Violation 1: any type
const config: any = getConfig();

// Violation 2: console.log
console.log('Debug message');

// Correct: winston logger
import winston from 'winston';
logger.info('Correct usage');
\`\`\`
EOF

# Claude headless mode로 스펙 검토
cd "$TEST_DIR"
RESULT=$(claude -p "/spec-review violation-spec.md" \
  --allowedTools "Read,Grep,Glob" \
  --output-format json \
  --dangerously-skip-permissions)

# 결과 파싱
SCORE=$(echo "$RESULT" | jq -r '.final_message' | grep -oP 'Score: \K[0-9]+')
VIOLATIONS=$(echo "$RESULT" | jq -r '.final_message' | grep -c "Violation" || true)

echo "  Score: $SCORE"
echo "  Violations found: $VIOLATIONS"

if [ "$VIOLATIONS" -eq 2 ]; then
  echo "  ✅ PASS: 2 violations detected correctly"
else
  echo "  ❌ FAIL: Expected 2 violations, found $VIOLATIONS"
  exit 1
fi

# 4. 테스트 케이스 2: 예외 패턴
echo ""
echo "🔍 Test 2: Exception Patterns Recognition"
echo "---------------------------------------"

cat > "$TEST_DIR/.specs/exception-spec.md" <<'EOF'
# Test Spec with Exception Patterns

## Anti-patterns to Avoid
- ❌ any 타입 사용 (avoid this)
- 대안: unknown 사용 (alternative)
- Use logger instead of console.log

## Correct Implementation
\`\`\`typescript
const config: unknown = getConfig();
logger.info('Correct');
\`\`\`
EOF

RESULT=$(claude -p "/spec-review exception-spec.md" \
  --allowedTools "Read,Grep,Glob" \
  --output-format json \
  --dangerously-skip-permissions)

VIOLATIONS=$(echo "$RESULT" | jq -r '.final_message' | grep -c "Violation" || true)

if [ "$VIOLATIONS" -eq 0 ]; then
  echo "  ✅ PASS: No false positives (exception patterns work)"
else
  echo "  ❌ FAIL: False positives detected ($VIOLATIONS)"
  exit 1
fi

# 5. 테스트 케이스 3: Relaxed Mode
echo ""
echo "🔍 Test 3: Relaxed Mode Hook Bypass"
echo "-------------------------------"

# pre-implementation-check 테스트
OUTPUT=$(CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "test.ts" 2>&1)

if echo "$OUTPUT" | grep -q "Relaxed mode enabled"; then
  echo "  ✅ PASS: Relaxed mode detected"
else
  echo "  ❌ FAIL: Relaxed mode not working"
  exit 1
fi

if echo "$OUTPUT" | grep -q "Skipping spec validation"; then
  echo "  ✅ PASS: Hook bypassed successfully"
else
  echo "  ❌ FAIL: Hook not bypassed"
  exit 1
fi

# 6. 정리
echo ""
echo "🧹 Cleaning up..."
cd "$ROOT_DIR"
rm -rf "$TEST_DIR"

echo ""
echo "======================================"
echo "✅ All tests passed!"
echo "======================================"
```

### CI/CD 통합 예제

**GitHub Actions**: `.github/workflows/test-constitution.yml`

```yaml
name: Constitution System Tests

on:
  pull_request:
    paths:
      - '.claude/agents/spec-analyzer.md'
      - '.claude/hooks/*.sh'
      - 'templates/constitution-template.md'
      - '.test/**'

jobs:
  test-constitution:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install Claude Code
        run: |
          # Claude Code 설치 (실제로는 Docker 이미지 사용)
          curl -fsSL https://claude.com/install.sh | sh

      - name: Run Constitution Tests
        run: |
          chmod +x .test/run-constitution-tests.sh
          ./.test/run-constitution-tests.sh

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: .test/results/
```

---

## 수동 테스트 체크리스트

### Phase 1: 기본 기능 검증 (30분)

- [ ] Constitution 파일 없을 때 정상 작동
- [ ] Constitution 파일 있을 때 검증 실행
- [ ] 금지 패턴 2개 이상 정확히 감지
- [ ] 예외 패턴 3개 이상 정상 인식
- [ ] 점수 계산 정확성 (위반당 -1점)

### Phase 2: Edge Cases (30분)

- [ ] Constitution 파일 형식 오류 시 graceful fail
- [ ] 스펙에 Constitution 참조 없어도 작동
- [ ] 다국어 패턴 (한국어/영어) 모두 감지
- [ ] Code block 내 패턴 올바른 처리
- [ ] 긴 스펙 파일 (1000+ 줄) 성능 테스트

### Phase 3: Relaxed Mode (15분)

- [ ] CLAUDE_MODE=prototype 정상 작동
- [ ] CLAUDE_MODE=relaxed 정상 작동
- [ ] 3개 Hook 모두 우회
- [ ] 환경변수 unset 후 복귀 확인
- [ ] 다른 환경변수 영향 없음

### Phase 4: 통합 테스트 (45분)

- [ ] 실제 프로젝트 생성 → Constitution 설정 → 스펙 작성 → 검토 → 구현
- [ ] 위반 발견 → 수정 → 재검토 → 승인 플로우
- [ ] Relaxed Mode로 빠른 프로토타입 개발
- [ ] 일반 모드로 복귀 후 정식 스펙 작성

---

## 테스트 결과 기록

### Test Run #1

- **날짜**: YYYY-MM-DD
- **테스터**: [이름]
- **환경**: macOS 14 / Claude Code v1.2.3
- **결과**:
  - Suite 1: ✅ 10/10 passed
  - Suite 2: ✅ 7/7 passed
  - Suite 3: ✅ 3/3 passed
  - Suite 4: ✅ 5/5 passed
- **이슈**: None
- **비고**: All tests passed

### Test Run #2

(추가 테스트 결과...)

---

## 트러블슈팅

### 문제 1: Constitution 검증이 실행되지 않음

**증상**: /spec-review 실행 시 Constitution 체크가 나타나지 않음

**확인사항**:
1. .specs/PROJECT-CONSTITUTION.md 파일 존재하는지 확인
2. spec-analyzer.md가 최신 버전인지 확인 (Step 4 포함)
3. Claude Code 버전 확인

**해결**:
```bash
# spec-analyzer 버전 확인
grep "Step 4: Constitution" .claude/agents/spec-analyzer.md

# Constitution 파일 확인
ls -la .specs/PROJECT-CONSTITUTION.md
```

### 문제 2: Relaxed Mode가 작동하지 않음

**증상**: CLAUDE_MODE 설정해도 Hook이 여전히 실행됨

**확인사항**:
1. Hook 파일이 최신 버전인지 확인
2. 환경변수 export 했는지 확인
3. Bash가 환경변수를 상속받는지 확인

**해결**:
```bash
# 환경변수 확인
echo $CLAUDE_MODE

# Hook 파일에 Relaxed Mode 코드 있는지 확인
grep "CLAUDE_MODE" .claude/hooks/pre-implementation-check.sh

# 강제로 환경변수 전달
CLAUDE_MODE=prototype bash .claude/hooks/pre-implementation-check.sh Edit "test.ts"
```

### 문제 3: 예외 패턴이 인식되지 않음

**증상**: "대안" 키워드 있는데도 위반으로 감지

**확인사항**:
1. 예외 패턴 주변 context 확인 (100자 이내)
2. 대소문자 구분 확인
3. 특수문자 이스케이프 확인

**해결**:
```bash
# spec-analyzer 로직 확인
grep -A 20 "is_exception" .claude/agents/spec-analyzer.md
```

---

## 다음 단계

테스트 완료 후:
1. [ ] 테스트 결과를 PR 코멘트로 추가
2. [ ] 발견된 버그 Issue 생성
3. [ ] 성능 병목 지점 문서화
4. [ ] 개선 사항 백로그에 추가

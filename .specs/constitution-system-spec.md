# Constitution System Specification

**Feature**: Project Constitution Management System
**Version**: 1.0.0
**Date**: 2025-10-18
**Author**: AI Spec-Based Development Helper Team

---

## 1. 개요

### 1.1 문제 정의

**현재 상황**:
- 프로젝트마다 코딩 표준, 기술 스택, 품질 기준이 암묵적으로만 존재
- 팀원들이 "금지 사항"을 모르고 위반하는 경우 발생
- spec-analyzer가 프로젝트별 특수한 규칙을 검증할 방법 없음
- GitHub Spec Kit의 "Constitution" 개념 부재

**구체적 문제 사례**:
1. 개발자 A: TypeScript `any` 타입 남발 → 타입 안전성 무너짐
2. 개발자 B: `console.log` 그대로 커밋 → 프로덕션 로그 오염
3. 개발자 C: 하드코딩된 API key 커밋 → 보안 사고 위험
4. 팀 전체: 기술 스택이 각자 다름 (Node 18 vs 20, pnpm vs npm)

### 1.2 목표

**주요 목표**:
1. **프로젝트별 개발 원칙을 명시적으로 문서화**
   - Constitution 파일 (`.specs/PROJECT-CONSTITUTION.md`)로 관리
   - 금지 사항, 기술 스택, 품질 기준 등 포함

2. **자동 검증으로 위반 방지**
   - spec-analyzer가 Constitution 자동 체크
   - 위반 시 점수 감점 + 구체적 피드백

3. **간단한 프로세스 유지**
   - Constitution 파일은 풍부하게 작성 가능
   - 검증 로직은 최대한 단순 (키워드 검색 수준)

**비목표 (Scope 제외)**:
- ❌ 복잡한 규칙 엔진 구축 (AST 파싱 등)
- ❌ 런타임 검증 (ESLint/Prettier는 기존 도구 활용)
- ❌ 모든 규칙 자동 검증 (일부만 `[AUTO-CHECK]` 마킹)

### 1.3 타겟 사용자

**Primary Users**:
- 팀 리드: Constitution 작성 및 유지보수
- 개발자: Constitution 준수하며 개발
- spec-analyzer: 자동 검증 수행

**User Stories**:
1. **팀 리드로서**, 우리 프로젝트의 코딩 표준을 명시적으로 정의하고 싶다
2. **개발자로서**, 무엇이 금지되고 무엇이 권장되는지 명확히 알고 싶다
3. **spec-analyzer로서**, 프로젝트별 특수 규칙을 자동으로 검증하고 싶다

### 1.4 성공 기준

**정량적 기준**:
- Constitution 템플릿 제공 (14개 섹션)
- spec-analyzer 검증 추가 (Constitution Compliance Check)
- 검증 시간: < 5초 (Constitution 체크 포함)
- 오탐률: < 5% (잘못된 위반 감지)

**정성적 기준**:
- ✅ Constitution 파일 작성이 직관적
- ✅ 위반 시 피드백이 구체적 (어디서, 왜 위반했는지)
- ✅ 프로세스가 기존 워크플로우에 자연스럽게 통합

---

## 2. 시스템 아키텍처

### 2.1 전체 구조도

```
┌─────────────────────────────────────────────────────────┐
│                   User Workflow                          │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  1. 프로젝트 시작                                        │
│     ↓                                                     │
│  2. templates/constitution-template.md 복사              │
│     → .specs/PROJECT-CONSTITUTION.md                     │
│     ↓                                                     │
│  3. 팀 규칙 작성 (금지 사항, 기술 스택 등)               │
│     ↓                                                     │
│  4. /spec-init 실행 (기능 스펙 작성)                     │
│     ↓                                                     │
│  5. /spec-review 실행                                    │
│     ↓                                                     │
│  ┌────────────────────────────────────────┐              │
│  │   spec-analyzer (Sub-agent)            │              │
│  │                                         │              │
│  │  Phase 1: 기존 스펙 품질 평가 (90점)   │              │
│  │  Phase 2: Constitution Compliance (NEW)│              │
│  │                                         │              │
│  │  ① .specs/PROJECT-CONSTITUTION.md 읽기│              │
│  │  ② [AUTO-CHECK] 섹션 파싱             │              │
│  │  ③ 스펙과 비교 (키워드 검색)          │              │
│  │  ④ 위반 항목 감점 + 피드백 생성       │              │
│  └────────────────────────────────────────┘              │
│     ↓                                                     │
│  6. 결과 확인 (90점 이상 → 승인)                         │
│                                                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   File Structure                         │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  templates/                                               │
│    constitution-template.md      ← 템플릿 (14개 섹션)   │
│                                                           │
│  .specs/                                                  │
│    PROJECT-CONSTITUTION.md        ← 프로젝트별 Constitution│
│    program-spec.md                                        │
│    api-spec.md                                            │
│    ui-ux-spec.md                                          │
│                                                           │
│  .claude/                                                 │
│    agents/                                                │
│      spec-analyzer.md             ← Constitution 검증 로직 추가│
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### 2.2 데이터 플로우

#### 2.2.1 Constitution 생성 플로우

```
[사용자]
  → cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md
  → 팀 규칙 작성 (금지 사항, 기술 스택 등)
  → Git 커밋 (팀원들과 공유)
```

#### 2.2.2 검증 플로우

```
[사용자] /spec-review
  ↓
[Claude] Task tool → spec-analyzer agent 실행
  ↓
[spec-analyzer]
  ① Read .specs/program-spec.md (또는 api-spec, ui-ux-spec)
  ② Read .specs/PROJECT-CONSTITUTION.md (존재 시)
  ③ Parse Constitution:
     - Section 1 (금지 사항) → `forbidden_patterns = ['any type', 'console.log', ...]`
     - Section 2 (기술 스택) → `required_stack = {'typescript': '5.x', ...}`
     - Section 5 (품질 기준) → `quality_thresholds = {90, 85, 85%}`
  ④ Check violations:
     FOR EACH forbidden_pattern:
       IF spec contains pattern AND NOT contains "avoid/대안":
         violations.add(pattern)
         score -= penalty
  ⑤ Generate feedback:
     - ✅ Compliant items
     - ⚠️ Violations (위치, 해결 방법)
     - 💡 Recommendations
  ↓
[사용자] 피드백 확인 → 스펙 수정 → 재검토
```

### 2.3 기술 스택

**기존 시스템 활용**:
- Claude Code Task tool (Sub-agent 실행)
- Markdown 파싱 (간단한 정규식)
- 키워드 검색 (복잡한 AST 파싱 없음)

**새로 추가할 컴포넌트**:
- `templates/constitution-template.md` (템플릿 파일)
- spec-analyzer 내 Constitution 검증 로직 (50줄 정도)

### 2.4 아키텍처 패턴

**선택한 패턴**: **Template Method Pattern**

```
Constitution Template (14개 섹션)
  ↓
프로젝트별 Constitution (팀이 채움)
  ↓
spec-analyzer (템플릿 구조에 맞춰 파싱)
```

**장점**:
- 구조가 표준화되어 파싱 로직 단순
- 팀이 자유롭게 내용 작성 가능
- 새 섹션 추가 용이

### 2.5 Architecture Decision Records (ADR)

#### ADR-001: Constitution을 별도 파일로 분리

**Context**:
- GitHub Spec Kit은 Constitution을 최상위 아티팩트로 관리
- 우리는 program-spec이 이미 "시스템 전체 스펙" 역할

**Decision**:
- Constitution을 `.specs/PROJECT-CONSTITUTION.md`로 별도 관리
- program-spec과 분리 (관심사 분리)

**Consequences**:
- ✅ Constitution은 "개발 원칙" (불변에 가까움)
- ✅ program-spec은 "기능 요구사항" (자주 변경)
- ✅ 역할이 명확히 구분됨
- ⚠️ 파일 1개 추가 (복잡도 약간 증가)

#### ADR-002: 간단한 키워드 검색 방식 채택

**Context**:
- 정교한 검증을 위해선 AST 파싱, 정적 분석 필요
- 하지만 복잡도가 급증하고 유지보수 어려움

**Decision**:
- 키워드 기반 검색만 수행
- 예: `spec.includes('any type') && !spec.includes('avoid any')`

**Consequences**:
- ✅ 구현 간단 (50줄)
- ✅ 빠른 실행 (< 1초)
- ⚠️ 오탐 가능 (예: "avoid any type" 문맥도 감지)
- ⚠️ 정교한 검증 불가 (하지만 ESLint로 보완 가능)

**트레이드오프 수용 이유**:
- Constitution은 "가이드" 역할 (100% 강제 아님)
- 실제 코드 검증은 ESLint, Prettier 등 기존 도구 활용
- spec-analyzer는 "스펙 단계에서 미리 경고" 목적

#### ADR-003: `[AUTO-CHECK]` 마킹 방식

**Context**:
- Constitution에 14개 섹션 → 모두 자동 검증은 불가능
- 일부만 자동 검증 가능 (금지 사항, 품질 기준)

**Decision**:
- 자동 검증 가능한 섹션에 `[AUTO-CHECK]` 마크
- spec-analyzer는 이 섹션만 파싱

**Consequences**:
- ✅ 사용자에게 명확한 신호 (어떤 규칙이 자동 체크되는지)
- ✅ 검증 로직 단순 (마크된 섹션만 파싱)
- ✅ 향후 확장 용이 (새 섹션에 마크 추가)

---

## 3. 핵심 기능 목록

### Feature 3.1: Constitution 템플릿 제공

**설명**: 팀이 쉽게 Constitution을 작성할 수 있도록 템플릿 제공

**세부 기능**:
- 14개 섹션 구조화된 템플릿
- 각 섹션별 설명 + 예시 포함
- `[AUTO-CHECK]` 마킹으로 자동 검증 섹션 표시

**파일**: `templates/constitution-template.md`

**섹션 구성**:
1. 금지 사항 `[AUTO-CHECK]`
2. 기술 스택 표준 `[AUTO-CHECK]`
3. 코드 스타일 가이드
4. Git 전략
5. 품질 기준 `[AUTO-CHECK]`
6. 테스트 전략
7. 문서화 기준
8. 보안 정책
9. 성능 기준
10. 배포 정책
11. 모니터링 및 로깅
12. 팀 협업
13. 예외 및 특수 상황
14. 체크리스트 요약

**구현 우선순위**: P0 (필수)

---

### Feature 3.2: spec-analyzer Constitution 검증

**설명**: spec-analyzer가 스펙 검토 시 Constitution 자동 체크

**세부 기능**:

#### 3.2.1 Constitution 파일 읽기
```
IF .specs/PROJECT-CONSTITUTION.md exists:
  constitution = read_file(path)
ELSE:
  skip_constitution_check()  # 선택적 기능
```

#### 3.2.2 `[AUTO-CHECK]` 섹션 파싱
```python
# 의사코드
sections = {}
current_section = None

for line in constitution.lines:
    if line.startswith('## ') and '[AUTO-CHECK]' in line:
        current_section = extract_section_name(line)
        sections[current_section] = []
    elif current_section:
        sections[current_section].append(line)

# 결과:
# sections = {
#   '금지 사항': ['❌ `any` 타입', '❌ console.log', ...],
#   '기술 스택 표준': ['TypeScript 5.x', 'Node.js 20 LTS', ...],
#   '품질 기준': ['/spec-review: 90+', ...]
# }
```

#### 3.2.3 금지 사항 검증
```python
# 섹션 1: 금지 사항
forbidden_items = sections['금지 사항']
violations = []

for item in forbidden_items:
    pattern = extract_pattern(item)  # '❌ `any` 타입' → 'any type'

    if pattern in spec.lower():
        # 예외 확인: "avoid any" 같은 문맥인지
        if not ('avoid ' + pattern in spec.lower() or
                '대안: ' in surrounding_context(spec, pattern)):
            violations.append({
                'pattern': pattern,
                'location': find_location(spec, pattern),
                'penalty': -5,  # 위반 1건당 -5점
                'suggestion': extract_suggestion(item)  # "대안: unknown"
            })

# 점수 감점
total_penalty = sum(v['penalty'] for v in violations)
score -= total_penalty
```

#### 3.2.4 기술 스택 검증 (경고만)
```python
# 섹션 2: 기술 스택 표준
required_stack = parse_tech_stack(sections['기술 스택 표준'])
# {'typescript': '5.x', 'nodejs': '20', 'pnpm': True}

warnings = []
for tech, version in required_stack.items():
    if tech in spec.lower():
        actual_version = extract_version(spec, tech)
        if actual_version != version:
            warnings.append(f"⚠️ Constitution에서 {tech} {version}를 권장하지만, {actual_version} 사용 예정")

# 감점 없음, 경고만
```

#### 3.2.5 품질 기준 확인
```python
# 섹션 5: 품질 기준
quality = parse_quality_criteria(sections['품질 기준'])
# {'/spec-review': 90, '/validate': 85, 'coverage': 85}

checks = []
if '테스트 커버리지' in spec:
    mentioned_coverage = extract_coverage(spec)
    if mentioned_coverage < quality['coverage']:
        checks.append(f"⚠️ Constitution 요구: {quality['coverage']}%, 스펙: {mentioned_coverage}%")
```

#### 3.2.6 피드백 생성
```markdown
## Constitution Compliance: 92/100

### ✅ Compliant
- 기술 스택: TypeScript 5.x ✓
- 품질 기준: 테스트 커버리지 85%+ 명시 ✓
- 금지 사항: console.log 미사용 ✓

### ⚠️ Violations (총 -8점)
- **금지 사항**: `any` 타입 사용 계획됨 (-5점)
  - 위치: Section 3.2 "Data Models"
  - 발견: "We will use `any` type for external API responses"
  - 해결: `unknown` 타입 사용 또는 명시적 인터페이스 정의
  - 참고: Constitution Section 1.1

- **금지 사항**: 하드코딩된 API key (-3점)
  - 위치: Section 4.3 "External Services"
  - 발견: "API_KEY = 'sk-abc123...'"
  - 해결: 환경변수 사용 (.env 파일)
  - 참고: Constitution Section 8

### 💡 Recommendations
- TypeScript 타입 안전성 가이드: Constitution Section 1.1
- 환경변수 관리 베스트 프랙티스: Constitution Section 8.1
```

**구현 우선순위**: P0 (필수)

**예상 구현 코드량**: ~80줄 (파싱 40줄 + 검증 40줄)

---

### Feature 3.3: /spec-init에 Constitution 참조

**설명**: 스펙 작성 시 Constitution 자동 참조

**세부 기능**:
- `/spec-init` 실행 시 `.specs/PROJECT-CONSTITUTION.md` 읽기
- 금지 사항을 프롬프트에 포함
- AI가 스펙 작성 시 자동으로 회피

**예시**:
```
User: /spec-init
      사용자 인증 API 만들기

AI (내부 프롬프트):
    Constitution을 읽었습니다:
    - 금지: `any` 타입, console.log, 하드코딩 credential
    - 기술 스택: TypeScript 5.x, PostgreSQL

    이를 준수하며 스펙을 작성하겠습니다...
```

**구현 우선순위**: P1 (중요, 하지만 P0 이후)

---

### Feature 3.4: Constitution 버전 관리

**설명**: Constitution 변경 이력 추적

**세부 기능**:
- Constitution 파일 상단에 버전 정보
- 변경 시 CHANGELOG 섹션 업데이트

**예시**:
```markdown
# Project Constitution

**Version**: 1.2.0
**Last Updated**: 2025-10-20

## Changelog

### v1.2.0 (2025-10-20)
- Added: Python 금지 사항 (exec, eval)
- Changed: 테스트 커버리지 80% → 85%

### v1.1.0 (2025-10-15)
- Added: 성능 기준 섹션

### v1.0.0 (2025-10-10)
- Initial version
```

**구현 우선순위**: P2 (nice-to-have)

---

## 4. 데이터 모델

### 4.1 Constitution 파일 구조

```yaml
Constitution:
  version: string
  last_updated: date
  sections:
    - name: "금지 사항"
      auto_check: true
      items:
        - pattern: "any type"
          penalty: -5
          alternative: "unknown or explicit type"
        - pattern: "console.log"
          penalty: -3
          alternative: "structured logger (winston, pino)"

    - name: "기술 스택 표준"
      auto_check: true
      items:
        - tech: "TypeScript"
          version: "5.x"
          required: true
        - tech: "Node.js"
          version: "20 LTS"
          required: true

    - name: "품질 기준"
      auto_check: true
      thresholds:
        spec_review: 90
        validation: 85
        coverage: 85
```

### 4.2 검증 결과 데이터 모델

```typescript
interface ConstitutionCheckResult {
  score: number;                    // 0-100
  compliant: string[];              // 준수한 항목들
  violations: Violation[];          // 위반 항목들
  warnings: string[];               // 경고 (감점 없음)
  recommendations: string[];        // 개선 제안
}

interface Violation {
  pattern: string;                  // 위반한 패턴 (예: "any type")
  location: string;                 // 스펙 내 위치 (예: "Section 3.2")
  context: string;                  // 발견된 문맥
  penalty: number;                  // 감점 (-5)
  solution: string;                 // 해결 방법
  reference: string;                // Constitution 참조 위치
}
```

### 4.3 ERD (파일 관계)

```
┌──────────────────────────────┐
│ PROJECT-CONSTITUTION.md      │
│                              │
│ - version: 1.0.0             │
│ - sections: [...]            │
└──────────────┬───────────────┘
               │
               │ referenced by
               │
               ↓
┌──────────────────────────────┐
│ program-spec.md              │ ──┐
│ api-spec.md                  │   │ checked by
│ ui-ux-spec.md                │   │
└──────────────┬───────────────┘   │
               │                   ↓
               │           ┌────────────────────┐
               │           │ spec-analyzer      │
               │           │                    │
               └──────────→│ Constitution Check │
                           └────────────────────┘
```

---

## 5. 비기능 요구사항

### 5.1 성능

| 메트릭 | 목표 | 측정 방법 |
|--------|------|-----------|
| Constitution 파싱 시간 | < 1초 | Constitution 파일 < 5KB 가정 |
| 검증 시간 | < 3초 | 키워드 검색 (정규식) |
| 전체 /spec-review 시간 | < 10초 | 기존 7초 + Constitution 3초 |

**성능 최적화 전략**:
- Constitution 파일 캐싱 (프로젝트당 1회만 읽기)
- 간단한 정규식 사용 (복잡한 파싱 지양)

### 5.2 보안

**Constitution 파일 보안**:
- Constitution에 credential 포함 금지 (템플릿에 경고 명시)
- Git에 커밋 (팀 공유 목적)
- `.gitignore`에 제외 안 함

### 5.3 확장성

**새 섹션 추가**:
```markdown
# 기존 14개 섹션 외에 추가
## 15. AI 사용 정책 [AUTO-CHECK]
- ❌ AI 생성 코드 리뷰 없이 커밋 금지
```

**spec-analyzer 로직 수정 없이 확장 가능**:
- `[AUTO-CHECK]` 마크만 추가하면 자동 파싱
- 검증 로직은 패턴 기반이라 섹션 수와 무관

### 5.4 가용성

**Constitution 파일 없을 때**:
- spec-analyzer가 Constitution 체크 스킵
- 기존 90점 평가만 수행
- 경고 메시지: "💡 Tip: PROJECT-CONSTITUTION.md 작성 권장"

### 5.5 유지보수성

**코드 구조**:
```
.claude/agents/spec-analyzer.md
  ├─ 기존 로직 (90점 평가)
  └─ NEW: Constitution Check 섹션
       ├─ parse_constitution()
       ├─ check_violations()
       └─ generate_feedback()
```

**테스트 전략**:
- Constitution 파일 샘플 3개 준비 (간단, 중간, 복잡)
- 각각에 대해 검증 로직 테스트

---

## 6. 외부 연동

### 6.1 기존 시스템 통합

**spec-analyzer와 통합**:
- `.claude/agents/spec-analyzer.md`에 새 섹션 추가
- 기존 100점 평가에 Constitution 점수 통합

**통합 방식**:
```
최종 점수 = 기존 점수 (100점) + Constitution 감점 (0 ~ -20점)

예시:
- 기존 점수: 95/100
- Constitution 위반: -8점 (any 타입 -5, 하드코딩 -3)
= 최종: 87/100
```

### 6.2 /spec-init 통합

**Constitution 자동 참조**:
```markdown
# .claude/commands/spec-init.md에 추가

## Step 0: Read Constitution (NEW)

IF .specs/PROJECT-CONSTITUTION.md exists:
  constitution = read_file()
  forbidden_patterns = extract_forbidden_items(constitution)

  Add to system prompt:
  "이 프로젝트는 다음을 금지합니다:
   - any 타입
   - console.log
   - 하드코딩 credential

   스펙 작성 시 이를 회피하세요."
```

### 6.3 컴포넌트 의존성 (NEW)

**의존성 그래프**:
```
templates/constitution-template.md (Static Template)
  └─→ .specs/PROJECT-CONSTITUTION.md (User creates)
       ├─→ spec-analyzer (.claude/agents/spec-analyzer.md)
       │    └─→ /spec-review (Command invokes agent)
       │
       └─→ /spec-init (.claude/commands/spec-init.md)
            └─→ (Optional) Reads Constitution for forbidden patterns

spec-analyzer 수정 (NEW Constitution Check section)
  ├─→ /spec-review (Immediate impact)
  ├─→ pre-implementation-check hook (Potential future extension)
  └─→ /validate (No impact - separate validator)

Backward Compatibility:
  ├─→ Constitution 없을 때: spec-analyzer gracefully skips check
  ├─→ 기존 스펙 파일: 영향 없음
  └─→ 기존 /spec-review 점수: 동일 (Constitution 감점만 추가)
```

**컴포넌트 간 데이터 흐름**:
```
1. User creates Constitution
   ↓
2. /spec-init reads Constitution (optional)
   → AI avoids forbidden patterns while writing spec
   ↓
3. User runs /spec-review
   ↓
4. spec-analyzer reads both:
   - Spec file (program/api/ui-ux)
   - Constitution file (if exists)
   ↓
5. Constitution Check phase:
   - Parse [AUTO-CHECK] sections
   - Compare spec vs Constitution
   - Generate violations list
   ↓
6. Final score calculation:
   - Base score (0-100) from existing logic
   - Minus Constitution penalties (0 to -20)
   = Final score
   ↓
7. User gets feedback with violations
```

**영향 받는 파일 목록**:
| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `templates/constitution-template.md` | **NEW** | Constitution 템플릿 |
| `.specs/PROJECT-CONSTITUTION.md` | **NEW** | 사용자 생성 (프로젝트별) |
| `.claude/agents/spec-analyzer.md` | **MODIFY** | Constitution Check 섹션 추가 (~100줄) |
| `.claude/commands/spec-init.md` | **MODIFY** (Optional) | Constitution 읽기 로직 추가 (~20줄) |
| `.claude/commands/spec-review.md` | **NO CHANGE** | 그대로 (agent 호출만) |
| `CLAUDE.md` | **MODIFY** | Constitution 사용법 문서화 |
| `README.md` | **MODIFY** | 새 기능 소개 |

**브레이킹 체인지 없음**:
- 기존 프로젝트: Constitution 없어도 정상 동작
- 기존 워크플로우: 변경 없음
- 기존 점수 체계: 유지 (감점만 추가)

---

## 7. 배포 전략

### 7.1 롤아웃 계획

**Phase 1: 템플릿 제공 (Day 1-2)**

작업 내용:
- `templates/constitution-template.md` 작성
- CLAUDE.md, README.md 문서화
- 사용 예시 추가

**완료 조건** (Phase 1 → Phase 2 전환):
- [ ] Constitution 템플릿 14개 섹션 모두 작성 완료
- [ ] 3개 `[AUTO-CHECK]` 섹션 명확히 마킹됨
- [ ] 샘플 Constitution 3개 생성 (간단/중간/복잡)
  - 간단: 5개 규칙
  - 중간: 15개 규칙
  - 복잡: 30개 규칙
- [ ] CLAUDE.md에 Constitution 사용법 섹션 추가
- [ ] README.md에 새 기능 소개 (200단어 이상)
- [ ] 템플릿 Markdown 문법 검증 (lint 통과)

---

**Phase 2: spec-analyzer 통합 (Day 3-4)**

작업 내용:
- Constitution 검증 로직 구현
- 테스트 (샘플 Constitution 3개)
- 오탐률 확인 (< 5%)

**완료 조건** (Phase 2 → Phase 3 전환):
- [ ] spec-analyzer.md에 Constitution Check 섹션 추가 (80-100줄)
- [ ] 4가지 함수 구현 완료:
  - `parse_auto_check_sections()`
  - `check_forbidden_patterns()`
  - `check_tech_stack()`
  - `generate_feedback()`
- [ ] 유닛 테스트 10개 모두 통과:
  - 금지 사항 위반 감지 (3개)
  - 예외 처리 (false positive 방지, 2개)
  - Constitution 파일 없을 때 (1개)
  - 파싱 에러 핸들링 (2개)
  - 다국어 처리 (2개)
- [ ] 통합 테스트 3개 시나리오 통과:
  - 샘플 간단 (5개 규칙)
  - 샘플 중간 (15개 규칙)
  - 샘플 복잡 (30개 규칙)
- [ ] 오탐률 측정 결과: < 10% (목표 5%)
- [ ] 검증 시간 측정: < 3초 (샘플 복잡 기준)

---

**Phase 3: /spec-init 통합 (Day 5)**

작업 내용:
- Constitution 자동 참조 로직 추가
- 엔드투엔드 테스트

**완료 조건** (Phase 3 → Phase 4 전환):
- [ ] `.claude/commands/spec-init.md`에 Step 0 추가
- [ ] Constitution 읽기 로직 구현 (~20줄)
- [ ] 금지 패턴 자동 프롬프트 주입 확인
- [ ] E2E 테스트 3개 시나리오 통과:
  1. Constitution 있음 + 스펙 작성 → 금지 패턴 회피 확인
  2. Constitution 없음 + 스펙 작성 → 정상 동작 확인
  3. 잘못된 Constitution 형식 → graceful degradation
- [ ] 기존 /spec-init 동작 회귀 테스트 통과 (10개 케이스)

---

**Phase 4: 문서화 및 배포 (Day 6)**

작업 내용:
- CHANGELOG.md 업데이트
- README.md에 사용 가이드 추가
- v0.1.0 → v0.2.0 릴리스

**완료 조건** (Phase 4 = 배포 준비):
- [ ] CHANGELOG.md 작성:
  - Added 섹션 (Constitution 시스템)
  - Changed 섹션 (spec-analyzer, /spec-init)
  - Migration Guide (기존 사용자 대상)
- [ ] README.md 업데이트:
  - Constitution 섹션 추가 (500단어 이상)
  - 사용 예시 3개 (코드 블록 포함)
  - Before/After 비교표
- [ ] Git tag 생성: `v0.2.0`
- [ ] GitHub Release 작성:
  - Release Notes (CHANGELOG 기반)
  - Breaking Changes: 없음 명시
  - Installation Instructions
- [ ] 롤백 테스트 완료:
  - spec-analyzer.md Constitution 섹션 주석 처리 → 정상 동작 확인
  - Constitution 파일 삭제 → 정상 동작 확인
- [ ] 최종 smoke test:
  - 새 프로젝트에서 `/spec-init` → `/spec-review` → 90+ 점수 확인

### 7.2 롤백 전략

**문제 발생 시**:
1. Constitution 검증 비활성화
   - spec-analyzer.md에서 해당 섹션 주석 처리
2. 템플릿만 제공
   - 검증은 수동으로 (팀 리드가 확인)
3. 버전 되돌리기
   - Git revert

**롤백 조건**:
- 오탐률 > 20%
- 검증 시간 > 10초
- 사용자 피드백 부정적 (3건 이상)

---

## 8. 테스트 전략

### 8.1 유닛 테스트

**테스트 대상**:
- Constitution 파싱 로직
- 금지 사항 검증 로직
- 피드백 생성 로직

**테스트 케이스**:

#### Test Case 1: 금지 사항 위반 감지
```gherkin
Given Constitution에 "❌ `any` 타입" 금지
And 스펙에 "We will use any type for flexibility"
When spec-analyzer 실행
Then 위반 감지됨
And 점수 -5점
And 피드백: "대안: unknown 타입 사용"
```

#### Test Case 2: 예외 처리 (false positive 방지)
```gherkin
Given Constitution에 "❌ `any` 타입" 금지
And 스펙에 "We will avoid any type and use unknown"
When spec-analyzer 실행
Then 위반 감지 안 됨 (예외 처리)
```

#### Test Case 3: Constitution 파일 없을 때
```gherkin
Given PROJECT-CONSTITUTION.md 파일 없음
When spec-analyzer 실행
Then Constitution 체크 스킵
And 경고: "Constitution 작성 권장"
```

### 8.2 통합 테스트

**시나리오**:
```bash
# 1. Constitution 생성
cp templates/constitution-template.md .specs/PROJECT-CONSTITUTION.md

# 2. 스펙 작성 (의도적으로 위반)
echo "우리는 any 타입을 쓸거야" >> .specs/test-spec.md

# 3. 검증
/spec-review

# 기대 결과:
# - 위반 감지
# - 점수 85/100 (기본 95 - 위반 10)
# - 구체적 피드백 제공
```

### 8.3 엣지케이스 테스트

#### Edge Case 1: Constitution이 매우 긴 경우 (100KB)
- 파싱 시간 < 5초 확인
- 메모리 사용량 < 10MB

#### Edge Case 2: 잘못된 Markdown 형식
```markdown
# 잘못된 예시
## [AUTO-CHECK] 금지 사항  ← [AUTO-CHECK]가 뒤에
```
- 파싱 실패 시 graceful degradation
- 에러 대신 경고만 표시

#### Edge Case 3: 한국어/영어 혼재
```markdown
## 금지 사항 (Forbidden Patterns) [AUTO-CHECK]
- ❌ `any` type
- ❌ console.log 사용 금지
```
- 양쪽 언어 모두 검색

#### Edge Case 4: 코드 블록 내 키워드
```markdown
스펙:
"다음 코드는 피해야 합니다:
```typescript
const x: any = ...  // 이건 예시일 뿐
```
"
```
- 코드 블록 내부는 검증 제외 (컨텍스트 파싱)

### 8.4 테스트 커버리지 목표

| 컴포넌트 | 목표 커버리지 | 비고 |
|---------|--------------|------|
| Constitution 파싱 | 90% | 핵심 로직 |
| 검증 로직 | 85% | 다양한 패턴 |
| 피드백 생성 | 70% | 템플릿 기반 |

---

## 9. 엣지케이스 및 리스크 분석

### 9.1 엣지케이스

#### EC-1: Constitution과 기존 코드베이스 불일치
**시나리오**:
- Constitution: "TypeScript 5.x 사용"
- 기존 코드: TypeScript 4.9

**처리 방법**:
- 경고만 표시 (감점 없음)
- "레거시 코드 점진적 마이그레이션 권장"

#### EC-2: Constitution 규칙이 너무 많음 (50개 이상)
**시나리오**:
- 팀이 과도하게 상세한 규칙 작성
- 검증 시간 > 10초

**처리 방법**:
- `[AUTO-CHECK]` 섹션만 검증 (제한적)
- 나머지는 수동 확인
- 경고: "Constitution 간소화 권장 (20개 이하)"

#### EC-3: 서로 모순되는 규칙
**시나리오**:
```markdown
## 금지 사항
- ❌ 클래스 사용 금지 (함수형 프로그래밍)

## 코드 스타일
- 클래스명: PascalCase  ← 모순
```

**처리 방법 (알고리즘)**:
```python
def detect_contradictions(constitution: str) -> List[Contradiction]:
    """
    Constitution 내 모순 규칙 감지

    Returns:
        List of contradictions with section pairs
    """
    contradictions = []

    # Step 1: 파싱 - 모든 섹션 추출
    sections = parse_all_sections(constitution)
    # sections = {
    #   '금지 사항': ['클래스 사용', 'any 타입', ...],
    #   '코드 스타일': ['클래스명: PascalCase', '함수명: camelCase', ...],
    #   ...
    # }

    # Step 2: 키워드 추출
    forbidden_keywords = extract_keywords(sections['금지 사항'])
    # forbidden_keywords = ['클래스', 'any', 'console.log', ...]

    # Step 3: 다른 섹션에서 같은 키워드 검색
    for section_name, items in sections.items():
        if section_name == '금지 사항':
            continue  # 자기 자신은 스킵

        for keyword in forbidden_keywords:
            for item in items:
                if keyword in item.lower():
                    # 모순 발견 (금지 vs 권장/사용)
                    contradictions.append({
                        'keyword': keyword,
                        'forbidden_in': '금지 사항',
                        'mentioned_in': section_name,
                        'forbidden_text': find_original_text(sections['금지 사항'], keyword),
                        'mentioned_text': item
                    })

    return contradictions

# 예시 출력:
# [
#   {
#     'keyword': '클래스',
#     'forbidden_in': '금지 사항',
#     'mentioned_in': '코드 스타일',
#     'forbidden_text': '❌ 클래스 사용 금지 (함수형 프로그래밍)',
#     'mentioned_text': '클래스명: PascalCase'
#   }
# ]
```

**경고 메시지 생성**:
```markdown
⚠️  Constitution 모순 감지됨 (1개)

1. 키워드 "클래스"
   - Section 1 (금지 사항): "❌ 클래스 사용 금지 (함수형 프로그래밍)"
   - Section 3 (코드 스타일): "클래스명: PascalCase"

   → 둘 중 하나를 수정하세요.

   제안:
   - Option A: 클래스 금지를 철회하고 코드 스타일 유지
   - Option B: 코드 스타일에서 클래스 관련 항목 삭제
```

**False Positive 방지**:
```python
# 예외 처리: "클래스" 키워드가 다른 의미로 쓰일 때
exception_patterns = [
    ('클래스', '테스트 클래스'),      # 테스트는 예외
    ('클래스', 'CSS 클래스'),         # CSS는 예외
    ('any', 'any 타입 피하기')       # "피하기" 문맥은 일치
]

def is_false_positive(keyword: str, text: str) -> bool:
    for pattern_keyword, exception_phrase in exception_patterns:
        if pattern_keyword == keyword and exception_phrase in text.lower():
            return True
    return False
```

**실행 시점**:
- Constitution 파일 파싱 직후
- spec-analyzer 실행 전 (사전 검증)
- 모순 발견 시: 경고만 표시, 검증은 계속 진행

#### EC-4: 다국어 Constitution
**시나리오**:
- 한국어/영어 섹션이 혼재
- 번역 불일치

**처리 방법**:
- 영어 섹션 우선 파싱
- 한국어는 보조 (키워드 양쪽 검색)

#### EC-5: Constitution 버전 충돌
**시나리오**:
- Feature 브랜치: Constitution v1.0
- Main 브랜치: Constitution v2.0 (새 규칙 추가)
- Merge conflict

**처리 방법**:
- Git merge conflict 해결 (일반 파일과 동일)
- 최신 버전 우선 (main 브랜치)

### 9.2 리스크 분석

#### Risk-1: 오탐 (False Positive) 높음
**확률**: Medium (30%)
**영향**: High (사용자 신뢰 저하)

**예시**:
```markdown
스펙: "We should avoid any type and use unknown instead"
검증 결과: "any type" 키워드 감지 → 위반으로 잘못 판단
```

**완화 전략 (구체화)**:

**1. 예외 패턴 정의 (7가지)**:
```python
def is_exception(context: str, pattern: str) -> bool:
    """
    오탐 방지: 예외 패턴 7가지 검증

    Args:
        context: 패턴 주변 ±50자 문맥
        pattern: 금지 패턴 (예: "any type")

    Returns:
        True if exception (위반 아님), False if violation
    """
    # Pattern 1: "avoid" 키워드
    if f'avoid {pattern}' in context.lower():
        return True

    # Pattern 2: "대안" 키워드 (한국어)
    if '대안' in context and pattern in context.lower():
        return True

    # Pattern 3: "instead of" 구문
    if f'instead of {pattern}' in context.lower():
        return True

    # Pattern 4: "금지" / "지양" 키워드 (Constitution 인용)
    if ('금지' in context or '지양' in context) and pattern in context.lower():
        return True

    # Pattern 5: "❌" 기호 (금지 표시 인용)
    if '❌' in context and pattern in context.lower():
        return True

    # Pattern 6: 코드 블록 내부 (```로 둘러싸임)
    if is_inside_code_block(context):
        return True

    # Pattern 7: 부정문 (not, don't, never)
    negation_keywords = ['not use', 'don\'t use', 'never use', 'must not']
    for neg in negation_keywords:
        if f'{neg} {pattern}' in context.lower():
            return True

    return False  # 예외 아님 = 위반

def is_inside_code_block(context: str) -> bool:
    """코드 블록 내부인지 확인 (```로 둘러싸임)"""
    before_cursor = context.count('```')
    return before_cursor % 2 == 1  # 홀수 = 코드 블록 내부
```

**2. 컨텍스트 추출 로직**:
```python
def get_surrounding_text(spec: str, pattern: str, radius: int = 50) -> str:
    """
    패턴 주변 ±radius 문자 추출

    Args:
        spec: 전체 스펙 텍스트
        pattern: 찾을 패턴
        radius: 주변 문자 개수 (기본 50)

    Returns:
        패턴 주변 문맥 (최대 100자)
    """
    import re

    # 대소문자 무시 검색
    match = re.search(re.escape(pattern), spec, re.IGNORECASE)
    if not match:
        return ""

    start = max(0, match.start() - radius)
    end = min(len(spec), match.end() + radius)

    return spec[start:end]
```

**3. 오탐 발생 시 피드백 개선**:
```markdown
### 오탐 의심 케이스 (사용자 확인 필요)

⚠️  다음 항목이 위반으로 감지되었지만, 문맥상 예외일 수 있습니다:

1. **패턴**: "any type"
   **위치**: Section 3.2 "Data Models"
   **문맥**: "...we will **avoid any type** and use unknown instead..."

   **판단**: 위반으로 표시됨 (감점 -5)
   **이유**: "avoid" 키워드가 있지만, 패턴 매칭 실패

   **확인 요청**:
   - [ ] 실제 위반이 맞습니다 → 점수 유지
   - [ ] 예외입니다 (오탐) → GitHub Issue 제출하여 패턴 개선

   [Issue 템플릿 링크]
```

**4. 오탐률 측정 방법**:
```python
# 테스트 데이터셋
test_cases = [
    # (스펙 텍스트, 예상 결과: True=예외, False=위반)
    ("We avoid any type", True),
    ("대안: any 타입 대신 unknown 사용", True),
    ("Use any type for flexibility", False),  # 실제 위반
    ("```typescript\nconst x: any = 123\n```", True),  # 코드 예시
    ("금지: any 타입", True),  # Constitution 인용
    ("Don't use console.log", True),  # 부정문
    ("console.log is useful", False),  # 실제 위반
]

def measure_false_positive_rate():
    correct = 0
    for text, expected in test_cases:
        result = is_exception(text, extract_pattern(text))
        if result == expected:
            correct += 1

    accuracy = correct / len(test_cases) * 100
    fpr = 100 - accuracy  # False Positive Rate
    return fpr

# 목표: FPR < 10%
```

**5. 지속적 개선**:
- 사용자가 오탐 신고 시 → test_cases에 추가
- 매 릴리스마다 FPR 측정
- FPR > 10% 시 예외 패턴 추가

**수용 기준**: 오탐률 < 10% (테스트 데이터셋 기준)

#### Risk-2: 검증 로직 복잡도 증가
**확률**: Low (10%)
**영향**: Medium (유지보수 부담)

**시나리오**:
- 새 섹션 추가 시마다 검증 로직 수정 필요
- 코드량 증가 (50줄 → 500줄)

**완화 전략**:
- 패턴 기반 검증 유지 (확장 용이)
- 새 섹션은 `[AUTO-CHECK]` 선택적 마킹
- 복잡한 규칙은 ESLint 등 외부 도구 활용

#### Risk-3: 팀원들이 Constitution 작성 안 함
**확률**: Medium (30%)
**영향**: Low (선택적 기능이므로 문제 없음)

**시나리오**:
- 프로젝트 시작 시 Constitution 생략
- spec-analyzer가 체크 스킵

**완화 전략**:
- 템플릿 제공으로 작성 장벽 낮춤
- /spec-init 시 경고: "Constitution 권장"
- 성공 사례 공유 (문서화)

#### Risk-4: Constitution과 ESLint 규칙 중복
**확률**: High (60%)
**영향**: Low (중복이지만 해롭지 않음)

**시나리오**:
```markdown
Constitution: "❌ any 타입"
ESLint: @typescript-eslint/no-explicit-any
```

**완화 전략**:
- Constitution은 "스펙 단계" 검증
- ESLint는 "코드 단계" 검증
- 역할 구분 명확 (Early warning vs Enforcement)

**트레이드오프 수용**:
- 중복이지만 서로 보완적
- Constitution이 더 넓은 범위 (보안, 배포 등)

### 9.3 리스크 매트릭스

```
영향도 ↑
  High │ Risk-1 (오탐)          │
       │                        │
Medium │ Risk-2 (복잡도)        │
       │                        │
   Low │ Risk-3 (미작성)  Risk-4│
       └────────────────────────┴→ 확률
         Low    Medium    High
```

**우선 대응**: Risk-1 (오탐률 낮추기)

---

## 10. 성공 메트릭

### 10.1 정량적 메트릭

| 메트릭 | 목표 | 측정 방법 | 현재 상태 |
|--------|------|-----------|-----------|
| Constitution 작성률 | 50%+ | 프로젝트 중 Constitution 보유 비율 | 0% (신규 기능) |
| 오탐률 | < 10% | 잘못된 위반 감지 / 전체 검증 | TBD |
| 검증 시간 | < 5초 | Constitution 체크 소요 시간 | TBD |
| /spec-review 점수 향상 | +5점 | Constitution 도입 전후 비교 | TBD |
| 위반 발견율 | 30%+ | 실제 Constitution 위반 건수 | TBD |

### 10.2 정성적 메트릭

| 메트릭 | 목표 | 측정 방법 |
|--------|------|-----------|
| 사용자 만족도 | "유용하다" 80%+ | 설문조사 (5점 척도) |
| 문서 명확성 | "이해하기 쉽다" 90%+ | 템플릿 가독성 평가 |
| 워크플로우 통합 | "자연스럽다" 70%+ | 기존 프로세스 방해 여부 |

### 10.3 성공 시나리오

**시나리오 1: 보안 위반 사전 방지**
```
팀원 A가 스펙 작성 시 API key를 하드코딩
→ /spec-review 실행
→ Constitution 위반 감지: "하드코딩된 credential"
→ 점수 85/100 (-15점)
→ 피드백: "환경변수 사용 (.env)"
→ 팀원 A가 수정
→ /spec-review 재실행 → 95/100 승인
→ 실제 코드에서 보안 사고 방지
```

**시나리오 2: 타입 안전성 개선**
```
팀 전체가 any 타입 남발
→ Constitution에 "❌ any 타입" 추가
→ 모든 스펙 검토 시 자동 감지
→ 3주 후: any 타입 사용 80% 감소
→ 런타임 에러 30% 감소
```

### 10.4 실패 기준 (Rollback 조건)

- 오탐률 > 20%
- 검증 시간 > 10초
- 사용자 만족도 < 50%
- 버그 발견 3건 이상 (Critical)

---

## 11. 개방된 질문 (Open Questions)

### Q1: Constitution을 프로젝트별 vs 전역으로?

**현재 결정**: 프로젝트별 (`.specs/PROJECT-CONSTITUTION.md`)

**대안**:
- 전역 Constitution: `~/.claude/constitution.md` (모든 프로젝트 공유)
- 계층 구조: 전역 + 프로젝트별 (override)

**해결 기한**: v0.3.0 (다음 버전에서 재검토)

### Q2: 검증 엄격도 조절 기능 필요?

**현재 결정**: 고정된 감점 (-5, -3, -10)

**대안**:
```markdown
## 금지 사항 [AUTO-CHECK]
- ❌ `any` 타입 (Severity: HIGH, -10점)
- ❌ console.log (Severity: LOW, -2점)
```

**해결 기한**: 사용자 피드백 후 결정 (v0.2.1)

### Q3: Constitution 자동 생성 기능?

**아이디어**:
```
/constitution-init
→ 기존 코드베이스 분석
→ 사용 중인 기술 스택 자동 감지
→ Constitution 초안 생성
```

**장점**: 진입 장벽 낮춤
**단점**: 구현 복잡

**해결 기한**: v0.3.0에서 검토

### Q4: 다른 파일 형식 지원? (YAML, JSON)

**현재**: Markdown만 지원

**대안**:
```yaml
# .specs/constitution.yml
forbidden:
  - pattern: "any type"
    penalty: -5
    alternative: "unknown"
```

**장점**: 파싱 쉬움, 구조화
**단점**: 가독성 낮음 (팀원이 읽기 어려움)

**해결 기한**: 사용자 요청 시 고려

---

## 12. 타임라인

### Week 1: 기반 구축
- **Day 1-2**: Constitution 템플릿 작성
  - 14개 섹션 구조화
  - 예시 및 설명 추가
  - 샘플 Constitution 3개 생성 (테스트용)

- **Day 3**: 문서화
  - CLAUDE.md 업데이트 (Constitution 사용법)
  - README.md 업데이트 (새 기능 소개)

### Week 2: 검증 로직 구현
- **Day 4-5**: spec-analyzer 통합
  - Constitution 파싱 로직 (~40줄)
  - 검증 로직 (~40줄)
  - 피드백 생성 (~20줄)

- **Day 6**: 테스트
  - 유닛 테스트 10개
  - 통합 테스트 3개
  - 오탐률 측정

### Week 3: 고급 기능
- **Day 7**: /spec-init 통합
  - Constitution 자동 참조 로직

- **Day 8**: 엔드투엔드 테스트
  - 실제 프로젝트 시나리오 테스트
  - 문서 최종 검토

- **Day 9**: 배포
  - v0.2.0 릴리스
  - CHANGELOG.md 작성
  - GitHub Release 생성

---

## 13. 참고 자료

### 13.1 관련 문서

- GitHub Spec Kit: https://github.com/github/spec-kit
- Conventional Commits: https://www.conventionalcommits.org/
- OWASP Top 10: https://owasp.org/www-project-top-ten/

### 13.2 유사 프로젝트

- ESLint: 코드 규칙 검증 (런타임)
- Prettier: 코드 포맷팅
- SonarQube: 코드 품질 분석

**차별점**:
- Constitution은 "스펙 단계" 검증 (코드 작성 전)
- 더 넓은 범위 (코드 + 아키텍처 + 프로세스)

---

## Appendix A: Constitution 템플릿 전체 구조

```markdown
# Project Constitution (14개 섹션)

1. 금지 사항 [AUTO-CHECK]
   - 언어별 금지 패턴 (TypeScript, Python, etc.)
   - 공통 금지 사항 (credential, debug mode, etc.)

2. 기술 스택 표준 [AUTO-CHECK]
   - Backend, Frontend, Testing, DevOps

3. 코드 스타일 가이드
   - 명명 규칙, 파일 구조, 주석 규칙

4. Git 전략
   - 브랜치 전략, 커밋 메시지, PR 규칙

5. 품질 기준 [AUTO-CHECK]
   - /spec-review: 90+
   - /validate: 85+
   - Coverage: 85%+

6. 테스트 전략
   - 테스트 레벨, 커버리지, 명명 규칙

7. 문서화 기준
   - 필수 문서, API 문서, ADR

8. 보안 정책
   - Secrets 관리, Dependency 관리, 리뷰 체크리스트

9. 성능 기준
   - API, Database, Frontend 성능

10. 배포 정책
    - 환경 구성, 체크리스트, 롤백

11. 모니터링 및 로깅
    - 로깅 레벨, 구조, 알람

12. 팀 협업
    - Code Review, 스펙 리뷰, 커뮤니케이션

13. 예외 및 특수 상황
    - 프로토타이핑, 긴급 핫픽스, 레거시

14. 체크리스트 요약
    - 개발 시작 전, 구현 중, PR 전, 배포 전
```

---

## Appendix C: Constitution 파일 완전한 예시 (NEW)

### 샘플: TypeScript Backend 프로젝트

```markdown
# Project Constitution

**Version**: 1.0.0
**Last Updated**: 2025-10-18
**Project**: E-Commerce API Backend

---

## 1. 금지 사항 [AUTO-CHECK]

### TypeScript
- ❌ `any` 타입 사용
  - **대안**: `unknown` 또는 명시적 타입 정의
  - **예외**: 서드파티 라이브러리 타입 불가피한 경우만 (주석으로 이유 명시)

- ❌ `console.log`, `console.error` 사용
  - **대안**: `winston` logger 사용
  - **예외**: 개발 환경 디버깅 (배포 전 제거 필수)

- ❌ `eval()`, `Function()` 생성자
  - **이유**: 보안 위험 (XSS, code injection)
  - **대안**: 없음 (절대 사용 금지)

### 공통
- ❌ 하드코딩된 credential, API key, password
  - **대안**: `.env` 파일 + 환경변수
  - **예외**: 테스트용 mock data (주석으로 "TEST ONLY" 명시)

- ❌ `.env` 파일을 Git에 커밋
  - **대안**: `.env.example`만 커밋 (값은 비움)

- ❌ Production 환경에 debug mode 활성화
  - **확인**: `NODE_ENV=production` 시 debug 로그 비활성화

- ❌ `TODO` 주석을 main 브랜치에 merge
  - **허용**: `TODO(issue-123): ...` (이슈 번호 포함)
  - **이유**: 추적 가능성

---

## 2. 기술 스택 표준 [AUTO-CHECK]

### Backend
- **언어**: TypeScript 5.3+
- **런타임**: Node.js 20 LTS
- **패키지 매니저**: pnpm 8.x (required)
- **프레임워크**: Express 4.18+
- **ORM**: Prisma 5.x
- **데이터베이스**: PostgreSQL 16+

### Testing
- **유닛 테스트**: Vitest 1.x
- **E2E**: Supertest
- **커버리지**: 85% 이상 필수

### DevOps
- **컨테이너**: Docker 24+
- **CI/CD**: GitHub Actions
- **클라우드**: AWS (ECS Fargate)

---

## 3. 코드 스타일 가이드

### 명명 규칙
- **변수/함수**: camelCase (`getUserProfile`)
- **클래스/인터페이스**: PascalCase (`UserService`, `IUserRepository`)
- **상수**: UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **파일명**: kebab-case (`user-service.ts`)
- **폴더명**: kebab-case (`auth-service/`)

### 파일 구조
```
src/
  features/           # Feature-based organization
    auth/
      auth.service.ts
      auth.controller.ts
      auth.repository.ts
      auth.test.ts
    users/
  shared/             # 공통 코드
    utils/
    types/
    middlewares/
```

### 주석 규칙
- **JSDoc**: 모든 public 함수/클래스 (필수)
- **TODO**: 반드시 이슈 번호 포함 (`TODO(#123): ...`)
- **복잡한 로직**: 간단한 인라인 주석 ("왜" 이렇게 했는지)

---

## 4. Git 전략

### 브랜치 전략
- `main`: Production-ready (보호됨)
- `develop`: 개발 통합 (선택적)
- `feature/<issue-number>-<description>`: 기능 개발
- `fix/<issue-number>-<description>`: 버그 수정
- `hotfix/<description>`: 긴급 패치

### 커밋 메시지 (Conventional Commits)
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: 새 기능
- `fix`: 버그 수정
- `docs`: 문서만 변경
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정

**예시**:
```
feat(auth): Add JWT refresh token rotation

- Implement 6-step rotation mechanism
- Add blacklist for revoked tokens
- Update API documentation

Closes #123
```

### PR 규칙
- 최소 1명 승인 필요
- 모든 테스트 통과 필수
- `/spec-review` 90+ 필수
- `/validate` 85+ 필수

---

## 5. 품질 기준 [AUTO-CHECK]

### Specification Quality
- **`/spec-review`**: 90점 이상 필수
- 아키텍처 다이어그램 포함
- 엣지케이스 5개 이상 정의
- 롤백 전략 명시

### Implementation Quality
- **`/validate`**: 85점 이상 필수
- 테스트 커버리지: 85% 이상
- 모든 엣지케이스 테스트 존재
- ESLint 0 errors

### Performance
- API 응답 시간: p95 < 200ms
- 번들 사이즈: N/A (backend)

### Security
- OWASP Top 10 준수
- SQL Injection 방어 (Prisma ORM 사용)
- 민감 데이터 암호화

---

## 6. 테스트 전략

### 테스트 레벨
```
E2E Tests (10%)          ← 핵심 사용자 플로우
  ↑
Integration Tests (30%)  ← API, 서비스 간 연동
  ↑
Unit Tests (60%)         ← 개별 함수, 클래스
```

### 커버리지 목표
- **전체**: 85% 이상
- **신규 코드**: 90% 이상
- **Critical Path**: 100%

---

## 7. 문서화 기준

### 필수 문서
- [ ] README.md (프로젝트 소개, 설치, 실행)
- [ ] API 문서 (OpenAPI 3.0)
- [ ] ADR (Architecture Decision Records)
- [ ] `.specs/` 디렉토리 (Specification-First)

---

## 8. 보안 정책

### Secrets 관리
- `.env` 파일 절대 커밋 금지
- Production secrets: AWS Secrets Manager

### Dependency 관리
- 주간 `pnpm audit` 실행
- Critical 취약점 발견 시 24시간 내 패치

---

## 9. 성능 기준

### API 성능
- p50: < 50ms
- p95: < 200ms
- p99: < 500ms

---

## 10. 배포 정책

### 배포 체크리스트
- [ ] 모든 테스트 통과
- [ ] `/validate` 85+ 통과
- [ ] Database migration 검증
- [ ] Rollback 계획 수립

---

## 11. 모니터링 및 로깅

### 로깅 레벨
- **ERROR**: 즉시 대응 필요
- **WARN**: 주의 필요
- **INFO**: 중요 이벤트

---

## 12. 팀 협업

### Code Review 기준
- 변경 사항 < 400줄 (권장)
- 리뷰 요청 후 24시간 내 응답

---

## 13. 예외 및 특수 상황

### Constitution 예외 처리
1. **프로토타이핑**: `CLAUDE_MODE=prototype` 환경변수
2. **긴급 핫픽스**: `.specs/.bypass` 파일 (24시간 내 삭제)

---

## 14. 체크리스트 요약

### 개발 시작 전
- [ ] GitHub Issue 생성
- [ ] `/spec-init` 실행
- [ ] `/spec-review` 90+ 확보

### PR 생성 전
- [ ] `/validate` 85+ 확보
- [ ] 테스트 커버리지 85%+
```

**특징**:
- 14개 섹션 모두 포함 (완전한 예시)
- 3개 `[AUTO-CHECK]` 섹션 명확히 마킹
- 실제 프로젝트 적용 가능 (E-Commerce API)
- 구체적 수치 (TypeScript 5.3+, Node 20, 85% 커버리지 등)
- 예외 처리 명시 (테스트 mock data 등)

---

## Appendix B: 검증 로직 의사코드

```python
def check_constitution_compliance(spec: str, constitution: str) -> Result:
    # Phase 1: 파싱
    sections = parse_auto_check_sections(constitution)
    # sections = {'금지 사항': [...], '기술 스택': [...], '품질 기준': [...]}

    # Phase 2: 검증
    violations = []
    warnings = []

    # 2.1 금지 사항 체크
    for item in sections['금지 사항']:
        pattern = extract_pattern(item)  # '❌ `any` 타입' → 'any type'

        if pattern in spec.lower():
            # 예외 처리
            context = get_surrounding_text(spec, pattern, radius=50)
            if not is_exception(context, pattern):
                violations.append({
                    'pattern': pattern,
                    'location': find_location(spec, pattern),
                    'penalty': get_penalty(item),  # -5, -3, -10
                    'solution': extract_alternative(item)
                })

    # 2.2 기술 스택 체크 (경고만)
    for tech, version in sections['기술 스택'].items():
        if tech in spec.lower():
            actual_version = extract_version(spec, tech)
            if actual_version != version:
                warnings.append(f"Constitution: {tech} {version}, Spec: {actual_version}")

    # 2.3 품질 기준 체크
    quality = sections['품질 기준']
    if 'coverage' in spec.lower():
        mentioned_coverage = extract_number(spec, 'coverage')
        if mentioned_coverage < quality['coverage']:
            warnings.append(f"Coverage {mentioned_coverage}% < {quality['coverage']}%")

    # Phase 3: 점수 계산
    total_penalty = sum(v['penalty'] for v in violations)
    score = 100 + total_penalty  # penalty는 음수

    # Phase 4: 피드백 생성
    feedback = generate_feedback(violations, warnings)

    return Result(score=score, violations=violations, warnings=warnings, feedback=feedback)


def is_exception(context: str, pattern: str) -> bool:
    """예외 처리: 'avoid any', '대안:' 등의 문맥"""
    exception_keywords = ['avoid', '대안', 'instead of', '지양']
    return any(kw in context.lower() for kw in exception_keywords)


def extract_penalty(item: str) -> int:
    """
    '❌ `any` 타입 (Critical)' → -10
    '❌ console.log' → -5 (기본값)
    """
    if 'critical' in item.lower():
        return -10
    elif 'major' in item.lower():
        return -5
    else:
        return -3
```

---

## Appendix D: ConstitutionCheckResult JSON 예시 (NEW)

### 케이스 1: 완벽 준수 (위반 0개)

```json
{
  "score": 100,
  "compliant": [
    "금지 사항: any 타입, console.log 미사용 ✓",
    "기술 스택: TypeScript 5.3, Node.js 20 LTS ✓",
    "품질 기준: /spec-review 90+, /validate 85+, 커버리지 85%+ 명시 ✓"
  ],
  "violations": [],
  "warnings": [],
  "recommendations": [
    "Constitution 모든 규칙을 준수했습니다!",
    "계속 이 수준을 유지하세요."
  ]
}
```

**Markdown 피드백**:
```markdown
## Constitution Compliance: 100/100 ✅

### ✅ Compliant
- 금지 사항: any 타입, console.log 미사용 ✓
- 기술 스택: TypeScript 5.3, Node.js 20 LTS ✓
- 품질 기준: /spec-review 90+, /validate 85+, 커버리지 85%+ 명시 ✓

🎉 모든 Constitution 규칙을 준수했습니다!
```

---

### 케이스 2: 경미한 위반 (1개, -5점)

```json
{
  "score": 95,
  "compliant": [
    "기술 스택: TypeScript 5.3 ✓",
    "품질 기준: 테스트 커버리지 85%+ 명시 ✓"
  ],
  "violations": [
    {
      "pattern": "any type",
      "location": "Section 3.2 Data Models",
      "context": "...for external API responses, we will use `any` type temporarily...",
      "penalty": -5,
      "solution": "`unknown` 타입 사용 또는 명시적 인터페이스 정의 (예: `interface ExternalAPIResponse { ... }`)",
      "reference": "Constitution Section 1.1 - TypeScript 금지 사항"
    }
  ],
  "warnings": [],
  "recommendations": [
    "TypeScript 타입 안전성 가이드: Constitution Section 1.1",
    "`unknown` 타입으로 변경하면 +5점 → 100점 달성 가능"
  ]
}
```

**Markdown 피드백**:
```markdown
## Constitution Compliance: 95/100 ⚠️

### ✅ Compliant
- 기술 스택: TypeScript 5.3 ✓
- 품질 기준: 테스트 커버리지 85%+ 명시 ✓

### ⚠️  Violations (총 -5점)
**1. 금지 사항: `any` 타입 사용 계획됨** (-5점)
   - **위치**: Section 3.2 "Data Models"
   - **발견**: "...for external API responses, we will use `any` type temporarily..."
   - **해결**: `unknown` 타입 사용 또는 명시적 인터페이스 정의
     ```typescript
     // ❌ 잘못된 방법
     const response: any = await fetch(...)

     // ✅ 올바른 방법 1: unknown
     const response: unknown = await fetch(...)
     if (isValidResponse(response)) { ... }

     // ✅ 올바른 방법 2: 명시적 interface
     interface ExternalAPIResponse {
       data: { ... }
       status: number
     }
     const response: ExternalAPIResponse = await fetch(...)
     ```
   - **참고**: Constitution Section 1.1

### 💡 Recommendations
- `unknown` 타입으로 변경하면 +5점 → 100점 달성 가능
```

---

### 케이스 3: 심각한 위반 (3개, -18점)

```json
{
  "score": 82,
  "compliant": [
    "기술 스택: TypeScript 5.3 ✓"
  ],
  "violations": [
    {
      "pattern": "any type",
      "location": "Section 3.2 Data Models",
      "context": "We will use `any` type for flexibility",
      "penalty": -5,
      "solution": "`unknown` 또는 명시적 타입",
      "reference": "Constitution Section 1.1"
    },
    {
      "pattern": "console.log",
      "location": "Section 5.3 Logging Strategy",
      "context": "Use console.log for debugging in production",
      "penalty": -3,
      "solution": "winston logger 사용",
      "reference": "Constitution Section 1.1"
    },
    {
      "pattern": "hardcoded credential",
      "location": "Section 4.2 External Services",
      "context": "API_KEY = 'sk-abc123456...'",
      "penalty": -10,
      "solution": "환경변수 사용 (.env 파일)",
      "reference": "Constitution Section 1 - 공통 금지 사항"
    }
  ],
  "warnings": [
    "⚠️  Constitution에서 Node.js 20 LTS 권장하지만, 스펙에서 Node 18 사용 예정"
  ],
  "recommendations": [
    "🔴 **Critical**: 하드코딩된 credential 즉시 제거 필요 (-10점)",
    "TypeScript 타입 안전성: Constitution Section 1.1",
    "로깅 베스트 프랙티스: Constitution Section 11",
    "환경변수 관리: Constitution Section 8"
  ]
}
```

**Markdown 피드백**:
```markdown
## Constitution Compliance: 82/100 ❌

### ✅ Compliant
- 기술 스택: TypeScript 5.3 ✓

### ⚠️  Violations (총 -18점)

**1. [CRITICAL] 하드코딩된 credential** (-10점)
   - **위치**: Section 4.2 "External Services"
   - **발견**: `API_KEY = 'sk-abc123456...'`
   - **해결**: 환경변수 사용
     ```typescript
     // ❌ 절대 금지
     const API_KEY = 'sk-abc123...'

     // ✅ 올바른 방법
     const API_KEY = process.env.OPENAI_API_KEY!
     ```
   - **참고**: Constitution Section 8 (보안 정책)

**2. 금지 사항: `any` 타입** (-5점)
   - **위치**: Section 3.2 "Data Models"
   - **발견**: "We will use `any` type for flexibility"
   - **해결**: `unknown` 또는 명시적 타입
   - **참고**: Constitution Section 1.1

**3. 금지 사항: `console.log`** (-3점)
   - **위치**: Section 5.3 "Logging Strategy"
   - **발견**: "Use console.log for debugging in production"
   - **해결**: winston logger 사용
     ```typescript
     // ❌ 금지
     console.log('User created:', user)

     // ✅ 올바른 방법
     logger.info('User created', { userId: user.id })
     ```
   - **참고**: Constitution Section 11 (로깅)

### ⚠️  Warnings
- Constitution에서 Node.js 20 LTS 권장하지만, 스펙에서 Node 18 사용 예정

### 💡 Recommendations
- 🔴 **우선순위 1**: 하드코딩된 credential 즉시 제거 필수
- 🟡 우선순위 2: `any` 타입 제거 (+5점)
- 🟡 우선순위 3: `console.log` → winston (+3점)

**수정 후 예상 점수**: 82 + 18 = 100점
```

---

### 케이스 4: 경고만 (위반 0개, 경고 2개)

```json
{
  "score": 100,
  "compliant": [
    "금지 사항: any 타입, console.log 미사용 ✓",
    "품질 기준: 모두 명시 ✓"
  ],
  "violations": [],
  "warnings": [
    "⚠️  Constitution에서 TypeScript 5.3+ 권장하지만, 스펙에서 5.0 사용 예정",
    "⚠️  Constitution에서 테스트 커버리지 85%+ 요구하지만, 스펙에서 80% 명시"
  ],
  "recommendations": [
    "TypeScript 5.3+로 업그레이드 권장 (신규 기능 활용)",
    "테스트 커버리지 85%로 상향 조정 권장"
  ]
}
```

**Markdown 피드백**:
```markdown
## Constitution Compliance: 100/100 ✅

### ✅ Compliant
- 금지 사항: any 타입, console.log 미사용 ✓
- 품질 기준: 모두 명시 ✓

### ⚠️  Warnings (감점 없음)
- Constitution에서 TypeScript 5.3+ 권장하지만, 스펙에서 5.0 사용 예정
- Constitution에서 테스트 커버리지 85%+ 요구하지만, 스펙에서 80% 명시

### 💡 Recommendations
- TypeScript 5.3+로 업그레이드 권장 (신규 기능 활용)
- 테스트 커버리지 85%로 상향 조정 권장

**참고**: 경고는 참고사항이며, 점수에 영향 없습니다.
```

---

**JSON 스키마 (TypeScript)**:
```typescript
interface ConstitutionCheckResult {
  score: number;                    // 0-100
  compliant: string[];              // 준수한 항목들
  violations: Violation[];          // 위반 항목들
  warnings: string[];               // 경고 (감점 없음)
  recommendations: string[];        // 개선 제안
}

interface Violation {
  pattern: string;                  // 위반한 패턴 (예: "any type")
  location: string;                 // 스펙 내 위치 (예: "Section 3.2")
  context: string;                  // 발견된 문맥
  penalty: number;                  // 감점 (-5, -3, -10)
  solution: string;                 // 해결 방법
  reference: string;                // Constitution 참조 위치
}
```

---

**END OF SPECIFICATION**

**다음 단계**:
1. `/spec-review` 실행 → 90점 이상 확보
2. 구현 시작
3. `/validate` 실행 → 85점 이상 확보

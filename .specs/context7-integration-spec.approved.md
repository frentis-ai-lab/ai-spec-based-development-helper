# Context7-Integrated Language Template System Specification

> **역할**: 언어별 최신 스펙을 Context7 기반으로 제공하는 지속 가능한 템플릿 시스템
> **버전**: 1.0.0
> **작성일**: 2025-10-20

---

**✅ APPROVED on 2025-10-20**
- **평가 점수**: 96/100
- **평가자**: spec-analyzer (AI Agent)
- **승인 사유**: 모든 핵심 요구사항 충족, 엣지케이스 완벽, 구현 가능성 높음

---

## 1. 개요

### 1.1 프로젝트 목적

**문제**:
- 언어별 템플릿을 우리가 직접 유지보수 → 금방 outdated
- 새 언어/프레임워크 추가할 때마다 수동 작업
- 프레임워크 조합 폭발 (TypeScript × Express/NestJS/Next.js/...)

**솔루션**:
- Context7 MCP를 활용해 최신 언어/프레임워크 스펙 자동 조회
- 우리는 "평가 프로세스"만 제공, "기술 스펙"은 Context7에 위임
- 언어 중립적인 가이드 제공

**타겟 사용자**:
- Specification-First 개발 방법론을 사용하는 개발자
- 최신 베스트 프랙티스를 따르고 싶은 팀
- 다양한 언어/프레임워크를 사용하는 프로젝트

### 1.2 핵심 가치 제안

- **항상 최신**: Context7이 제공하는 최신 공식 문서 기반
- **지속 가능**: 우리는 프로세스만 관리, 기술 스펙은 Context7에 위임
- **확장 가능**: Context7에 있는 모든 언어/프레임워크 자동 지원
- **품질 보장**: 공식 문서 기반 검증 (+10점 보너스)

### 1.3 프로젝트 범위

**포함**:
- Context7 통합 로직 (spec-analyzer, /spec-init)
- "Modern Best Practices" 평가 기준 (10점)
- 언어 중립적 가이드 (`language-spec-guide.md`)
- 예시 스펙 3개 (TypeScript, Python, Java)
- Constitution 템플릿에 Context7 참조 가이드 추가

**제외**:
- 언어별 세부 템플릿 작성 (Context7가 제공)
- 프레임워크별 상세 가이드 (Context7가 제공)
- 버전별 마이그레이션 가이드 (Context7가 제공)

**향후 계획**:
- Phase 2: Context7 캐싱 최적화 (API 호출 최소화)
- Phase 3: Outdated 패턴 자동 감지 및 제안
- Phase 4: Context7 기반 자동 코드 예제 생성

---

## 2. 시스템 아키텍처

### 2.1 전체 구조도

```
┌─────────────────────────────────────────────────────────────┐
│                    User: /spec-init                         │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   spec-init Command            │
         │   (.claude/commands/)          │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Project Analyzer             │
         │   - Detect language            │
         │   - Detect frameworks          │
         │   - Extract versions           │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Context7 Query Engine        │
         │   - resolve-library-id         │
         │   - get-library-docs           │
         │   - Cache responses (15min)    │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Spec Generator               │
         │   - Merge template             │
         │   - Inject Context7 refs       │
         │   - Add version matrix         │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Output: .specs/[name].md     │
         │   - Technology References      │
         │   - Context7 links embedded    │
         │   - Best practices checklist   │
         └────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 User: /spec-review                          │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   spec-analyzer Agent          │
         │   (.claude/agents/)            │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Modern Best Practices        │
         │   Evaluator (NEW)              │
         │   - Context7 ref check (3pt)   │
         │   - Latest patterns (4pt)      │
         │   - Version compliance (3pt)   │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Context7 Validator           │
         │   - Fetch referenced docs      │
         │   - Compare with spec code     │
         │   - Detect deprecated patterns │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │   Score Report                 │
         │   - Total: X/100               │
         │   - Modern: Y/10               │
         │   - Recommendations            │
         └────────────────────────────────┘
```

### 2.2 기술 스택

**언어**: Bash (hooks), Markdown (agents, commands)
**MCP 통합**: Context7 (resolve-library-id, get-library-docs)
**프로젝트 감지**: 파일 기반 (package.json, pyproject.toml, pom.xml)
**캐싱**: Context7 내장 (15분 self-cleaning cache)

### 2.3 핵심 컴포넌트

#### 2.3.1 Project Analyzer

**역할**: 프로젝트 파일 분석 → 언어/프레임워크 감지

**입력**: 프로젝트 루트 디렉토리
**출력**:
```json
{
  "language": "typescript",
  "version": "5.3.3",
  "frameworks": ["express", "prisma"],
  "context7Targets": [
    "/microsoft/TypeScript/v5.3",
    "/expressjs/express",
    "/prisma/prisma"
  ]
}
```

**감지 로직**:
```bash
# TypeScript
if [[ -f "package.json" ]]; then
  lang="typescript"
  version=$(jq -r '.devDependencies.typescript // .dependencies.typescript' package.json)
  frameworks=$(jq -r '.dependencies | keys[]' package.json | grep -E 'express|nestjs|next')
fi

# Python
if [[ -f "pyproject.toml" ]]; then
  lang="python"
  version=$(grep 'python = ' pyproject.toml | sed 's/.*"\^*\([0-9.]*\)".*/\1/')
  frameworks=$(grep -E 'fastapi|django|flask' pyproject.toml)
fi

# Java
if [[ -f "pom.xml" ]]; then
  lang="java"
  version=$(xmllint --xpath '//maven.compiler.source/text()' pom.xml)
  frameworks=$(xmllint --xpath '//dependency/artifactId/text()' pom.xml | grep -E 'spring-boot|quarkus')
fi
```

#### 2.3.2 Context7 Query Engine

**역할**: Context7 MCP를 통해 최신 문서 조회

**API 사용**:
```typescript
// Step 1: Resolve library ID
const result = await mcp__context7__resolve_library_id({
  libraryName: "TypeScript"
});
// Returns: { id: "/microsoft/TypeScript", versions: ["v5.4", "v5.3", ...] }

// Step 2: Get documentation
const docs = await mcp__context7__get_library_docs({
  context7CompatibleLibraryID: "/microsoft/TypeScript/v5.4",
  topic: "strict mode, type inference",
  tokens: 5000
});
// Returns: { content: "...", snippets: [...] }
```

**캐싱 전략**:
- Context7 내장 15분 캐시 활용
- 동일한 library ID 재조회 시 캐시 히트
- 스펙 작성 중 여러 번 참조해도 API 호출 최소화

#### 2.3.3 Spec Generator

**역할**: 템플릿 + Context7 데이터 → 최종 스펙 생성

**생성 프로세스**:
1. `program-spec-template.md` 읽기
2. 사용자 요구사항 + 명확화 질문 답변
3. Context7 데이터 주입:
   - "Technology References" 섹션 생성
   - Version Matrix 테이블 생성
   - 코드 예제에 Context7 링크 주석 추가
4. `.specs/[feature-name]-spec.md` 작성

**주입 예시**:
```markdown
## 0. Technology References

### Context7 Documentation
- **TypeScript**: `/microsoft/TypeScript/v5.4`
  - Strict mode configuration
  - Type inference best practices
  - [Latest updates](context7:/microsoft/TypeScript/v5.4)

### Version Matrix
| 기술 | 현재 | 권장 | Context7 | Status |
|------|------|------|----------|--------|
| TypeScript | 5.3.3 | 5.4+ | `/microsoft/TypeScript/v5.4` | ⚠️  Update |
| Express | 4.18.2 | 4.19+ | `/expressjs/express` | ✅ OK |
| Node.js | 18.17.0 | 20.11+ | `/nodejs/node` | ⚠️  LTS 20 권장 |
```

#### 2.3.4 Modern Best Practices Evaluator

**역할**: spec-analyzer에 통합되는 평가 모듈

**평가 항목 (10점)**:

1. **Context7 참조 여부 (3점)**
   ```python
   def check_context7_references(spec_content):
       score = 0

       # Technology References 섹션 존재?
       if "## 0. Technology References" in spec_content:
           score += 1

       # Context7 링크 개수
       context7_links = re.findall(r'`/[a-z-]+/[a-z-]+(/v[0-9.]+)?`', spec_content)
       if len(context7_links) >= 3:
           score += 2
       elif len(context7_links) >= 1:
           score += 1

       return score
   ```

2. **최신 패턴 준수 (4점)**
   ```python
   async def check_latest_patterns(spec_content, context7_links):
       score = 0

       for link in context7_links:
           # Context7에서 해당 문서 조회
           docs = await get_library_docs(link)

           # 스펙의 코드 예제 추출
           code_examples = extract_code_blocks(spec_content)

           # Deprecated 패턴 감지
           deprecated = find_deprecated_patterns(code_examples, docs)

           if not deprecated:
               score += 1  # 최대 4점

       return min(score, 4)
   ```

3. **버전 명시 및 준수 (3점)**
   ```python
   def check_version_compliance(spec_content):
       score = 0

       # Version Matrix 테이블 존재?
       if "### Version Matrix" in spec_content:
           score += 1

       # EOL 버전 경고?
       if check_eol_versions(spec_content):
           score += 1

       # 권장 버전 명시?
       if "권장" in spec_content and "현재" in spec_content:
           score += 1

       return score
   ```

### 2.4 핵심 아키텍처 결정 (ADR)

#### ADR-001: Context7 vs 자체 템플릿 유지보수

**결정**: Context7 활용
**이유**:
- 최신 공식 문서 자동 반영
- 언어 추가 시 제로 작업량
- 프레임워크 조합 폭발 문제 해결

**트레이드오프**:
- Context7 API 의존성 (offline 작동 불가)
- 네트워크 지연 (캐싱으로 완화)

#### ADR-002: 평가 점수 추가 vs 기존 100점 유지

**결정**: 110점 만점 → 100점 환산
**이유**:
- 기존 90점 기준 유지 (하위 호환성)
- Modern Best Practices는 "보너스"로 인식
- Context7 미사용 시에도 90점 달성 가능

**계산식**:
```
기존 점수 (100점) + Modern (10점) = 110점
최종 점수 = (총점 / 110) × 100
```

#### ADR-003: Context7 조회 시점 - /spec-init vs /spec-review

**결정**: 두 시점 모두 사용
**이유**:
- **/spec-init**: 스펙 작성 시 참조 자료 제공
- **/spec-review**: 스펙 검증 시 최신성 확인

**시점별 역할**:
| 시점 | Context7 용도 |
|------|--------------|
| /spec-init | 스펙에 Context7 링크 주입, 최신 패턴 제안 |
| /spec-review | 링크 검증, deprecated 패턴 감지 |

---

## 3. 핵심 기능 목록

### 3.1 자동 프로젝트 분석

**요구사항**:
- 프로젝트 루트 파일 스캔 (package.json, pyproject.toml, pom.xml)
- 언어 및 버전 감지
- 주요 프레임워크/라이브러리 추출
- Context7 library ID 매핑

**입력**: 프로젝트 디렉토리
**출력**:
```json
{
  "detectedLanguage": "typescript",
  "version": "5.3.3",
  "frameworks": ["express", "prisma"],
  "context7Mappings": {
    "typescript": "/microsoft/TypeScript/v5.3",
    "express": "/expressjs/express",
    "prisma": "/prisma/prisma"
  },
  "recommendations": [
    "TypeScript 5.4+ 업그레이드 권장",
    "Node.js 20 LTS 사용 권장"
  ]
}
```

**엣지케이스**:
1. 언어 감지 실패 → 사용자에게 명시적 선택 요청
2. 여러 언어 혼합 (예: TypeScript + Python) → 주 언어 판단 후 부언어 표시
3. 버전 정보 없음 → Context7 최신 버전 사용

### 3.2 Context7 자동 조회

**요구사항**:
- `/spec-init` 실행 시 자동으로 Context7 조회
- 주요 기술별 최신 문서 가져오기
- 스펙에 참조 링크 주입

**API 호출 시퀀스**:
```
1. resolve-library-id("TypeScript")
   → "/microsoft/TypeScript"

2. get-library-docs("/microsoft/TypeScript/v5.4", topic="strict mode")
   → { content: "...", trustScore: 9 }

3. [스펙에 주입]
   - Technology References 섹션
   - 코드 예제 주석
   - Version Matrix
```

**엣지케이스**:
1. Context7에 없는 라이브러리 → 경고 + 사용자에게 수동 링크 요청
2. 네트워크 오류 → 캐시 우선, 없으면 스킵 + 경고
3. 버전 불일치 (현재 5.3, Context7 최신 5.4) → 업그레이드 권장 메시지

### 3.3 스펙 생성 시 Context7 통합

**요구사항**:
- 기존 `program-spec-template.md` 기반
- 새로운 "Technology References" 섹션 추가 (섹션 0)
- 코드 예제에 Context7 주석 자동 삽입

**생성 예시**:
```markdown
# User Authentication Specification

## 0. Technology References

### Context7 Documentation
- **TypeScript**: `/microsoft/TypeScript/v5.4`
  - Strict mode configuration
  - Type inference best practices

- **Express.js**: `/expressjs/express/v4.19`
  - Middleware composition
  - Error handling patterns

### Version Matrix
| 기술 | 현재 버전 | 권장 버전 | Context7 링크 | Status |
|------|-----------|-----------|--------------|--------|
| TypeScript | 5.3.3 | 5.4+ | `/microsoft/TypeScript/v5.4` | ⚠️  Update |
| Express | 4.18.2 | 4.19+ | `/expressjs/express` | ✅ OK |

---

## 5. 데이터 모델

### User Interface
```typescript
// Reference: TypeScript 5.4 - Strict Null Checks
// Context7: /microsoft/TypeScript/v5.4#strict-mode
interface User {
  id: string;          // UUID v4
  email: string;       // Unique, validated
  passwordHash: string; // bcrypt, rounds: 10
  createdAt: Date;
}
```

**타입 안정성 체크**:
- [x] Context7 참조: TypeScript strict mode
- [x] 모든 필드 명시적 타입
- [ ] Zod schema 정의 (Context7: `/colinhacks/zod`)
```

### 3.4 spec-analyzer에 Modern Best Practices 평가 추가

**요구사항**:
- 기존 100점 평가에 10점 추가 (110점 만점)
- Context7 참조 품질 평가
- Deprecated 패턴 자동 감지

**평가 프로세스**:
```
1. 스펙 파일 읽기
   ↓
2. "Technology References" 섹션 파싱
   ↓
3. Context7 링크 추출
   ↓
4. 각 링크에 대해:
   - Context7에서 최신 문서 조회
   - 스펙의 코드 예제 추출
   - Deprecated 패턴 비교
   ↓
5. 점수 계산:
   - 참조 여부: 3점
   - 최신 패턴: 4점
   - 버전 준수: 3점
   ↓
6. 피드백 생성
```

**출력 예시**:
```markdown
## Modern Best Practices: 8/10 points

✅ Compliant (8 points):
1. Context7 References (3/3)
   - 3개 주요 기술 참조
   - Version Matrix 포함

2. Latest Patterns (3/4)
   - TypeScript strict mode ✅
   - Express middleware composition ✅
   - Prisma query optimization ✅
   - bcrypt async 사용 권장 (현재 sync) ⚠️

3. Version Compliance (2/3)
   - 버전 명시 ✅
   - EOL 체크 ✅
   - 업그레이드 계획 없음 ❌

⚠️  Recommendations:
- bcrypt.hash() 대신 bcrypt.hashSync() 사용 중
  - Context7: /kelektiv/node.bcrypt.js#async-recommended
  - Fix: Use async variant in async context

- TypeScript 5.3 → 5.4 업그레이드 계획 추가
```

### 3.5 언어 중립적 가이드 작성

**요구사항**:
- `templates/language-spec-guide.md` 생성
- 모든 언어에 공통 적용 가능한 가이드
- Context7 활용법 상세 설명

**가이드 구조**:
```markdown
# Language Specification Guide

## 1. Context7 활용법
- 어떻게 라이브러리 찾기?
- 최신 버전 확인 방법
- Topic 키워드 작성 팁

## 2. 스펙 작성 체크리스트
- [ ] Technology References 섹션 추가
- [ ] Version Matrix 작성
- [ ] 코드 예제에 Context7 주석

## 3. 언어별 고려사항
### TypeScript
- strict mode 체크리스트
- 타입 안정성 검증

### Python
- Type hints 활용
- Virtual environment 전략

### Java
- JPMS 모듈 설계
- Maven/Gradle 표준
```

---

## 4. 데이터 모델

### 4.1 Project Detection Result

```typescript
interface ProjectDetectionResult {
  language: string;              // "typescript" | "python" | "java"
  version: string;               // "5.3.3"
  frameworks: string[];          // ["express", "prisma"]
  context7Mappings: Record<string, string>; // { "typescript": "/microsoft/TypeScript/v5.3" }
  recommendations: string[];     // ["TypeScript 5.4+ 권장"]
  confidence: number;            // 0.0 - 1.0
}
```

### 4.2 Context7 Query Result

```typescript
interface Context7QueryResult {
  libraryId: string;             // "/microsoft/TypeScript/v5.4"
  content: string;               // Markdown documentation
  snippets: CodeSnippet[];       // Code examples
  trustScore: number;            // 1-10
  lastUpdated: string;           // ISO date
}

interface CodeSnippet {
  language: string;
  code: string;
  description: string;
}
```

### 4.3 Modern Best Practices Score

```typescript
interface ModernBestPracticesScore {
  total: number;                 // 0-10
  breakdown: {
    context7References: number;  // 0-3
    latestPatterns: number;      // 0-4
    versionCompliance: number;   // 0-3
  };
  issues: Issue[];
  recommendations: string[];
}

interface Issue {
  severity: "error" | "warning" | "info";
  category: "deprecated" | "outdated" | "missing";
  message: string;
  context7Reference?: string;   // Link to docs
  fix?: string;                 // Suggested fix
}
```

---

## 5. 비기능 요구사항

### 5.1 성능

- **Context7 조회 시간**: < 2초 (캐시 미스)
- **Context7 조회 시간**: < 100ms (캐시 히트)
- **스펙 생성 시간**: < 5초 (Context7 조회 포함)
- **spec-analyzer 실행**: < 10초 (Modern 평가 포함)

### 5.2 신뢰성

- **Context7 오류 시**: Graceful degradation (스펙 생성은 계속, 경고만 표시)
- **네트워크 오류**: 캐시 우선 사용
- **타임아웃**: 5초 후 스킵

### 5.3 사용성

- **자동 감지 정확도**: > 95% (주요 3개 언어)
- **Context7 링크 품질**: Trust Score > 7 우선 사용
- **에러 메시지**: 구체적 해결 방법 포함

### 5.4 확장성

- **언어 추가**: Context7에 있으면 자동 지원 (코드 변경 불필요)
- **프레임워크 추가**: Detection 로직만 업데이트
- **평가 기준 추가**: Pluggable evaluator 구조

---

## 6. 외부 연동

### 6.1 Context7 MCP Integration

**API 사용**:
1. `mcp__context7__resolve-library-id`
   - 입력: 라이브러리 이름 (예: "TypeScript")
   - 출력: Context7 호환 ID (예: "/microsoft/TypeScript")

2. `mcp__context7__get-library-docs`
   - 입력: Context7 ID, topic, tokens
   - 출력: 문서 내용, 코드 스니펫, trust score

**에러 처리**:
```typescript
try {
  const docs = await get_library_docs(libraryId);
} catch (error) {
  if (error.code === "LIBRARY_NOT_FOUND") {
    console.warn(`⚠️  Context7에 ${libraryId} 없음. 수동 참조 필요.`);
    // Continue without Context7 data
  } else if (error.code === "NETWORK_ERROR") {
    console.warn(`⚠️  네트워크 오류. 캐시된 데이터 사용.`);
    // Use cached data or skip
  } else {
    throw error;
  }
}
```

### 6.2 캐싱 전략

**Context7 내장 캐시**:
- 15분 self-cleaning cache
- 동일 library ID 재조회 시 캐시 히트
- 별도 캐시 구현 불필요

**로컬 캐시 (Optional)**:
```bash
# .cache/context7/
# - typescript-5.4.json (24시간 유효)
# - express-latest.json
```

---

## 7. 구현 계획

### 7.1 Phase 1: Context7 Integration Core (Week 1)

#### Task 1.1: Project Analyzer 구현
```bash
# 파일: .claude/lib/project-analyzer.sh

function detect_project_type() {
  local project_root="$1"

  # TypeScript detection
  if [[ -f "$project_root/package.json" ]]; then
    echo "typescript"
    return 0
  fi

  # Python detection
  if [[ -f "$project_root/pyproject.toml" ]] || [[ -f "$project_root/setup.py" ]]; then
    echo "python"
    return 0
  fi

  # Java detection
  if [[ -f "$project_root/pom.xml" ]] || [[ -f "$project_root/build.gradle" ]]; then
    echo "java"
    return 0
  fi

  echo "unknown"
  return 1
}

function extract_frameworks() {
  local lang="$1"
  local project_root="$2"

  case "$lang" in
    typescript)
      jq -r '.dependencies | keys[]' "$project_root/package.json" \
        | grep -E 'express|nestjs|next|fastify'
      ;;
    python)
      grep -E 'fastapi|django|flask' "$project_root/pyproject.toml" \
        | cut -d'=' -f1 | tr -d ' "'
      ;;
    java)
      xmllint --xpath '//dependency/artifactId/text()' "$project_root/pom.xml" \
        | grep -E 'spring-boot|quarkus|micronaut'
      ;;
  esac
}
```

#### Task 1.2: Context7 Query Wrapper
```markdown
# 파일: .claude/lib/context7-query.md

## Context7 Query Function

### Usage
```bash
query_context7 "TypeScript" "strict mode, type inference"
# Returns: { libraryId, content, snippets }
```

### Implementation
1. Call `resolve-library-id` with library name
2. Extract library ID from response
3. Call `get-library-docs` with ID and topic
4. Cache result (15min)
5. Return structured data
```

#### Task 1.3: /spec-init 업데이트
```markdown
# 파일: .claude/commands/spec-init.md

## 기존 로직 유지
1. 요구사항 이해
2. 명확화 질문

## 추가 로직 (NEW)
3. **프로젝트 분석**
   - `source .claude/lib/project-analyzer.sh`
   - `detect_project_type .`
   - `extract_frameworks $lang .`

4. **Context7 자동 조회**
   - 각 감지된 기술별로 `query_context7` 호출
   - 결과를 변수에 저장

5. **스펙 생성 시 주입**
   - "Technology References" 섹션 생성
   - Version Matrix 생성
   - 코드 예제 주석 추가

6. 기존 스펙 작성 로직
```

### 7.2 Phase 2: spec-analyzer 업데이트 (Week 1)

#### Task 2.1: Modern Best Practices Evaluator
```markdown
# 파일: .claude/agents/spec-analyzer.md

## 기존 평가 항목 (100점)
[유지]

## 새 평가 항목 (10점)

### 6. Modern Best Practices (10점)

#### 6.1 Context7 참조 여부 (3점)

**평가 기준**:
```python
def evaluate_context7_references(spec_content):
    score = 0
    feedback = []

    # Technology References 섹션 존재?
    if "## 0. Technology References" in spec_content:
        score += 1
        feedback.append("✅ Technology References 섹션 존재")
    else:
        feedback.append("❌ Technology References 섹션 없음")
        return score, feedback

    # Context7 링크 개수
    context7_links = re.findall(
        r'`/[a-z-]+/[a-z-]+(/v[0-9.]+)?`',
        spec_content
    )

    if len(context7_links) >= 3:
        score += 2
        feedback.append(f"✅ Context7 참조 {len(context7_links)}개 (3개 이상)")
    elif len(context7_links) >= 1:
        score += 1
        feedback.append(f"⚠️  Context7 참조 {len(context7_links)}개 (3개 이상 권장)")
    else:
        feedback.append("❌ Context7 참조 없음")

    return score, feedback
```

#### 6.2 최신 패턴 준수 (4점)

**평가 프로세스**:
1. 스펙에서 Context7 링크 추출
2. 각 링크에 대해 `get-library-docs` 호출
3. 스펙의 코드 예제 추출
4. Deprecated 패턴 감지

**Deprecated 패턴 예시**:
```typescript
// TypeScript 5.4+
// Deprecated: namespace
namespace Utils { ... }  // ❌

// Recommended: ES modules
export function utils() { ... }  // ✅

// Deprecated: any
function process(data: any) { ... }  // ❌

// Recommended: unknown or generic
function process<T>(data: T) { ... }  // ✅
```

**점수 계산**:
```python
deprecated_patterns = detect_deprecated(code_examples, context7_docs)

if len(deprecated_patterns) == 0:
    score = 4
elif len(deprecated_patterns) <= 2:
    score = 2
else:
    score = 0
```

#### 6.3 버전 준수 (3점)

**평가 기준**:
- Version Matrix 존재: +1점
- EOL 버전 체크: +1점
- 업그레이드 계획 (outdated 시): +1점

**EOL 체크**:
```python
EOL_VERSIONS = {
    "node": ["14.x", "16.x"],       # EOL 2023
    "python": ["3.7", "3.8"],       # EOL 2023
    "java": ["8", "11"],            # Non-LTS
}

def check_eol(version_matrix):
    warnings = []
    for tech, version in version_matrix.items():
        if version in EOL_VERSIONS.get(tech, []):
            warnings.append(f"⚠️  {tech} {version} is EOL")
    return warnings
```
```

#### Task 2.2: 최종 점수 계산 로직

```markdown
## 점수 환산

**총점 계산**:
```
기존 점수 (100점) + Modern Best Practices (10점) = 110점
최종 점수 = (총점 / 110) × 100
```

**예시**:
- 기존 항목: 85/100
- Modern: 8/10
- 총점: 93/110
- 최종: (93/110) × 100 = **84.5/100**

**승인 기준**:
- 최종 점수 ≥ 90점: ✅ APPROVED
- 최종 점수 < 90점: ❌ REQUEST REVISION
```

### 7.3 Phase 3: 문서 및 예시 (Week 2)

#### Task 3.1: language-spec-guide.md 작성
```
templates/
└── language-spec-guide.md (NEW)
    - Context7 활용 매뉴얼
    - 체크리스트 템플릿
    - 언어별 팁
```

#### Task 3.2: 예시 스펙 3개 작성
```
templates/examples/
├── typescript-backend-example.md
├── python-fastapi-example.md
└── java-spring-example.md
```

#### Task 3.3: Constitution 템플릿 업데이트
```markdown
## 2. 기술 스택 표준 [AUTO-CHECK]

### 2.1 Context7 참조 필수

**모든 주요 라이브러리 사용 시 Context7 문서 참조 필수**

| 라이브러리 | Context7 링크 | 필수 여부 |
|-----------|--------------|----------|
| TypeScript | `/microsoft/TypeScript` | Required |
| Express | `/expressjs/express` | Required |
| Prisma | `/prisma/prisma` | Required |

**체크 항목**:
- [ ] 스펙에 "Technology References" 섹션 존재
- [ ] 주요 기술별 Context7 링크 포함
- [ ] Version Matrix 작성
```

### 7.4 Phase 4: 테스트 및 검증 (Week 2)

#### Task 4.1: 통합 테스트
```bash
# Test case 1: TypeScript 프로젝트 감지
cd examples/typescript-todo-api
/spec-init
# Expected: TypeScript, Express, Prisma 감지
# Expected: Context7 링크 3개 이상

# Test case 2: spec-analyzer Modern 평가
/spec-review
# Expected: Modern Best Practices 항목 출력
# Expected: 점수 계산 정확

# Test case 3: Python 프로젝트
cd examples/python-ml-project
/spec-init
# Expected: Python, FastAPI 감지
```

#### Task 4.2: /validate 실행
```bash
# 모든 구현 완료 후
/validate

# Expected:
# - Spec Compliance: 90+ (모든 요구사항 구현)
# - Code Quality: 85+
# - Test Coverage: 80+
```

---

## 8. 엣지케이스 및 리스크

### 8.1 엣지케이스

#### Case 1: Context7에 없는 라이브러리
**시나리오**: 사내 라이브러리 또는 마이너 프레임워크
**처리**:
```bash
⚠️  Context7에 'internal-auth-lib' 라이브러리 없음.

수동 참조 방법:
1. GitHub 링크 추가
2. 내부 문서 링크 추가
3. Version Matrix에 수동 입력

예:
## 0. Technology References
- **internal-auth-lib**: [GitHub](https://github.com/company/auth)
  - v2.3.1 (internal docs)
```

#### Case 2: 여러 언어 혼합 프로젝트
**시나리오**: Fullstack (TypeScript frontend + Python backend)
**처리**:
```bash
[프로젝트 분석]
- 주 언어: TypeScript (package.json 우선)
- 부 언어: Python (api/ 디렉토리)

생성할 스펙:
1. program-spec.md (전체 아키텍처)
2. api-spec.md (Python FastAPI)
3. ui-ux-spec.md (TypeScript React)

각 스펙에 해당 언어의 Context7 참조 포함
```

#### Case 3: 버전 불일치 (현재 < 권장)
**시나리오**: TypeScript 5.3 사용 중, Context7 최신은 5.4
**처리**:
```markdown
### Version Matrix
| 기술 | 현재 | 권장 | Context7 | Status |
|------|------|------|----------|--------|
| TypeScript | 5.3.3 | 5.4+ | `/microsoft/TypeScript/v5.4` | ⚠️  Update |

**업그레이드 계획**:
- [ ] TypeScript 5.4 호환성 체크
- [ ] 의존성 업데이트 (주 단위 마이그레이션)
- [ ] Breaking changes 대응
```

#### Case 4: Context7 네트워크 오류
**시나리오**: API 타임아웃 또는 서비스 장애
**처리**:
```bash
⚠️  Context7 조회 실패 (timeout after 5s)

Fallback:
1. 캐시된 데이터 사용 (15분 이내)
2. 캐시 없음 → 스펙 생성 계속 (경고 표시)
3. /spec-review 시 "Modern Best Practices" 항목 스킵

스펙 생성은 계속 진행됩니다.
Context7 참조는 나중에 추가 가능합니다.
```

#### Case 5: EOL 버전 사용
**시나리오**: Node.js 16 (EOL 2023-09-11)
**처리**:
```markdown
⚠️  **Security Alert**: Node.js 16.x is End-of-Life

### Version Matrix
| 기술 | 현재 | 권장 | Context7 | Status |
|------|------|------|----------|--------|
| Node.js | 16.17.0 | 20.11+ (LTS) | `/nodejs/node` | ❌ EOL |

**즉시 조치 필요**:
- Node.js 20 LTS로 업그레이드
- Security patches 받을 수 없음
- 마이그레이션 가이드: https://nodejs.org/en/blog/...
```

### 8.2 리스크 및 완화 전략

#### Risk 1: Context7 API 의존성 (HIGH)

**리스크**: Context7 서비스 장애 시 스펙 생성 불가
**완화 전략**:
1. Graceful degradation (경고 표시 후 계속)
2. 로컬 캐시 우선 사용
3. Essential data는 템플릿에 fallback 포함

**테스트**:
```bash
# Context7 비활성화 테스트
export CONTEXT7_DISABLED=true
/spec-init
# Expected: 경고 표시 + 스펙 생성 성공
```

#### Risk 2: 잘못된 프로젝트 타입 감지 (MEDIUM)

**리스크**: package.json 있지만 Python 프로젝트 (scripts만 있음)
**완화 전략**:
1. 복합 지표 사용 (파일 개수, 디렉토리 구조)
2. Confidence score 계산 (< 0.7이면 사용자 확인 요청)

**검증 로직**:
```bash
function validate_detection() {
  local lang="$1"
  local confidence=1.0

  if [[ "$lang" == "typescript" ]]; then
    # TypeScript 파일 개수 확인
    ts_files=$(find . -name "*.ts" | wc -l)
    if [[ $ts_files -lt 5 ]]; then
      confidence=0.5
    fi
  fi

  if (( $(echo "$confidence < 0.7" | bc -l) )); then
    echo "⚠️  언어 감지 신뢰도: $confidence"
    echo "수동 확인 필요. 언어 선택: [1] TypeScript [2] Python [3] Java"
  fi
}
```

#### Risk 3: Context7 Trust Score 낮은 문서 (MEDIUM)

**리스크**: Trust Score < 5인 문서 참조 → 잘못된 정보
**완화 전략**:
1. Trust Score ≥ 7만 자동 사용
2. 5-6: 경고 표시 + 사용자 확인
3. < 5: 스킵 + 대안 제시

**필터링 로직**:
```python
def filter_by_trust_score(results):
    high_trust = [r for r in results if r.trust_score >= 7]

    if high_trust:
        return high_trust[0]  # 가장 높은 trust score

    medium_trust = [r for r in results if r.trust_score >= 5]
    if medium_trust:
        print(f"⚠️  Trust Score: {medium_trust[0].trust_score}/10")
        print("수동 검증 권장")
        return medium_trust[0]

    print("❌ 신뢰할 수 있는 문서 없음. 공식 문서 직접 참조하세요.")
    return None
```

#### Risk 4: Deprecated 패턴 오탐 (LOW)

**리스크**: "avoid X" 예제를 deprecated로 잘못 감지
**완화 전략**:
1. 컨텍스트 분석 (주석, 섹션 제목)
2. 7가지 예외 패턴 인식
3. False positive 시 수동 무시 가능

**예외 패턴**:
```python
EXCEPTION_PATTERNS = [
    r"// ❌",           # Bad example marker
    r"// Don't",
    r"// Avoid",
    r"대안:",
    r"instead of",
    r"금지",
    r"Deprecated:"     # Explicit label
]

def is_negative_example(code_block):
    context = get_surrounding_text(code_block, lines=3)
    for pattern in EXCEPTION_PATTERNS:
        if re.search(pattern, context, re.IGNORECASE):
            return True
    return False
```

---

## 9. 테스트 전략

### 9.1 유닛 테스트

#### Test Suite 1: Project Analyzer
```bash
# test-project-analyzer.sh

test_detect_typescript() {
  cd fixtures/typescript-project
  result=$(detect_project_type .)
  assertEquals "typescript" "$result"
}

test_extract_frameworks() {
  cd fixtures/typescript-express
  frameworks=$(extract_frameworks typescript .)
  assertContains "$frameworks" "express"
  assertContains "$frameworks" "prisma"
}

test_unknown_project() {
  cd fixtures/empty-project
  result=$(detect_project_type .)
  assertEquals "unknown" "$result"
}
```

#### Test Suite 2: Context7 Query
```typescript
// test-context7-query.ts

describe("Context7 Query", () => {
  it("should resolve library ID", async () => {
    const result = await resolveLibraryId("TypeScript");
    expect(result.id).toBe("/microsoft/TypeScript");
  });

  it("should handle not found", async () => {
    const result = await resolveLibraryId("NonExistentLib");
    expect(result).toBeNull();
  });

  it("should use cache", async () => {
    await getLibraryDocs("/microsoft/TypeScript/v5.4");
    const start = Date.now();
    await getLibraryDocs("/microsoft/TypeScript/v5.4");
    const duration = Date.now() - start;
    expect(duration).toBeLessThan(100); // Cache hit
  });
});
```

#### Test Suite 3: Modern Best Practices Evaluator
```python
# test_modern_evaluator.py

def test_context7_references():
    spec = """
    ## 0. Technology References
    - TypeScript: `/microsoft/TypeScript/v5.4`
    - Express: `/expressjs/express`
    - Prisma: `/prisma/prisma`
    """
    score = evaluate_context7_references(spec)
    assert score == 3

def test_no_references():
    spec = "# Spec without Context7"
    score = evaluate_context7_references(spec)
    assert score == 0

def test_deprecated_detection():
    code = """
    namespace Utils {
      function helper() {}
    }
    """
    docs = get_library_docs("/microsoft/TypeScript/v5.4")
    deprecated = detect_deprecated([code], docs)
    assert "namespace" in deprecated
```

### 9.2 통합 테스트

#### E2E Test 1: Full Spec Creation Flow
```bash
# test-e2e-spec-creation.sh

test_full_typescript_flow() {
  # Setup
  cd fixtures/typescript-todo-api
  rm -rf .specs

  # Execute /spec-init
  echo "할일 CRUD API" | /spec-init

  # Assertions
  assertTrue "Spec file created" "[ -f .specs/todo-api-spec.md ]"

  spec_content=$(cat .specs/todo-api-spec.md)
  assertContains "$spec_content" "## 0. Technology References"
  assertContains "$spec_content" "/microsoft/TypeScript"
  assertContains "$spec_content" "### Version Matrix"
}
```

#### E2E Test 2: Full Review Flow
```bash
test_full_review_flow() {
  cd fixtures/typescript-todo-api

  # Execute /spec-review
  output=$(/spec-review)

  # Assertions
  assertContains "$output" "Modern Best Practices"
  assertContains "$output" "/10 points"
  assertContains "$output" "Context7 References"
}
```

### 9.3 테스트 커버리지 목표

| 카테고리 | 목표 |
|---------|------|
| Project Analyzer | 95% |
| Context7 Query | 90% |
| Modern Evaluator | 95% |
| spec-init Integration | 85% |
| spec-analyzer Integration | 85% |
| **전체** | **90%** |

---

## 10. 성공 메트릭

### 10.1 정량적 메트릭

| 메트릭 | 현재 | 목표 | 측정 방법 |
|--------|------|------|----------|
| 프로젝트 감지 정확도 | N/A | 95%+ | 통합 테스트 pass rate |
| Context7 조회 성공률 | N/A | 99%+ | API 호출 성공/실패 비율 |
| 스펙 생성 시간 | N/A | < 5초 | Time to .specs/*.md 생성 |
| Modern 평가 추가 시간 | N/A | < 2초 | /spec-review 증가 시간 |
| 사용자 만족도 | N/A | 4.5/5 | 설문 조사 |

### 10.2 정성적 메트릭

**기대 효과**:
1. **유지보수 부담 감소**: 언어별 템플릿 업데이트 불필요
2. **최신성 보장**: Context7 기반 자동 최신 패턴 적용
3. **확장성 향상**: 새 언어 추가 시 제로 작업
4. **품질 향상**: 공식 문서 기반 검증 → 프로덕션 버그 추가 -10%

---

## 11. 롤백 전략

### 11.1 기능 롤백

**시나리오**: Context7 통합이 문제 발생 시

**롤백 단계**:
```bash
# 1. Feature flag 비활성화
export CONTEXT7_ENABLED=false

# 2. 기존 동작으로 fallback
/spec-init  # Context7 없이 기존 템플릿만 사용

# 3. 이미 생성된 스펙은 유지
# (Technology References 섹션만 무시)
```

### 11.2 데이터 롤백

**시나리오**: 잘못된 Context7 데이터로 스펙 생성

**복구 방법**:
```bash
# 1. 기존 스펙 백업
cp .specs/feature-spec.md .specs/feature-spec.md.bak

# 2. Technology References 섹션 제거
sed -i '/## 0. Technology References/,/## 1./d' .specs/feature-spec.md

# 3. 수동 검증 후 재생성
/spec-init
```

### 11.3 코드 롤백

**Git 전략**:
```bash
# Feature branch로 개발
git checkout -b feature/context7-integration

# 문제 발생 시
git revert <commit-hash>

# 또는 완전 롤백
git checkout main
```

---

## 12. 개방된 질문 (Open Questions)

### 12.1 아직 결정하지 못한 사항

1. ❓ Context7 API 호출 빈도 제한이 있는가?
   - **영향**: Rate limiting 고려 필요
   - **해결 기한**: Phase 1 시작 전

2. ❓ Context7 Trust Score 계산 방식은?
   - **영향**: 필터링 threshold 결정
   - **해결 기한**: Phase 2 전

3. ❓ 로컬 캐시 구현 필요 여부?
   - **영향**: 성능 vs 복잡도 트레이드오프
   - **해결 기한**: Phase 1 중 성능 테스트 후

4. ❓ 프레임워크 조합 우선순위?
   - **예**: Next.js + Express 혼합 시 어느 것 우선?
   - **해결 기한**: Phase 1 중

5. ❓ Constitution에서 Context7 참조 강제 여부?
   - **옵션 A**: 필수 (점수 패널티)
   - **옵션 B**: 권장 (보너스만)
   - **해결 기한**: Phase 2 전

---

## 13. 부록

### 13.1 Context7 API 참조

```typescript
// resolve-library-id
interface ResolveLibraryIdRequest {
  libraryName: string; // "TypeScript", "Express", etc.
}

interface ResolveLibraryIdResponse {
  id: string;          // "/microsoft/TypeScript"
  versions: string[];  // ["v5.4", "v5.3", ...]
  trustScore: number;  // 1-10
}

// get-library-docs
interface GetLibraryDocsRequest {
  context7CompatibleLibraryID: string; // "/microsoft/TypeScript/v5.4"
  topic?: string;                      // "strict mode, type inference"
  tokens?: number;                     // default: 5000
}

interface GetLibraryDocsResponse {
  content: string;                     // Markdown documentation
  snippets: CodeSnippet[];
  trustScore: number;
  lastUpdated: string;                 // ISO date
}
```

### 13.2 프로젝트 감지 매핑 테이블

| 파일 | 언어 | 프레임워크 추출 방법 |
|------|------|---------------------|
| package.json | TypeScript | `jq '.dependencies \| keys'` |
| pyproject.toml | Python | `grep dependencies` + parse |
| pom.xml | Java | `xmllint --xpath '//artifactId'` |
| Cargo.toml | Rust | `toml get dependencies` |
| go.mod | Go | `grep require` |

### 13.3 Deprecated 패턴 데이터베이스

```yaml
# deprecated-patterns.yaml

typescript:
  - pattern: "namespace"
    replacement: "ES modules"
    context7: "/microsoft/TypeScript/v5.4#modules"

  - pattern: ": any"
    replacement: ": unknown or <T>"
    context7: "/microsoft/TypeScript/v5.4#strict-mode"

python:
  - pattern: "typing.List"
    replacement: "list (Python 3.9+)"
    context7: "/python/cpython/v3.12#type-hints"

java:
  - pattern: "new Date()"
    replacement: "LocalDateTime.now()"
    context7: "/openjdk/jdk/v21#datetime-api"
```

### 13.4 예시 출력

#### Example 1: /spec-init with Context7

```bash
$ /spec-init

[프로젝트 분석]
✅ 언어: TypeScript 5.3.3
✅ 프레임워크: Express 4.18.2, Prisma 5.9.0
✅ 런타임: Node.js 18.17.0

[Context7 조회 중...]
✅ TypeScript: /microsoft/TypeScript/v5.4 (Trust: 9/10)
✅ Express: /expressjs/express (Trust: 8/10)
✅ Prisma: /prisma/prisma (Trust: 9/10)

⚠️  권장사항:
- TypeScript 5.4+ 업그레이드 (새 기능: const type parameters)
- Node.js 20 LTS 고려 (현재 18은 2025-04 EOL)

요구사항을 설명해주세요:
User: 할일 CRUD API 만들고 싶어요

명확화 질문:
1. 인증 필요한가요? (JWT? Session?)
[...]

[스펙 생성 중...]
✅ .specs/todo-crud-api-spec.md
   - Technology References 섹션 추가됨
   - Context7 링크 3개 포함
   - Version Matrix 생성됨

다음: /spec-review 실행하세요
```

#### Example 2: /spec-review with Modern Best Practices

```bash
$ /spec-review

[spec-analyzer 실행 중...]

===== SPECIFICATION REVIEW REPORT =====

총점: 93/110 → 84.5/100

1. 아키텍처 이해도: 23/25
2. 요구사항 완성도: 24/25
3. 구현 계획: 18/20
4. 엣지케이스 & 리스크: 19/20
5. 예제 & 문서: 9/10
6. Modern Best Practices: 8/10 ⭐ (NEW)

---

## Modern Best Practices 상세 (8/10)

### Context7 참조 (3/3) ✅
✅ Technology References 섹션 존재
✅ Context7 링크 3개 (TypeScript, Express, Prisma)
✅ Version Matrix 완성

### 최신 패턴 (3/4) ⚠️
✅ TypeScript strict mode
✅ Express async middleware
✅ Prisma query optimization
❌ bcrypt sync 사용 (async 권장)

**수정 필요**:
- Line 145: `bcrypt.hashSync()` → `bcrypt.hash()`
  - Context7: /kelektiv/node.bcrypt.js#async-recommended
  - Reason: Blocks event loop

### 버전 준수 (2/3) ⚠️
✅ 버전 명시
✅ EOL 체크 통과
❌ 업그레이드 계획 없음

**권장사항**:
- TypeScript 5.3 → 5.4 마이그레이션 일정 추가
- 예상 영향: breaking changes 없음

---

**결정**: ⚠️  REQUEST REVISION

**다음 단계**:
1. bcrypt async 변경
2. TypeScript 업그레이드 계획 추가
3. /spec-review 재실행

목표: 90/100 (현재 84.5)
```

---

## 14. 검토 체크리스트

### 스펙 완성도
- [x] 모든 섹션 구체적으로 작성
- [x] Context7 통합 시나리오 명확
- [x] 엣지케이스 5개 이상 (총 5개)
- [x] 테스트 전략 상세
- [x] 롤백 전략 명확
- [x] 성공 메트릭 측정 가능

### 기술적 타당성
- [x] Context7 MCP API 활용 가능
- [x] Bash 스크립트로 구현 가능
- [x] 기존 시스템과 통합 가능
- [x] 성능 요구사항 달성 가능

### 비즈니스 가치
- [x] 유지보수 부담 감소
- [x] 확장성 대폭 개선
- [x] 품질 향상 기대
- [x] 사용자 경험 개선

---

**문서 버전**: 1.0.0
**최종 수정**: 2025-10-20
**작성자**: AI Assistant (Claude)
**승인자**: spec-analyzer (AI Agent)
**승인 날짜**: 2025-10-20
**다음 단계**: 구현 시작 (Phase 1)

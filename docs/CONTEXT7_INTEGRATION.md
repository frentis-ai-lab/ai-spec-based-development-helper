# Context7 Integration Guide

> **목적**: Context7 MCP를 통한 최신 라이브러리 문서 자동 조회
> **버전**: 1.0.0
> **업데이트**: 2025-10-20

---

## 📚 개요

### Context7이란?

Context7은 **최신 라이브러리/프레임워크 공식 문서를 자동으로 제공하는 MCP 서버**입니다.

**장점**:
- ✅ 항상 최신 문서 (자동 업데이트)
- ✅ 공식 소스 기반 (Trust Score로 신뢰도 측정)
- ✅ 유지보수 불필요 (우리가 관리할 템플릿 없음)

### 왜 필요한가?

| Before (템플릿 방식) | After (Context7 방식) |
|---------------------|---------------------|
| 언어별 템플릿 수동 작성 | Context7 자동 조회 |
| 정기 업데이트 필요 (주 2시간) | 자동 최신화 (0시간) |
| 새 언어 추가: 4시간 | 새 언어 추가: 0시간 |
| Outdated 위험 | 항상 최신 |

---

## 🚀 설정 방법

### 1. MCP 서버 설정

프로젝트에 `.mcp.json` 파일이 이미 포함되어 있습니다:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {}
    }
  }
}
```

### 2. Claude Code 재시작

1. Claude Code 완전 종료
2. 다시 시작
3. MCP 아이콘 확인 (하단 바 또는 상태 표시)

### 3. 확인

```bash
# Claude Code에서
/spec-init

# 출력에서 확인:
[프로젝트 분석]
✅ 언어: TypeScript
✅ Context7 조회 중...
✅ TypeScript: /microsoft/TypeScript/v5.4 (Trust: 9/10)
```

---

## 📖 사용 방법

### 자동 사용 (권장)

`/spec-init` 실행 시 자동으로:

1. **프로젝트 분석**
   ```
   - package.json 감지 → TypeScript
   - express, prisma 감지 → 프레임워크
   ```

2. **Context7 자동 조회**
   ```
   - TypeScript → /microsoft/TypeScript/v5.4
   - Express → /expressjs/express
   - Prisma → /prisma/prisma
   ```

3. **스펙에 자동 주입**
   ```markdown
   ## 0. Technology References

   ### Context7 Documentation
   - **TypeScript**: `/microsoft/TypeScript/v5.4`
     - Strict mode configuration
     - Type inference best practices

   ### Version Matrix
   | 기술 | 현재 | 권장 | Context7 | Status |
   |------|------|------|----------|--------|
   | TypeScript | 5.3.3 | 5.4+ | `/microsoft/TypeScript/v5.4` | ⚠️  Update |
   ```

### 수동 사용

직접 MCP 도구 호출:

```typescript
// 1. Library ID 조회
const result = await mcp__context7__resolve_library_id({
  libraryName: "TypeScript"
});
// Returns: { id: "/microsoft/TypeScript", versions: [...] }

// 2. 문서 조회
const docs = await mcp__context7__get_library_docs({
  context7CompatibleLibraryID: "/microsoft/TypeScript/v5.4",
  topic: "strict mode, type inference",
  tokens: 5000
});
// Returns: { content: "...", snippets: [...], trustScore: 9 }
```

---

## 🎯 지원 언어 및 프레임워크

### 자동 감지 지원

| 언어 | 감지 파일 | 프레임워크 예시 |
|------|----------|----------------|
| **TypeScript** | `package.json` | Express, NestJS, Next.js, Fastify |
| **Python** | `pyproject.toml`, `requirements.txt` | FastAPI, Django, Flask |
| **Java** | `pom.xml`, `build.gradle` | Spring Boot, Quarkus, Micronaut |

### Context7 매핑

자동으로 다음과 같이 매핑됩니다:

```bash
TypeScript → /microsoft/TypeScript
Express   → /expressjs/express
React     → /facebook/react
FastAPI   → /tiangolo/fastapi
Django    → /django/django
Spring    → /spring-projects/spring-boot
```

전체 매핑 목록: `.claude/lib/project-analyzer.sh` 참조

---

## 📊 Trust Score

Context7은 각 문서에 Trust Score (1-10)를 제공합니다.

### 기준

- **9-10**: 공식 문서, 매우 신뢰할 수 있음
- **7-8**: 검증된 커뮤니티 문서
- **5-6**: 일반 문서, 수동 검증 권장
- **1-4**: 신뢰도 낮음, 사용 비권장

### 자동 필터링

spec-analyzer가 자동으로 필터링:

```python
if docs.trustScore >= 7:
    # 자동 사용 승인
    inject_to_spec(docs)
elif docs.trustScore >= 5:
    # 경고 + 사용자 확인
    warn("Trust Score: 5/10 - Manual verification recommended")
else:
    # 스킵
    skip("Trust Score too low")
```

---

## 🔍 작동 원리

### 1. 프로젝트 분석

```bash
.claude/lib/project-analyzer.sh
├─ detect_project_type()      # TypeScript, Python, Java
├─ extract_version()           # 5.3.3
├─ extract_frameworks()        # express, prisma
└─ map_to_context7_id()        # /microsoft/TypeScript
```

### 2. Context7 조회

```
Claude → MCP Client → Context7 Server → Official Docs
         ↑
    .mcp.json
```

### 3. 스펙 주입

```
/spec-init 실행
  ↓
project-analyzer.sh 실행
  ↓
Context7 조회 (MCP)
  ↓
"§ 0. Technology References" 생성
  ↓
.specs/feature-spec.md
```

### 4. 검증

```
/spec-review 실행
  ↓
spec-analyzer.md
  ↓
"Modern Best Practices" 평가 (10점)
  - Context7 참조 여부: 3점
  - 최신 패턴 준수: 4점
  - 버전 준수: 3점
  ↓
90+ 점 → 승인
```

---

## 🛠️ 트러블슈팅

### MCP 아이콘이 보이지 않음

**원인**: MCP 서버가 시작되지 않음

**해결**:
```bash
# 1. .mcp.json 확인
cat .mcp.json

# 2. Node.js 버전 확인 (>= 18 필요)
node --version

# 3. npx 작동 확인
npx -y @upstash/context7-mcp --help

# 4. Claude Code 재시작
```

### Context7 조회 실패

**원인**: 네트워크 오류 또는 라이브러리 없음

**동작**:
```
⚠️  Context7 조회 실패 (timeout after 5s)

Fallback:
1. 캐시된 데이터 사용 (15분 이내)
2. 캐시 없음 → 스펙 생성 계속 (경고 표시)

스펙 생성은 계속 진행됩니다.
Context7 참조는 나중에 추가 가능합니다.
```

**수동 수정**:
```markdown
## 0. Technology References
- **TypeScript**: [GitHub](https://github.com/microsoft/TypeScript)
  - (Context7 대신 수동 링크)
```

### Deprecated 패턴 오탐

**원인**: "avoid X" 예제를 deprecated로 잘못 감지

**해결**: 7가지 예외 패턴 자동 인식
```markdown
❌ 이런 패턴은 OK (교육 목적):
- "avoid any type"
- "대안: unknown 사용"
- "// ❌ console.log 금지"
```

### EOL 버전 경고

**상황**:
```
❌ **Security Alert**: Node.js 16.x is End-of-Life

**즉시 조치 필요**:
- Node.js 20 LTS로 업그레이드
```

**대응**:
1. 업그레이드 계획 작성
2. Version Matrix에 반영
3. /spec-review 재실행

---

## 📈 성능

### 캐싱

Context7은 15분 self-cleaning cache 제공:

| 상황 | 조회 시간 |
|------|----------|
| 첫 조회 (캐시 미스) | ~2초 |
| 재조회 (캐시 히트) | <100ms |
| 15분 후 | 다시 2초 |

### API 호출 최소화

```
/spec-init 1회 실행:
- TypeScript 조회: 1회
- Express 조회: 1회
- Prisma 조회: 1회
- 총 3회 API 호출

/spec-review:
- 기존 링크 재검증: 캐시 히트 (0 API 호출)
```

---

## 🎓 예시

### 완전한 예시

`templates/examples/typescript-backend-example.md` 참조:

```markdown
## 0. Technology References

### Context7 Documentation
- **TypeScript**: `/microsoft/TypeScript/v5.4`
  - Strict mode configuration
  - Type inference best practices
  - Const type parameters (new in 5.4)

- **Express**: `/expressjs/express/v4.19`
  - Async error handling middleware
  - Router composition patterns

### Version Matrix
| 기술 | 현재 | 권장 | Context7 | Status |
|------|------|------|----------|--------|
| TypeScript | 5.4.0 | 5.4+ | `/microsoft/TypeScript/v5.4` | ✅ OK |
| Express | 4.19.0 | 4.19+ | `/expressjs/express` | ✅ OK |

### Code Example
```typescript
// Reference: TypeScript 5.4 - Strict Null Checks
// Context7: /microsoft/TypeScript/v5.4#strict-mode
interface User {
  id: string;
  email: string;
}
```

**예상 점수**: 10/10 (Modern Best Practices)
```

---

## 📚 추가 자료

- **전체 스펙**: `.specs/context7-integration-spec.md`
- **언어별 가이드**: `templates/language-spec-guide.md`
- **Project Analyzer**: `.claude/lib/project-analyzer.sh`
- **Context7 Query 가이드**: `.claude/lib/context7-query.md`

---

## 🤝 기여

Context7 매핑 추가는 쉽습니다:

```bash
# .claude/lib/project-analyzer.sh
map_to_context7_id() {
  case "$lib_name" in
    # 새 매핑 추가
    your-lib) echo "/org/your-lib" ;;
    ...
  esac
}
```

PR 환영합니다!

---

**Version**: 1.0.0
**Last Updated**: 2025-10-20
**Maintainer**: Frentis AI Lab

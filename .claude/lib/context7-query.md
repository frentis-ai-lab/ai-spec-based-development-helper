# Context7 Query Helper

This document provides instructions for querying Context7 MCP to retrieve latest documentation for libraries and frameworks.

## Purpose

When generating specifications with `/spec-init`, automatically query Context7 to:
1. Get latest documentation for detected technologies
2. Inject Context7 references into the spec
3. Create a Version Matrix table
4. Add code example comments with Context7 links

## Usage Pattern

### Step 1: Resolve Library ID

Given a library name (e.g., "TypeScript", "Express"), resolve it to a Context7-compatible ID.

```typescript
// Use the MCP tool
const result = await mcp__context7__resolve_library_id({
  libraryName: "TypeScript"
});

// Result format:
{
  id: "/microsoft/TypeScript",
  versions: ["v5.4", "v5.3", "v5.2"],
  trustScore: 9
}
```

**Error Handling**:
- If library not found → Log warning, continue without Context7 data
- If network error → Use cached data if available, otherwise skip

### Step 2: Get Library Documentation

Once you have the library ID, fetch the documentation:

```typescript
const docs = await mcp__context7__get_library_docs({
  context7CompatibleLibraryID: "/microsoft/TypeScript/v5.4",
  topic: "strict mode, type inference, best practices",
  tokens: 5000
});

// Result format:
{
  content: "...",  // Markdown documentation
  snippets: [...], // Code examples
  trustScore: 9,
  lastUpdated: "2025-01-15"
}
```

**Topic Selection Tips**:
- For language: "best practices, latest features, common patterns"
- For framework: "architecture, middleware, error handling"
- For library: "usage examples, common pitfalls"

### Step 3: Filter by Trust Score

Only use documentation with Trust Score ≥ 7 for automatic injection.

```typescript
if (docs.trustScore < 7) {
  console.warn(`⚠️  Trust Score: ${docs.trustScore}/10 (threshold: 7)`);
  console.warn("Manual verification recommended");
  // Still use, but with warning
}

if (docs.trustScore < 5) {
  console.error(`❌ Trust Score too low: ${docs.trustScore}/10`);
  // Skip this library
  return null;
}
```

## Spec Injection Format

### Section 0: Technology References

Add this as the first section (before "## 1. 개요"):

```markdown
## 0. Technology References

### Context7 Documentation

- **TypeScript**: \`/microsoft/TypeScript/v5.4\`
  - Strict mode configuration
  - Type inference best practices
  - Latest features (const type parameters)

- **Express.js**: \`/expressjs/express/v4.19\`
  - Middleware composition patterns
  - Error handling strategies
  - Async route handlers

### Version Matrix

| 기술 | 현재 버전 | 권장 버전 | Context7 링크 | Status |
|------|-----------|-----------|--------------|--------|
| TypeScript | 5.3.3 | 5.4+ | \`/microsoft/TypeScript/v5.4\` | ⚠️  Update |
| Express | 4.18.2 | 4.19+ | \`/expressjs/express\` | ✅ OK |
| Node.js | 18.17.0 | 20.11+ (LTS) | \`/nodejs/node\` | ⚠️  LTS 20 권장 |

**Status 기준**:
- ✅ OK: 현재 버전이 권장 버전 이상
- ⚠️  Update: 업그레이드 권장
- ❌ EOL: End-of-Life, 즉시 업그레이드 필요
```

### Code Example Comments

When adding code examples to the spec, include Context7 references:

```markdown
### User Interface

\`\`\`typescript
// Reference: TypeScript 5.4 - Strict Null Checks
// Context7: /microsoft/TypeScript/v5.4#strict-mode
interface User {
  id: string;          // UUID v4
  email: string;       // Unique, validated
  passwordHash: string; // bcrypt, rounds: 10
  createdAt: Date;
}
\`\`\`

**타입 안정성 체크**:
- [x] Context7 참조: TypeScript strict mode
- [x] 모든 필드 명시적 타입
- [ ] Zod schema 정의 (Context7: \`/colinhacks/zod\`)
```

## EOL Version Detection

Check if detected versions are End-of-Life:

```typescript
const EOL_VERSIONS = {
  node: ["14.x", "16.x"],      // EOL 2023
  python: ["3.7", "3.8"],      // EOL 2023
  java: ["8"],                 // Non-LTS (11 is)
};

function checkEOL(tech: string, version: string): boolean {
  const eolList = EOL_VERSIONS[tech] || [];
  return eolList.some(eol => version.startsWith(eol));
}
```

If EOL detected:
```markdown
⚠️  **Security Alert**: Node.js 16.x is End-of-Life

**즉시 조치 필요**:
- Node.js 20 LTS로 업그레이드
- Security patches 받을 수 없음
- 마이그레이션 가이드: [Context7 링크]
```

## Caching Strategy

Context7 has built-in 15-minute cache. For same library ID:
- First call: ~2 seconds (network)
- Subsequent calls: <100ms (cache hit)

No additional caching implementation needed unless:
- Need longer cache duration (24 hours)
- Want offline fallback
- Need to persist across sessions

## Error Scenarios

### Library Not Found in Context7

```markdown
⚠️  Context7에 'internal-auth-lib' 라이브러리 없음.

**수동 참조 방법**:
1. GitHub 링크 추가
2. 내부 문서 링크 추가
3. Version Matrix에 수동 입력

예:
## 0. Technology References
- **internal-auth-lib**: [GitHub](https://github.com/company/auth)
  - v2.3.1 (internal docs)
```

### Network Error

```markdown
⚠️  Context7 조회 실패 (timeout after 5s)

**Fallback**:
1. 캐시된 데이터 사용 (15분 이내)
2. 캐시 없음 → 스펙 생성 계속 (경고 표시)
3. /spec-review 시 "Modern Best Practices" 항목 스킵

스펙 생성은 계속 진행됩니다.
Context7 참조는 나중에 추가 가능합니다.
```

### Multiple Languages (Fullstack)

For projects with multiple languages (e.g., TypeScript + Python):

```markdown
## 0. Technology References

### Frontend (TypeScript)
- **TypeScript**: \`/microsoft/TypeScript/v5.4\`
- **React**: \`/facebook/react\`

### Backend (Python)
- **Python**: \`/python/cpython/v3.12\`
- **FastAPI**: \`/tiangolo/fastapi\`

### Version Matrix
| 카테고리 | 기술 | 현재 | 권장 | Context7 |
|---------|------|------|------|----------|
| Frontend | TypeScript | 5.3 | 5.4+ | \`/microsoft/TypeScript/v5.4\` |
| Backend | Python | 3.11 | 3.12+ | \`/python/cpython/v3.12\` |
```

## Implementation Checklist

When implementing Context7 integration in `/spec-init`:

- [ ] Source project-analyzer.sh
- [ ] Detect project type and frameworks
- [ ] For each detected technology:
  - [ ] Call `resolve-library-id`
  - [ ] Call `get-library-docs` with relevant topic
  - [ ] Check trust score (≥7)
  - [ ] Store results
- [ ] Generate "Technology References" section
- [ ] Generate "Version Matrix" table
- [ ] Check for EOL versions
- [ ] Inject Context7 comments in code examples
- [ ] Handle errors gracefully (network, not found, etc.)

## Example Output

See `.specs/context7-integration-spec.md` § 13.4 for full examples of:
- `/spec-init` output with Context7 integration
- Generated spec with Technology References section
- Version Matrix with status indicators

## Testing

Test Context7 integration with:

```bash
# Test 1: Resolve library ID
resolve-library-id "TypeScript"
# Expected: /microsoft/TypeScript

# Test 2: Get documentation
get-library-docs "/microsoft/TypeScript/v5.4" "strict mode"
# Expected: Markdown content with trust score

# Test 3: Network error handling
# (simulate by disconnecting network)
# Expected: Graceful degradation, spec generation continues
```

## Notes

- Context7 caching is automatic (15min)
- Trust score threshold: 7 (configurable)
- EOL version list should be updated quarterly
- All Context7 links should use backticks: \`/org/repo\`
- Version Matrix status emoji: ✅ ⚠️ ❌

---

**Document Version**: 1.0.0
**Last Updated**: 2025-10-20

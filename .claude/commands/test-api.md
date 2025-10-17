# Test API - API Tests Only

Generate and execute ONLY API tests (endpoint testing, authentication, etc.).

## Usage

```bash
/test api [path]
```

**Use case**: Backend development. Test REST API endpoints, authentication, error responses.

---

## Your Task

Invoke test-runner with API-test-only mode:

```
Run automated test generation and execution - API TESTS ONLY.

Target: {target_path or current directory}
Model preference: haiku
Coverage target: 85%
Test scope: API ONLY (HTTP endpoints, authentication, API error handling)

Execute phases:
1. Analysis - Detect project type (must be backend), find api-spec.md
2. Generation - Generate ONLY API tests
   - Focus: Endpoint tests (GET, POST, PUT, DELETE)
   - Focus: Authentication/authorization
   - Focus: Request validation (400 errors)
   - Focus: Error responses (401, 404, 500)
   - Skip: Unit tests for internal functions
   - Skip: UI tests

   Use framework:
   - TypeScript: Supertest
   - Python: httpx or TestClient (FastAPI)

3. Execution - Run API tests (may be slower than unit tests)
4. Reporting - Create report

Reference: .specs/api-spec.md (if exists)

Provide:
- Console summary (brief, cyan-colored)
- Detailed report in .test-reports/YYYY-MM-DD-HHmmss/
```

---

**Expected api-spec.md structure**:
- API endpoints with request/response schemas
- Error codes (400, 401, 404, 500)
- Authentication method (JWT, session, API key)
- Edge cases (invalid input, missing fields, etc.)

---

**Next Steps**:

After API tests pass:
```
✅ API tests passing

Next steps:
1. /test unit (if not done) - Test business logic
2. /validate - Full implementation validation
3. Manual integration testing (Postman, curl)
```

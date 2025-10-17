# Test Unit - Unit Tests Only

Generate and execute ONLY unit tests (faster feedback, no API/UI tests).

## Usage

```bash
/test unit [path]
```

**Use case**: Quick feedback loop during development. API/UI tests are slower.

---

## Your Task

Invoke test-runner with unit-test-only mode:

```
Run automated test generation and execution - UNIT TESTS ONLY.

Target: {target_path or current directory}
Model preference: haiku
Coverage target: 85%
Test scope: UNIT ONLY (exclude API, UI, integration tests)

Execute phases:
1. Analysis - Detect project type, find specs
2. Generation - Generate ONLY unit tests for functions/classes
   - Skip: API endpoint tests
   - Skip: UI component tests
   - Focus: Pure functions, business logic, utility functions
3. Execution - Run unit tests only (faster)
4. Reporting - Create report

Provide:
- Console summary (brief, cyan-colored)
- Detailed report in .test-reports/YYYY-MM-DD-HHmmss/
```

---

**Next Steps**:

After unit tests pass:
```
✅ Unit tests passing

Next steps:
1. /test api (if backend) - Test API endpoints
2. /test ui (if frontend) - Test UI components
3. /validate - Full implementation validation
```

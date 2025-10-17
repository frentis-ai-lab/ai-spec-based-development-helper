# Test - Automated Test Generation and Execution

Generate and execute tests automatically based on specification files.

## Usage

```bash
/test [path] [--model haiku|sonnet] [--coverage N]
```

**Parameters**:
- `path` (optional): Target file or directory (default: current directory)
- `--model` (optional): AI model to use (default: `haiku`)
- `--coverage` (optional): Coverage target percentage (default: `85`)

**Examples**:
```bash
/test                          # Test entire project
/test src/services/todo.ts     # Test specific file
/test src/services/            # Test directory
/test --model sonnet           # Use Sonnet for complex logic
/test --coverage 90            # Aim for 90% coverage
```

---

## Your Task

### Step 1: Parse Arguments

Extract from user's command:
- `target_path`: File/directory to test (default: `.`)
- `model_preference`: `haiku` or `sonnet` (default: `haiku`)
- `coverage_target`: Number 0-100 (default: `85`)

---

### Step 2: Invoke test-runner Agent

Use the Task tool to launch the test-runner sub-agent:

```
Run automated test generation and execution.

Target: {target_path}
Model preference: {model_preference}
Coverage target: {coverage_target}%

Execute all 4 phases:
1. Analysis - Detect project type, find specs, analyze existing tests
2. Generation - Generate missing tests based on specs
3. Execution - Run tests with coverage
4. Reporting - Create detailed report

Provide:
- Console summary (brief, cyan-colored)
- Detailed report in .test-reports/YYYY-MM-DD-HHmmss/
- Actionable next steps

Reference specification at: .specs/test-runner-spec.md
```

---

### Step 3: Monitor Progress

The test-runner agent will output progress messages. Display them to the user in real-time.

Expected phases:
1. "Phase 1: Analysis - Detecting project type..."
2. "Phase 2: Generation - Creating X tests..."
3. "Phase 3: Execution - Running tests..."
4. "Phase 4: Reporting - Generating summary..."

---

### Step 4: Display Results

When test-runner completes, it will output:
- Console summary with test counts, coverage %, top failures
- File path to detailed report

Show this directly to the user.

---

### Step 5: Guide Next Steps

Based on the test results:

**If all tests pass AND coverage >= target**:
```
✅ All tests passing!
✅ Coverage target met ({actual}% >= {target}%)

Next: Run /validate to verify implementation quality
```

**If tests fail OR coverage < target**:
```
⚠️  Action required:

1. Fix {N} failing tests (see report for details)
2. Add tests to reach {target}% coverage (currently {actual}%)

Full report: .test-reports/{timestamp}/summary.md

After fixes, run /test again, then /validate
```

**If test generation failed**:
```
❌ Test generation failed

Common issues:
- No spec files → Run /spec-init first
- Test framework missing → Install vitest/pytest
- Syntax errors in code → Fix before testing

Check error message above for details.
```

---

## Important Notes

- **Spec-driven**: test-runner references `.specs/*.md` files
- **If no specs**: Basic tests generated from code structure (limited coverage)
- **Cost-efficient**: Uses Haiku by default (Sonnet for complex functions only)
- **Non-destructive**: Never overwrites existing tests, only appends

---

## Integration with Specification-First Workflow

**Typical usage**:
```
1. /spec-init     → Write spec
2. /spec-review   → Get 90+ score
3. [Implement]    → Write code
4. /test          → Generate & run tests ← YOU ARE HERE
5. /validate      → Verify spec compliance (85+ score)
6. [Deploy]       → Ship it!
```

---

## Troubleshooting

**"No spec files found"**:
- Run `/spec-init` to create specifications
- Or continue with basic tests (limited quality)

**"Vitest/PyTest not found"**:
- test-runner will prompt to install
- Approve installation when asked

**"Test execution timed out"**:
- Large test suites may take > 5 minutes
- Try testing smaller directories
- Or increase timeout in test-runner.md

**"Coverage not improving"**:
- Check `.test-reports/*/summary.md` for uncovered lines
- Verify generated tests are actually testing edge cases
- May need to manually add complex scenario tests

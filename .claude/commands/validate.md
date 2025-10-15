# Validate Implementation

Validate that the implementation matches the specification using the implementation-validator agent.

## Your Task

1. **Locate Specification & Implementation**
   - Find the relevant spec in `.specs/`
   - Identify which files were implemented
   - If unclear, ask user which implementation to validate

2. **Read Both Spec and Code**
   - Read the specification document thoroughly
   - Read all implementation files
   - Note any test files

3. **Invoke implementation-validator Agent**
   Use the Task tool to launch the implementation-validator agent:

   ```
   Validate the implementation against the specification.

   Specification: [spec-file-path]
   Implementation files: [list of files]

   Check:
   1. Spec Compliance (40 points)
      - All requirements implemented
      - No scope creep
      - Matches architecture
      - Follows specified patterns
      - Handles documented edge cases

   2. Code Quality (30 points)
      - Language best practices
      - Proper error handling
      - No code smells
      - Consistent naming
      - Adequate comments

   3. Testing (20 points)
      - Unit tests present
      - Edge cases tested
      - Error scenarios covered
      - Coverage meets standards
      - Integration tests for critical paths

   4. Completeness (10 points)
      - Documentation updated
      - Migration scripts (if needed)
      - Configuration examples
      - Clear commit messages

   Identify "should work" red flags:
   - Untested code paths
   - TODO comments in critical sections
   - Missing error handling
   - Hardcoded values
   - Assumptions without validation

   Provide:
   - Compliance score (X/100)
   - What's correctly implemented
   - Partial/incomplete features
   - Missing/incorrect items
   - Code quality issues (with line numbers)
   - Test coverage analysis
   - Required fixes (prioritized)
   - Recommendation (ACCEPT / REQUEST REVISION / REJECT)
   ```

4. **Process Validation Results**
   - Display the validation report
   - If score >= 85: Implementation acceptable
   - If score < 85: List required fixes
   - Update validation timestamp: `date +%s > .specs/.last-validation`

5. **Guide Next Steps**
   Based on score:
   - **85-100**: "Implementation approved. Consider peer review."
   - **70-84**: "Good work. Address these issues before merging."
   - **60-69**: "Significant gaps. Revision required."
   - **< 60**: "Does not meet spec. Major rework needed."

## Validation Standards
- Zero tolerance for untested critical paths
- Demand proof, not promises
- Enforce spec alignment
- Code must reveal understanding
- All assumptions must be validated
- "It works" requires evidence

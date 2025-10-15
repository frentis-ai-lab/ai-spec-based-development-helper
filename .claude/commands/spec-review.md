# Review Specification

Analyze the specification document using the spec-analyzer agent to ensure it meets quality standards before implementation.

## Your Task

1. **Locate Specification Files**
   - Look in `.specs/` directory
   - If multiple specs exist, ask which one to review
   - If no spec found, guide user to run `/spec-init`

2. **Invoke spec-analyzer Agent**
   Use the Task tool to launch the spec-analyzer agent with this prompt:

   ```
   Review the specification document at [spec-file-path].

   Provide a detailed analysis using the scoring framework:
   - Architecture Understanding (25 points)
   - Requirements Completeness (25 points)
   - Implementation Planning (20 points)
   - Edge Cases & Blockers (20 points)
   - Examples & Documentation (10 points)

   Return a comprehensive report with:
   - Overall score
   - Strengths
   - Critical gaps
   - Required improvements
   - Recommendation (APPROVE/REVISION)

   Be strict. Demand "ultrathink" level quality.
   ```

3. **Process Results**
   - Display the agent's analysis to the user
   - If score >= 90: Create `.specs/[name].approved.md` marker
   - If score < 90: List required improvements
   - Do NOT proceed to implementation unless approved

4. **Provide Guidance**
   Based on the score:
   - **90-100**: "Excellent! Ready for implementation. Run `/validate` after coding."
   - **75-89**: "Good foundation. Address the gaps before implementing."
   - **60-74**: "Significant revision needed. Focus on [critical gaps]."
   - **< 60**: "Incomplete. Restart with `/spec-init` and think deeper."

## Important Notes
- Be ruthless in quality assessment
- "Should work" is not acceptable
- Demand concrete examples and evidence
- Challenge vague statements
- Enforce the "will work" standard

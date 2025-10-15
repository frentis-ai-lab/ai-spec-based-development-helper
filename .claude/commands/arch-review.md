# Architecture Review

Review the system architecture using the architecture-reviewer agent to validate design decisions.

## Your Task

1. **Locate Architecture Documentation**
   - Check `.specs/` for specification with architecture section
   - Look for architecture diagrams or design docs
   - If not found, ask user to specify which section to review

2. **Invoke architecture-reviewer Agent**
   Use the Task tool to launch the architecture-reviewer agent:

   ```
   Review the architecture design in [spec-file-path].

   Evaluate:
   1. System Design Principles (SOLID, DRY, KISS, YAGNI, Separation of Concerns)
   2. Scalability (horizontal/vertical scaling, caching, bottlenecks)
   3. Security (auth, encryption, input validation, secrets management)
   4. Maintainability (modularity, testing, documentation, monitoring)
   5. Technology Choices (justification, alternatives considered)

   Ask critical questions:
   - Why this architecture?
   - What breaks first under load?
   - How do we rollback?
   - Is this the simplest solution?
   - How do we test this?

   Provide:
   - Strengths
   - Concerns
   - Questions for design team
   - Recommendations
   - Decision (APPROVED / APPROVED WITH CONDITIONS / REQUIRES REDESIGN)
   - Risk Level (LOW / MEDIUM / HIGH)
   ```

3. **Process Review Results**
   - Present the architectural analysis
   - Highlight any high-risk concerns
   - List unanswered questions
   - Suggest alternatives if redesign needed

4. **Document Decisions**
   - If approved: Add architecture review stamp to spec
   - If conditional: List conditions to be met
   - If redesign needed: Guide user on what to reconsider

## Review Standards
- Challenge all assumptions
- Demand evidence for technology choices
- Think long-term (5 year horizon)
- Consider team capabilities
- Favor simplicity over complexity
- Require justification for complex designs

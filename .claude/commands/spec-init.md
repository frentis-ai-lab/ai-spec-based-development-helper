# Initialize New Specification

Create a comprehensive specification document for a new feature or project following the Specification-First methodology.

## Your Task

1. **Understand the Requirement**
   - Ask clarifying questions if the user's request is vague
   - Identify the core problem being solved
   - Determine the scope and boundaries

2. **Create Specification Document**

   Create a file in `.specs/[feature-name]-spec.md` with the following structure:

   ```markdown
   # [Feature Name] Specification

   **Author**: [Name/AI]
   **Date**: [Current Date]
   **Status**: Draft
   **Version**: 1.0

   ## 1. Overview
   ### Problem Statement
   [What problem are we solving?]

   ### Goals
   - [Primary goals]
   - [Success criteria]

   ### Non-Goals
   - [What we're explicitly not doing]

   ## 2. Architecture

   ### System Components
   [Diagram or description of major components]

   ### Data Flow
   [How data moves through the system]

   ### Technology Stack
   - **Language**: [e.g., TypeScript, Python]
   - **Framework**: [e.g., React, FastAPI]
   - **Database**: [if applicable]
   - **Infrastructure**: [deployment environment]

   ### Dependencies
   - [Internal dependencies]
   - [External dependencies]

   ## 3. Detailed Requirements

   ### Functional Requirements
   1. [Requirement 1]
   2. [Requirement 2]
   ...

   ### Non-Functional Requirements
   - **Performance**: [targets]
   - **Security**: [requirements]
   - **Scalability**: [considerations]
   - **Reliability**: [SLA, error handling]

   ## 4. Implementation Plan

   ### Phase 1: [Name]
   - [ ] Task 1
   - [ ] Task 2

   ### Phase 2: [Name]
   - [ ] Task 3
   - [ ] Task 4

   ### Rollback Strategy
   [How to undo if things go wrong]

   ## 5. Edge Cases & Risks

   ### Known Edge Cases
   1. [Edge case 1] - [How to handle]
   2. [Edge case 2] - [How to handle]

   ### Potential Blockers
   - [Blocker 1] - [Mitigation strategy]
   - [Blocker 2] - [Mitigation strategy]

   ### Risk Assessment
   | Risk | Probability | Impact | Mitigation |
   |------|-------------|--------|------------|
   | [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |

   ## 6. Testing Strategy

   ### Unit Tests
   [What needs unit testing]

   ### Integration Tests
   [What needs integration testing]

   ### Test Cases
   1. **Test Case**: [Name]
      - **Input**: [...]
      - **Expected Output**: [...]

   ## 7. Examples

   ### Code Example
   ```language
   // Example of key implementation
   ```

   ### API Contract (if applicable)
   ```json
   {
     "endpoint": "/api/example",
     "method": "POST",
     "request": {},
     "response": {}
   }
   ```

   ## 8. Documentation & Migration

   ### Documentation Updates
   - [ ] README updates
   - [ ] API documentation
   - [ ] User guide

   ### Migration Path (if applicable)
   [Steps to migrate from old to new system]

   ## 9. Success Metrics

   ### Definition of Done
   - [ ] All requirements implemented
   - [ ] Tests passing (>80% coverage)
   - [ ] Documentation complete
   - [ ] Peer reviewed

   ### KPIs
   - [Metric 1]: [Target]
   - [Metric 2]: [Target]

   ## 10. Open Questions
   - [ ] Question 1?
   - [ ] Question 2?
   ```

3. **Engage Ultrathink Mode**
   - Take time to think deeply about edge cases
   - Question assumptions
   - Map all dependencies
   - Consider what could go wrong

4. **Next Steps**
   After creating the spec:
   - Notify user that spec is ready for review
   - Suggest running `/spec-review` to analyze quality
   - Do NOT proceed to implementation until spec is approved

## Important Guidelines
- **Be thorough** - Don't rush to code
- **Ask questions** - Better to clarify now than fix later
- **Think critically** - Challenge the approach
- **Document assumptions** - Make implicit knowledge explicit
- **Consider alternatives** - Why this approach vs others?

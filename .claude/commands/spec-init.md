# Initialize New Specification

Create comprehensive specification documents for a new feature or project following the Specification-First methodology with 3-file structure.

## Your Task

1. **Check Existing Spec Files**
   - List files in `.specs/` directory
   - Identify which spec files already exist (program-spec.md, api-spec.md, ui-ux-spec.md)
   - Determine project structure (backend/frontend/fullstack)

2. **Understand the Requirement**
   - Ask clarifying questions if the user's request is vague
   - Identify the core problem being solved
   - Determine the scope and boundaries
   - Understand which aspects need specification (architecture, API, UI/UX)

3. **Create/Update Specification Documents**

   Based on project structure, work with these files:

   ### For Fullstack Projects (all 3 files):
   - `.specs/program-spec.md` - System architecture, data models, requirements
   - `.specs/api-spec.md` - API endpoints, authentication, data schemas
   - `.specs/ui-ux-spec.md` - UI components, user flows, interactions

   ### For Backend Projects:
   - `.specs/program-spec.md` - System architecture, data models
   - `.specs/api-spec.md` - API endpoints, authentication

   ### For Frontend Projects:
   - `.specs/program-spec.md` - System architecture, state management
   - `.specs/ui-ux-spec.md` - UI components, user flows

   **If template files already exist**, update them with actual content.
   **If no template files exist**, create them using the structure below:

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

4. **Fill Out Each Spec File**

   Work through each spec file systematically:

   **Step 1: Program Spec (program-spec.md)**
   - Start here - this is the master document
   - Define system architecture, tech stack, data models
   - Reference API and UI specs where appropriate
   - Use template sections as guide

   **Step 2: API Spec (api-spec.md)** [if backend/fullstack]
   - Define all API endpoints
   - Specify authentication, data schemas, error handling
   - Cross-reference program-spec for data models
   - Cross-reference ui-ux-spec for how UI uses each API

   **Step 3: UI/UX Spec (ui-ux-spec.md)** [if frontend/fullstack]
   - Define design system, components, user flows
   - Specify each screen in detail with wireframes
   - Cross-reference api-spec for API calls
   - Cross-reference program-spec for features

5. **Engage Ultrathink Mode**
   - Take time to think deeply about edge cases
   - Question assumptions
   - Map all dependencies across the 3 files
   - Ensure consistency between program/api/ui specs
   - Consider what could go wrong

6. **Cross-File Consistency**
   - Ensure data models match between program-spec and api-spec
   - Ensure UI flows match API endpoints
   - Ensure feature list in program-spec covers all APIs and UIs
   - Use cross-references (e.g., `api-spec.md#auth-api`)

7. **Next Steps**
   After creating/updating the specs:
   - Notify user which spec files were created/updated
   - Show summary of each spec (sections filled)
   - Suggest running `/spec-review` to analyze quality
   - Remind: Do NOT proceed to implementation until spec is approved (90+ score)

## Important Guidelines
- **Be thorough** - Don't rush to code, fill all template sections
- **Ask questions** - Better to clarify now than fix later
- **Think critically** - Challenge the approach
- **Document assumptions** - Make implicit knowledge explicit
- **Consider alternatives** - Why this approach vs others?
- **Maintain consistency** - Keep the 3 specs in sync with cross-references
- **Use templates** - If spec templates exist, use them as structure guide

# Initialize New Specification

Create comprehensive specification documents for a new feature or project following the Specification-First methodology with 3-file structure.

## Your Task

1. **Check Existing Spec Files**
   - List files in `.specs/` directory
   - Identify which spec files already exist (program-spec.md, api-spec.md, ui-ux-spec.md)
   - Determine project structure (backend/frontend/fullstack)

2. **Analyze Project with Context7 Integration** (NEW)

   Before asking questions, analyze the project to provide context-aware recommendations:

   a. **Read Context7 Query Guide**
   - Read `.claude/lib/context7-query.md` for Context7 usage instructions

   b. **Detect Project Type**
   - Source `.claude/lib/project-analyzer.sh`
   - Run project analysis to detect language, version, frameworks
   - Example output:
     ```
     Language: typescript
     Version: 5.3.3
     Frameworks: express, prisma
     Context7 Mappings: /microsoft/TypeScript, /expressjs/express, /prisma/prisma
     ```

   c. **Query Context7 for Each Technology**
   - For each detected technology, use Context7 MCP tools:
     1. `mcp__context7__resolve_library_id` - Get library ID
     2. `mcp__context7__get_library_docs` - Get latest documentation
   - Filter by trust score (≥7 preferred)
   - Store results for later injection into spec

   d. **Check for EOL Versions**
   - Compare detected versions with EOL list
   - Flag any End-of-Life versions for immediate upgrade warning

   e. **Generate Version Recommendations**
   - Compare current versions with Context7 latest versions
   - Prepare upgrade recommendations if current < recommended

3. **Understand the Requirement**
   - Ask clarifying questions if the user's request is vague
   - Identify the core problem being solved
   - Determine the scope and boundaries
   - Understand which aspects need specification (architecture, API, UI/UX)
   - **Use detected technology context** to ask relevant questions
     (e.g., for Express projects, ask about middleware strategy)

4. **Create/Update Specification Documents**

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

   ## 0. Technology References (NEW - Context7 Integration)

   ### Context7 Documentation

   [Inject Context7 links for detected technologies]

   - **[Technology 1]**: `/org/repo/version`
     - [Key topics from Context7 docs]
     - [Best practices]
     - [Latest features]

   - **[Technology 2]**: `/org/repo/version`
     - [Key topics]

   ### Version Matrix

   | 기술 | 현재 버전 | 권장 버전 | Context7 링크 | Status |
   |------|-----------|-----------|--------------|--------|
   | [Tech 1] | [current] | [recommended] | `/org/repo/version` | [✅/⚠️/❌] |
   | [Tech 2] | [current] | [recommended] | `/org/repo/version` | [✅/⚠️/❌] |

   **Status 기준**:
   - ✅ OK: 현재 버전이 권장 버전 이상
   - ⚠️  Update: 업그레이드 권장
   - ❌ EOL: End-of-Life, 즉시 업그레이드 필요

   **Version Recommendations**:
   [If current < recommended, add upgrade plan]
   - [ ] [Technology] upgrade from [current] to [recommended]
   - Estimated effort: [hours/days]
   - Breaking changes: [link to migration guide]

   ---

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
   // Reference: [Technology Version] - [Feature Name]
   // Context7: /org/repo/version#feature
   // Example of key implementation

   [Your code here]
   ```

   **Technology Reference Check**:
   - [x] Context7 link added to code comments
   - [x] Referenced Context7 documentation topic
   - [ ] [Add any language-specific checks from Context7]

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
   - **Show Project Analysis Summary**:
     ```
     ✅ Language: [detected]
     ✅ Frameworks: [list]
     ✅ Context7: [count] technologies referenced
     ⚠️  Recommendations: [version upgrades if any]
     ```
   - Notify user which spec files were created/updated
   - Show summary of each spec (sections filled, including § 0. Technology References)
   - **Highlight Context7 Integration**:
     - Number of Context7 links added
     - Version Matrix status (any EOL or outdated versions)
   - Suggest running `/spec-review` to analyze quality (including Modern Best Practices)
   - Remind: Do NOT proceed to implementation until spec is approved (90+ score)

## Important Guidelines
- **Context7 First** - Always run project analysis and query Context7 before spec creation
- **Be thorough** - Don't rush to code, fill all template sections (especially § 0. Technology References)
- **Ask questions** - Better to clarify now than fix later
- **Think critically** - Challenge the approach, use Context7 docs for best practices
- **Document assumptions** - Make implicit knowledge explicit
- **Consider alternatives** - Why this approach vs others? (Check Context7 for alternative patterns)
- **Maintain consistency** - Keep the 3 specs in sync with cross-references
- **Use templates** - If spec templates exist, use them as structure guide
- **Version awareness** - Always include Version Matrix and flag EOL versions
- **Trust Score** - Only use Context7 docs with trust score ≥7 for automatic injection

# Specification Status

Check the current status of specifications and implementation progress.

## Your Task

1. **Scan .specs Directory**
   - List all specification files
   - Check for approval markers (*.approved.md)
   - Check last validation timestamp (.last-validation)
   - Identify implementation status

2. **Generate Status Report**

   Display a report in this format:

   ```markdown
   # Specification Status Report

   **Generated**: [Current Date/Time]

   ## Specifications

   | Spec File | Status | Score | Last Updated |
   |-----------|--------|-------|--------------|
   | feature-a-spec.md | ✅ Approved | 92/100 | 2025-01-15 |
   | feature-b-spec.md | ⚠️  Draft | N/A | 2025-01-14 |
   | feature-c-spec.md | ❌ Needs Revision | 65/100 | 2025-01-13 |

   ## Implementation Status

   | Feature | Spec Status | Implementation | Validation | Status |
   |---------|-------------|----------------|------------|--------|
   | Feature A | Approved | Complete | Passed (88/100) | ✅ Ready |
   | Feature B | Draft | Not Started | N/A | ⏸️  Blocked |
   | Feature C | Needs Revision | In Progress | Failed (62/100) | ❌ Revise |

   ## Last Validation
   - **Timestamp**: [timestamp or "Never"]
   - **Time Since**: [human readable, e.g., "2 hours ago"]

   ## Recommendations
   1. [Action item based on status]
   2. [...]

   ## Quick Actions
   - To review a spec: `/spec-review`
   - To validate implementation: `/validate`
   - To start new feature: `/spec-init`
   ```

3. **Parse Spec Files for Metadata**
   Look for:
   - Status field in spec (Draft/Approved/Revision)
   - Version number
   - Last updated date
   - Author

4. **Check Implementation Files**
   - Look for corresponding implementation files
   - Check git status if in a repo
   - Identify which specs have implementations

5. **Provide Actionable Insights**
   - Highlight specs that need review
   - Flag implementations without validation
   - Warn about outdated specs
   - Suggest next steps

## Output Format
- Use emojis for visual clarity (✅ ⚠️ ❌ ⏸️ 🚧)
- Use tables for structured data
- Include timestamps
- Provide clear next actions

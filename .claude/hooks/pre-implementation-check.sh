#!/bin/bash

# Pre-Implementation Check Hook
# Enforces specification-first approach by checking for spec file before allowing edits/writes

TOOL_NAME="$1"
TOOL_ARGS="$2"

# Only check for Edit and Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Check if spec directory exists
SPEC_DIR=".specs"
if [ ! -d "$SPEC_DIR" ]; then
  echo "⚠️  WARNING: No .specs directory found!"
  echo ""
  echo "Specification-First Requirement:"
  echo "Before implementing code, you must:"
  echo "1. Run /spec-init to create a specification"
  echo "2. Have the spec reviewed by spec-analyzer agent"
  echo "3. Get approval score of 90+"
  echo ""
  echo "To bypass this check (not recommended): Create .specs/.bypass"

  # Check for bypass flag
  if [ -f "$SPEC_DIR/.bypass" ]; then
    echo ""
    echo "⚠️  Bypass flag detected - proceeding without spec"
    exit 0
  fi

  exit 1
fi

# Check if there's any spec file
SPEC_COUNT=$(find "$SPEC_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
if [ "$SPEC_COUNT" -eq 0 ]; then
  echo "⚠️  WARNING: No specification files found in $SPEC_DIR!"
  echo ""
  echo "Please create a specification using /spec-init before coding."
  exit 1
fi

# Check for approval marker
APPROVED_COUNT=$(find "$SPEC_DIR" -name "*.approved.md" -type f | wc -l | tr -d ' ')
if [ "$APPROVED_COUNT" -eq 0 ]; then
  echo "⚠️  WARNING: No approved specifications found!"
  echo ""
  echo "Your specifications need to be reviewed and approved."
  echo "Run: /spec-review to analyze your specification"
  echo ""
  echo "Proceeding with caution..."
  # Don't block, just warn
fi

exit 0

#!/bin/bash

# Post-Edit Validation Hook
# Reminds to validate implementation against specification after code changes

TOOL_NAME="$1"
TOOL_RESULT="$2"

# Only run after Edit or Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Check if validation has been run recently
VALIDATION_MARKER=".specs/.last-validation"
CURRENT_TIME=$(date +%s)

if [ -f "$VALIDATION_MARKER" ]; then
  LAST_VALIDATION=$(cat "$VALIDATION_MARKER")
  TIME_DIFF=$((CURRENT_TIME - LAST_VALIDATION))

  # If validated within last 5 minutes (300 seconds), skip reminder
  if [ "$TIME_DIFF" -lt 300 ]; then
    exit 0
  fi
fi

echo ""
echo "📋 Reminder: Validate your implementation"
echo ""
echo "After making changes, remember to:"
echo "1. Run /validate to check spec compliance"
echo "2. Run tests to verify functionality"
echo "3. Review with implementation-validator agent"
echo ""
echo "To mark as validated, run: date +%s > .specs/.last-validation"

exit 0

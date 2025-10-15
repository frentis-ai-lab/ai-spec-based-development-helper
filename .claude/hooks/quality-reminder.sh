#!/bin/bash

# Quality Reminder Hook
# Runs on user prompt submit to remind about specification-first principles

PROMPT="$1"

# Check if prompt contains implementation keywords without spec mention
IMPL_KEYWORDS="implement|create|build|code|write"
SPEC_KEYWORDS="spec|specification|design|architecture"

# Convert prompt to lowercase for case-insensitive matching
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Check if this is an implementation request
if echo "$PROMPT_LOWER" | grep -qE "$IMPL_KEYWORDS"; then
  # Check if spec is mentioned
  if ! echo "$PROMPT_LOWER" | grep -qE "$SPEC_KEYWORDS"; then
    # Check if this is a simple/small request (< 20 words)
    WORD_COUNT=$(echo "$PROMPT" | wc -w | tr -d ' ')

    if [ "$WORD_COUNT" -gt 20 ]; then
      echo ""
      echo "💡 Specification-First Reminder:"
      echo ""
      echo "For complex implementations, consider:"
      echo "1. Creating a specification first (/spec-init)"
      echo "2. Having it reviewed (/spec-review)"
      echo "3. Then implementing with validation"
      echo ""
      echo "This approach reduces iterations by 61% and increases success rate to 89%."
      echo ""
      echo "Proceeding with your request..."
    fi
  fi
fi

exit 0

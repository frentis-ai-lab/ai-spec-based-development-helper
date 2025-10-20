#!/bin/bash

# Project Analyzer Library
# Detects project type, language version, and frameworks
# Used by /spec-init for Context7 integration

# Detect project type based on config files
# Returns: typescript | python | java | unknown
detect_project_type() {
  local project_root="${1:-.}"

  # TypeScript detection (package.json with typescript)
  if [[ -f "$project_root/package.json" ]]; then
    # Check if TypeScript is in dependencies or devDependencies
    if command -v jq >/dev/null 2>&1; then
      local has_ts=$(jq -r '(.dependencies.typescript // .devDependencies.typescript // empty)' "$project_root/package.json")
      if [[ -n "$has_ts" ]]; then
        echo "typescript"
        return 0
      fi
    fi

    # Fallback: check for .ts files
    if find "$project_root" -maxdepth 3 -name "*.ts" -o -name "*.tsx" 2>/dev/null | head -1 | grep -q .; then
      echo "typescript"
      return 0
    fi
  fi

  # Python detection
  if [[ -f "$project_root/pyproject.toml" ]] || [[ -f "$project_root/setup.py" ]] || [[ -f "$project_root/requirements.txt" ]]; then
    echo "python"
    return 0
  fi

  # Java detection
  if [[ -f "$project_root/pom.xml" ]] || [[ -f "$project_root/build.gradle" ]] || [[ -f "$project_root/build.gradle.kts" ]]; then
    echo "java"
    return 0
  fi

  echo "unknown"
  return 1
}

# Extract language version
# Args: language, project_root
# Returns: version string (e.g., "5.3.3")
extract_version() {
  local lang="$1"
  local project_root="${2:-.}"

  case "$lang" in
    typescript)
      if command -v jq >/dev/null 2>&1 && [[ -f "$project_root/package.json" ]]; then
        jq -r '(.dependencies.typescript // .devDependencies.typescript // "unknown")' "$project_root/package.json" | sed 's/[\^~]//g'
      else
        echo "unknown"
      fi
      ;;

    python)
      if [[ -f "$project_root/pyproject.toml" ]]; then
        grep -E 'python\s*=' "$project_root/pyproject.toml" | head -1 | sed -E 's/.*"[\^~]?([0-9.]+)".*/\1/'
      elif command -v python3 >/dev/null 2>&1; then
        python3 --version 2>&1 | sed 's/Python //'
      else
        echo "unknown"
      fi
      ;;

    java)
      if [[ -f "$project_root/pom.xml" ]] && command -v xmllint >/dev/null 2>&1; then
        xmllint --xpath 'string(//maven.compiler.source)' "$project_root/pom.xml" 2>/dev/null || echo "unknown"
      elif [[ -f "$project_root/build.gradle" ]]; then
        grep -E 'sourceCompatibility|targetCompatibility' "$project_root/build.gradle" | head -1 | sed -E "s/.*['\"]?([0-9]+)['\"]?.*/\1/" || echo "unknown"
      else
        echo "unknown"
      fi
      ;;

    *)
      echo "unknown"
      ;;
  esac
}

# Extract frameworks/libraries used in the project
# Args: language, project_root
# Returns: newline-separated list of frameworks
extract_frameworks() {
  local lang="$1"
  local project_root="${2:-.}"

  case "$lang" in
    typescript)
      if command -v jq >/dev/null 2>&1 && [[ -f "$project_root/package.json" ]]; then
        jq -r '.dependencies // {} | keys[]' "$project_root/package.json" | grep -E '^(express|nestjs|@nestjs/core|next|fastify|koa|hapi)$' 2>/dev/null || true
      fi
      ;;

    python)
      if [[ -f "$project_root/pyproject.toml" ]]; then
        grep -E '(fastapi|django|flask|tornado|aiohttp)\s*=' "$project_root/pyproject.toml" | sed -E 's/\s*=.*//' | tr -d '"' | tr -d "'" || true
      elif [[ -f "$project_root/requirements.txt" ]]; then
        grep -E '^(fastapi|django|flask|tornado|aiohttp)' "$project_root/requirements.txt" | sed 's/[>=<].*//' || true
      fi
      ;;

    java)
      if [[ -f "$project_root/pom.xml" ]] && command -v xmllint >/dev/null 2>&1; then
        xmllint --xpath '//dependency/artifactId/text()' "$project_root/pom.xml" 2>/dev/null | grep -E '(spring-boot|quarkus|micronaut)' || true
      elif [[ -f "$project_root/build.gradle" ]]; then
        grep -E 'implementation.*["\x27](org.springframework.boot|io.quarkus|io.micronaut)' "$project_root/build.gradle" | sed -E 's/.*["\x27]([^:]+):.*/\1/' || true
      fi
      ;;
  esac
}

# Map library name to Context7 library ID
# Args: library_name, language
# Returns: Context7 compatible library ID (e.g., "/microsoft/TypeScript")
map_to_context7_id() {
  local lib_name="$1"
  local lang="$2"

  case "$lib_name" in
    # TypeScript ecosystem
    typescript) echo "/microsoft/TypeScript" ;;
    express) echo "/expressjs/express" ;;
    nestjs|@nestjs/core) echo "/nestjs/nest" ;;
    next) echo "/vercel/next.js" ;;
    fastify) echo "/fastify/fastify" ;;
    react) echo "/facebook/react" ;;
    vue) echo "/vuejs/vue" ;;

    # Python ecosystem
    fastapi) echo "/tiangolo/fastapi" ;;
    django) echo "/django/django" ;;
    flask) echo "/pallets/flask" ;;

    # Java ecosystem
    spring-boot) echo "/spring-projects/spring-boot" ;;
    quarkus) echo "/quarkusio/quarkus" ;;

    # Runtime
    node|nodejs) echo "/nodejs/node" ;;
    python) echo "/python/cpython" ;;
    java|openjdk) echo "/openjdk/jdk" ;;

    *)
      # Unknown library, return as-is and let Context7 try to resolve
      echo "$lib_name"
      ;;
  esac
}

# Calculate detection confidence score
# Args: language, project_root
# Returns: confidence score (0.0 - 1.0)
calculate_confidence() {
  local lang="$1"
  local project_root="${2:-.}"
  local confidence=1.0

  case "$lang" in
    typescript)
      # Check for actual .ts files
      local ts_count=$(find "$project_root" -maxdepth 3 -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$ts_count" -lt 5 ]]; then
        confidence=0.6
      fi

      # Check for tsconfig.json
      if [[ ! -f "$project_root/tsconfig.json" ]]; then
        confidence=$(echo "$confidence * 0.8" | bc -l)
      fi
      ;;

    python)
      # Check for actual .py files
      local py_count=$(find "$project_root" -maxdepth 3 -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$py_count" -lt 3 ]]; then
        confidence=0.6
      fi
      ;;

    java)
      # Check for actual .java files
      local java_count=$(find "$project_root" -maxdepth 3 -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$java_count" -lt 3 ]]; then
        confidence=0.6
      fi
      ;;

    unknown)
      confidence=0.0
      ;;
  esac

  echo "$confidence"
}

# Main analysis function - generates full project detection result
# Args: project_root
# Outputs: JSON-like structure (or simple text for bash compatibility)
analyze_project() {
  local project_root="${1:-.}"

  echo "=== Project Analysis ===" >&2

  # Detect language
  local lang=$(detect_project_type "$project_root")
  echo "Language: $lang" >&2

  if [[ "$lang" == "unknown" ]]; then
    echo "⚠️  Could not detect project type" >&2
    echo "Please specify language manually" >&2
    return 1
  fi

  # Get version
  local version=$(extract_version "$lang" "$project_root")
  echo "Version: $version" >&2

  # Get frameworks
  echo "Frameworks:" >&2
  local frameworks=$(extract_frameworks "$lang" "$project_root")
  if [[ -n "$frameworks" ]]; then
    echo "$frameworks" | while read -r fw; do
      echo "  - $fw" >&2
    done
  else
    echo "  (none detected)" >&2
  fi

  # Calculate confidence
  local confidence=$(calculate_confidence "$lang" "$project_root")
  echo "Confidence: $confidence" >&2

  # Check confidence threshold
  if (( $(echo "$confidence < 0.7" | bc -l) )); then
    echo "" >&2
    echo "⚠️  Low detection confidence: $confidence" >&2
    echo "Consider manual verification:" >&2
    echo "  1. TypeScript" >&2
    echo "  2. Python" >&2
    echo "  3. Java" >&2
  fi

  # Generate Context7 mappings
  echo "" >&2
  echo "Context7 Mappings:" >&2

  # Add language itself
  local lang_id=$(map_to_context7_id "$lang" "$lang")
  echo "  $lang -> $lang_id" >&2

  # Add frameworks
  if [[ -n "$frameworks" ]]; then
    echo "$frameworks" | while read -r fw; do
      local fw_id=$(map_to_context7_id "$fw" "$lang")
      echo "  $fw -> $fw_id" >&2
    done
  fi

  # Return machine-readable format on stdout
  echo "LANGUAGE=$lang"
  echo "VERSION=$version"
  echo "CONFIDENCE=$confidence"
  if [[ -n "$frameworks" ]]; then
    echo "FRAMEWORKS=$frameworks"
  fi
}

# Export functions for use in other scripts
export -f detect_project_type
export -f extract_version
export -f extract_frameworks
export -f map_to_context7_id
export -f calculate_confidence
export -f analyze_project

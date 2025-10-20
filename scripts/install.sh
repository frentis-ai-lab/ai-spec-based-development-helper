#!/bin/bash

# AI Specification-Based Development Helper - Installation Script
# Version: 2.0.0
#
# Usage:
#   ./install.sh [target-directory] [options]
#   curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash
#   curl -fsSL https://[...]/install.sh | bash -s /path/to/project
#   curl -fsSL https://[...]/install.sh | bash -s -- --update
#
# Options:
#   --update          Update existing installation
#   --version VERSION Install specific version (default: latest)
#   --dry-run         Show what would be installed without doing it
#   --force           Skip all confirmations
#   --skip-claude     Skip Claude Code availability check

set -e

# Script version
SCRIPT_VERSION="2.0.0"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="frentis-ai-lab"
REPO_NAME="ai-spec-based-development-helper"
REPO_URL="https://github.com/$REPO_OWNER/$REPO_NAME"
REPO_API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"
INSTALL_VERSION="latest"  # or specific tag like "v0.0.2"

# Parse arguments
UPDATE_MODE=false
DRY_RUN=false
FORCE_MODE=false
SKIP_CLAUDE_CHECK=false
TARGET_DIR="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --version)
            INSTALL_VERSION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        --skip-claude)
            SKIP_CLAUDE_CHECK=true
            shift
            ;;
        -*)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Usage: install.sh [target-directory] [--update] [--version VERSION] [--dry-run] [--force] [--skip-claude]"
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Print header
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
if [ "$UPDATE_MODE" = true ]; then
    echo -e "${BLUE}║${NC}  ${CYAN}🔄 AI Spec Helper Update${NC}             ${BLUE}║${NC}"
else
    echo -e "${BLUE}║${NC}  ${GREEN}📦 AI Spec Helper Installation${NC}        ${BLUE}║${NC}"
fi
echo -e "${BLUE}║${NC}  Script v$SCRIPT_VERSION                       ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}🔍 DRY RUN MODE (no files will be modified)${NC}"
    echo ""
fi

# Resolve target directory
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

echo "Target directory: $TARGET_DIR"
echo "Install version: $INSTALL_VERSION"
echo ""

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ Error: Directory $TARGET_DIR does not exist${NC}"
    exit 1
fi

# Check if Claude Code is available
if [ "$SKIP_CLAUDE_CHECK" = false ]; then
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: 'claude' command not found${NC}"
        echo "   Claude Code is required to use this tool"
        echo "   Install: https://claude.com/claude-code"
        echo "   Or use --skip-claude to skip this check"
        echo ""

        if [ "$FORCE_MODE" = false ]; then
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation cancelled."
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}✓${NC} Claude Code found"
    fi
fi

# Determine version to install
if [ "$INSTALL_VERSION" = "latest" ]; then
    echo -e "${BLUE}Fetching latest version...${NC}"

    # Get latest release tag from GitHub API
    LATEST_TAG=$(curl -s "$REPO_API_URL/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_TAG" ]; then
        echo -e "${YELLOW}⚠️  Could not fetch latest version, using 'main' branch${NC}"
        INSTALL_VERSION="main"
    else
        INSTALL_VERSION="$LATEST_TAG"
        echo -e "${GREEN}✓${NC} Latest version: $INSTALL_VERSION"
    fi
fi

echo ""

# Function to download and extract tarball (faster than git clone)
download_from_github() {
    local version=$1
    local target_path=$2

    echo -e "${BLUE}Downloading from GitHub ($version)...${NC}"

    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    TARBALL="$TMP_DIR/repo.tar.gz"

    # Determine download URL
    if [[ "$version" == v* ]]; then
        # Tagged release
        DOWNLOAD_URL="$REPO_URL/archive/refs/tags/$version.tar.gz"
    else
        # Branch (e.g., main)
        DOWNLOAD_URL="$REPO_URL/archive/refs/heads/$version.tar.gz"
    fi

    # Download with retry
    MAX_RETRIES=3
    RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if curl -fsSL "$DOWNLOAD_URL" -o "$TARBALL"; then
            echo -e "${GREEN}✓${NC} Download successful"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                echo -e "${YELLOW}⚠️  Download failed, retrying ($RETRY_COUNT/$MAX_RETRIES)...${NC}"
                sleep 2
            else
                echo -e "${RED}❌ Download failed after $MAX_RETRIES attempts${NC}"
                rm -rf "$TMP_DIR"
                return 1
            fi
        fi
    done

    # Extract
    echo -e "${BLUE}Extracting files...${NC}"
    cd "$TMP_DIR"
    tar -xzf repo.tar.gz

    # Find extracted directory (GitHub adds repo name + version)
    EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n 1)

    if [ -z "$EXTRACTED_DIR" ]; then
        echo -e "${RED}❌ Failed to extract archive${NC}"
        rm -rf "$TMP_DIR"
        return 1
    fi

    cd "$EXTRACTED_DIR"

    # Copy .claude directory
    if [ -d ".claude" ]; then
        if [ "$DRY_RUN" = false ]; then
            cp -r .claude "$target_path/"
        fi
        echo -e "${GREEN}✓${NC} .claude/ copied"
    else
        echo -e "${RED}✗${NC} .claude/ not found in archive"
    fi

    # Copy templates directory
    if [ -d "templates" ]; then
        if [ "$DRY_RUN" = false ]; then
            cp -r templates "$target_path/"
        fi
        echo -e "${GREEN}✓${NC} templates/ copied"
    else
        echo -e "${RED}✗${NC} templates/ not found in archive"
    fi

    # Cleanup
    cd /
    rm -rf "$TMP_DIR"
}

# Check for existing installation
EXISTING_VERSION=""
if [ -f "$TARGET_DIR/.claude/.version" ]; then
    EXISTING_VERSION=$(cat "$TARGET_DIR/.claude/.version")
    echo -e "${CYAN}Existing installation found: $EXISTING_VERSION${NC}"
    echo ""
fi

# Handle existing installations
if [ "$UPDATE_MODE" = true ]; then
    # Update mode: automatically overwrite .claude and templates
    echo -e "${BLUE}Update mode: Overwriting .claude/ and templates/${NC}"
    echo ""

    if [ -d "$TARGET_DIR/.claude" ]; then
        if [ "$DRY_RUN" = false ]; then
            rm -rf "$TARGET_DIR/.claude"
        fi
        echo -e "${GREEN}✓${NC} Removed old .claude/"
    fi

    if [ -d "$TARGET_DIR/templates" ]; then
        if [ "$DRY_RUN" = false ]; then
            rm -rf "$TARGET_DIR/templates"
        fi
        echo -e "${GREEN}✓${NC} Removed old templates/"
    fi

    # Check if .specs exists (should exist in update mode)
    if [ ! -d "$TARGET_DIR/.specs" ]; then
        echo -e "${YELLOW}⚠️  Warning: .specs/ not found. This might not be an existing project.${NC}"
        echo "   Continuing anyway..."
    else
        echo -e "${GREEN}✓${NC} .specs/ preserved (your specifications are safe)"
    fi
    echo ""
else
    # Install mode: prompt for confirmation
    if [ -d "$TARGET_DIR/.claude" ]; then
        echo -e "${YELLOW}⚠️  .claude/ directory already exists${NC}"
        echo "   Hint: Use --update flag to update an existing installation"

        if [ "$FORCE_MODE" = false ]; then
            read -p "Do you want to overwrite it? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation cancelled."
                exit 0
            fi
        fi

        if [ "$DRY_RUN" = false ]; then
            rm -rf "$TARGET_DIR/.claude"
        fi
    fi

    if [ -d "$TARGET_DIR/templates" ]; then
        echo -e "${YELLOW}⚠️  templates/ directory already exists${NC}"

        if [ "$FORCE_MODE" = false ]; then
            read -p "Do you want to overwrite it? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Skipping templates installation."
            else
                if [ "$DRY_RUN" = false ]; then
                    rm -rf "$TARGET_DIR/templates"
                fi
            fi
        else
            if [ "$DRY_RUN" = false ]; then
                rm -rf "$TARGET_DIR/templates"
            fi
        fi
    fi
fi

# Download and install
download_from_github "$INSTALL_VERSION" "$TARGET_DIR"

# Create .specs directory if it doesn't exist
if [ ! -d "$TARGET_DIR/.specs" ]; then
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$TARGET_DIR/.specs"
    fi
    echo -e "${GREEN}✓${NC} Created .specs/ directory"
else
    echo -e "${CYAN}ℹ${NC}  .specs/ directory already exists (keeping it)"
fi

# Set executable permissions on hooks
if [ -d "$TARGET_DIR/.claude/hooks" ]; then
    if [ "$DRY_RUN" = false ]; then
        chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
    fi
    echo -e "${GREEN}✓${NC} Set executable permissions on hooks"
fi

# Write version file
if [ "$DRY_RUN" = false ]; then
    echo "$INSTALL_VERSION" > "$TARGET_DIR/.claude/.version"
    echo -e "${GREEN}✓${NC} Version file created ($INSTALL_VERSION)"
fi

# Create .gitignore entries (optional)
GITIGNORE_FILE="$TARGET_DIR/.gitignore"
if [ -f "$GITIGNORE_FILE" ]; then
    if ! grep -q ".specs/.bypass" "$GITIGNORE_FILE"; then
        if [ "$DRY_RUN" = false ]; then
            cat >> "$GITIGNORE_FILE" <<EOF

# AI Spec Helper
.specs/.bypass
.specs/.last-validation
.test-reports/
EOF
        fi
        echo -e "${GREEN}✓${NC} Updated .gitignore"
    fi
fi

# Print completion message
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}║${NC}  ${CYAN}🔍 Dry run complete!${NC}                   ${BLUE}║${NC}"
elif [ "$UPDATE_MODE" = true ]; then
    echo -e "${BLUE}║${NC}  ${GREEN}✅ Update complete!${NC}                    ${BLUE}║${NC}"
else
    echo -e "${BLUE}║${NC}  ${GREEN}✅ Installation complete!${NC}              ${BLUE}║${NC}"
fi
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "Dry run summary:"
    echo "  - Would install version: $INSTALL_VERSION"
    echo "  - Target directory: $TARGET_DIR"
    echo "  - Files would be copied: .claude/, templates/"
    echo ""
    echo "Run without --dry-run to perform actual installation"
elif [ "$UPDATE_MODE" = true ]; then
    echo "Updated components:"
    echo "  - .claude/ (Sub-agents, Hooks, Commands)"
    echo "  - templates/ (Spec templates)"
    echo "  - .specs/ preserved (your work is safe)"
    echo ""
    echo "Version: $EXISTING_VERSION → $INSTALL_VERSION"
    echo ""
    echo "You can now continue using your project with the latest features!"
else
    echo "Next steps:"
    echo "  1. cd $TARGET_DIR"
    echo "  2. claude"
    echo "  3. /spec-init"
    echo ""
    echo "Documentation:"
    echo "  - Quick Start: https://github.com/$REPO_OWNER/$REPO_NAME/blob/main/QUICKSTART.md"
    echo "  - Full Guide: https://github.com/$REPO_OWNER/$REPO_NAME/blob/main/README.md"
    echo ""
    echo "🎯 Remember: 'Reason before you type'"
fi

echo ""
echo -e "${CYAN}Installed version: $INSTALL_VERSION${NC}"
echo -e "${CYAN}GitHub: $REPO_URL${NC}"

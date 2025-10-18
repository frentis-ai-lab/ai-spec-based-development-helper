#!/bin/bash

# AI Specification-Based Development Helper - Installation Script
# Usage:
#   ./install.sh [target-directory] [--update]
#   curl -fsSL https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main/scripts/install.sh | bash
#   curl -fsSL https://[...]/install.sh | bash -s /path/to/project
#   curl -fsSL https://[...]/install.sh | bash -s -- --update

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
UPDATE_MODE=false
TARGET_DIR="."

for arg in "$@"; do
    case $arg in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        *)
            TARGET_DIR="$arg"
            ;;
    esac
done

# Configuration
REPO_URL="https://github.com/frentis-ai-lab/ai-spec-based-development-helper"
REPO_RAW_URL="https://raw.githubusercontent.com/frentis-ai-lab/ai-spec-based-development-helper/main"

if [ "$UPDATE_MODE" = true ]; then
    echo -e "${BLUE}🔄 AI Spec Helper Update${NC}"
else
    echo -e "${GREEN}📦 AI Spec Helper Installation${NC}"
fi
echo "Target directory: $TARGET_DIR"
echo ""

# Resolve target directory
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ Error: Directory $TARGET_DIR does not exist${NC}"
    exit 1
fi

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: 'claude' command not found${NC}"
    echo "   Please install Claude Code: https://claude.com/claude-code"
    echo ""
fi

# Function to download directory from GitHub
download_directory() {
    local dir_name=$1
    local target_path=$2

    echo -e "${GREEN}Downloading $dir_name...${NC}"

    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    # Clone with sparse checkout
    git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" repo 2>/dev/null
    cd repo
    git sparse-checkout set "$dir_name"

    # Copy to target
    if [ -d "$dir_name" ]; then
        cp -r "$dir_name" "$target_path/"
        echo -e "  ${GREEN}✓${NC} $dir_name copied"
    else
        echo -e "  ${RED}✗${NC} Failed to download $dir_name"
        cd /
        rm -rf "$TMP_DIR"
        return 1
    fi

    # Cleanup
    cd /
    rm -rf "$TMP_DIR"
}

# Handle existing installations
if [ "$UPDATE_MODE" = true ]; then
    # Update mode: automatically overwrite .claude and templates
    echo -e "${BLUE}Update mode: Overwriting .claude/ and templates/${NC}"

    if [ -d "$TARGET_DIR/.claude" ]; then
        rm -rf "$TARGET_DIR/.claude"
        echo -e "  ${GREEN}✓${NC} Removed old .claude/"
    fi

    if [ -d "$TARGET_DIR/templates" ]; then
        rm -rf "$TARGET_DIR/templates"
        echo -e "  ${GREEN}✓${NC} Removed old templates/"
    fi

    INSTALL_TEMPLATES=true

    # Check if .specs exists (should exist in update mode)
    if [ ! -d "$TARGET_DIR/.specs" ]; then
        echo -e "${YELLOW}⚠️  Warning: .specs/ not found. This might not be an existing project.${NC}"
        echo "   Continuing anyway..."
    else
        echo -e "  ${GREEN}✓${NC} .specs/ preserved (your specifications are safe)"
    fi
    echo ""
else
    # Install mode: prompt for confirmation
    if [ -d "$TARGET_DIR/.claude" ]; then
        echo -e "${YELLOW}⚠️  .claude/ directory already exists${NC}"
        echo "   Hint: Use --update flag to update an existing installation"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
        rm -rf "$TARGET_DIR/.claude"
    fi

    if [ -d "$TARGET_DIR/templates" ]; then
        echo -e "${YELLOW}⚠️  templates/ directory already exists${NC}"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping templates installation."
            INSTALL_TEMPLATES=false
        else
            rm -rf "$TARGET_DIR/templates"
            INSTALL_TEMPLATES=true
        fi
    else
        INSTALL_TEMPLATES=true
    fi
fi

# Download .claude directory
download_directory ".claude" "$TARGET_DIR"

# Download templates directory (if approved)
if [ "$INSTALL_TEMPLATES" = true ]; then
    download_directory "templates" "$TARGET_DIR"
fi

# Create .specs directory if it doesn't exist
if [ ! -d "$TARGET_DIR/.specs" ]; then
    mkdir -p "$TARGET_DIR/.specs"
    echo -e "${GREEN}✓${NC} Created .specs/ directory"
else
    echo -e "${YELLOW}⚠️${NC}  .specs/ directory already exists (keeping it)"
fi

# Set executable permissions on hooks
if [ -d "$TARGET_DIR/.claude/hooks" ]; then
    chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Set executable permissions on hooks"
fi

# Create .gitignore entries (optional)
GITIGNORE_FILE="$TARGET_DIR/.gitignore"
if [ -f "$GITIGNORE_FILE" ]; then
    if ! grep -q ".specs/.bypass" "$GITIGNORE_FILE"; then
        echo "" >> "$GITIGNORE_FILE"
        echo "# AI Spec Helper" >> "$GITIGNORE_FILE"
        echo ".specs/.bypass" >> "$GITIGNORE_FILE"
        echo ".specs/.last-validation" >> "$GITIGNORE_FILE"
        echo ".test-reports/" >> "$GITIGNORE_FILE"
        echo -e "${GREEN}✓${NC} Updated .gitignore"
    fi
fi

echo ""
if [ "$UPDATE_MODE" = true ]; then
    echo -e "${BLUE}✅ Update complete!${NC}"
    echo ""
    echo "Updated components:"
    echo "  - .claude/ (Sub-agents, Hooks, Commands)"
    echo "  - templates/ (Spec templates)"
    echo "  - .specs/ preserved (your work is safe)"
    echo ""
    echo "You can now continue using your project with the latest features!"
else
    echo -e "${GREEN}✅ Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd $TARGET_DIR"
    echo "  2. claude"
    echo "  3. /spec-init"
fi
echo ""
echo "Documentation:"
echo "  - Quick Start: https://github.com/frentis-ai-lab/ai-spec-based-development-helper/blob/main/QUICKSTART.md"
echo "  - Full Guide: https://github.com/frentis-ai-lab/ai-spec-based-development-helper/blob/main/README.md"
echo ""
echo "🎯 Remember: 'Reason before you type'"

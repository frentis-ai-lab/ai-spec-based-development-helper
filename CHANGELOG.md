# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-01-18

### Added

#### Core Features
- **3-File Spec Structure**: Specification management with program-spec.md, api-spec.md, ui-ux-spec.md
- **Sub-Agents**: Specialized AI agents for quality enforcement
  - `spec-analyzer`: Analyzes 3-file spec structure, scores 0-100, approves 90+
  - `architecture-reviewer`: Reviews system design layer-by-layer (system/API/frontend)
  - `implementation-validator`: Validates spec-by-spec compliance, approves 85+
  - `test-runner`: Generates spec-based tests automatically, targets 85%+ coverage
- **Intelligent Hooks**: Automated quality gates
  - `pre-implementation-check`: Blocks coding without approved specs
  - `post-edit-validation`: Reminds validation after edits
  - `quality-reminder`: Suggests spec-first for complex requests
- **Slash Commands**: Workflow automation
  - `/spec-init`: Initialize 3-file spec (program/api/ui-ux based on project type)
  - `/spec-review`: Analyze spec quality with cross-file consistency checks
  - `/arch-review`: Review architecture with cross-layer validation
  - `/test`: Auto-generate and run tests (NEW)
  - `/test-unit`, `/test-api`: Targeted test generation
  - `/validate`: Validate implementation against all spec files
  - `/spec-status`: Check current specification status

#### Templates
- **program-spec-template.md**: System architecture, data models, overall requirements
- **api-spec-template.md**: API endpoints, authentication, data schemas
- **ui-ux-spec-template.md**: UI components, user flows, design system
- **feature-spec-template.md**: Legacy single-file spec (optional)

#### Installation & Project Management
- **Installation Script** (`scripts/install.sh`):
  - One-line remote installation via curl
  - Copies actual files (no symlinks) for cross-platform compatibility
  - Auto-sets hook permissions and updates .gitignore
  - `--update` flag for seamless updates to existing projects
- **Project Initialization CLI** (`bin/spec-init-project.js`):
  - Create new projects with `pnpm run new [name]`
  - Structure options: `--structure backend|frontend|fullstack`
  - Language support: `--type typescript|python|rust`
  - Auto-generates 3 spec files based on project type

#### Documentation
- **README.md**: Comprehensive guide with real-world examples
- **QUICKSTART.md**: 20-second quick start guide in Korean
- **CLAUDE.md**: Developer rules and workflow enforcement
- **workspaces/README.md**: Workspace management guide

### Technical Details

#### Workflow Enforcement
- Minimum spec score: 90/100 for approval
- Minimum implementation score: 85/100 for deployment
- Test coverage target: 85%+
- Cross-file consistency validation
- Cross-layer integration validation (backend ↔ frontend)

#### Quality Gates
- Architecture diagrams required
- Edge cases (minimum 5) with handling strategies
- Test cases (minimum 10) for critical paths
- Rollback strategies for deployments
- Security checklist (OWASP Top 10)

#### Cost Optimization
- Haiku model as default for test generation
- Sonnet model only for complex logic
- Efficient spec-based test generation

### Repository Structure
```
.claude/
├── agents/          # Sub-agents (4 total)
├── commands/        # Slash commands (8 total)
└── hooks/           # Quality hooks (3 total)
templates/           # Spec templates (4 total)
scripts/             # Installation and utility scripts
bin/                 # CLI tools
workspaces/          # Example projects
```

### References
- Based on research: "Supervising an AI Engineer" (techtrenches.substack.com)
- Proven results: 89% success rate, 61% fewer iterations, 82% fewer production bugs

[0.0.1]: https://github.com/frentis-ai-lab/ai-spec-based-development-helper/releases/tag/v0.0.1

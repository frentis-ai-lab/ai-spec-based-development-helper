#!/usr/bin/env node

/**
 * Spec-First Project Initializer CLI
 * Usage: spec-init-project <project-name>
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// ANSI colors
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
};

const log = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset} ${msg}`),
  success: (msg) => console.log(`${colors.green}✓${colors.reset} ${msg}`),
  warn: (msg) => console.log(`${colors.yellow}⚠${colors.reset} ${msg}`),
  error: (msg) => console.log(`${colors.red}✗${colors.reset} ${msg}`),
  step: (msg) => console.log(`${colors.cyan}▸${colors.reset} ${msg}`),
};

function showHelp() {
  console.log(`
${colors.bright}Spec-First Project Initializer${colors.reset}

${colors.bright}Usage:${colors.reset}
  spec-init-project <project-name> [options]

${colors.bright}Options:${colors.reset}
  -t, --type <type>         Project type: node, python, rust (default: node)
  -s, --structure <struct>  Project structure: backend, frontend, fullstack (default: fullstack)
  -h, --help                Show this help message

${colors.bright}Examples:${colors.reset}
  spec-init-project my-app
  spec-init-project my-api --type node --structure backend
  spec-init-project my-web --type node --structure frontend
  spec-init-project my-fullstack --structure fullstack
  spec-init-project ml-api --type python --structure backend

${colors.bright}Structure Types:${colors.reset}
  backend     → program-spec.md + api-spec.md
  frontend    → program-spec.md + ui-ux-spec.md
  fullstack   → program-spec.md + api-spec.md + ui-ux-spec.md (default)

${colors.bright}What it does:${colors.reset}
  ✓ Creates workspaces/<project-name>/
  ✓ Sets up .claude/ symlink (Sub-agents, Hooks, Commands)
  ✓ Sets up templates/ symlink
  ✓ Creates .specs/ directory with spec templates
  ✓ Generates README.md and .gitignore
  ✓ Optionally initializes project (pnpm/uv/cargo)
`);
}

function createProject(projectName, options = {}) {
  const projectType = options.type || 'node';
  const projectStructure = options.structure || 'fullstack';
  const rootDir = process.cwd();
  const projectDir = path.join(rootDir, 'workspaces', projectName);

  // Check if already exists
  if (fs.existsSync(projectDir)) {
    log.error(`Project "${projectName}" already exists in workspaces/`);
    process.exit(1);
  }

  log.info(`Creating Spec-First project: ${colors.bright}${projectName}${colors.reset}`);
  log.info(`Type: ${colors.bright}${projectType}${colors.reset}, Structure: ${colors.bright}${projectStructure}${colors.reset}`);
  console.log('');

  // 1. Create directory
  log.step('Creating project directory...');
  fs.mkdirSync(projectDir, { recursive: true });
  log.success(`Created workspaces/${projectName}/`);

  // 2. Create symlinks
  log.step('Setting up symlinks...');
  const claudeLink = path.join(projectDir, '.claude');
  const templatesLink = path.join(projectDir, 'templates');

  fs.symlinkSync('../../.claude', claudeLink);
  log.success('.claude/ → ../../.claude (symlink)');

  fs.symlinkSync('../../templates', templatesLink);
  log.success('templates/ → ../../templates (symlink)');

  // 3. Create .specs directory with spec files
  log.step('Creating .specs directory with spec templates...');
  const specsDir = path.join(projectDir, '.specs');
  fs.mkdirSync(specsDir);
  createSpecFiles(specsDir, projectStructure, rootDir);
  log.success('.specs/ directory created with spec templates');

  // 4. Create README.md
  log.step('Generating README.md...');
  const readme = generateReadme(projectName, projectType);
  fs.writeFileSync(path.join(projectDir, 'README.md'), readme);
  log.success('README.md generated');

  // 5. Create .gitignore
  log.step('Generating .gitignore...');
  const gitignore = generateGitignore(projectType);
  fs.writeFileSync(path.join(projectDir, '.gitignore'), gitignore);
  log.success('.gitignore generated');

  // 6. Initialize project based on type
  console.log('');
  log.info(`Project type: ${colors.bright}${projectType}${colors.reset}`);

  const oldCwd = process.cwd();
  process.chdir(projectDir);

  try {
    switch (projectType) {
      case 'node':
        log.step('Initializing Node.js project...');
        execSync('pnpm init', { stdio: 'inherit' });
        log.success('package.json created');
        break;
      case 'python':
        log.step('Initializing Python project...');
        execSync('uv init', { stdio: 'inherit' });
        log.success('Python project initialized');
        break;
      case 'rust':
        log.step('Initializing Rust project...');
        execSync('cargo init', { stdio: 'inherit' });
        log.success('Cargo project initialized');
        break;
    }
  } catch (error) {
    log.warn(`Could not initialize ${projectType} project (command not found)`);
    log.info('You can initialize it manually later');
  } finally {
    process.chdir(oldCwd);
  }

  // Final message
  console.log('');
  log.success(`${colors.bright}Project created successfully!${colors.reset}`);
  console.log('');
  console.log(`${colors.bright}Next steps:${colors.reset}`);
  console.log(`  ${colors.cyan}1.${colors.reset} cd workspaces/${projectName}`);
  console.log(`  ${colors.cyan}2.${colors.reset} claude`);
  console.log(`  ${colors.cyan}3.${colors.reset} /spec-init`);
  console.log('');
  console.log(`${colors.bright}Available commands in Claude Code:${colors.reset}`);
  console.log(`  • /spec-init    - Create specification`);
  console.log(`  • /spec-review  - Review spec (90+ score target)`);
  console.log(`  • /arch-review  - Review architecture`);
  console.log(`  • /validate     - Validate implementation (85+ score)`);
  console.log(`  • /spec-status  - Check project status`);
  console.log('');
}

function generateReadme(projectName, projectType) {
  return `# ${projectName}

이 프로젝트는 **Specification-First** 방법론을 사용합니다.

## 프로젝트 타입

**${projectType.toUpperCase()}** 프로젝트

## 시작하기

\`\`\`bash
# Claude Code 실행
claude

# 스펙 작성부터 시작
/spec-init
\`\`\`

## Specification-First 워크플로우

1. \`/spec-init\` - 스펙 작성 (질문 → 템플릿 작성)
2. \`/spec-review\` - 스펙 검토 (목표: 90점 이상)
3. 구현 - 스펙 기반 코딩
4. \`/validate\` - 구현 검증 (목표: 85점 이상)
5. 배포 - 준비 완료

## 설정

- ✅ Sub-agents: \`../../.claude/agents/\` (symlink)
- ✅ Commands: \`../../.claude/commands/\` (symlink)
- ✅ Hooks: \`../../.claude/hooks/\` (symlink)
- ✅ Templates: \`../../templates/\` (symlink)
- ✅ Specs: \`./.specs/\` (독립적)

## 구조

\`\`\`
${projectName}/
├── .claude/           → ../../.claude (symlink)
├── templates/         → ../../templates (symlink)
├── .specs/            # 이 프로젝트만의 스펙
├── src/               # 소스 코드
├── tests/             # 테스트
└── README.md
\`\`\`

## 품질 기준

- **스펙 품질**: 90점 이상
- **구현 품질**: 85점 이상
- **테스트 커버리지**: 80% 이상

## 핵심 원칙

> **"Reason before you type"** 🧠 → ⌨️

1. 항상 스펙부터 작성
2. Ultrathink (깊은 사고) 강제
3. 엄격한 품질 기준
4. 검증 습관화

---

**Generated by**: [AI Specification-Based Development Helper](../../README.md)
`;
}

function createSpecFiles(specsDir, structure, rootDir) {
  const templatesDir = path.join(rootDir, 'templates');

  // 구조에 따라 복사할 템플릿 결정
  const specFiles = {
    backend: ['program-spec-template.md', 'api-spec-template.md'],
    frontend: ['program-spec-template.md', 'ui-ux-spec-template.md'],
    fullstack: ['program-spec-template.md', 'api-spec-template.md', 'ui-ux-spec-template.md']
  };

  const filesToCopy = specFiles[structure] || specFiles.fullstack;

  // 템플릿 파일을 .specs/로 복사 (템플릿 접미사 제거)
  filesToCopy.forEach(templateFile => {
    const sourcePath = path.join(templatesDir, templateFile);
    const destFileName = templateFile.replace('-template', '');
    const destPath = path.join(specsDir, destFileName);

    if (fs.existsSync(sourcePath)) {
      const content = fs.readFileSync(sourcePath, 'utf8');
      fs.writeFileSync(destPath, content);
      log.success(`  ${destFileName} created`);
    } else {
      log.warn(`  Template ${templateFile} not found, skipping`);
    }
  });
}

function generateGitignore(projectType) {
  const common = `# Specs runtime
.specs/.last-validation
.specs/.bypass

# OS
.DS_Store
Thumbs.db
._.DS_Store

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
npm-debug.log*
yarn-debug.log*
`;

  const typeSpecific = {
    node: `
# Node.js
node_modules/
.pnpm-store/
dist/
build/
coverage/

# Environment
.env
.env.local
.env.*.local
`,
    python: `
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/

# Environment
.env
.env.local
`,
    rust: `
# Rust
target/
Cargo.lock
**/*.rs.bk
*.pdb

# Environment
.env
.env.local
`,
  };

  return common + (typeSpecific[projectType] || typeSpecific.node);
}

// Parse arguments
function parseArgs(args) {
  const options = { type: 'node', structure: 'fullstack' };
  let projectName = null;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '-h' || arg === '--help') {
      showHelp();
      process.exit(0);
    } else if (arg === '-t' || arg === '--type') {
      options.type = args[++i];
    } else if (arg === '-s' || arg === '--structure') {
      options.structure = args[++i];
    } else if (!arg.startsWith('-')) {
      projectName = arg;
    }
  }

  return { projectName, options };
}

// Main
const args = process.argv.slice(2);

if (args.length === 0) {
  showHelp();
  process.exit(0);
}

const { projectName, options } = parseArgs(args);

if (!projectName) {
  log.error('Project name is required');
  console.log('');
  showHelp();
  process.exit(1);
}

// Validate project type
const validTypes = ['node', 'python', 'rust'];
if (!validTypes.includes(options.type)) {
  log.error(`Invalid project type: ${options.type}`);
  log.info(`Valid types: ${validTypes.join(', ')}`);
  process.exit(1);
}

// Validate project structure
const validStructures = ['backend', 'frontend', 'fullstack'];
if (!validStructures.includes(options.structure)) {
  log.error(`Invalid project structure: ${options.structure}`);
  log.info(`Valid structures: ${validStructures.join(', ')}`);
  process.exit(1);
}

createProject(projectName, options);

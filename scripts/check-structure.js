#!/usr/bin/env node

/**
 * Structure Validation Script
 * Checks if all required files and directories are present
 */

const fs = require('fs');
const path = require('path');

const REQUIRED_STRUCTURE = {
  '.claude/agents/spec-analyzer.md': 'file',
  '.claude/agents/architecture-reviewer.md': 'file',
  '.claude/agents/implementation-validator.md': 'file',
  '.claude/commands/spec-init.md': 'file',
  '.claude/commands/spec-review.md': 'file',
  '.claude/commands/arch-review.md': 'file',
  '.claude/commands/validate.md': 'file',
  '.claude/commands/spec-status.md': 'file',
  '.claude/hooks/pre-implementation-check.sh': 'file',
  '.claude/hooks/post-edit-validation.sh': 'file',
  '.claude/hooks/quality-reminder.sh': 'file',
  '.claude/hooks.json': 'file',
  'templates/feature-spec-template.md': 'file',
  'templates/api-spec-template.md': 'file',
  'README.md': 'file',
  'QUICK_START.md': 'file'
};

function checkStructure() {
  console.log('🔍 Validating project structure...\n');

  let allValid = true;
  const results = [];

  for (const [filePath, type] of Object.entries(REQUIRED_STRUCTURE)) {
    const fullPath = path.join(process.cwd(), filePath);
    const exists = fs.existsSync(fullPath);

    if (exists) {
      const stats = fs.statSync(fullPath);
      const isCorrectType =
        (type === 'file' && stats.isFile()) ||
        (type === 'directory' && stats.isDirectory());

      if (isCorrectType) {
        results.push({ path: filePath, status: '✅', message: 'OK' });
      } else {
        results.push({
          path: filePath,
          status: '❌',
          message: `Wrong type (expected ${type})`
        });
        allValid = false;
      }
    } else {
      results.push({ path: filePath, status: '❌', message: 'Missing' });
      allValid = false;
    }
  }

  // Print results
  results.forEach(({ path, status, message }) => {
    console.log(`${status} ${path} - ${message}`);
  });

  console.log('\n' + '─'.repeat(60));

  if (allValid) {
    console.log('✅ All required files and directories are present!');
    console.log('\nNext steps:');
    console.log('1. Run: pnpm run setup');
    console.log('2. Start Claude Code: claude');
    console.log('3. Try: /spec-init');
    process.exit(0);
  } else {
    console.log('❌ Some files or directories are missing or invalid.');
    console.log('\nPlease ensure all required files are present.');
    process.exit(1);
  }
}

// Check hook permissions
function checkHookPermissions() {
  console.log('\n🔒 Checking hook permissions...\n');

  const hooks = [
    '.claude/hooks/pre-implementation-check.sh',
    '.claude/hooks/post-edit-validation.sh',
    '.claude/hooks/quality-reminder.sh'
  ];

  let allExecutable = true;

  hooks.forEach(hook => {
    const fullPath = path.join(process.cwd(), hook);
    if (fs.existsSync(fullPath)) {
      try {
        fs.accessSync(fullPath, fs.constants.X_OK);
        console.log(`✅ ${hook} - Executable`);
      } catch (err) {
        console.log(`⚠️  ${hook} - Not executable (run: pnpm run setup)`);
        allExecutable = false;
      }
    }
  });

  return allExecutable;
}

// Main
console.log('AI Spec-Based Development Helper - Structure Validator\n');
checkStructure();
checkHookPermissions();

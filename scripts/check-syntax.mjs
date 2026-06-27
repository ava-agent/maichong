import { readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const roots = ['src', 'scripts'];
const extraFiles = ['vite.config.js'];
const ignoredDirs = new Set(['node_modules', 'dist', '.git', '.vercel', '.playwright-mcp']);

function collectJsFiles(dir, result = []) {
  for (const entry of readdirSync(dir)) {
    const fullPath = join(dir, entry);
    const stat = statSync(fullPath);
    if (stat.isDirectory()) {
      if (!ignoredDirs.has(entry)) {
        collectJsFiles(fullPath, result);
      }
      continue;
    }
    if (/\.(mjs|js)$/.test(entry)) {
      result.push(fullPath);
    }
  }
  return result;
}

const files = [
  ...roots.flatMap(root => collectJsFiles(root)),
  ...extraFiles,
];

let failed = false;
for (const file of files) {
  const check = spawnSync(process.execPath, ['--check', file], { stdio: 'inherit' });
  if (check.status !== 0) {
    failed = true;
  }
}

if (failed) {
  process.exit(1);
}

console.log(`Checked ${files.length} JavaScript files.`);


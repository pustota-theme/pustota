#!/usr/bin/env node
// Builds VSCode `themes/` and Zed `zed/` from `src/palettes/*.js`.
//
// Usage:
//   node src/build.js          # (re)generate theme files
//   node src/build.js --check  # fail if generated files differ from the committed ones
const fs = require('fs');
const path = require('path');

const vscodeFiles = require('./vscode');
const zedFiles = require('./zed');

const PALETTES = [
  require('./palettes/dark'),
  require('./palettes/light'),
];
const ROOT = path.join(__dirname, '..');

function main(argv) {
  const check = argv.includes('--check');
  let failed = false;

  for (const { file, content } of [...vscodeFiles(PALETTES), ...zedFiles(PALETTES)]) {
    const target = path.join(ROOT, file);

    if (check) {
      const existing = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null;
      if (existing === content) {
        console.log(`OK       ${file}`);
      } else {
        console.error(`OUTDATED ${file}, run \`npm run build\``);
        failed = true;
      }
    } else {
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.writeFileSync(target, content);
      console.log(`Written  ${file}`);
    }
  }

  process.exitCode = failed ? 1 : 0;
}

main(process.argv.slice(2));

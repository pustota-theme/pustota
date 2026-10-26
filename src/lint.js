#!/usr/bin/env node
// Checks the generated themes and the injection grammars for mistakes
// that VSCode silently ignores, like broken regexes or conflicting scopes.
//
// Usage:
//   node src/lint.js
const fs = require("fs");
const path = require("path");
const onig = require("vscode-oniguruma");

const ROOT = path.join(__dirname, "..");
const SYNTAXES_DIR = path.join(ROOT, "syntaxes");
const pkg = require(path.join(ROOT, "package.json"));

// Minimal contrast of syntax colors against the editor background:
// WCAG AA for large text by default, WCAG AAA for the contrast theme.
const MIN_CONTRAST = 3;
const MIN_CONTRAST_BY_THEME = {
  "pustota-contrast-color-theme.json": 7,
};

const COLOR = /^#(?:[0-9a-f]{6}|[0-9a-f]{8})$/i;
const FONT_STYLES = new Set(["italic", "bold", "underline", "strikethrough"]);
const REGEX_KEYS = new Set(["match", "begin", "end", "while"]);

const errors = [];

function fail(where, message) {
  errors.push(`${where}: ${message}`);
}

function relative(file) {
  return path.relative(ROOT, file);
}

// Theme files start with a `//` header, see `src/build.js`.
function readTheme(file) {
  const text = fs.readFileSync(file, "utf8").replace(/^\/\/.*$/gm, "");
  return JSON.parse(text);
}

function luminance(color) {
  const [r, g, b] = [1, 3, 5].map((i) => {
    const value = parseInt(color.slice(i, i + 2), 16) / 255;
    return value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function contrast(a, b) {
  const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (light + 0.05) / (dark + 0.05);
}

function lintColor(where, value) {
  if (typeof value !== "string" || !COLOR.test(value)) {
    fail(where, `invalid color ${JSON.stringify(value)}`);
    return false;
  }
  return true;
}

function lintTheme(file) {
  const where = relative(file);
  const theme = readTheme(file);
  const background = theme.colors["editor.background"];
  const minContrast = MIN_CONTRAST_BY_THEME[path.basename(file)] || MIN_CONTRAST;

  for (const [name, value] of Object.entries(theme.colors)) {
    lintColor(`${where} colors.${name}`, value);
  }

  const seen = new Map();
  theme.tokenColors.forEach((rule, index) => {
    const ruleWhere = `${where} tokenColors[${index}]`;
    if (!Array.isArray(rule.scope) || rule.scope.length === 0) {
      fail(ruleWhere, "expected a non-empty `scope` list");
      return;
    }

    for (const scope of rule.scope) {
      if (seen.has(scope)) {
        fail(ruleWhere, `scope \`${scope}\` is already listed in tokenColors[${seen.get(scope)}]`);
      } else {
        seen.set(scope, index);
      }
    }

    const { foreground, background: ruleBackground, fontStyle } = rule.settings;
    if (foreground !== undefined && lintColor(`${ruleWhere}.foreground`, foreground)) {
      const ratio = contrast(foreground, background);
      if (ratio < minContrast) {
        fail(
          `${ruleWhere}.foreground`,
          `${foreground} has contrast ${ratio.toFixed(2)} against ${background}, expected at least ${minContrast}`,
        );
      }
    }
    if (ruleBackground !== undefined) {
      lintColor(`${ruleWhere}.background`, ruleBackground);
    }
    if (fontStyle !== undefined) {
      for (const style of fontStyle.split(" ").filter(Boolean)) {
        if (!FONT_STYLES.has(style)) {
          fail(`${ruleWhere}.fontStyle`, `unknown style \`${style}\``);
        }
      }
    }
  });

  for (const [selector, value] of Object.entries(theme.semanticTokenColors || {})) {
    const color = typeof value === "string" ? value : value.foreground;
    lintColor(`${where} semanticTokenColors.${selector}`, color);
  }
}

// Backreferences in `end` and `while` refer to `begin` captures,
// VSCode replaces them before compiling, so they are dropped here.
function lintRegex(where, key, source) {
  const compiled = key === "end" || key === "while" ? source.replace(/\\\d+/g, "") : source;
  try {
    new onig.OnigScanner([compiled]).dispose();
  } catch (error) {
    fail(where, `invalid regex in \`${key}\`: ${error.message}`);
  }
}

function lintPatterns(where, node) {
  if (Array.isArray(node)) {
    node.forEach((item, index) => lintPatterns(`${where}[${index}]`, item));
  } else if (node && typeof node === "object") {
    for (const [key, value] of Object.entries(node)) {
      if (REGEX_KEYS.has(key) && typeof value === "string") {
        lintRegex(`${where}.${key}`, key, value);
      } else {
        lintPatterns(`${where}.${key}`, value);
      }
    }
  }
}

function lintInjections() {
  const registered = new Map();
  for (const grammar of pkg.contributes.grammars) {
    const file = path.join(ROOT, grammar.path);
    const where = `package.json grammar \`${grammar.scopeName}\``;
    if (registered.has(file)) {
      fail(where, `\`${grammar.path}\` is registered more than once`);
    }
    registered.set(file, grammar);

    if (!fs.existsSync(file)) {
      fail(where, `\`${grammar.path}\` does not exist`);
    }
    if (!Array.isArray(grammar.injectTo) || grammar.injectTo.length === 0) {
      fail(where, "expected a non-empty `injectTo` list");
    }
  }

  for (const name of fs.readdirSync(SYNTAXES_DIR).sort()) {
    const file = path.join(SYNTAXES_DIR, name);
    const where = relative(file);
    if (!name.endsWith(".injection.json")) {
      fail(where, "expected a `*.injection.json` file name");
      continue;
    }

    let grammar;
    try {
      grammar = JSON.parse(fs.readFileSync(file, "utf8"));
    } catch (error) {
      fail(where, `invalid JSON: ${error.message}`);
      continue;
    }

    // `lua-function-names.injection.json` is `pustota.injection.lua.function-names`
    const expected = `pustota.injection.${name.replace(".injection.json", "").replace("-", ".")}`;
    if (grammar.scopeName !== expected) {
      fail(where, `expected \`scopeName\` to be \`${expected}\`, got \`${grammar.scopeName}\``);
    }
    if (!registered.has(file)) {
      fail(where, "is not registered in `package.json` grammars");
    } else if (registered.get(file).scopeName !== grammar.scopeName) {
      fail(where, `\`scopeName\` does not match \`${registered.get(file).scopeName}\` in \`package.json\``);
    }
    for (const key of ["comment", "injectionSelector", "patterns"]) {
      if (!grammar[key]) {
        fail(where, `missing \`${key}\``);
      }
    }
    lintPatterns(where, grammar.patterns);
  }
}

// Comments like "from `syntaxes/python-function-names.injection.json`"
// must point to files that still exist.
function lintThemeReferences() {
  const file = path.join(__dirname, "theme.js");
  const lines = fs.readFileSync(file, "utf8").split("\n");
  lines.forEach((line, index) => {
    for (const [reference] of line.matchAll(/syntaxes\/[\w.-]+\.json/g)) {
      if (!fs.existsSync(path.join(ROOT, reference))) {
        fail(`${relative(file)}:${index + 1}`, `\`${reference}\` does not exist`);
      }
    }
  });
}

async function main() {
  const wasm = fs.readFileSync(require.resolve("vscode-oniguruma/release/onig.wasm"));
  await onig.loadWASM(wasm.buffer);

  for (const theme of pkg.contributes.themes) {
    lintTheme(path.join(ROOT, theme.path));
  }
  lintInjections();
  lintThemeReferences();

  if (errors.length) {
    for (const error of errors) {
      console.error(`ERROR    ${error}`);
    }
    process.exitCode = 1;
  } else {
    console.log("OK       themes and syntaxes");
  }
}

main();

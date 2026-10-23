// Common `pustota` layout: UI colors and syntax highlight rules.
//
// This file does not contain any actual color values,
// they come from palettes in `./palettes/*.json`.
// Each palette is applied to the very same layout,
// so all `pustota` variants highlight exactly the same things.

// Adds a hex alpha channel to a `#rrggbb` color.
function alpha(color, value) {
  if (!/^#[0-9a-f]{6}$/.test(color)) {
    throw new Error(`Expected an opaque #rrggbb color, got: ${color}`);
  }
  return `${color}${value}`;
}

// Fully transparent color, to hide things.
const TRANSPARENT = '#00000000';

// Semi-transparent black, works as a shade on both dark and light backgrounds.
const SHADE = '#00000030';

function colors(c) {
  return {
    // Editor
    // ======

    // Editor does contain some extra colors, because this is what I'm used to.
    'editor.background': c.base.bg,
    'editor.findMatchBackground': c.base.bg,
    'editor.findMatchBorder': c.accent.main,
    'editor.findMatchHighlightBackground': alpha(c.accent.main, '0d'),
    'editor.findMatchHighlightBorder': alpha(c.accent.main, 'be'),
    'editor.findRangeHighlightBackground': alpha(c.selection.inactive, 'f2'),
    'editor.findRangeHighlightBorder': alpha(c.base.bg, '00'),
    'editor.foreground': c.base.fg,
    'editor.inactiveSelectionBackground': alpha(c.selection.inactive, 'f2'),
    'editor.lineHighlightBackground': c.base.line,
    'editor.rangeHighlightBackground': c.base.bg,
    'editor.selectionBackground': c.selection.bg,
    'editor.selectionHighlightBackground': alpha(c.selection.inactive, 'f2'),
    'editor.selectionHighlightBorder': c.selection.border,
    'editor.wordHighlightBackground': alpha(c.vcs.modified, '12'),
    'editor.wordHighlightBorder': alpha(c.vcs.modified, '80'),
    'editor.wordHighlightStrongBackground': alpha(c.vcs.added, '12'),
    'editor.wordHighlightStrongBorder': alpha(c.vcs.added, '80'),

    'editorLineNumber.activeForeground': alpha(c.base.fg, 'cc'),
    'editorLineNumber.foreground': alpha(c.base.fg, '80'),
    'editorInlayHint.foreground': c.syntax.comment,

    // Stuff that I don't really care about, mostly copied from Ayu:
    // TODO: rework?
    'editorBracketMatch.background': alpha(c.base.ui, '4d'),
    'editorBracketMatch.border': alpha(c.base.ui, '99'),
    'editorCodeLens.foreground': c.syntax.comment,
    'editorCursor.foreground': c.accent.main,
    'editorGroup.border': c.base.line,
    'editorGroupHeader.noTabsBackground': c.base.bg,
    'editorGroupHeader.tabsBackground': c.base.bg,
    'editorGroupHeader.tabsBorder': c.base.bg,
    'editorGutter.addedBackground': alpha(c.vcs.added, '99'),
    'editorGutter.deletedBackground': alpha(c.vcs.removed, '99'),
    'editorGutter.modifiedBackground': alpha(c.vcs.modified, '99'),
    'editorHoverWidget.background': c.base.bg,
    'editorHoverWidget.border': c.base.panelBorder,
    'editorIndentGuide.activeBackground': alpha(c.base.ui, 'b3'),
    'editorIndentGuide.background': alpha(c.base.ui, '66'),
    'editorInfo.foreground': TRANSPARENT,
    'editorLink.activeForeground': c.accent.main,
    'editorMarkerNavigation.background': c.base.bg,
    'editorOverviewRuler.addedForeground': alpha(c.vcs.added, '99'),
    'editorOverviewRuler.border': c.base.line,
    'editorOverviewRuler.deletedForeground': alpha(c.vcs.removed, '99'),
    'editorOverviewRuler.errorForeground': c.syntax.error,
    'editorOverviewRuler.modifiedForeground': alpha(c.vcs.modified, '99'),
    'editorOverviewRuler.warningForeground': c.accent.main,
    'editorRuler.foreground': alpha(c.base.ui, '66'),
    'editorSuggestWidget.background': c.base.bg,
    'editorSuggestWidget.border': c.base.bg,
    'editorSuggestWidget.highlightForeground': c.accent.alt,
    'editorSuggestWidget.selectedBackground': c.selection.suggest,
    'editorWhitespace.foreground': alpha(c.base.ui, '99'),
    'editorWidget.background': c.base.bg,
    'editorWidget.resizeBorder': c.base.bg,
    'editorWidget.border': c.base.bg,

    // I do these customizations locally,
    // because I don't want to see any decorations
    // on my code from 3rd party tools, but others might not like it:
    // 'editorError.foreground': TRANSPARENT,
    // 'editorWarning.foreground': TRANSPARENT,

    // I am just used to these colors:
    // TODO: rework?
    'gitDecoration.addedResourceForeground': c.syntax.string,
    'gitDecoration.conflictingResourceForeground': c.vcs.conflict,
    'gitDecoration.deletedResourceForeground': alpha(c.vcs.removed, 'b3'),
    'gitDecoration.ignoredResourceForeground': c.base.uiMuted,
    'gitDecoration.modifiedResourceForeground': c.vcs.modifiedFile,
    'gitDecoration.submoduleResourceForeground': alpha(c.syntax.constant, 'b3'),
    'gitDecoration.untrackedResourceForeground': alpha(c.vcs.added, 'b3'),

    // General
    // =======

    'focusBorder': c.base.bg, // no visual border
    'errorForeground': c.syntax.keyword,
    'foreground': c.base.fg,

    'activityBar.activeBorder': c.accent.alt,
    'activityBar.background': c.base.bg,
    'activityBar.border': c.base.bg,
    'activityBar.foreground': alpha(c.base.fg, 'bf'),
    'activityBar.inactiveForeground': alpha(c.base.ui, '99'),
    'activityBarBadge.background': c.accent.main,
    'activityBarBadge.foreground': c.base.bg,

    // Sidebar
    'sideBar.background': c.base.bg,
    'sideBar.border': c.base.bg,
    'sideBar.foreground': alpha(c.base.fg, 'bf'),
    'sideBarSectionHeader.background': c.base.bg,
    'sideBarSectionHeader.border': c.base.bg,
    'sideBarSectionHeader.foreground': alpha(c.base.fg, 'bf'),
    'sideBarTitle.foreground': c.base.bg,

    // Inputs and lists
    'badge.background': alpha(c.accent.main, '33'),
    'badge.foreground': c.accent.main,
    'button.background': c.accent.main,
    'button.foreground': c.base.bg,
    'button.hoverBackground': c.accent.hover,
    'icon.foreground': c.base.fg,
    'input.background': c.base.bg,
    'input.border': c.base.bg,
    'input.foreground': c.base.fg,
    'input.placeholderForeground': alpha(c.base.fg, '80'),
    'inputOption.activeBorder': c.accent.main,
    'inputValidation.errorBackground': c.base.bg,
    'inputValidation.errorBorder': c.syntax.keyword,
    'inputValidation.infoBackground': c.base.bg,
    'inputValidation.infoBorder': c.syntax.entity,
    'inputValidation.warningBackground': c.base.bg,
    'inputValidation.warningBorder': c.accent.main,

    // Breakpoints
    'debugIcon.breakpointDisabledForeground': c.syntax.entity,
    'debugIcon.breakpointForeground': c.accent.main,

    'debugExceptionWidget.background': c.base.bg,
    'debugExceptionWidget.border': c.base.bg,
    'debugToolBar.background': c.base.bg,
    'descriptionForeground': c.base.ui,
    'diffEditor.insertedTextBackground': alpha(c.syntax.string, '26'),
    'diffEditor.removedTextBackground': alpha(c.syntax.operator, '26'),
    'dropdown.background': c.base.bg,
    'dropdown.border': c.base.dropdownBorder,
    'dropdown.foreground': c.base.ui,

    'textBlockQuote.background': c.base.bg,
    'textLink.activeForeground': c.accent.main,
    'textLink.foreground': c.accent.main,
    'textPreformat.foreground': c.base.fg,
    'tree.indentGuidesStroke': alpha(c.base.ui, 'b3'),
    'walkThrough.embeddedEditorBackground': c.base.bg,
    'widget.shadow': c.base.bg,

    'list.hoverBackground': c.base.bg,
    'list.hoverForeground': c.base.fg,
    'list.activeSelectionBackground': c.base.bg,
    'list.activeSelectionForeground': c.accent.main,
    'list.inactiveSelectionBackground': c.base.bg,
    'list.focusAndSelectionOutline': c.base.bg, // no visual border
    'list.errorForeground': c.syntax.keyword,
    'list.filterMatchBackground': alpha(c.accent.main, '0d'),
    'list.filterMatchBorder': c.accent.main,
    'list.focusBackground': c.base.bg,
    'list.focusForeground': c.base.ui,
    'list.highlightForeground': c.accent.main,
    'list.inactiveSelectionForeground': c.base.ui,
    'list.invalidItemForeground': c.base.uiDim,
    'listFilterWidget.background': c.base.bg,
    'listFilterWidget.noMatchesOutline': c.syntax.keyword,
    'listFilterWidget.outline': c.accent.main,

    'peekView.border': c.base.bg,
    'peekViewEditor.background': c.base.bg,
    'peekViewEditor.matchHighlightBackground': alpha(c.accent.main, '33'),
    'peekViewResult.background': c.base.bg,
    'peekViewResult.fileForeground': c.base.ui,
    'peekViewResult.matchHighlightBackground': alpha(c.accent.main, '33'),
    'peekViewTitle.background': c.base.bg,
    'peekViewTitleDescription.foreground': c.base.ui,
    'peekViewTitleLabel.foreground': c.base.ui,
    'pickerGroup.border': c.base.bg,
    'pickerGroup.foreground': c.base.uiMuted,
    'progressBar.background': c.accent.main,
    'scrollbar.shadow': c.base.bg,
    'scrollbarSlider.activeBackground': alpha(c.base.ui, 'b3'),
    'scrollbarSlider.background': alpha(c.base.ui, '66'),
    'scrollbarSlider.hoverBackground': alpha(c.base.ui, '99'),
    'selection.background': alpha(c.selection.bg, 'fd'),
    'settings.headerForeground': c.base.fg,
    'settings.modifiedItemIndicator': c.vcs.modified,

    // Quick input (cmd + p)
    'quickInput.background': c.base.bg,
    'quickInput.foreground': alpha(c.base.fg, 'bf'),
    'quickInputList.focusBackground': c.base.bg,
    'quickInputList.focusForeground': c.accent.alt,

    // Panels
    'panel.background': c.base.bg,
    'panel.border': c.base.bg,
    'panelTitle.activeBorder': c.accent.main,
    'panelTitle.activeForeground': c.base.fg,
    'panelTitle.inactiveForeground': c.base.ui,
    'panelSectionHeader.foreground': c.base.fg,

    // Title
    'titleBar.activeBackground': c.base.bg,
    'titleBar.activeForeground': c.base.fg,
    'titleBar.border': c.base.bg, // no visual border
    'titleBar.inactiveBackground': c.base.bg,
    'titleBar.inactiveForeground': c.base.fg,

    // Statusbar
    'statusBar.background': c.base.bg,
    'statusBar.border': c.base.bg,
    'statusBar.debuggingBackground': c.syntax.operator,
    'statusBar.debuggingForeground': c.base.bg,
    'statusBar.foreground': c.base.ui,
    'statusBar.noFolderBackground': c.base.bg,
    'statusBarItem.activeBackground': c.base.line,
    'statusBarItem.hoverBackground': c.base.line,
    'statusBarItem.prominentBackground': c.base.line,
    'statusBarItem.prominentHoverBackground': SHADE,

    // Tabs
    'tab.activeBackground': c.base.bg,
    'tab.activeBorder': c.accent.main,
    'tab.activeForeground': c.base.fg,
    'tab.border': c.base.bg,
    'tab.inactiveBackground': c.base.bg,
    'tab.inactiveForeground': c.base.ui,
    'tab.unfocusedActiveBorder': c.base.ui,
    'tab.unfocusedActiveForeground': c.base.ui,
    'tab.unfocusedInactiveForeground': c.base.ui,

    // Terminal
    // TODO: rework ansi colors
    'terminal.ansiBlack': c.terminal.black,
    'terminal.ansiBlue': c.terminal.blue,
    'terminal.ansiBrightBlack': c.terminal.brightBlack,
    'terminal.ansiBrightBlue': c.terminal.brightBlue,
    'terminal.ansiBrightCyan': c.terminal.brightCyan,
    'terminal.ansiBrightGreen': c.terminal.brightGreen,
    'terminal.ansiBrightMagenta': c.terminal.brightMagenta,
    'terminal.ansiBrightRed': c.terminal.brightRed,
    'terminal.ansiBrightWhite': c.terminal.brightWhite,
    'terminal.ansiBrightYellow': c.terminal.brightYellow,
    'terminal.ansiCyan': c.terminal.cyan,
    'terminal.ansiGreen': c.terminal.green,
    'terminal.ansiMagenta': c.terminal.magenta,
    'terminal.ansiRed': c.terminal.red,
    'terminal.ansiWhite': c.terminal.white,
    'terminal.ansiYellow': c.terminal.yellow,
    'terminal.background': c.base.bg,
    'terminal.foreground': c.base.fg,

    // Other
    'extensionButton.prominentBackground': c.accent.main,
    'extensionButton.prominentForeground': c.base.bg,
    'extensionButton.prominentHoverBackground': c.accent.hover,
  };
}

function tokenColors(c) {
  return [
    // Group 1: comments
    {
      scope: [
        'comment',

        'comment.block.documentation storage.type.class',
        'comment.block.documentation storage.type',
        'comment.block.documentation storage',
        'comment.block.documentation keyword.other',
      ],
      settings: {
        foreground: c.syntax.comment,
        fontStyle: 'italic',
      },
    },

    // Group 2: strings / text
    {
      scope: [
        'string',
        'constant.other.symbol',
        'constant.character.escape',

        // JS:
        'string.quoted invalid.illegal.newline', // in-progress strings
        // Markdown:
        'markup.quote meta.paragraph',
      ],
      settings: {
        foreground: c.syntax.string,
      },
    },

    // Group 3: constants
    {
      scope: [
        'constant.numeric',
        'constant.language',
        'support.constant',

        // CSS:
        'constant.other.color',
        // HTML:
        'string.unquoted.html',
      ],
      settings: {
        foreground: c.accent.main,
      },
    },

    // Group 4: keywords and operators
    {
      scope: [
        'keyword',
        'keyword.operator',
        'storage.modifier',
        'support.macro',
        'storage.type.function',
        'storage.type.class',
        'punctuation.definition.decorator', // `@` operator
        'punctuation.definition.annotation',
        'punctuation.decorator',
        'punctuation.separator.continuation.line',
        'punctuation.separator.annotation.result', // `->` operator in annotations

        // C:
        'constant.character.escape.line-continuation.c', // `\` operator
        'storage.type.struct.c', // `struct` keyword
        'storage.type.enum.c', // `enum`
        'storage.type.union.c', // `union`
        // JS:
        'meta.method.declaration storage.type', // `constructor`
        // TS:
        'meta.var.expr storage.type', // `type`
        'meta.interface storage.type.interface', // `interface`
        'storage.type.enum.ts', // `enum`
        'meta.type.declaration storage.type.type',
        // Rust:
        'punctuation.definition.attribute.rust', // `#` before `[]`
        'storage.type.rust',
        // Ruby:
        'punctuation.separator.other.ruby', // `:` in ternary
        // Python:
        'storage.type.type.python',  // `type` keyword
        // Lisp:
        'storage.type.function-type.lisp', // `def*`
        // Objective-C:
        'punctuation.definition.storage.type.objc', // `@implementation` / etc
        'punctuation.definition.keyword.objc',
        // Bash:
        'storage.type.alias.shell', // `alias` keyword
        // Markdown:
        'entity.name.section.markdown', // headers
        // HTML / JSX / TSX:
        'punctuation.definition.tag.begin',
        'punctuation.definition.tag.end',
        // TOML:
        'source.toml support.type.property-name.table',
        'source.toml support.type.property-name.array',
        // INI:
        'entity.name.section.group-title',
        // Makefile:
        'support.function.target.PHONY',
        // C#:
        'storage.type.namespace.cs',
        'storage.type.record.cs',
        'storage.type.var.cs',
        'storage.type.accessor.get.cs',
        'storage.type.accessor.set.cs',
        'storage.type.accessor.init.cs',
        'storage.type.delegate.cs',
        'storage.type.enum.cs',
        'storage.type.struct.cs',
        'storage.type.interface.cs',
        'storage.type.event.cs',
        'storage.type.operator.cs',
      ],
      settings: {
        foreground: c.syntax.keyword,
      },
    },

    // Group 5: Function definitions
    {
      scope: [
        'meta.definition entity.name.function',
        'meta.definition support.function',
        'meta.function.definition entity.name.function',

        // Python:
        'meta.function.python entity.name.function',
        'meta.function.python support.function',
        'meta.function.python support.variable', // constants used as functions
        'meta.function.python variable.legacy', // old types used as functions
        // Rust:
        'meta.macro.rules entity.name.function.macro.rust',
        // Ruby:
        'meta.function.method entity.name.function',
        // PHP:
        'meta.function.php entity.name.function',
        // Go:
        'entity.name.function.go',
        // Haskell:
        'meta.function.type-declaration entity.name.function',
        // CSS:
        'entity.other.keyframe-offset',
        // SASS / SCSS:
        'meta.at-rule entity.name.function',
        'meta.at-rule support.function',
        // Bash:
        'meta.function entity.name.function.shell',
        // Lisp:
        'entity.name.function.lisp',
        // Objective-C:
        'meta.function entity.name.function.objc', // function def with params
        'meta.function entity.name.function.name-of-parameter.objc',

        // ---
        // Not really functions, but these elements also need a color accent
        // ---

        // Markdown:
        'markup.inline.raw.string',
        // HTML / JSX / TSX:
        'entity.other.attribute-name',
        // Makefile:
        'entity.name.function.target.makefile',
      ],
      settings: {
        foreground: c.syntax.func,
      },
    },

    // Group 6: Type definitons
    {
      scope: [
        'meta.class entity.name.type',

        // Rust:
        'entity.name.type.struct',
        'entity.name.type.trait',
        // Dart:
        'support.class.dart',
        // Elixir:
        'meta.module entity.name.type.module',
        // Haskell:
        'meta.declaration storage.type.haskell',
        // TS:
        'meta.type.declaration entity.name.type.alias',
        'meta.interface entity.name.type.interface',
        'entity.name.type.enum.ts',
        // Lisp:
        'entity.name.type.lisp',
        // Objective-C:
        'meta.interface-or-protocol entity.name.type.objc',
        // C#:
        'entity.name.type.class.cs',
        'entity.name.type.interface.cs',
        'entity.name.type.struct.cs',
        'entity.name.type.alias.cs',
        'entity.name.type.enum.cs',

        // ---
        // Not really types, but these elements also need a color accent
        // ---

        // CSS / SCSS / SASS / Stylus:
        'entity.name.tag.css',
        // Markdown
        'meta.link.inline string.other.link.title',
        'meta.image.inline string.other.link.description',
      ],
      settings: {
        foreground: c.syntax.entity,
      },
    },

    // Everything else:
    {
      scope: [
        'storage.modifier.import',
        'storage.modifier.package',
        'entity.name.type.package',
        'entity.name.function.support',
        'entity.name.function.decorator',
        'meta.function.decorator support.type',

        // Special case: no special formatting for invalid nodes:
        'invalid',

        // Some operators are just punctuation:
        'keyword.operator.key-value',
        'keyword.operator.access.dot',
        'keyword.operator.namespace',

        // Python:
        'meta.function meta.function.parameters support.function.builtin.python',
        'keyword.illegal.name.python',
        // C:
        'meta.body meta.function.definition.parameters entity.name.function.c',
        // C#:
        'source.cs keyword.type', // primitive types like `int`
        // JS:
        'string.template meta.template', // expressions inside `${}`
        'meta.class entity.name.type.module.js', // `class A extends M.C`
        // TS:
        'meta.type.annotation entity.name.type',
        'meta.return.type entity.name.type',
        'meta.type.parameters entity.name.type',
        'keyword.operator.type.annotation.ts',
        // CSS:
        'source.css support.constant', // all values and constant likes
        'source.css meta.at-rule support.function', // `var()` func
        // JSON:
        'support.type.property-name',
        // YAML:
        'entity.name.tag.yaml',
        // CSS:
        'string.quoted.double.attribute-value',
        // Elixir and Ruby:
        'constant.language.symbol',
        'constant.other.symbol.hashkey',
        // PHP:
        'meta.method-call.static keyword.operator',
        'keyword.operator.return-value.php',
        'keyword.operator.class.php',
        // Rust:
        'keyword.operator.macro.dollar.rust', // `$` in macro defs
        // Ruby:
        'keyword.other.special-method.ruby', // `.new()`
        // Lisp:
        'keyword.constant.lisp', // :value
        // Objective-C:
        'source.objc keyword.other.property', // `@property` / `@syntesize`
        // editorconfig:
        'source.editorconfig keyword.other.definition',
        // INI:
        'source.ini punctuation.definition.entity',
        'keyword.other.definition.ini',
        // Bash:
        'string.unquoted.argument.shell',
        'string.interpolated.dollar.shell',
        'source.shell string.unquoted.argument',
      ],
      settings: {
        foreground: c.base.fg,
      },
    },

    // Special cases (font changes, mostly for markup languages)
    {
      scope: ['markup.italic'],
      settings: { fontStyle: 'italic' },
    },
    {
      scope: ['markup.bold'],
      settings: { fontStyle: 'bold' },
    },
    {
      scope: ['markup.strikethrough'],
      settings: { fontStyle: 'strikethrough' },
    },
  ];
}

// Builds a complete VSCode color theme from a palette.
// Semantic tokens come from language servers (like Pylance) and are applied
// on top of TextMate scopes. We only use them where TextMate grammars
// cannot tell the cases apart.
function semanticTokenColors(c) {
  return {
    // Python: builtin type names used as function/method names,
    // like `def set(self): ...`. The grammar scopes the name as
    // `support.type.python`, exactly like `set(items)` or `-> set`,
    // so only the language server can tell the definition apart.
    'function.declaration:python': c.syntax.func,
    'method.declaration:python': c.syntax.func,
  };
}

module.exports = function buildTheme(palette) {
  return {
    name: palette.name,
    $schema: 'vscode://schemas/color-theme',
    type: palette.type,
    semanticHighlighting: true,

    // There are several default VSCode colors that we don't customize:
    // - diffs
    // - replacements
    // - some other internals
    colors: colors(palette.colors),
    tokenColors: tokenColors(palette.colors),
    semanticTokenColors: semanticTokenColors(palette.colors),
  };
};

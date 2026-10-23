// Common `pustota` layout: UI colors and syntax highlight rules.
//
// This file does not contain any actual color values,
// they come from palettes in `./palettes/*.js`.
// Each palette is applied to the very same layout,
// so all `pustota` variants highlight exactly the same things.

const alpha = require('./alpha');

// Fully transparent color, to hide things.
const TRANSPARENT = '#00000000';

// Semi-transparent black, works as a shade on both dark and light backgrounds.
const SHADE = '#00000030';

function colors(c) {
  return {
    // Editor
    // ======

    // Editor does contain some extra colors, because this is what I'm used to.
    'editor.background': c.bg,
    'editor.findMatchBackground': c.bg,
    'editor.findMatchBorder': c.accent,
    'editor.findMatchHighlightBackground': alpha(c.accent, '0d'),
    'editor.findMatchHighlightBorder': alpha(c.accent, 'be'),
    'editor.findRangeHighlightBackground': alpha(c.selectionInactive, 'f2'),
    'editor.findRangeHighlightBorder': alpha(c.bg, '00'),
    'editor.foreground': c.fg,
    'editor.inactiveSelectionBackground': alpha(c.selectionInactive, 'f2'),
    'editor.lineHighlightBackground': c.line,
    'editor.rangeHighlightBackground': c.bg,
    'editor.selectionBackground': c.selection,
    'editor.selectionHighlightBackground': alpha(c.selectionInactive, 'f2'),
    'editor.selectionHighlightBorder': c.selectionBorder,
    'editor.wordHighlightBackground': alpha(c.vcsModified, '12'),
    'editor.wordHighlightBorder': alpha(c.vcsModified, '80'),
    'editor.wordHighlightStrongBackground': alpha(c.vcsAdded, '12'),
    'editor.wordHighlightStrongBorder': alpha(c.vcsAdded, '80'),

    'editorLineNumber.activeForeground': alpha(c.fg, 'cc'),
    'editorLineNumber.foreground': alpha(c.fg, '80'),
    'editorInlayHint.foreground': c.comment,

    // Stuff that I don't really care about, mostly copied from Ayu:
    // TODO: rework?
    'editorBracketMatch.background': alpha(c.ui, '4d'),
    'editorBracketMatch.border': alpha(c.ui, '99'),
    'editorCodeLens.foreground': c.comment,
    'editorCursor.foreground': c.accent,
    'editorGroup.border': c.line,
    'editorGroupHeader.noTabsBackground': c.bg,
    'editorGroupHeader.tabsBackground': c.bg,
    'editorGroupHeader.tabsBorder': c.bg,
    'editorGutter.addedBackground': alpha(c.vcsAdded, '99'),
    'editorGutter.deletedBackground': alpha(c.vcsRemoved, '99'),
    'editorGutter.modifiedBackground': alpha(c.vcsModified, '99'),
    'editorHoverWidget.background': c.bg,
    'editorHoverWidget.border': c.panelBorder,
    'editorIndentGuide.activeBackground': alpha(c.ui, 'b3'),
    'editorIndentGuide.background': alpha(c.ui, '66'),
    'editorInfo.foreground': TRANSPARENT,
    'editorLink.activeForeground': c.accent,
    'editorMarkerNavigation.background': c.bg,
    'editorOverviewRuler.addedForeground': alpha(c.vcsAdded, '99'),
    'editorOverviewRuler.border': c.line,
    'editorOverviewRuler.deletedForeground': alpha(c.vcsRemoved, '99'),
    'editorOverviewRuler.errorForeground': c.error,
    'editorOverviewRuler.modifiedForeground': alpha(c.vcsModified, '99'),
    'editorOverviewRuler.warningForeground': c.accent,
    'editorRuler.foreground': alpha(c.ui, '66'),
    'editorSuggestWidget.background': c.bg,
    'editorSuggestWidget.border': c.bg,
    'editorSuggestWidget.highlightForeground': c.accentAlt,
    'editorSuggestWidget.selectedBackground': c.suggestSelection,
    'editorWhitespace.foreground': alpha(c.ui, '99'),
    'editorWidget.background': c.bg,
    'editorWidget.resizeBorder': c.bg,
    'editorWidget.border': c.bg,

    // I do these customizations locally,
    // because I don't want to see any decorations
    // on my code from 3rd party tools, but others might not like it:
    // 'editorError.foreground': TRANSPARENT,
    // 'editorWarning.foreground': TRANSPARENT,

    // I am just used to these colors:
    // TODO: rework?
    'gitDecoration.addedResourceForeground': c.string,
    'gitDecoration.conflictingResourceForeground': c.conflict,
    'gitDecoration.deletedResourceForeground': alpha(c.vcsRemoved, 'b3'),
    'gitDecoration.ignoredResourceForeground': c.uiMuted,
    'gitDecoration.modifiedResourceForeground': c.gitModifiedFile,
    'gitDecoration.submoduleResourceForeground': alpha(c.constant, 'b3'),
    'gitDecoration.untrackedResourceForeground': alpha(c.vcsAdded, 'b3'),

    // General
    // =======

    'focusBorder': c.bg, // no visual border
    'errorForeground': c.keyword,
    'foreground': c.fg,

    'activityBar.activeBorder': c.accentAlt,
    'activityBar.background': c.bg,
    'activityBar.border': c.bg,
    'activityBar.foreground': alpha(c.fg, 'bf'),
    'activityBar.inactiveForeground': alpha(c.ui, '99'),
    'activityBarBadge.background': c.accent,
    'activityBarBadge.foreground': c.bg,

    // Sidebar
    'sideBar.background': c.bg,
    'sideBar.border': c.bg,
    'sideBar.foreground': alpha(c.fg, 'bf'),
    'sideBarSectionHeader.background': c.bg,
    'sideBarSectionHeader.border': c.bg,
    'sideBarSectionHeader.foreground': alpha(c.fg, 'bf'),
    'sideBarTitle.foreground': c.bg,

    // Inputs and lists
    'badge.background': alpha(c.accent, '33'),
    'badge.foreground': c.accent,
    'button.background': c.accent,
    'button.foreground': c.bg,
    'button.hoverBackground': c.accentHover,
    'icon.foreground': c.fg,
    'input.background': c.bg,
    'input.border': c.bg,
    'input.foreground': c.fg,
    'input.placeholderForeground': alpha(c.fg, '80'),
    'inputOption.activeBorder': c.accent,
    'inputValidation.errorBackground': c.bg,
    'inputValidation.errorBorder': c.keyword,
    'inputValidation.infoBackground': c.bg,
    'inputValidation.infoBorder': c.entity,
    'inputValidation.warningBackground': c.bg,
    'inputValidation.warningBorder': c.accent,

    // Breakpoints
    'debugIcon.breakpointDisabledForeground': c.entity,
    'debugIcon.breakpointForeground': c.accent,

    'debugExceptionWidget.background': c.bg,
    'debugExceptionWidget.border': c.bg,
    'debugToolBar.background': c.bg,
    'descriptionForeground': c.ui,
    'diffEditor.insertedTextBackground': alpha(c.string, '26'),
    'diffEditor.removedTextBackground': alpha(c.operator, '26'),
    'dropdown.background': c.bg,
    'dropdown.border': c.dropdownBorder,
    'dropdown.foreground': c.ui,

    'textBlockQuote.background': c.bg,
    'textLink.activeForeground': c.accent,
    'textLink.foreground': c.accent,
    'textPreformat.foreground': c.fg,
    'tree.indentGuidesStroke': alpha(c.ui, 'b3'),
    'walkThrough.embeddedEditorBackground': c.bg,
    'widget.shadow': c.bg,

    'list.hoverBackground': c.bg,
    'list.hoverForeground': c.fg,
    'list.activeSelectionBackground': c.bg,
    'list.activeSelectionForeground': c.accent,
    'list.inactiveSelectionBackground': c.bg,
    'list.focusAndSelectionOutline': c.bg, // no visual border
    'list.errorForeground': c.keyword,
    'list.filterMatchBackground': alpha(c.accent, '0d'),
    'list.filterMatchBorder': c.accent,
    'list.focusBackground': c.bg,
    'list.focusForeground': c.ui,
    'list.highlightForeground': c.accent,
    'list.inactiveSelectionForeground': c.ui,
    'list.invalidItemForeground': c.uiDim,
    'listFilterWidget.background': c.bg,
    'listFilterWidget.noMatchesOutline': c.keyword,
    'listFilterWidget.outline': c.accent,

    'peekView.border': c.bg,
    'peekViewEditor.background': c.bg,
    'peekViewEditor.matchHighlightBackground': alpha(c.accent, '33'),
    'peekViewResult.background': c.bg,
    'peekViewResult.fileForeground': c.ui,
    'peekViewResult.matchHighlightBackground': alpha(c.accent, '33'),
    'peekViewTitle.background': c.bg,
    'peekViewTitleDescription.foreground': c.ui,
    'peekViewTitleLabel.foreground': c.ui,
    'pickerGroup.border': c.bg,
    'pickerGroup.foreground': c.uiMuted,
    'progressBar.background': c.accent,
    'scrollbar.shadow': c.bg,
    'scrollbarSlider.activeBackground': alpha(c.ui, 'b3'),
    'scrollbarSlider.background': alpha(c.ui, '66'),
    'scrollbarSlider.hoverBackground': alpha(c.ui, '99'),
    'selection.background': alpha(c.selection, 'fd'),
    'settings.headerForeground': c.fg,
    'settings.modifiedItemIndicator': c.vcsModified,

    // Quick input (cmd + p)
    'quickInput.background': c.bg,
    'quickInput.foreground': alpha(c.fg, 'bf'),
    'quickInputList.focusBackground': c.bg,
    'quickInputList.focusForeground': c.accentAlt,

    // Panels
    'panel.background': c.bg,
    'panel.border': c.bg,
    'panelTitle.activeBorder': c.accent,
    'panelTitle.activeForeground': c.fg,
    'panelTitle.inactiveForeground': c.ui,
    'panelSectionHeader.foreground': c.fg,

    // Title
    'titleBar.activeBackground': c.bg,
    'titleBar.activeForeground': c.fg,
    'titleBar.border': c.bg, // no visual border
    'titleBar.inactiveBackground': c.bg,
    'titleBar.inactiveForeground': c.fg,

    // Statusbar
    'statusBar.background': c.bg,
    'statusBar.border': c.bg,
    'statusBar.debuggingBackground': c.operator,
    'statusBar.debuggingForeground': c.bg,
    'statusBar.foreground': c.ui,
    'statusBar.noFolderBackground': c.bg,
    'statusBarItem.activeBackground': c.line,
    'statusBarItem.hoverBackground': c.line,
    'statusBarItem.prominentBackground': c.line,
    'statusBarItem.prominentHoverBackground': SHADE,

    // Tabs
    'tab.activeBackground': c.bg,
    'tab.activeBorder': c.accent,
    'tab.activeForeground': c.fg,
    'tab.border': c.bg,
    'tab.inactiveBackground': c.bg,
    'tab.inactiveForeground': c.ui,
    'tab.unfocusedActiveBorder': c.ui,
    'tab.unfocusedActiveForeground': c.ui,
    'tab.unfocusedInactiveForeground': c.ui,

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
    'terminal.background': c.bg,
    'terminal.foreground': c.fg,

    // Other
    'extensionButton.prominentBackground': c.accent,
    'extensionButton.prominentForeground': c.bg,
    'extensionButton.prominentHoverBackground': c.accentHover,
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
        foreground: c.comment,
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
        foreground: c.string,
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
        foreground: c.accent,
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
        foreground: c.keyword,
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
        foreground: c.func,
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
        foreground: c.entity,
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
        foreground: c.fg,
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
function theme(palette) {
  return {
    name: palette.name,
    $schema: 'vscode://schemas/color-theme',
    type: palette.type,

    // There are several default VSCode colors that we don't customize:
    // - diffs
    // - replacements
    // - some other internals
    colors: colors(palette.colors),
    tokenColors: tokenColors(palette.colors),
  };
}

// VSCode reads theme files as JSONC, so a comment header is fine here.
function header(palette) {
  return [
    '// This file is generated by `npm run build`, do not edit it by hand.',
    `// Layout: \`src/vscode.js\`, colors: \`${palette.source}\`.`,
    '',
  ].join('\n');
}

module.exports = function vscodeFiles(palettes) {
  return palettes.map(palette => ({
    file: `themes/${palette.filename}`,
    content: header(palette) + JSON.stringify(theme(palette), null, 2) + '\n',
  }));
};

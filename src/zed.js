// `pustota` layout for Zed: same palettes, Zed theme keys.
//
// Zed theme schema: https://zed.dev/schema/themes/v0.2.0.json
// Zed has fewer customization points than VSCode,
// so this layout maps palette roles to the closest Zed keys.

const alpha = require('./alpha');
const { name, version, author, homepage } = require('../package.json');

function style(c) {
  return {
    'accents': [c.accent],
    'background': c.bg,
    'background.appearance': 'opaque',
    'surface.background': c.bg,
    'elevated_surface.background': c.bg,

    // Text and icons
    'text': c.fg,
    'text.accent': c.accent,
    'text.muted': c.ui,
    'text.disabled': alpha(c.ui, '99'),
    'text.placeholder': alpha(c.fg, '80'),
    'link_text.hover': c.accent,
    'icon': c.fg,
    'icon.accent': c.accent,
    'icon.muted': alpha(c.ui, '99'),
    'icon.disabled': alpha(c.ui, '99'),
    'icon.placeholder': alpha(c.fg, '80'),

    // Borders are hidden, `pustota` is borderless
    'border': c.bg,
    'border.variant': c.bg,
    'border.transparent': alpha(c.bg, '00'),
    'border.focused': c.accent,
    'border.selected': c.accent,
    'border.disabled': c.bg,
    'pane.focused_border': c.bg,
    'pane_group.border': c.line,
    'panel.focused_border': c.bg,

    // Elements
    'element.background': c.bg,
    'element.hover': c.line,
    'element.active': c.line,
    'element.selected': c.bg,
    'element.disabled': c.bg,
    'element.selection_background': c.selection,
    'ghost_element.background': c.bg,
    'ghost_element.hover': c.bg,
    'ghost_element.active': c.line,
    'ghost_element.selected': c.selectionInactive,
    'ghost_element.disabled': c.bg,
    'drop_target.background': alpha(c.selectionInactive, 'f2'),

    // Editor
    'editor.background': c.bg,
    'editor.foreground': c.fg,
    'editor.gutter.background': c.bg,
    'editor.line_number': alpha(c.fg, '80'),
    'editor.active_line_number': alpha(c.fg, 'cc'),
    'editor.active_line.background': c.line,
    'editor.highlighted_line.background': alpha(c.selectionInactive, 'f2'),
    'editor.indent_guide': alpha(c.ui, '66'),
    'editor.indent_guide_active': alpha(c.ui, 'b3'),
    'editor.wrap_guide': alpha(c.ui, '66'),
    'editor.active_wrap_guide': alpha(c.ui, 'b3'),
    'editor.invisible': alpha(c.ui, '99'),
    'editor.document_highlight.bracket_background': alpha(c.ui, '4d'),
    'editor.document_highlight.read_background': alpha(c.vcsModified, '12'),
    'editor.document_highlight.write_background': alpha(c.vcsAdded, '12'),
    'editor.subheader.background': c.bg,
    'search.match_background': alpha(c.accent, '33'),
    'scrollbar.thumb.background': alpha(c.ui, '66'),
    'scrollbar.thumb.hover_background': alpha(c.ui, '99'),
    'scrollbar.thumb.border': c.bg,
    'scrollbar.track.background': c.bg,
    'scrollbar.track.border': c.bg,

    // Bars, tabs and panels
    'title_bar.background': c.bg,
    'title_bar.inactive_background': c.bg,
    'toolbar.background': c.bg,
    'tab_bar.background': c.bg,
    'tab.active_background': c.bg,
    'tab.inactive_background': c.bg,
    'panel.background': c.bg,
    'panel.indent_guide': alpha(c.ui, 'b3'),
    'panel.indent_guide_active': alpha(c.ui, 'b3'),
    'panel.indent_guide_hover': alpha(c.ui, '99'),
    'status_bar.background': c.bg,

    // Terminal
    'terminal.background': c.bg,
    'terminal.foreground': c.fg,
    'terminal.ansi.background': c.bg,
    'terminal.ansi.black': c.terminal.black,
    'terminal.ansi.red': c.terminal.red,
    'terminal.ansi.green': c.terminal.green,
    'terminal.ansi.yellow': c.terminal.yellow,
    'terminal.ansi.blue': c.terminal.blue,
    'terminal.ansi.magenta': c.terminal.magenta,
    'terminal.ansi.cyan': c.terminal.cyan,
    'terminal.ansi.white': c.terminal.white,
    'terminal.ansi.bright_black': c.terminal.brightBlack,
    'terminal.ansi.bright_red': c.terminal.brightRed,
    'terminal.ansi.bright_green': c.terminal.brightGreen,
    'terminal.ansi.bright_yellow': c.terminal.brightYellow,
    'terminal.ansi.bright_blue': c.terminal.brightBlue,
    'terminal.ansi.bright_magenta': c.terminal.brightMagenta,
    'terminal.ansi.bright_cyan': c.terminal.brightCyan,
    'terminal.ansi.bright_white': c.terminal.brightWhite,

    // VCS and diagnostics
    'created': c.string,
    'created.background': alpha(c.string, '26'),
    'created.border': alpha(c.vcsAdded, '99'),
    'success': c.string,
    'success.background': alpha(c.string, '26'),
    'success.border': alpha(c.vcsAdded, '99'),
    'modified': c.gitModifiedFile,
    'modified.background': alpha(c.vcsModified, '26'),
    'modified.border': alpha(c.vcsModified, '99'),
    'deleted': alpha(c.vcsRemoved, 'b3'),
    'deleted.background': alpha(c.operator, '26'),
    'deleted.border': alpha(c.vcsRemoved, '99'),
    'renamed': alpha(c.constant, 'b3'),
    'conflict': c.conflict,
    'ignored': c.uiMuted,
    'ignored.background': c.bg,
    'ignored.border': c.bg,
    'hidden': c.uiMuted,
    'error': c.keyword,
    'error.background': c.bg,
    'error.border': c.keyword,
    'warning': c.accent,
    'warning.background': c.bg,
    'warning.border': c.accent,
    'info': c.entity,
    'info.background': c.bg,
    'info.border': c.entity,
    'hint': c.comment,
    'hint.background': c.bg,
    'hint.border': c.comment,
    'predictive': c.comment,
    'unreachable': c.comment,

    'players': [{ cursor: c.accent, selection: c.selection }],
    'syntax': syntax(c),
  };
}

function syntax(c) {
  const rules = [
    [{ color: c.comment, font_style: 'italic' }, ['comment', 'comment.doc', 'tag.doctype']],
    [{ color: c.comment }, ['hint', 'predictive']],
    [{ color: c.string }, [
      'string', 'string.escape', 'string.regex', 'string.special',
      'string.special.symbol', 'text.literal', 'link_uri',
    ]],
    [{ color: c.accent }, ['boolean', 'constant', 'constant.builtin', 'number']],
    [{ color: c.keyword }, [
      'keyword', 'operator', 'preproc', 'punctuation.list_marker',
      'punctuation.special', 'tag',
    ]],
    [{ color: c.func }, [
      'attribute', 'constructor', 'function.definition', 'function.method.constructor',
      'function.method.definition', 'function.macro', 'label',
    ]],
    [{ color: c.entity }, ['link_text', 'title', 'type.class.definition']],
    [{ color: c.fg }, [
      'embedded', 'enum', 'function', 'function.builtin', 'function.call',
      'function.decorator', 'function.decorator.call', 'function.kwargs',
      'function.method', 'function.method.call', 'primary', 'property',
      'punctuation', 'punctuation.bracket', 'punctuation.delimiter',
      'type', 'type.builtin', 'type.class', 'type.class.inheritance',
      'type.class.call', 'type.definition', 'type.interface', 'type.super',
      'definition.type', 'definition.class',
      'variable', 'variable.parameter', 'variable.special', 'variant',
    ]],
    [{ color: alpha(c.vcsModified, '99') }, ['diff.delta']],
    [{ color: alpha(c.vcsAdded, '99') }, ['diff.plus']],
    [{ color: alpha(c.vcsRemoved, '99') }, ['diff.minus']],
    [{ font_style: 'italic' }, ['emphasis']],
    [{ font_weight: 700 }, ['emphasis.strong']],
  ];
  return Object.fromEntries(rules.flatMap(([token, names]) => names.map(name => [name, token])));
}

// Builds a Zed theme family with all palettes.
function family(palettes) {
  return {
    $schema: 'https://zed.dev/schema/themes/v0.2.0.json',
    name,
    author,
    themes: palettes.map(palette => ({
      name: palette.name,
      appearance: palette.type,
      style: style(palette.colors),
    })),
  };
}

// Extension version follows `package.json`, so both are released together.
function manifest() {
  return [
    '# This file is generated by `npm run build`, do not edit it by hand.',
    `id = "${name}-theme"`,
    `name = "${name}"`,
    `version = "${version}"`,
    'schema_version = 1',
    `authors = ["${author}"]`,
    'description = "Minimalistic theme inspired by old-fashioned hobbies"',
    `repository = "${homepage}"`,
    '',
  ].join('\n');
}

module.exports = function zedFiles(palettes) {
  return [
    {
      file: `zed/themes/${name}.json`,
      content: JSON.stringify(family(palettes), null, 2) + '\n',
    },
    {
      file: 'zed/extension.toml',
      content: manifest(),
    },
  ];
};

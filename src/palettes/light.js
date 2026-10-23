// `pustota light` palette.
//
// Colors are taken from Ayu Light (`ayu` colors v7, as shipped in
// https://github.com/ayu-theme/vscode-ayu around mid-2020),
// each color plays the same role as its Ayu Dark counterpart
// does in the `pustota` (dark) palette, see `./dark.js`.
module.exports = {
  name: 'pustota light',
  type: 'light',
  source: 'src/palettes/light.js',
  filename: 'pustota-light-color-theme.json',

  colors: {
    // Base
    bg: '#fafafa', // `common.bg`
    line: '#8a91991a', // `ui.line`: `common.ui` at 10%, Ayu Light has no opaque line color
    fg: '#575f66', // `common.fg`: main text color
    ui: '#8a9199', // `common.ui`: inactive text in UI
    uiDim: '#b2b7bb', // `common.ui` faded into `bg` (invalid / placeholder items)
    uiMuted: '#c9cccf', // `common.ui` faded even more (ignored files, picker groups)
    dropdownBorder: '#dddfe1',
    panelBorder: '#f0f0f0',

    // Accent
    accent: '#ff9940', // `common.accent`
    accentHover: '#f9943b', // `common.accent` slightly darkened, used for hovered buttons
    accentAlt: '#f48f36', // `common.accent` darkened, Ayu Light uses it for accent-colored text

    // Syntax
    comment: '#abb0b6', // `syntax.comment`
    string: '#86b300', // `syntax.string`
    // Keywords, functions and types are the main markers while scrolling the code,
    // so they are `syntax.*` hues darkened to at least 4.5:1 contrast with `bg`:
    keyword: '#be5305', // `syntax.keyword` (`#fa8d3e`), darkened
    func: '#a3660c', // `syntax.func` (`#f2ae49`), darkened
    entity: '#1878bd', // `syntax.entity` (`#399ee6`), darkened
    constant: '#a37acc', // `syntax.constant`, only used in UI, not in code
    operator: '#ed9366', // `syntax.operator`, only used in UI, not in code
    error: '#f51818', // `syntax.error`, only used in UI, not in code
    conflict: '#ff0000', // git conflicts

    // Selection
    selection: '#d1e4f4', // `ui.selection.bg`
    selectionInactive: '#e7e8e9', // `ui.selection.inactive`
    selectionBorder: '#e1e1e2', // `ui.selection.border`
    suggestSelection: '#c4dbf0', // selected item in the autocomplete popup, a bit stronger than `selection`

    // VCS
    vcsAdded: '#99bf4d',
    vcsModified: '#709ecc',
    vcsRemoved: '#f27983',
    gitModifiedFile: '#c2a620', // modified files in the explorer, between `string` and `accent`

    // Terminal
    terminal: {
      black: '#000000',
      red: '#ea6c6d',
      green: '#99bf4d',
      yellow: '#eca944',
      blue: '#3199e1',
      magenta: '#9e75c7',
      cyan: '#46ba94',
      white: '#c7c7c7',
      brightBlack: '#686868',
      brightRed: '#f07171',
      brightGreen: '#86b300',
      brightYellow: '#f2ae49',
      brightBlue: '#399ee6',
      brightMagenta: '#a37acc',
      brightCyan: '#4cbf99',
      brightWhite: '#d1d1d1',
    },
  },
};

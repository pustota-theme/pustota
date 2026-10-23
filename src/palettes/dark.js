// `pustota` (dark) palette.
//
// Colors are taken from Ayu Dark (`ayu` colors v7, as shipped in
// https://github.com/ayu-theme/vscode-ayu around mid-2020),
// the only "logic" of `pustota` is to apply them to a minimalistic,
// borderless layout. The layout itself lives in `../vscode.js` and `../zed.js`.
module.exports = {
  name: 'pustota',
  type: 'dark',
  source: 'src/palettes/dark.js',
  filename: 'pustota-color-theme.json',

  colors: {
    // Base
    bg: '#0a0e14', // `common.bg`
    line: '#00010a', // `ui.line`: a bit darker than `bg`, used for subtle highlights
    fg: '#b3b1ad', // `common.fg`: main text color
    ui: '#4d5566', // `common.ui`: inactive text in UI
    uiDim: '#414856', // `common.ui` faded into `bg` (invalid / placeholder items)
    uiMuted: '#373d49', // `common.ui` faded even more (ignored files, picker groups)
    dropdownBorder: '#2b303a',
    panelBorder: '#000000',

    // Accent
    accent: '#e6b450', // `common.accent`
    accentHover: '#e1af4b', // `common.accent` slightly darkened, used for hovered buttons
    accentAlt: '#e5b358', // a slightly different accent for highlighted text in lists

    // Syntax
    comment: '#626a73', // `syntax.comment`
    string: '#c2d94c', // `syntax.string`
    keyword: '#ff8f40', // `syntax.keyword`
    func: '#ffb454', // `syntax.func`
    entity: '#59c2ff', // `syntax.entity`
    constant: '#ffee99', // `syntax.constant`, only used in UI, not in code
    operator: '#f29668', // `syntax.operator`, only used in UI, not in code
    error: '#ff3333', // `syntax.error`, only used in UI, not in code
    conflict: '#ff0000', // git conflicts

    // Selection
    selection: '#273747', // `ui.selection.bg`
    selectionInactive: '#1b2733', // `ui.selection.inactive`
    selectionBorder: '#304357', // `ui.selection.border`
    suggestSelection: '#1c2a42', // selected item in the autocomplete popup

    // VCS
    vcsAdded: '#91b362',
    vcsModified: '#6994bf',
    vcsRemoved: '#d96c75',
    gitModifiedFile: '#d4cb68', // modified files in the explorer, between `string` and `accent`

    // Terminal
    terminal: {
      black: '#00010a',
      red: '#ea6c73',
      green: '#91b362',
      yellow: '#f9af4f',
      blue: '#53bdfa',
      magenta: '#fae994',
      cyan: '#90e1c6',
      white: '#c7c7c7',
      brightBlack: '#686868',
      brightRed: '#f07178',
      brightGreen: '#c2d94c',
      brightYellow: '#ffb454',
      brightBlue: '#59c2ff',
      brightMagenta: '#ffee99',
      brightCyan: '#95e6cb',
      brightWhite: '#ffffff',
    },
  },
};

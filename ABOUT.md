# pustota

[pustota](https://ru.wikipedia.org/wiki/%D0%9F%D1%83%D1%81%D1%82%D0%BE%D1%82%D0%B0) is a minimalistic VSCode theme inspired by old-fashioned hobbies.

[Preview it online](https://vscode.dev/editor/theme/sobolevn.pustota) on `vscode.dev` with default settings.

## Core features

- Minimalistic
- Borderless
- High contrast for the needed parts
- Small amount of colors
- Only statically known parts are highlighed

Unlike many other themes, this one only highlights a few things:
1. Comments (`#626A73`) ![#626A73](https://placehold.co/15x15/626A73/626A73.png)
2. Strings (`#C2D94C`) ![#C2D94C](https://placehold.co/15x15/C2D94C/C2D94C.png)
3. Constants (`#E6B450`) ![#E6B450](https://placehold.co/15x15/E6B450/E6B450.png)
4. Keywords and operators (`#FF8F40`) ![#FF8F40](https://placehold.co/15x15/FF8F40/FF8F40.png)
5. Function definitions (`#FFB454`) ![#FFB454](https://placehold.co/15x15/FFB454/FFB454.png)
6. Type-like definitions (`#59C2FF`) ![#59C2FF](https://placehold.co/15x15/59C2FF/59C2FF.png)

Everything else is just white (`#B3B1AD`) ![#B3B1AD](https://placehold.co/15x15/B3B1AD/B3B1AD.png)

![default](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/default.png)

### pustota light

`pustota light` is the same theme with colors from [Ayu Light](https://github.com/ayu-theme/vscode-ayu) instead of Ayu Dark.
It highlights exactly the same things:
1. Comments (`#737B84`) ![#737B84](https://placehold.co/15x15/737B84/737B84.png)
2. Strings (`#478F00`) ![#478F00](https://placehold.co/15x15/478F00/478F00.png)
3. Constants (`#AB8600`) ![#AB8600](https://placehold.co/15x15/AB8600/AB8600.png)
4. Keywords and operators (`#D43811`) ![#D43811](https://placehold.co/15x15/D43811/D43811.png)
5. Function definitions (`#CC7E00`) ![#CC7E00](https://placehold.co/15x15/CC7E00/CC7E00.png)
6. Type-like definitions (`#007ADA`) ![#007ADA](https://placehold.co/15x15/007ADA/007ADA.png)

Everything else is just dark grey (`#181B1F`) ![#181B1F](https://placehold.co/15x15/181B1F/181B1F.png)

![default-light](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/default-light.png)

### pustota contrast

`pustota contrast` is the same dark theme with brighter text, comments and constants.
It highlights exactly the same things:
1. Comments (`#959DA6`) ![#959DA6](https://placehold.co/15x15/959DA6/959DA6.png)
2. Strings (`#C2D94C`) ![#C2D94C](https://placehold.co/15x15/C2D94C/C2D94C.png)
3. Constants (`#F5BD47`) ![#F5BD47](https://placehold.co/15x15/F5BD47/F5BD47.png)
4. Keywords and operators (`#FF8F40`) ![#FF8F40](https://placehold.co/15x15/FF8F40/FF8F40.png)
5. Function definitions (`#FFB454`) ![#FFB454](https://placehold.co/15x15/FFB454/FFB454.png)
6. Type-like definitions (`#59C2FF`) ![#59C2FF](https://placehold.co/15x15/59C2FF/59C2FF.png)

Everything else is just white (`#E0DED8`) ![#E0DED8](https://placehold.co/15x15/E0DED8/E0DED8.png)

![default-contrast](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/default-contrast.png)

## Pairings

Pairs greatly with [`FiraCode`](https://github.com/tonsky/FiraCode) font and [`sobole`](https://github.com/sobolevn/sobole-zsh-theme) theme for ZSH.

This theme does not include an icon theme, so you can use any:
- `Ayu` has a great one that I am using
- `Seti` - the default one - is also fine

You can also check my [`.dotfiles`](https://github.com/sobolevn/dotfiles) with the whole setup.

## Installation

[Install it from the official website](https://marketplace.visualstudio.com/items?itemName=sobolevn.pustota) or install it with CLI: `code --install-extension sobolevn.pustota`

VSCodium and OpenVSX [are also supported](https://open-vsx.org/extension/sobolevn/pustota).

And then choose `Preferences: Color Theme` to be `"pustota"`, `"pustota light"`, or `"pustota contrast"`.

## Supported languages

This theme [supports a lot of languages](https://github.com/pustota-theme/pustota/tree/master/test), starting from mainstream ones
like Python, TypeScript, and Java.
And ending with languages like Elixir, Lisp, and Haskell.

If you want to contribute a language support, please feel free!
It is quite easy to do, since there are only 5 major colors :)

### Semantic tokens

Most languages are highlighted with TextMate grammars only,
but some definitions can not be told apart from usages without a language server.
These languages need semantic tokens from an extension:

| Language | What needs semantic tokens | Extension |
|----------|----------------------------|-----------|
| Dart | Class, extension type, function, and method definition names | [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) |

Without the extension these names are not highlighted, everything else works as usual.

## Development

Files in `themes/` are generated, do not edit them by hand.
The layout and highlight rules live in `src/theme.js`,
colors for each variant live in `src/palettes/`.
To regenerate themes after a change run:

```bash
npm run build
```

To check the generated themes and the injection grammars in `syntaxes/` run:

```bash
npm run lint
```

## Ports

- Neovim port is available at [pustota.nvim](https://github.com/pustota-theme/pustota.nvim)
- Zed post is available at [pustota.zed](https://github.com/pustota-theme/pustota.zed)
- Codex post is available at [pustota.codex](https://github.com/pustota-theme/pustota.codex)

## Showcase

Theme with [my VSCode settings](https://github.com/sobolevn/dotfiles/tree/master/vscode):

![minimal](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/minimal.png)

![main](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/main.png)

## Recommended settings

[Full list of the settings I use](https://github.com/sobolevn/dotfiles/blob/master/vscode/settings.json).

Major ones:
- `"editor.semanticHighlighting.enabled": true` to turn on semantic syntax
- `"editor.matchBrackets": "never"` to turn off parens highlight

## Thanks to

- [Ayu Dark](https://github.com/ayu-theme/vscode-ayu) which was the main source of the style and colors (and even some tests)
- [Alabster](https://github.com/tonsky/vscode-theme-alabaster) for the concept of "small visual noise"

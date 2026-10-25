---
title: "pustota"
description: Syntax highlighting fixture for Markdown
tags: [theme, vscode, markdown]
draft: false
version: 0.34.0
---

# Header

Some text.

## Subheader

```python
import ast

ast.dump(ast.parse('print(1)'))
```

<!---
your comment goes here
and here
-->

> Quote
> Other

*Italic*, **bold**, `code inline`, ~~crossed out~~

[link](https://github.com)
![main](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/main.png)
[![image](https://link.com)](https://abc.ru)
[`code link`](https://github.com)


Setext Header Level One
=======================

Setext Header Level Two
-----------------------

### Third level

#### Fourth level

##### Fifth level

###### Sixth level ######

Emphasis: *asterisk italic*, _underscore italic_, **asterisk bold**,
__underscore bold__, ***bold italic***, ___also bold italic___,
**bold with _nested italic_ inside**, ~~strikethrough~~, ~single tilde~.

Inline code: `const x = 1;`, ``code with a ` backtick inside``,
` `` ` and a `<tag>` that stays literal. Escapes: \*not italic\*,
\_not italic\_, \`not code\`, \# not a heading, \[not a link\], 1\. not a list.

Hard line break with two trailing spaces  
and a hard line break with a backslash\
then the paragraph continues. Emoji shortcodes: :sparkles: :rocket: :tada:

Autolink <https://github.com/pustota-theme/pustota> and mail <mail@sobolevn.me>,
a bare URL https://sobolevn.me and an [inline link with title](https://github.com "GitHub"),
a [reference link][gh], a [collapsed reference][], a [shortcut reference],
and an [angle-bracket link](<https://example.com/path with spaces> 'single-quoted title').

![alt text](https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/main.png "Image title")
![reference image][logo]

[gh]: https://github.com/pustota-theme/pustota
[collapsed reference]: https://code.visualstudio.com/ "Visual Studio Code"
[shortcut reference]: <https://marketplace.visualstudio.com/> (Marketplace)
[logo]: https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/logo.png

Footnotes[^1] and another one[^note].

[^1]: The first footnote.
[^note]: A named footnote
    with a continuation line.

## Lists

- Unordered with dash
- Second item
  - Nested with two spaces
    - Deeper nesting
  - Back one level
- Third item

* Asterisk bullet
* Another asterisk

+ Plus bullet
+ Another plus

1. Ordered with dot
2. Second
   1. Nested ordered
   2. Nested ordered
3. Third

1) Ordered with parenthesis
2) Second
3) Third

- [ ] Unchecked task
- [x] Checked task
- [X] Checked with capital X
  - [ ] Nested task

- A loose list item

- Separated by blank lines

  with a second paragraph inside the item.

- And a final item.

Term
: Definition-list-like text (pandoc / PHP Markdown Extra style)

Another term
: Another definition
: A second definition for the same term

## Block quotes

> Level one quote
> continues here.
>
> > Nested quote
> > with **bold** and `code`.
> >
> > > Third level
>
> Back to level one with a list:
>
> - item in a quote
> - another item
>
> ```js
> console.log("code inside a quote");
> ```

## Code blocks

```javascript
export function square(n) {
  return n * n;
}
```

```ts
type Theme = "dark" | "light" | "contrast";
const current: Theme = "dark";
```

```json
{"name": "pustota", "type": "dark", "versions": [0.33, 0.34]}
```

```yaml
stage: test
script:
  - make lint
```

```bash
#!/usr/bin/env bash
set -euo pipefail
npm run build && code --install-extension pustota-*.vsix
```

```diff
- old line
+ new line
```

```
Plain fenced block with no language tag.
```

~~~python
def hello(name: str) -> str:
    return f"Hello, {name}!"
~~~

~~~~
Tilde fence containing ~~~ three tildes inside.
~~~~

`````md
Backtick fence containing a ```python fence inside.
`````

    Indented code block
    with four spaces
        and extra indentation

## Tables

| Left aligned | Centered | Right aligned | Default |
|:-------------|:--------:|--------------:|---------|
| `code`       | **bold** | 1.0           | plain   |
| [link](#)    | *italic* | -2.5          | ~~del~~ |
| a \| pipe    | :tada:   | 1e-5          |         |

Header | Without leading pipes
------ | ---------------------
cell   | cell

## Horizontal rules

---

***

___

- - -

## Math

Inline math $E = mc^2$ and $\frac{a}{b}$, display math:

$$
\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
$$

$$\begin{aligned} a &= b + c \\ d &= e \end{aligned}$$

## HTML

Inline <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>, <sup>superscript</sup>,
<sub>subscript</sub>, <mark>highlighted</mark>, <abbr title="Visual Studio Code">VS Code</abbr>,
and an <a href="https://github.com" target="_blank">HTML link</a>.

<details>
<summary>Click to expand</summary>

Markdown **inside** a details block:

- item one
- item two

</details>

<div align="center">
  <img src="https://raw.githubusercontent.com/pustota-theme/pustota/master/assets/logo.png" width="120" alt="logo">
  <p><em>Centered HTML block</em></p>
</div>

<table>
  <tr><th>HTML</th><th>table</th></tr>
  <tr><td>cell</td><td>cell</td></tr>
</table>

<br/>
<hr>

<!-- single-line HTML comment -->

Trailing paragraph after all the blocks.

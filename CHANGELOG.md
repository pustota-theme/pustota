# Changelog

All notable changes to the "pustota" extension will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.

## 0.0.27

- Fixed `.new()` highlight in `ruby`, #57

## 0.0.26

- Fixed debug breakpoints colors

## 0.0.25

- Fixed inlay hints color, #40

## 0.0.24

- Fixed VSCodium support

## 0.0.23

- Added VSCodium support, #16

## 0.0.22

- Improve `C` highlight: fix `union` and `enum`, #32
- Improve `C#` highlight: fix types and classes highlight

## 0.0.21

- Improve `CSS` highlight: fix `@keyframes` highlight, #30

## 0.0.20

- Improve `TypeScript` highlight: `enum` is now highlighted properly, #27
- Improve `JavaScript` highlight:
  `extends Module.Class` is now highlighted properly, #26

## 0.0.19

- Improve `CSS` highlight: now less constants are highlighted
- Adds CSS test file

## 0.0.18

- Project was moved to https://github.com/pustota-theme org
- All links were updated

## 0.0.17

- Fixes Python highlight of types

## 0.0.16

- Fixes installation problem

## 0.0.15

- Fixes how functions deinitions with names
  like `__module__` or `set` are highlighted in Python

## 0.0.14

- Improve `C` highlight: do not colorize builtin types
- Imporve `go` highlight: highlight function names

## 0.0.13

- Revert `0.0.12` change

## 0.0.12

- Fixes Python builtins not highlighted when used as function names

## 0.0.11

- Fixes old legacy Python builtins not highlighted when used as function names

## 0.0.10

- Fixes `${}` highlight in JS / TS
- Fixes last char highlight when typing a string without ending quote in JS / TS

## 0.0.9

- Fixes `alias` keyword in Bash

## 0.0.8

- Added Lisp support

## 0.0.7

- Fixed `mod` highlight in Rust
- Fixed `->` in Python annotations highlight

## 0.0.6

- Fixed Markdown headings highlight
- Fixed keywords highligh in jsdoc, phpdoc, etc
- Fixed Makefile syntax highlights
- Fixed PHP syntax highlights
- Added configuration instructions
- Ignored multiple folders from the result build

## 0.0.5

- Fixed ternary operator in Ruby
- Fixed `.editorconfig` file colors
- Fixed INI and TOML colors
- Fixed escape chars in Python's strings
- Fixed Bash's function definitions

## 0.0.4

- Fix several Markdown syntax highlights
- Fixed theme name to be lowercase: `pustota`

## 0.0.3

- Fixes multiple JS and TS syntax highlights
- Removes "incorrect" scope matcher
- Enforce more `#0A0E14` usage

## 0.0.2

- Adds theme icon

## 0.0.1

- Initial release

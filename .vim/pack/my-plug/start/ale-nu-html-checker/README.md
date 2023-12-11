# ale-nu-html-checker

## Introduction

Add ale linter 'Nu HTML chkecer'

## Require

- Vim 8.0
  - do not work NeoVim
- JAVA
  - [Oracle](https://www.oracle.com/j) JAVA
  - [OpenJDK](OpenJDK)
  - etc.
- [vnu-jar](https://github.com/validator/validator/pkgs/npm/vnu-jar)
- [ale](https://github.com/dense-analysis/ale)

## Setup

### install vnu-jar

```sh
npm install vnu-jar
```

Or

```sh
npm install -g vnu-jar
```

### copy plug-in

```sh
cp ale-nu-html-checker $HOME/.vim/pack/HOGE/start/ale-nu-html-checker
```

### writing $HOME/.vim/vimrc, \~/.vimrc, $HOME/\_vimrc, $HOME/vimfiles/vimrc or $VIM/\_vimrc etc

if vnu-jar do not save in $HOME/node\_modules, for example

- UNIX

  ```vim
  let g:ale_nu_html_checker_use_global = "/usr/local/lib/node_modules/"
  ```

- Windows

  ```vim
  let g:ale_nu_html_checker_use_global = 'C:¥Users¥USER_NAME¥AppData¥Roaming¥npm¥node_modules'
  ```

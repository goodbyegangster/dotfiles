# dotfiles

## Overview

WSL と Windows 開発環境で使う設定ファイル、導入 script、作業メモを管理する。

## Requirements

初回セットアップでは、必要に応じて次の公式ドキュメントを参照する。

- [Windows ターミナル](https://learn.microsoft.com/ja-jp/windows/terminal/)
- [PowerToys](https://learn.microsoft.com/ja-jp/windows/powertoys/install#install-with-microsoft-store)
- [WSL](https://learn.microsoft.com/ja-jp/windows/wsl/install)
- [GitHub CLI](https://github.com/cli/cli?tab=readme-ov-file#installation)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [VS Code Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

## Usage

利用できる task を表示する。

```shell
make
```

dotfiles の symbolic link を作成または更新する。

```shell
make link-update
```

古い backup link を削除する。

```shell
make link-remove
```

## Directory Layout

```text
./
├── .config/                  # CLI tool と formatter/linter の設定
│   ├── biome/
│   ├── cspell/
│   ├── editorconfig/
│   ├── html/
│   ├── markdownlint-cli2/
│   ├── pip/
│   ├── pnpm/
│   ├── sqlfluff/
│   ├── textlint/
│   └── uv/
├── bash/                     # Bash の設定
│   ├── .bash_aliases
│   ├── .bashrc
│   └── .profile
├── git/                      # Git の設定
│   ├── .gitconfig
│   └── .gitconfig.local.sample
├── mise/                     # mise の設定
│   └── config.toml
├── scripts/                  # link 更新と install 用 script
│   ├── aws/
│   ├── install/
│   ├── link-remove.sh
│   └── link-update.sh
├── skills/                   # agent 用 skill
│   ├── code-search/
│   ├── dependency-review/
│   └── write-readme/
├── tips/                     # tool ごとの短いメモ
│   ├── JavaScript/
│   ├── PowerShell/
│   ├── Python/
│   └── mise/
├── vscode/                   # VS Code の設定、task、snippet
│   ├── settings-windows/
│   ├── settings-wsl/
│   ├── snippets/
│   ├── keybindings.json
│   └── tasks.json
├── .gitignore
├── Makefile
├── README.md
└── dotfiles.code-workspace
```

## Related Documentation

- [mise](./tips/mise/mise.md)
- [PowerShell](./tips/PowerShell/PowerShell.md)
- [uv](./tips/Python/uv.md)
- [Poetry](./tips/Python/Poetry.md)
- [pnpm](./tips/JavaScript/pnpm.md)
- [Biome](./tips/JavaScript/Biome.md)

# dotfiles

## Overview

WSL と Windows の開発環境で使う設定ファイルを管理する。

Bash、Git、mise、PowerShell、VS Code、各種 formatter/linter の設定を含む。
設定ファイルを配置するための script も含む。

## Requirements

主な操作では次の command を使う。

- Bash 4.4 以上
- GNU Make

初回セットアップでは、必要に応じて次のドキュメントを参照する。

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

設定ファイルの symbolic link を作成または更新する。

```shell
make link-update
```

古い symbolic link の backup を削除する。

```shell
make link-remove
```

## Directory Layout

```text
./
├── .config/                  # CLI tool と formatter/linter の設定
├── bash/                     # Bash の設定
├── git/                      # Git の設定
├── mise/                     # mise の設定
├── pwsh/                     # PowerShell module と ScriptAnalyzer 設定
├── scripts/                  # link 更新と install 用 script
├── skills/                   # agent 用 skill
├── tips/                     # tool ごとの短いメモ
├── vscode/                   # VS Code の設定、task、snippet
├── .gitignore
├── Makefile
├── README.md
└── dotfiles.code-workspace
```

## Related Documentation

- [mise](./tips/mise/mise.md)
- [PowerShell](./tips/PowerShell/PowerShell.md)
- [uv](./tips/Python/uv.md)
- [pnpm](./tips/JavaScript/pnpm.md)
- [Biome](./tips/JavaScript/Biome.md)

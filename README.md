# dotfiles

## Initial setup

### Common

- [Visual Studio Code](https://code.visualstudio.com/download)

### Windows

- [Windows ターミナル](https://learn.microsoft.com/ja-jp/windows/terminal/)
- [PowerToys](https://learn.microsoft.com/ja-jp/windows/powertoys/install#install-with-microsoft-store)
- [WSL](https://learn.microsoft.com/ja-jp/windows/wsl/install)
- [GitHub CLI](https://github.com/cli/cli?tab=readme-ov-file#installation)
- [VS Code Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

### macOS

- [Homebrew](https://brew.sh/ja/)
- [Bash](./tips/bash/bash.md)
- [Ghostty](https://ghostty.org/download)
- [GitHub CLI](https://github.com/cli/cli?tab=readme-ov-file#installation)
- [Docker](./tips/docker/docker.md)

## Usage

### mise setup

下記より mise を選択してインストール。

```sh
make run-install-scripts
```

mise 管理のモジュールをインストール。

```sh
mise install
```

### update link

設定ファイルの symbolic link を作成または更新する。

```sh
make link-update
```

古い symbolic link の backup を削除する。

```sh
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
- [pnpm](./tips/TypeScript/pnpm.md)
- [Biome](./tips/TypeScript/Biome.md)

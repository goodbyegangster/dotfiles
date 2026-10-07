# Bash

## macOS

Homebrew で最新の Bash をインストールする。

```sh
brew install bash
```

新しい Bash を有効なシェル一覧 `/etc/shells` に追加する。

```sh
BREW_BASH="$(brew --prefix bash)/bin/bash"
grep -qxF "$BREW_BASH" /etc/shells || echo "$BREW_BASH" | sudo tee -a /etc/shells
```

標準のシェルを新しい Bash に変更する。

```sh
chsh -s "$BREW_BASH"
```

ターミナルを開き直して、バージョンを確認する。

```sh
echo "$SHELL"
bash --version
```

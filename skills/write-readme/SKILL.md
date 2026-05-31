---
name: write-readme
description: README.md を作成・編集・見直しするときに利用
---

# write-readme

## 目的

有用で、具体的で、簡潔で、lint に通しやすい README.md を作成する。

優先順位は、まず明確さ、次に正確さ、最後に網羅性とする。

README.md は入口であり、完全なマニュアルではない。

## README.md を作成するパス

指示ない限り project root に作成する。

## 必要なディレクトリ調査

README.md を作成・編集する前に、該当 README.md パス配下のディレクトリを調査し、次の情報を特定する。

- WHAT:
  - この project・package・app・library が何であるか
- WHY:
  - ドキュメントの目的
- WHO:
  - 想定ユーザー
- HOW:
  - Requirements
  - 一般的な使い方
  - Repository Layout
  - 関連ドキュメントがどこにあるのか

不足している情報を捏造しない。

## 推奨構成

対象のディレクトリが別の構成を強く示していない限り、次の構成を使う。

1. Overview
2. Requirements
3. Usage
4. Repository Layout
5. Related documentation

正確に書けないセクションは省略する。

## 言語

指示ない限り `日本語` で記載する。

## 文体

- 指示ない限り `日本語` で記載する。文体は `常体` を利用する
- 短く、直接的な文を使う
- 具体的なコマンドと example を優先する
- 明らかなことを説明しない

## 長さの制限

README.md 全体は、次の上限を守る。

- 80-120 行

指示ない限り、次の上限を守る。

- Overview: 最大 120 文字
- Usage: 最大 2 examples
- Section body: 最大 2 つの短い paragraph、または 1 つの list
- Paragraph: 最大 3 sentences

さらに詳細が必要な場合は、README.md を膨らませず、別のドキュメントへ link する。

## `Repository Layout` の表現方法

指示ない限り、下記の tree コマンド結果にコメントを付与する形で表現する。

```shell
tree -F --dirsfirst --gitignore -L 2 -a
```

## README 範囲外

- 完全な reference documentation を含めない
- 長い design explanation を含めない
- すべての edge case を含めない

## 検証

README.md を編集した後、利用可能な検査を実行する。

安全であり、かつ要求されている場合は、fix を適用し、検査を再実行する。

### textlint

```shell
textlint --fix --dry-run README.md
```

非対話 shell で textlint が見つからない場合は、下記の binary と config を直接使う。

```shell
$HOME/dotfiles/.config/textlint/node_modules/.bin/textlint \
  --config $HOME/dotfiles/.config/textlint/config.json \
  --fix --dry-run README.md
```

### markdownlint

```shell
markdownlint-cli2 --no-globs README.md
```

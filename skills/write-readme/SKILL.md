---
name: write-readme
description: README.md を作成・編集・見直しするときに利用する。簡潔で明確な README.md を作成し、textlint / markdownlint で検証する。
---

# write-readme

## 目的

有用で、具体的で、簡潔で、lint に通しやすい README.md を作成する。

優先順位は、まず明確さ、次に正確さ、最後に網羅性とする。

README.md は入口であり、完全なマニュアルではない。

## README.md を作成するパス

明示的な指示がない限り、project root に作成する。

## 必要なディレクトリ調査

README.md を作成・編集する前に、対象 README.md の配置先ディレクトリ配下を調査し、次の情報を特定する。

- WHAT:
  - この project、package、app、library が何であるか
- WHY:
  - このドキュメントの目的
- WHO:
  - 想定ユーザー
- HOW:
  - Requirements
  - 一般的な使い方
  - Directory Layout
  - 関連ドキュメントの場所

不足している情報を捏造しない。

## 推奨構成

対象ディレクトリが別の構成を強く示していない限り、次の構成を使う。

1. Overview
2. Requirements
3. Usage
4. Directory Layout
5. Related documentation

正確に書けない section は省略する。

## 言語

明示的な指示がない限り、日本語で記載する。

## 文体

- 文体は常体を使う
- 短く、直接的な文を使う
- 具体的なコマンドと example を優先する
- 明らかなことを説明しない
- Marketing language を避ける

## 長さの制限

README.md 全体は、明示的な指示がない限り 80-120 行に収める。

次の上限を守る。

- Overview: 最大 80 文字
- Usage: 最大 2 examples
- Section body: 最大 2 つの短い paragraph、または 1 つの list
- Paragraph: 最大 3 sentences

さらに詳細が必要な場合は、README.md を膨らませず、別のドキュメントへ link する。

## `Repository Layout` の表現方法

明示的な指示がない限り、次の `tree` コマンドの結果にコメントを付与する形で表現する。

```shell
tree -F --dirsfirst --gitignore -L 2 -a
```

## README.md の範囲外

- 完全な reference documentation を含めない
- 長い design explanation を含めない
- すべての edge case を含めない
- 根拠のない badges、roadmap、production readiness を含めない
- 確認できない commands、environment variables、package names を含めない

## 検証

README.md を編集した後、利用可能な検査を実行する。

安全であり、かつ要求されている場合は、fix を適用し、検査を再実行する。

検証コマンドの `README.md` は、対象の README.md パスに置き換える。

### textlint

```shell
textlint --fix --dry-run <対象 README.md>
```

非対話 shell で textlint が見つからない場合は、次の binary と config を直接使う。

```shell
$HOME/dotfiles/.config/textlint/node_modules/.bin/textlint \
  --config $HOME/dotfiles/.config/textlint/config.json \
  --fix --dry-run <対象 README.md>
```

### markdownlint

```shell
markdownlint-cli2 --no-globs <対象 README.md>
```

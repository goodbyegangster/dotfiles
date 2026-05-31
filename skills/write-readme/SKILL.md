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

- この project・package・app・library が何であるか
- 何に使うものか
- 想定ユーザー
- Requirements
- 一般的な使い方
- 関連ドキュメント

不足している情報を捏造しない。

## README 範囲

README.md は次の問いに答える。

1. これは何か
2. 誰のためのものか
3. 次に何ができるか
4. 最も一般的な workflow をどう実行するか
5. 詳細なドキュメントはどこにあるか

## README 範囲外

- 完全な reference documentation を含めない
- 長い design explanation を含めない
- すべての edge case を含めない
- 詳細な内容が必要な場合は、必要に応じて docs/ に移動する

## 推奨構成

リポジトリが別の構成を強く示していない限り、次の構成を使う。

1. Overview
2. Repository Layout
3. Requirements
4. Usage
5. Related documentation

正確に書けない section は省略する。

## 言語

指示ない限り `日本語` で記載する。文体は `常体` を利用する。

## 長さの制限

標準の目安は次のとおり。

- 小さな個人プロジェクト: 80-150 行
- Library または CLI tool: 120-220 行
- Application または service: 150-300 行

明示的に要求されていない限り、次の上限を守る。

- Overview: 最大 120 words
- Usage: 最大 2 examples
- Section body: 最大 2 つの短い paragraph、または 1 つの list
- Paragraph: 最大 3 sentences
- Sentence: 25 words 未満を推奨

さらに詳細が必要な場合は、README.md を膨らませず、別のドキュメントへ link する。

## 文体

短く、直接的な文を使う。

具体的なコマンドと example を優先する。

Active voice を優先する。

Present tense を優先する。

明らかなことを説明しない。

Marketing language を避ける。

## 検証

README.md を編集した後、利用可能な検査を実行する。

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

安全であり、かつ要求されている場合は、fix を適用し、検査を再実行する。

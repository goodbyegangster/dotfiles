---
name: review-bash
description: bash スクリプトをレビューし、同意がある場合のみ修正して、shellcheck / shfmt で検査する。
---

# review-bash

## 目的

bash スクリプトをレビューし、移植性の問題、可読性、保守性を評価する。

## レビュー手順

- 対象コードだけでは判断できない事項を、推測で断定しない
- 明示的な修正依頼がない場合、レビュー結果を提示してから修正可否を確認する

## レビュー項目

### 移植性

#### Shebang

以下を利用する。

```shell
#!/usr/bin/env bash
```

#### Requirements

- GNU Bash 4.4 or later

### 行長

1 行の長さを 100 文字までとする。

### 命名規則

#### ファイル名

- `kebab-case` を利用

#### 定数

- `UPPER_SNAKE_CASE` を利用
- `readonly` 宣言を必須

#### グローバル変数

- `UPPER_SNAKE_CASE` を利用

#### ローカル変数

- `lower_snake_case` を利用
- `local` 宣言を必須

#### 関数

- `lower_snake_case` を利用
- `function` keyword を利用しない
- 関数名の後の `()` を必須

```shell
function_name() {
    :
}
```

### Shell option

スクリプト処理内容との整合性を確認し、原則以下を利用する。

```shell
set -euo pipefail
```

### エントリーポイント

main 関数を用意する。

```shell
main() {
    :
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### path の操作

ファイルを参照する場合、現在の working directory ではなく、スクリプトの配置場所を基準にする。

```shell
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR
```

### 条件式

`[[ ]]` を利用する。

```shell
if [[ -f "${file}" ]]; then
    :
fi
```

### コメント

明示的に指定ないかぎり `日本語` で記載する。

#### スクリプト単位

次の項目を、ファイル先頭に記載する。

- 処理概要
  - 120 文字以内の簡潔な文章とする
- Requirement Bash Version

必要と判断される項目のみ、それぞれ 120 文字以内で記載する。

- スクリプトの目的
- 前提条件
- 実行環境上の制約

以下の形式を利用する。

```shell
#!/usr/bin/env bash
#
# <write description>
# 
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -euo pipefail
```

#### 関数単位

以下の項目を 80 文字以内で記載する。

- 処理概要

コードの複雑さより必要と判断した場合のみ、以下より必要項目のみを記載する。

- 引数
- 標準出力
- 標準エラー出力
- 終了ステータス

以下の形式を利用する。

```shell
# <write description>
# 
# 引数
#   $1: hogehoge
function_name() {
  :
}
```

#### 副作用の発生箇所

破壊的な副作用のある箇所を、コメントから識別できるようにする。

## 検証

- コードを更新した場合、更新後に shellcheck / shfmt を実行する
- コードを更新しない場合でも、レビュー判断に必要であれば shellcheck / shfmt を実行する
- プロジェクトに既定の検査コマンドがある場合は、そのコマンドを優先する
- 検査できない場合は、実行したコマンドと理由を報告し、成功したものとして扱わない

### shellcheck

```shell
shellcheck -x --rcfile=${HOME}/.shellcheckrc <path_to_file>
```

### shfmt

```shell
shfmt --diff <path_to_file>
```

更新を許可された場合、以下を実行する。

```shell
shfmt --write <path_to_file>
```

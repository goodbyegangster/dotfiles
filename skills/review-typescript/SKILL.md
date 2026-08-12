---
name: review-typescript
description: TypeScript コードをレビューし、同意がある場合のみ修正、Biome で検査する。
---

# review-typescript

## 目的

TypeScript のコードをレビューし、可読性、保守性、不要な複雑さを評価する。

ユーザーの指示とプロジェクト固有の規約を、この skill の規則より優先する。

## レビュー手順

- 対象ファイルだけでなく、判断に必要な呼び出し元 / 呼び出し先 / 型定義を確認する
- 対象コードだけでは判断できない事項を、推測で断定しない
- 明示的な修正依頼がない場合、レビュー結果を提示してから修正可否を確認する

## レビュー項目

### JSDoc

- export される宣言には JSDoc を付与する
- 冒頭に、その API が何を表すか、または何を提供するかを簡潔に記載する
- 必要に応じて、用途、引数と戻り値の意味、副作用、例外、制約、ライフサイクル、非推奨理由と代替手段を記載する
- 型から明らかな情報を `@param` や `@returns` で重複させない
- 概要が自明でも、IDE のホバー表示のため省略しない

## コードの更新

- ユーザーが明示的に依頼または同意した変更だけを行う
- レビュー対象外の変更や、必要性のないリファクタリングを行わない
- 更新後に差分を確認し、意図しない変更がないことを確認する

## 検査

### Biome

修正前または同意前は、書き込みを行わない。

```shell
biome check \
  --config-path "$HOME/.config/biome/biome.json" \
  --vcs-root "$(git rev-parse --show-toplevel)" \
  <path_to_target>
```

同意を得て修正した後は、自動修正を適用して再検査する。

```shell
biome check \
  --config-path "$HOME/.config/biome/biome.json" \
  --vcs-root "$(git rev-parse --show-toplevel)" \
  --write <path_to_target>
```

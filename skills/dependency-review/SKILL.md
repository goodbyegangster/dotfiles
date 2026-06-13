---
name: dependency-review
description: 指定された外部ライブラリの採用可否を、保守・安全性・撤退可能性の観点で判断する。
---

# dependency-review

## 目的

利用者が指定した外部ライブラリについて、採用可否を判断する。

判断では、便利さよりも保守・安全性・撤退可能性を優先する。

## 対象

利用者が明示的に指定した外部ライブラリを調査対象とする。

## 調査方法

原則として、公開 Web 情報のみで調査する。

### 確認に使ってよい情報源

- 公式サイト
- 公式ドキュメント
- 公式リポジトリ
- package registry
- changelog / release notes
- security advisory
- license 表示
- GitHub Advisory Database
- OSV database

### 禁止事項

- 指定されていないライブラリを勝手に採用候補にしない
- 対象ライブラリを clone / download / install しない
- package manager で対象ライブラリを取得しない
- install / build / test / generate を実行しない

## 確認観点

### 必要性

- 標準ライブラリで足りないか
- 小さく自前実装できないか
- 既存依存で代替できないか

### 依存の重さ

- direct / transitive dependency はどれだけ増えるか
- runtime dependency か build-time dependency か
- bundle size / binary size に影響するか

### 保守性

- メンテされているか
- 利用者は十分にいるか
- テストはあるか
- 過去に破壊的変更が多いか
- 今後も破壊的変更が起きやすそうか

### ライセンス

- license は用途に合うか

### 安全性

- install script / postinstall script はあるか
- 不審な maintainer 変更や release はないか
- GitHub Advisory Database で、未修正の advisory が残っていないか
  - GitHub Advisory Database または GitHub REST API で確認する
- OSV database で、未修正の脆弱性が残っていないか
  - OSV API または OSV.dev の Web UI で確認する
- 確認できなかった場合は「未確認」と書き、「安全」とは断定しない

### 境界と撤退

- import を wrapper / adapter に閉じ込められるか
- public API に外部ライブラリ固有の型を漏らさずに済むか
- 後から削除・置換できるか

## 判断

次のいずれかで判断する。

- 採用
- 条件付き採用
- 見送り

条件付き採用の場合は、以下の例を参考に、条件を明示する。

- wrapper 経由でのみ使う
- version を固定する
- 利用箇所を限定する
- 追加の test を書く
- dev dependency に限定する

## 出力形式

- 冒頭に「レビュー時最新バージョン」を記載
- 確認できなかった項目は、推測で埋めず「未確認」と記載
- 出典となるリンクを付記

```text
Dependency Review: <library>

## レビュー時最新バージョン
## 判断
## 条件
## 用途
## 必要性
## 依存の重さ
## 保守性
## ライセンス
## 安全性
## 境界と撤退
```

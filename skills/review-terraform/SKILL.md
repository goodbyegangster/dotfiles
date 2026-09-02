---
name: review-terraform
description: Terraform のコードをレビューし、同意がある場合のみ修正する。
---

# review-terraform

## 目的

Terraform のコードをレビューし、正確性、可読性、保守性を評価する。

ユーザーの指示とプロジェクト固有の規約を、この skill の規則より優先する。

## レビュー手順

- 対象コードだけでは判断できない事項を、推測で断定しない
- 明示的な修正依頼がない場合、レビュー結果を提示してから修正可否を確認する

## レビュー項目

### Resource Naming

### Comment

## コードの更新

- ユーザーが明示的に依頼または同意した変更だけを行う
- レビュー対象外の変更や、必要性のないリファクタリングを行わない
- 更新後に差分を確認し、意図しない変更がないことを確認する

## 検査

```shell
terraform fmt -check
terraform validate
```

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

以下を確認する。

- snake_case を利用している
- Resource Type にあたる情報を Resource Naming に含めていない

### Comment

以下を確認する。

- `#` 形式のコメントを利用している
- `resource` ブロックには、直前に作成リソースについてのコメントを記載している

### Meta-Argument Ordering

通常の引数とメタ引数が同じブロックに含まれる場合、以下を確認する。

- メタ引数を通常の引数より先に記載している
- メタ引数と通常の引数の間を、1行の空行で区切っている
- `lifecycle` などのメタ引数ブロックを、他のブロックより後に記載している
- メタ引数ブロックと他のブロックの間を、1行の空行で区切っている

```hcl
resource "aws_instance" "example" {
  # meta-argument first
  count = 2

  ami           = "abc123"
  instance_type = "t2.micro"

  network_interface {
    # ...
  }

  # meta-argument block last
  lifecycle {
    create_before_destroy = true
  }
}
```

## コードの更新

- ユーザーが明示的に依頼または同意した変更だけを行う
- レビュー対象外の変更や、必要性のないリファクタリングを行わない
- 更新後に差分を確認し、意図しない変更がないことを確認する

## 検査

- コードを更新した場合、更新後に validate / fmt コマンドを実行する
- コードを更新しない場合でも、レビュー判断に必要であれば validate / fmt コマンドを実行する
- プロジェクトに既定の検査コマンドがある場合は、そのコマンドを優先する
- 検査できない場合は、実行したコマンドと理由を報告し、成功したものとして扱わない

### lint

```shell
tflint --init --config "$HOME/dotfiles/.config/tflint/.tflint.hcl"

tflint --config "$HOME/dotfiles/.config/tflint/.tflint.hcl"
```

### validate

```shell
terraform validate
```

### format

```shell
terraform fmt -check
```

更新を許可された場合、以下を実行する。

```shell
terraform fmt
```

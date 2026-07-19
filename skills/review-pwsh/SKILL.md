---
name: review-pwsh
description: PowerShell の .ps1、.psm1、.psd1 をレビュー・改善するときに使う。
---

# review-pwsh

## 目的

PowerShell script / module を、汎用 shell script ではなく PowerShell の作法としてレビューする。発見しやすさ、pipeline での扱いやすさ、失敗時の予測可能性を、小さく慣用的な変更で改善する。

## 手順

1. 編集前に対象ファイルを読む。
2. 新しい書き方を入れる前に、`rg` で repo 内の既存パターンを確認する。
3. ユーザーが明示しない限り、BOM と既存 encoding を変えない。
4. `#requires` は実行文より前に置く。
5. module scope の `Set-StrictMode` は先頭付近に置く。通常は `#requires` の後に置く。
6. 可能なら `Import-Module` または dot-source、`Get-Help`、PSScriptAnalyzer で検証する。

## StrictMode

- script / module scope に `Set-StrictMode` があるか確認する。
- 各関数内ではなく、module scope への配置を優先する。
- `#requires` がある場合は、その後に置く。
- `-Version Latest` が repo の方針に合うか確認する。互換性を安定させたい場合は、`3.0` など固定 version のほうが驚きが少ないことを伝える。
- UTF-8 BOM は不用意に移動・削除しない。Windows PowerShell 5.1 互換がありそうな場合は特に残す。

推奨する先頭の形:

```powershell
#requires -Version 5.1
Set-StrictMode -Version Latest
```

## コメントベースヘルプ

export される関数やユーザーが直接呼ぶ関数では、関数直前または関数 body 冒頭にコメントベースヘルプがあるか確認する。

最低限確認する項目:

- `.SYNOPSIS`
- 前提条件や副作用がある場合の `.DESCRIPTION`
- ユーザー向け parameter ごとの `.PARAMETER`
- 通常利用の `.EXAMPLE`

必要に応じて追加する項目:

- success output を出す場合の `.OUTPUTS`
- platform や依存関係の前提を書く `.NOTES`

help は次で検証する:

```powershell
Import-Module ./path/to/module.psm1 -Force
Get-Help Function-Name -Full
Get-Help Function-Name -Parameter ParameterName
```

## Advanced Function

- ユーザー向け関数には `[CmdletBinding()]` を使う。
- success output を意図している場合は `[OutputType(...)]` を付ける。
- data は `Write-Output` または暗黙 output を優先する。
- 進捗や詳細情報は `Write-Verbose` を優先する。
- 表示だけが目的の関数でない限り、`Write-Host` は避ける。
- `ValueFromPipeline` と `ValueFromPipelineByPropertyName` は意図して使う。
- `FullName` などの alias は、`Get-ChildItem | Function-Name` のような実用的な pipeline 利用を改善する場合だけ追加する。
- 解決済み filesystem path を wildcard 展開したくない場合は `-LiteralPath` を使う。

## エラー処理

- 呼び出し側が失敗を検知する必要がある場合、`Write-Error` だけで握りつぶさない。
- 現在の error を単に再 throw する場合は、`catch` 内で bare `throw` を使う。
- `$PSCmdlet.ThrowTerminatingError(...)` は、意図的に `ErrorRecord` を組み立てる、または保持する価値がある場合だけ使う。
- 外部 resource の cleanup は `finally` に置く。

## 検証

可能なら次を実行する:

```powershell
Import-Module ./path/to/module.psm1 -Force
Invoke-ScriptAnalyzer -Path ./path/to/file.psm1
```

repo に PSScriptAnalyzer 設定がある場合はそれを使う:

```powershell
Invoke-ScriptAnalyzer -Path ./path/to/file.psm1 -Settings ./pwsh/ScriptAnalyzerSettings.psd1
```

COM automation のような Windows 専用機能に依存する関数では、ローカルで parse / help / analyzer を検証し、runtime 検証ができない場合はその旨を明示する。

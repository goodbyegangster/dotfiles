#requires -Version 5.1
Set-StrictMode -Version Latest

<#
.SYNOPSIS
PowerPoint プレゼンテーションを PDF に変換します。

.DESCRIPTION
PowerPoint の COM オブジェクトを使用して、指定された PowerPoint ファイルを PDF としてエクスポートします。
この関数は Windows 上で PowerPoint がインストールされている環境を前提としています。

.PARAMETER Path
変換する PowerPoint ファイルのパスを指定します。
パイプライン入力、およびプロパティ名によるパイプライン入力に対応します。

.PARAMETER OutputPath
出力する PDF ファイルのパスを指定します。
省略した場合は、入力ファイルと同じフォルダーに同じベース名の .pdf ファイルを出力します。

.OUTPUTS
System.String
変換に成功した PDF ファイルのパスを出力します。

.EXAMPLE
Export-PptToPdf -Path .\slides.pptx

slides.pptx を slides.pdf に変換します。

.EXAMPLE
Export-PptToPdf -Path .\slides.pptx -OutputPath .\output\slides.pdf

slides.pptx を指定した出力先の PDF に変換します。

.EXAMPLE
Get-ChildItem .\*.pptx | Export-PptToPdf

カレントディレクトリの .pptx ファイルをまとめて PDF に変換します。
#>
function Export-PptToPdf {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath
    )

    process {
        # COMオブジェクトは相対パスを扱えないため、絶対パスに解決する
        $resolvedInPath = (Resolve-Path $Path).ProviderPath

        if ([string]::IsNullOrEmpty($OutputPath)) {
            $resolvedOutPath = [System.IO.Path]::ChangeExtension($resolvedInPath, ".pdf")
        }
        else {
            $resolvedOutPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
        }

        $outputDirectory = Split-Path -Path $resolvedOutPath -Parent
        if (-not (Test-Path -Path $outputDirectory -PathType Container)) {
            throw "出力先ディレクトリが存在しません: $outputDirectory"
        }

        Write-Verbose "変換中: '$resolvedInPath' -> '$resolvedOutPath'"

        $ppt = $null
        $doc = $null
        try {
            # PowerPointをバックグラウンド（非表示）で起動
            $ppt = New-Object -ComObject PowerPoint.Application

            # 引数: (ファイル名, ReadOnly=True, Untitled=False, WithWindow=False)
            $doc = $ppt.Presentations.Open($resolvedInPath, $true, $false, $false)

            # PDF としてエクスポート
            # 第2引数 2 = ppFixedFormatTypePDF
            $doc.ExportAsFixedFormat($resolvedOutPath, 2)

            Write-Verbose "変換成功: '$resolvedOutPath'"
            Write-Output $resolvedOutPath
        }
        catch {
            throw
        }
        finally {
            # メモリ解放と PowerPoint プロセスの確実な終了
            if ($null -ne $doc) {
                $doc.Close()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($doc) | Out-Null
            }
            if ($null -ne $ppt) {
                $ppt.Quit()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null
            }
            # GC 強制実行
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()
        }
    }
}

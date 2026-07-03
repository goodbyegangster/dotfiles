function Export-PptToPdf {
    [CmdletBinding()]
    param (
        # 必須パラメーター（パイプラインからの入力に対応）
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        # 任意パラメーター（省略時は入力と同じフォルダーに.pdfで保存）
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

            Write-Host "変換成功: $resolvedOutPath" -ForegroundColor Green
        }
        catch {
            Write-Error "エラーが発生しました: $_"
        }
        finally {
            # メモリ解放とPowerPointプロセスの確実な終了（ゾンビプロセス化を防ぐ）
            if ($null -ne $doc) {
                $doc.Close()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($doc) | Out-Null
            }
            if ($null -ne $ppt) {
                $ppt.Quit()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null
            }
            # ガベージコレクションを強制実行
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()
        }
    }
}


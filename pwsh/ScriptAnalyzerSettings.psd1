@{
    Rules = @{
        # 互換性ルールを有効化する
        PSUseCompatibleCmdlets = @{
            Enable         = $true
            # PowerShell のバージョンを指定（Windows PowerShell 5.1）
            TargetProfiles = @('5.1')
        }
    }
}

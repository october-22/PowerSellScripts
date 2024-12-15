<#
.SYNOPSIS
    10進数をPack10形式に変換

.DESCRIPTION
    入力された10進数をPack10形式で2進数に変換出力する。
    出力された使用領域が8bitで割り切れない場合、1111(F)を追加し、byte単位とする。

.PARAMETER numbers
    1単位の整数(10進数)を指定。複数の値を処理しない。

.EXAMPLE
    Convert-Pack10 20241231
    出力: "00100000001001000001001000110001"

.NOTES
    バージョン 1.0
    作成者:
#>
function Convert-Pack10 {
    param (
        [string]$numbers
    )
    
    $pack10 = ""

    foreach ($number in $numbers.ToCharArray()) {
        $binary = [convert]::ToString([string]$number, 2)
        $pack10 += "{0:D4}" -f [int]$binary
    }

    if ($pack10.Length % 8 -ne 0) {
        $pack10 += "1111"
    }

    return $pack10
}

if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    $numbers = "20241231"
    $pack10 = Convert-Pack10 -numbers $numbers
    $now = Get-Date -Format "yyyyMMdd-HHmmss"
    $current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $savepath = $current_dir + "\pack10_" + $now + ".dat"
    $pack10 | Out-File -FilePath $savepath -Encoding UTF8
    Write-Output $pack10
}
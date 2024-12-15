<#
.SYNOPSIS
    0埋め文字列をリスト生成する。

.DESCRIPTION
    入力された整数から0埋め文字列を返す。

.PARAMETER ZeroCount
    整数値　0の数を指定

.EXAMPLE
    Get-ZeroFillString -count $Count
    入力 : 3 出力 "000"

.NOTES
    バージョン 1.0
    作成者: 
#>

function Get-ZeroFillString {
    param (
        [int]$ZeroCount
    )
    
    $formatString = "{0:D$ZeroCount}"
    $formattedString = $formatString -f 0
    return $formattedString
}


if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    $ColumnData = Get-ZeroFillString -ZeroCount 3
    Write-Output $ColumnData
}
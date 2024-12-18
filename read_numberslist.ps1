<#
.SYNOPSIS
    テキストファイルの各行を配列として返す。

.DESCRIPTION
    入力されたファイルパスからテキストを読み込み各行を配列として返す。

.PARAMETER filePath
    テキストファイルパス

.EXAMPLE
    Read-NumbersList ".\Desktop\pack10\numberslist.txt"
    出力: ["A", "B", "C"]

.NOTES
    バージョン 1.0
#>

function Read-NumbersList {
    param (
        [string]$filePath
    )

    if (Test-Path $filePath) {
        $lines = Get-Content $filePath
        return $lines
        
    } else {
        Write-Error "ファイルが見つかりません: $filePath"
        return $null
    }
}

if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    $current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $filePath = $current_dir + "\numberslist.txt"
    Read-NumbersList -filePath $filePath
}

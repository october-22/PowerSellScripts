
function Show-Passed(){
    param (
        [string]$In,
        [string]$Out
    )
    Write-Host "Test Passed: Input: '$In' Output:'$Out'" -ForegroundColor Green     
}

function Show-Passed-BytesHex(){
    param (
        [string[]]$In,
        [string[]]$Out
    )
    $Out = Convert-Bytes-Decimal-To-Hex -DecimalValues $Out
    Write-Host "Test Passed: Input: '$In' Output:'$Out'" -ForegroundColor Green     
}

function Show-Failed(){
    param (
        [string]$In,
        [string]$Out,
        [string]$Result
    )
    Write-Host "Test Failed: Input: '$In'. Output: $Out, Got: $Result" -ForegroundColor Red     
}

function Show-Failed-BytesHex(){
    param (
        [string[]]$In,
        [string[]]$Out,
        [string[]]$Result
    )
    $Out = Convert-Bytes-Decimal-To-Hex -DecimalValues $Out
    $Result = Convert-Bytes-Decimal-To-Hex -DecimalValues $Result
    Write-Host "Test Failed: Input: '$In'. Output: $Out, Got: $Result" -ForegroundColor Red     
}

function Show-Error(){
    param (
        [string]$In,
        [string]$Out,
        [string]$Result
    )
    Write-Host "Test Error: Input: '$In'. Exception: '$Result'" -ForegroundColor Yellow     
}

function Show-Error-BytesHex(){
    param (
        [string[]]$In,
        [string[]]$Out,
        [string[]]$Result
    )
    $Out = Convert-Bytes-Decimal-To-Hex -DecimalValues $Out
    $Result = Convert-Bytes-Decimal-To-Hex -DecimalValues $Result
    Write-Host "Test Error: Input: '$In'. Exception: '$Result'" -ForegroundColor Yellow     
}


<#
.SYNOPSIS
    10進数バイト配列を16進数に変換する。

.DESCRIPTION
    テスト結果表記が10進数になるので、16進数表記をするため。

.PARAMETER $DecimalValues
    10進数バイト配列を渡す。

.OUTPUTS
    [byte[]] 16進数表記のバイト配列を返す。

.EXAMPLE
    $decimals = @("49", "47", "51", "13", "10")
    Convert-Bytes-Decimal-To-Hex -DecimalValues $decimals
    結果: @("31", "2F", "33", "OD", "OA")
#>
function Convert-Bytes-Decimal-To-Hex(){
    param (
        [byte[]]$DecimalValues
    )
    $hexValues = $DecimalValues | ForEach-Object { "{0:X2}" -f $_ }
    return $hexValues
}

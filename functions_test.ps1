
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
    10�i���o�C�g�z���16�i���ɕϊ�����B

.DESCRIPTION
    �e�X�g���ʕ\�L��10�i���ɂȂ�̂ŁA16�i���\�L�����邽�߁B

.PARAMETER $DecimalValues
    10�i���o�C�g�z���n���B

.OUTPUTS
    [byte[]] 16�i���\�L�̃o�C�g�z���Ԃ��B

.EXAMPLE
    $decimals = @("49", "47", "51", "13", "10")
    Convert-Bytes-Decimal-To-Hex -DecimalValues $decimals
    ����: @("31", "2F", "33", "OD", "OA")
#>
function Convert-Bytes-Decimal-To-Hex(){
    param (
        [byte[]]$DecimalValues
    )
    $hexValues = $DecimalValues | ForEach-Object { "{0:X2}" -f $_ }
    return $hexValues
}

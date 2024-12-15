﻿<#
.SYNOPSIS
    Excelワークシート指定範囲を二次元配列として取得

.DESCRIPTION
    開始セル、終了セルを指定し、範囲指定された部分を二次元配列として取得
    空のセルは文字列"null"が入る。

.PARAMETER ExcelFilePath
    Excelファイル絶対パス

.PARAMETER WorkSheetNumber
    ワークシート番号

.PARAMETER StartColumn
    開始列位置、最小値1

.PARAMETER EndColumn
    終了列位置

.PARAMETER StartRow
    開始行位置、最小値1

.PARAMETER EndRow
    終了行位置

.EXAMPLE
    Get-Array2D_ExcelRange -ExcelFilePath $excelFilePath -WorkSheetNumber 1 -StartColumn 3 -EndColumn 4 -StartRow 2 -EndRow 6 
    出力: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]

.NOTES
    バージョン 1.0
    作成者: 
#>

function Get-Array2D_ExcelRange {
    param (
        [string]$ExcelFilePath,
        [int]$WorkSheetNumber,
        [int]$StartColumn,
        [int]$EndColumn,
        [int]$StartRow,
        [int]$EndRow
    )

    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Workbook = $Excel.Workbooks.Open($ExcelFilePath)
    $Worksheet = $Workbook.Worksheets.Item($WorkSheetNumber)

    $Array2D = @()
    for ($col = $StartColumn; $col -le $EndColumn; $col++) {
        $Array = @()
        for ($row = $StartRow; $row -le $EndRow; $row++) {
            $CellValue = $Worksheet.Cells.Item($row, $col).Value2
            if ($CellValue -eq $null) {
                $Array += "null"
            } else {
                $Array += $CellValue
            }
         }
        $Array2D += $Array
    }

    $Workbook.Close($false)
    $Excel.Quit()

    # COMオブジェクトの解放
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    return $Array2D
}

if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    $excelFilePath = "C:\Users\user1\Desktop\pack10\workbook1.xlsx"
    $Array2D = Get-ExcelColumnData -ExcelFilePath $excelFilePath -WorkSheetNumber 1 -StartColumn 3 -EndColumn 4 -StartRow 2 -EndRow 6 
    Write-Output $Array2D
}
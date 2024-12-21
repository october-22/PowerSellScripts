<#
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

.PARAMETER Direction
    セル参照方向 "column" : 一列ずつ配列化 "row": 一行ずつ配列化  

.EXAMPLE
    Get-Table-FromExcel -ExcelFilePath $excelFilePath -WorkSheetNumber 1 -StartColumn 3 -EndColumn 4 -StartRow 2 -EndRow 6 
    出力: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]

.NOTES
    バージョン 1.0 
#>
function Get-Table-FromExcel {
    param (
        [string]$ExcelFilePath,
        [int]$WorkSheetNumber,
        [int]$StartRow,
        [int]$EndRow,
        [int]$StartColumn,
        [int]$EndColumn,
        [string]$Direction = "row"
    )

    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Workbook = $Excel.Workbooks.Open($ExcelFilePath)
    $Worksheet = $Workbook.Worksheets.Item($WorkSheetNumber)

    $Array2D = @()
    
    if($Direction -eq "column"){
        for ($col = $StartColumn; $col -le $EndColumn; $col++) {
            $Array = @()
            for ($row = $StartRow; $row -le $EndRow; $row++) {
                $CellValue = $Worksheet.Cells.Item($row, $col).Value2
                if ($null -eq $CellValue) {
                    $Array += "null"
                } else {
                    $Array += $CellValue
                }
             }
            $Array2D += ,$Array
        }
    }else{
        for ($row = $StartRow; $row -le $EndRow; $row++) {
            $Array = @()
            for ($col = $StartColumn; $col -le $EndColumn; $col++) {
                $CellValue = $Worksheet.Cells.Item($row, $col).Value2
                if ($null -eq $CellValue) {
                    $Array += "null"
                } else {
                    $Array += $CellValue
                }
             }
            $Array2D += ,$Array
        }
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

<#
.SYNOPSIS
    string型二次元配列の各行配列要素を連結し、string型一次元配列として返す。

.DESCRIPTION
    水平方向の要素全てを文字列として連結し、一つの要素にまとめる。
    全ての行で同一の処理をした結果、二次元配列は一次元配列となる。
        
.PARAMETER Table
    string型二次元配列 もしくは、int型二次元配列

.EXAMPLE
    $table = @(["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"])
    Join-Horizontal-Cells -Table $table
    #結果 ["123","456","789"]

.NOTES
    引数$Tableに渡されるのがint型二次元配列であっても、暗黙的キャストとしてstring型として処理される。
    スペースを含む場合も処理可
#>
function Join-Horizontal-Cells {
    param (
        [string[][]]$Table
    )
    $lines = $Table | ForEach-Object {
        ($_ -join "")
    }
    return $lines
}

<#
.SYNOPSIS
    二次元配列(Table)からCSV形式の文字列を生成する関数。

.DESCRIPTION
    二次元配列を受け取り、そのデータをCSV形式の文字列に変換します。
    各行はカンマで区切られ、テーブルの各列のデータがCSVとして整形されます。

.PARAMETER Table
    二次元配列。

.EXAMPLE
    $Table = @(
        @("Header1", "Header2", "Header3"),
        @("Data1", "Data2", "Data3"),
        @("Data4", "Data5", "Data6")
    )
    $csv = Convert-CSV-FromTable -Table $Table
    # 結果    
    Header1,Header2,Header3
    Data1,Data2,Data3
    Data4,Data5,Data6
#>
function Convert-CSV-FromTable {
    param (
        [string[][]]$Table
    )
    $csv = $Table | ForEach-Object {
        ($_ -join ",")
    }
    return $csv
}

<#
.SYNOPSIS
    テーブルのデータ部を取得する関数。

.DESCRIPTION
    二次元配列の最初の行(header)と最後の行(futter)を除いた部分(dataTabel)を返します。

.PARAMETER Table
    2次元配列。ヘッダー行、データ行、フッター行を含む配列です。

.EXAMPLE
    $Table = @(
        @("Header1", "Header2", "Header3"),
        @("Data1", "Data2", "Data3"),      
        @("Data4", "Data5", "Data6"),      
        @("Footer1", "Footer2", "Footer3")
    )
    $data = Get-DataTable -Table $Table
    #結果
    ["Data1","Data2","Data3"],["Data4","Data5","Data6"]
#>
function Get-TableData {
    param (
        [string[][]]$Table
    )
    return $Table[1..($Table.Length - 2)]
}


if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    
    # test Get-Table-FromExcel
    <#
    $excelFilePath = $PSScriptRoot + "\test_sample\test_pattern_table.xlsx"
    $table = Get-Table-FromExcel -ExcelFilePath $excelFilePath -WorkSheetNumber 1 -StartRow 2 -EndRow 3 -StartColumn 2 -EndColumn 11 
    $table | ForEach-Object {
        Write-Host $_
    }
    #>
    
    # test Join-Horizontal-Cells
    <#
    $table_string = @(@("1","2","3"), @("4","5","6"), @("7"," ","9"))
    $table_int = @(@(1,2,3), @(4,5,6), @(7,8,9))
    $lines = Join-Horizontal-Cells -Table $table_string
    $lines | ForEach-Object {
        Write-Host $_
    }
    #>
}

    
. $PSScriptRoot\functions_table_control.ps1
. $PSScriptRoot\functions_binary.ps1
. $PSScriptRoot\functions_widget.ps1


<# 
.SYNOPSIS
    テストパターンテーブルからバイナリファイルを生成。

.DESCRIPTION
    Excelファイルからテストパターンテーブルを取得、各行データをバイナリに変換、ファイル保存します。
    テストパターンを分割、複数ファイルに保存、1つのファイルにまとめて保存するかを選択できます。

.PARAMETER TestPatternTablePath
    テストパターンテーブルが含まれるExcelファイルパス。
    ワークシート(1)にテーブルが存在すること。

.PARAMETER OutputFilePath
    バイナリデータ出力ファイルパス。

.PARAMETER RowStart
    テストパターンテーブルの開始行（1行目が1）。

.PARAMETER RowEnd
    テストパターンテーブルの終了行。

.PARAMETER ColumnStart
    テストパターンテーブルの開始列(A列が1)

.PARAMETER ColumnEnd
    テストパターンテーブルの終了列。

.PARAMETER SplitFiles
    $true : 行ごとに別々のファイルに分割する。
    $false : 一つにまとめる。

.EXAMPLE
    Generate-BinaryFiles -TestPatternTablePath "C:\path\to\testpattern.xlsx" `
                         -OutputFilePath "C:\path\to\output.bin" `
                         -RowStart 1 -RowEnd 10 `
                         -ColumnStart 1 -ColumnEnd 5 `
                         -SplitFiles $true
#>
function Generate-BinaryFiles(){
    param (
        [string]$TestPatternTablePath,
        [string]$OutputFilePath,
        [int]$RowStart,
        [int]$RowEnd,
        [int]$ColumnStart,
        [int]$ColumnEnd,
        [int]$SplitFiles = $false
    )
    $table = Get-Table-FromExcel -ExcelFilePath $TestPatternTablePath `
                                 -WorkSheetNumber 1 `
                                 -StartRow $RowStart `
                                 -EndRow $RowEnd `
                                 -StartColumn $ColumnStart `
                                 -EndColumn $ColumnEnd

    $table_header = $table[0]
    $table_futter = $table[-1]
    $table_data = Get-TableData -Table $table
    $binary_all_test_pattern = @()

    for ($i = 0; $i -lt $table_data.Count; $i++) {
        $row = $table_data[$i]
        $binary_line = Convert-Binary-Line -Row $row -Futter $table_futter
        $binary_all_test_pattern += $binary_line
        if ($true -eq $Split_Files){
            $split_filepath = Add-Index-FileName -Path $OutputFilePath -Index ($i + 1)
            [System.IO.File]::WriteAllBytes($split_filepath, $binary_line)
        }
    }
    if ($false -eq $Split_Files){
        [System.IO.File]::WriteAllBytes($OutputFilePath, $binary_all_test_pattern)
    }  
}


<#
.SYNOPSIS
    文字列型配列各要素をバイナリデータに変換する。

.DESCRIPTION
    バイナリデータ変換には、Pack10圧縮後バイナリ化と通常のバイナリ化の二種がある。
    $Futterの値に"p"があった場合のみPack10圧縮を行う。
    行全体をバイナリ形式として結合、末尾に改行コード(\r\n)を付加して返します。

.PARAMETER Row
    変換対象となる文字列型配列。注意：0-9までのstring型整数と半角空白のみ

.PARAMETER Futter
    各行データ($Row)に対する処理方法を示す配列。
    - `"p"`: Pack10圧縮処理を適用。
    - その他: 指定したエンコーディング($Encode)を使用して変換。

.PARAMETER Encode
    エンコーディング形式を指定(デフォルト:"euc-jp")

.OUTPUTS
    [byte[]]
    バイナリ形式に変換されたデータ行。末尾に改行コード (\r\n) 付加。

.EXAMPLE
    $Row = @("123", "abc", "456")
    $Futter = @("p", "", "p")
    $binaryLine = Convert-Binary-Line -Row $Row -Futter $Futter -Encode "utf-8"
#>
function Convert-Binary-Line() {
    param (
        [string[]]$Row,
        [string[]]$Futter,
        [string]$Encode = "euc-jp"
    )
    $binary_line = @()
    for ($i = 0; $i -lt $Row.Count; $i++){
        $cell = $Row[$i]
        $futter_ = $Futter[$i]     
        if ($futter_ -eq "p") {
            $binary_data = Convert-BinaryData-Pack10 -Data $cell
        }else{
            $binary_data = [System.Text.Encoding]::GetEncoding($Encode).GetBytes($cell)        
        }
        $binary_line += $binary_data     
    }
    $crlf = [byte[]](0x0D, 0x0A)
    return $binary_line + $crlf
}


<#
.SYNOPSIS
    ファイルパスにインデックスを追加し、新しいファイル名を作成。

.DESCRIPTION
    与えられたファイルパスのファイル名末尾にインデックスを追加、新しいファイル名でパス生成します。
    ファイル拡張子は保持。インデックスは、ファイル名と拡張子の間に追加。

.PARAMETER Path
    ファイルのフルパス。

.PARAMETER Index
    ファイル名に追加するインデックス。整数値指定。

.EXAMPLE
    Add-Index-FileName -Path "C:\Example\file.txt" -Index 1
    このコマンドは、`file.txt` のファイル名を `file_1.txt` に変更し、新しいパスを返します。
#>
function Add-Index-FileName() {
    param (
        [string]$Path,
        [int]$Index
    )
    $dir = Split-Path $Path -Parent
    $fileName_ext = Split-Path $Path -Leaf
    $ext = [System.IO.Path]::GetExtension($fileName_ext)
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($fileName_ext)
    $fileName = $fileName + "_" + $index + $ext
    return Join-Path -Path $dir -ChildPath $fileName
}

# from ---------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "generate test binary files"
$form.Size = New-Object System.Drawing.Size(570, 160)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

$label_table = New-Object System.Windows.Forms.Label
$label_table.Text = "test pattern table (.xlsx) :"
$label_table.Location = New-Object System.Drawing.Point(10, 10)
$label_table.Size = New-Object System.Drawing.Size(150, 15)

$textbox_table = New-Object System.Windows.Forms.TextBox
$textbox_table.Location = New-Object System.Drawing.Point(10, 30)
$textbox_table.Size = New-Object System.Drawing.Size(500, 25)

$button_table = New-Object System.Windows.Forms.Button
$button_table.Text = "..."
$button_table.Location = New-Object System.Drawing.Point(520, 28)
$button_table.Size = New-Object System.Drawing.Size(30, 25)

$widget_start_row = New-Widget-TextBox -Label "start row" -X 10  -Y 60
$widget_end_row   = New-Widget-TextBox -Label "end row"   -X 10  -Y 90
$widget_start_col = New-Widget-TextBox -Label "start col" -X 110 -Y 60
$widget_end_col   = New-Widget-TextBox -Label "end col"   -X 110 -Y 90
$widget_split_files = Widget-CheckBox -Label "split files" -X 210 -Y 60

$button_run = New-Object System.Windows.Forms.Button
$button_run.Text = "run"
$button_run.Location = New-Object System.Drawing.Point(470, 90)
$button_run.Size = New-Object System.Drawing.Size(80, 25)

# file dialog ----------------------------------------------------
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog
$fileDialog.Filter = "Excel Files (*.xlsx;*.xlsm)|*.xlsx;*.xlsm"

$button_table.Add_Click({
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textbox_table.Text = $fileDialog.FileName
    }
})

# run click -----------------------------------------------------
$button_run.Add_Click({
    
    $test_pattern_table = $textbox_table.Text
    $start_row = [int]$widget_start_row.TextBox.Text
    $end_row = [int]$widget_end_row.TextBox.Text
    $start_column = [int]$widget_start_col.TextBox.Text
    $end_column = [int]$widget_end_col.TextBox.Text
    $split_files = $widget_split_files.CheckBox.Checked

    if ([string]::IsNullOrWhiteSpace($test_pattern_table)) {
        [System.Windows.Forms.MessageBox]::Show("not path is not specified.", "Error")
        return
    }

    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $outputFile = $saveFileDialog.FileName
        try {
            $result = Generate-BinaryFiles -TestPatternTablePath $test_pattern_table `
                                           -OutputFilePath $outputFile `
                                           -RowStart $start_row `
                                           -RowEnd $end_row `
                                           -ColumnStart $start_column `
                                           -ColumnEnd $end_column `
                                           -SplitFiles $split_files
            if($false -eq $result){
                $ErrorMessage = "Error! : Binary generation failed."
                [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error!", 
                [System.Windows.Forms.MessageBoxButtons]::OK, 
                [System.Windows.Forms.MessageBoxIcon]::Error)
            }else{
                [System.Windows.Forms.MessageBox]::Show($outputFile, "complate!", 
                [System.Windows.Forms.MessageBoxButtons]::OK, 
                [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("ERROR: $_", "error!", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

$form.Controls.AddRange(@(
    $label_table, 
    $textbox_table,
    $button_table, 
    $widget_start_row.Panel,
    $widget_end_row.Panel,
    $widget_start_col.Panel,
    $widget_end_col.Panel,
    $widget_split_files.Panel,  
    $button_run
))

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

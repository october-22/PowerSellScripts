<#
.SYNOPSIS
    指定されたデータファイルを読み込み、分割定義ファイルを使用して各行をCSV形式に変換し、
    指定された出力ファイルに書き込みます。

.DESCRIPTION
    入力データファイルと定義ファイルを読み込み、定義ファイルに基づいて文字列を分割します。
    分割後、各行をCSV形式に変換して、指定された出力ファイルに結果を書き込みます。

.PARAMETER DataFilePath
    処理するデータファイルパス。
    
.PARAMETER DefinitionFilePath
    文字列分割を行うための定義ファイルのパス。各行に整数が記載され、分割の長さを指定します。

.PARAMETER OutputFilePath
    結果を保存する出力ファイルのパス。分割された結果がCSV形式で保存。

.EXAMPLE
    Convert-String-CSVFile -DataFilePath "string.txt" -DefinitionFilePath "definition.txt" -OutputFilePath "output.csv"
    この例では、`string.txt` と `definition.txt` を使用してデータを処理し、
    結果を `output.csv` に書き込みます。

.NOTES
    データファイル.txt 各行同一文字数。
    abbccc
    deefff
    ghhiii

    分割定義ファイル.txt 各行の合計値はデータファイル一行分の文字数を一致すること。
    1
    2
    3

    "Error! : Wrong definition. Does not match data."
    上記のエラーになる場合、分割定義ファイルとデータに不一致があるか確認すること。
    ※注意　ファイル末尾行は改行無しであること。
#>
function Convert-String-CSVFile {
    param (
        [string]$DataFilePath,
        [string]$DefinitionFilePath,
        [string]$OutputFilePath
    )
    $stringLines = Get-Content -Path $DataFilePath
    $splitPoints = Get-Content -Path $DefinitionFilePath | ForEach-Object { [int]$_ }

    $outputLines = @()
    foreach ($line in $stringLines) {
        $result = Convert-String-CSV -String $line -SplitPoints $splitPoints
        if($false -eq $result){
            return $false
        }
        $outputLines += $result
    }
    $outputLines | Set-Content -Path $OutputFilePath
    return $OutputFilePath
}

<#
.SYNOPSIS
    文字列を指定された分割点で分割し、カンマ区切りの結果を返す。

.DESCRIPTION
    指定された文字列 `$String` を、配列で渡された分割点 `$SplitPoints`
    に基づいて分割します。
    分割点は、文字列の各部分を区切るためのインデックスを指定します。
    分割点の合計が文字列の長さと一致しない場合、falseが返される。
    すべての部分をカンマ区切りで結合して返します。

.PARAMETER String
    分割する対象の文字列。

.PARAMETER SplitPoints
    文字列を分割するための位置を指定する整数の配列です。各整数は、分割する部分の長さを指定。

.EXAMPLE
    $result = Split-String -String "abbccc" -SplitPoints 1, 2, 3
    # 結果: "a,bb,ccc"

    この例では、文字列 "abbccc" を分割点 `[1, 2, 3]` に従って分割し、
    結果として "a,bb,ccc" が返されます。
#>
function Convert-String-CSV {
    param (
        [string]$String,
        [int[]]$SplitPoints
    )
    if($false -eq (Test-SplitPoint -String $String -SplitPoints $SplitPoints)){
        return $false
    }

    $result = @()
    $startIndex = 0
    
    foreach ($point in $SplitPoints) {
        $substring = $String.Substring($startIndex, $point)
        $result += $substring
        $startIndex += $point
    }

    if ($startIndex -lt $String.Length) {
        $result += $String.Substring($startIndex)
    }
    return $result -join "," #convert csv data
}

<#
.SYNOPSIS
    指定された文字列と分割ポイントの合計が一致するかをテスト。

.DESCRIPTION
    この関数は、`$SplitPoints` 配列の合計値が `$String` の長さと
    一致するかどうかを確認します。
    一致すれば `$true`、一致しない場合は `$false` を返します。

.PARAMETER String
    チェックする対象の文字列。文字列の長さと分割ポイントの合計が一致するか確認。

.PARAMETER SplitPoints
    文字列を分割する位置を指定する整数の配列。この配列の合計値が 
    `$String` の長さと一致するかをテスト。

.EXAMPLE
    # 文字列 "abbccc" と分割ポイント [1, 2, 3] を指定して、合計が一致するかをテスト
    Test-SplitPoint -String "abbccc" -SplitPoints [1, 2, 3]
    # 出力: $true (合計 1 + 2 + 3 = 6, 文字列の長さは 6)

.EXAMPLE
    # 文字列 "abbccc" と分割ポイント [1, 2, 4] を指定して、合計が一致するかをテスト
    Test-SplitPoint -String "abbccc" -SplitPoints [1, 2, 4]
    # 出力: $false (合計 1 + 2 + 4 = 7, 文字列の長さは 6)

.NOTES
    この関数は、文字列の長さと分割ポイントの合計が一致するかどうかのみをチェックします。
    文字列を実際に分割する処理は行いません。
#>
function Test-SplitPoint {
    param (
        [string]$String,
        [int[]]$SplitPoints
    )
    $totalLength = $SplitPoints | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    if ($totalLength-eq $String.Length) {
        return $true
    }else{
        return $false
    }
}

# from ---------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Convert string to CSV"
$form.Size = New-Object System.Drawing.Size(570, 190)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

$label_data = New-Object System.Windows.Forms.Label
$label_data.Text = "data file :"
$label_data.Location = New-Object System.Drawing.Point(10, 10)
$label_data.Size = New-Object System.Drawing.Size(100, 15)

$textbox_data = New-Object System.Windows.Forms.TextBox
$textbox_data.Location = New-Object System.Drawing.Point(10, 30)
$textbox_data.Size = New-Object System.Drawing.Size(500, 25)

$button_data = New-Object System.Windows.Forms.Button
$button_data.Text = "..."
$button_data.Location = New-Object System.Drawing.Point(520, 28)
$button_data.Size = New-Object System.Drawing.Size(30, 25)

$label_def = New-Object System.Windows.Forms.Label
$label_def.Text = "definition file :"
$label_def.Location = New-Object System.Drawing.Point(10, 60)
$label_def.Size = New-Object System.Drawing.Size(100, 15)

$textbox_def = New-Object System.Windows.Forms.TextBox
$textbox_def.Location = New-Object System.Drawing.Point(10, 80)
$textbox_def.Size = New-Object System.Drawing.Size(500, 25)

$button_def = New-Object System.Windows.Forms.Button
$button_def.Text = "..."
$button_def.Location = New-Object System.Drawing.Point(520, 78)
$button_def.Size = New-Object System.Drawing.Size(30, 25)

$button_run = New-Object System.Windows.Forms.Button
$button_run.Text = "run"
$button_run.Location = New-Object System.Drawing.Point(470, 115)
$button_run.Size = New-Object System.Drawing.Size(80, 25)

# file dialog ----------------------------------------------------
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog

$button_data.Add_Click({
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textbox_data.Text = $fileDialog.FileName
    }
})

$button_def.Add_Click({
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textbox_def.Text = $fileDialog.FileName
    }
})

# run click -----------------------------------------------------
$button_run.Add_Click({

    $dataFile = $textbox_data.Text
    $defFile = $textbox_def.Text

    if ([string]::IsNullOrWhiteSpace($dataFile) -or [string]::IsNullOrWhiteSpace($defFile)) {
        [System.Windows.Forms.MessageBox]::Show("not path is not specified.", "Error")
        return
    }

    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $outputFile = $saveFileDialog.FileName
        try {
            $result = Convert-String-CSVFile -DataFilePath $dataFile -DefinitionFilePath $defFile -OutputFilePath $outputFile
            if($false -eq $result){
                $ErrorMessage = "Error! : Wrong definition. Does not match data."
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
    $label_data, 
    $textbox_data, 
    $button_data,
    $label_def, 
    $textbox_def, 
    $button_def,
    $button_run
))

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()


<#
.SYNOPSIS
  複数のバイナリファイルを結合して1つのファイルに出力。

.DESCRIPTION
  指定したパスリストを順番に読み込み、出力ファイルにバイナリ形式で追記します。
  すべての入力ファイルが処理されると、1つの連結されたバイナリファイルが生成。

.PARAMETER InputFiles
  結合対象ファイルパスのリスト

.PARAMETER OutputFile
  結合結果としての出力ファイルパス。

.EXAMPLE
  Join-BinaryFiles -InputFiles @("file1.bin", "file2.bin") -OutputFile "output.bin"
  file1.bin と file2.bin を結合し、output.bin を作成。

.NOTES
  バイナリデータを扱うため、テキストファイルには使用しない。

#>
function Join-BinaryFiles {
    param (
        [string[]]$InputFiles,
        [string]$OutputFile
    )
    $outputStream = [System.IO.File]::OpenWrite($OutputFile)

    try {
        foreach ($file in $InputFiles) {
            $data = [System.IO.File]::ReadAllBytes($file)
            $outputStream.Write($data, 0, $data.Length)
        }
    } finally {
        $outputStream.Close()
    }
}

# form -----------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Join BinaryFiles"
$form.Size = New-Object System.Drawing.Size(510, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20, 10)
$listBox.Size = New-Object System.Drawing.Size(400, 300)
$listBox.AllowDrop = $true
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.SetToolTip($listBox, "Drop selected binary files here. | .dat or .bin")

$button_open = New-Object System.Windows.Forms.Button
$button_open.Text = "..."
$button_open.Location = New-Object System.Drawing.Point(430, 10)
$button_open.Size = New-Object System.Drawing.Size(60, 25)

$button_up = New-Object System.Windows.Forms.Button
$button_up.Text = "↑"
$button_up.Location = New-Object System.Drawing.Point(430, 50)
$button_up.Size = New-Object System.Drawing.Size(60, 25)

$button_down = New-Object System.Windows.Forms.Button
$button_down.Text = "↓"
$button_down.Location = New-Object System.Drawing.Point(430, 90)
$button_down.Size = New-Object System.Drawing.Size(60, 25)

$button_delete = New-Object System.Windows.Forms.Button
$button_delete.Text = "del"
$button_delete.Location = New-Object System.Drawing.Point(430, 130)
$button_delete.Size = New-Object System.Drawing.Size(60, 25)

$button_clear = New-Object System.Windows.Forms.Button
$button_clear.Text = "clear"
$button_clear.Location = New-Object System.Drawing.Point(430, 170)
$button_clear.Size = New-Object System.Drawing.Size(60, 25)

$button_run = New-Object System.Windows.Forms.Button
$button_run.Text = "join"
$button_run.Location = New-Object System.Drawing.Point(430, 280)
$button_run.Size = New-Object System.Drawing.Size(60, 25)

$fileDialog = New-Object System.Windows.Forms.OpenFileDialog
$fileDialog.Filter = "Binary Files (*.bin;*.dat)|*.bin;*.dat|All Files (*.*)|*.*"
$fileDialog.Multiselect = $true

# listbox drag and drop event ---------------------------------------------------

$listBox.Add_DragEnter({
    param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $filePaths = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
        $acceptFiles = $true
        foreach ($filePath in $filePaths) {
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            if ($extension -ne ".dat" -and $extension -ne ".bin") {
                $acceptFiles = $false
                break
            }
        }
        if ($acceptFiles) {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
        } else {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::None
        }
    } else {
        $e.Effect = [System.Windows.Forms.DragDropEffects]::None
    }
})

$listBox.Add_DragDrop({
    param($sender, $e)
    $filePaths = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    foreach ($filePath in $filePaths) {
        $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
        if ($extension -eq ".dat" -or $extension -eq ".bin") {
            $listBox.Items.Add($filePath)
        }
    }
})

# button click event -------------------------------------------------

$button_open.Add_Click({
    if ($fileDialog.ShowDialog() -eq "OK") {
       $listBox.Items.Clear()
        foreach ($filePath in $fileDialog.FileNames) {
            $listBox.Items.Add($filePath)
        }
    }
})

$button_up.Add_Click({
    $selectedIndex = $listBox.SelectedIndex
    if ($selectedIndex -gt 0) {
        $item = $listBox.SelectedItem
        $listBox.Items.RemoveAt($selectedIndex)
        $listBox.Items.Insert($selectedIndex - 1, $item)
        $listBox.SelectedIndex = $selectedIndex - 1
    }
})

$button_down.Add_Click({
    $selectedIndex = $listBox.SelectedIndex

    if ($selectedIndex -eq -1) {
        return
    }
    if ($selectedIndex -lt $listBox.Items.Count - 1) {
        $item = $listBox.SelectedItem
        $listBox.Items.RemoveAt($selectedIndex)
        $listBox.Items.Insert($selectedIndex + 1, $item)
        $listBox.SelectedIndex = $selectedIndex + 1
    }
})

$button_delete.Add_Click({
    $selectedIndex = $listBox.SelectedIndex
    if ($selectedIndex -ge 0) {
        $listBox.Items.RemoveAt($selectedIndex)
    }
})

$button_clear.Add_Click({
    $listBox.Items.Clear()
})

$button_run.Add_Click({
    if ($listBox.Items.Count -eq 0) {
        return
    }
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "Binary Files (*.bin;*.dat)|*.bin;*.dat|All Files (*.*)|*.*"
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $outputFile = $saveFileDialog.FileName
        $inputFiles = @($listBox.Items)
        try {
            Join-BinaryFiles -InputFiles $inputFiles -OutputFile $outputFile
            $listBox.Items.Clear()
            [System.Windows.Forms.MessageBox]::Show($outputFile, "complate!", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("ERROR: $_", "error!", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

$form.Controls.AddRange(@(
    $listBox, $button_open, $button_up, $button_down, $button_delete, $button_clear, $button_run
))

$form.ShowDialog()




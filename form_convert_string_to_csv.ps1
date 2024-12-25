<#
.SYNOPSIS
    �w�肳�ꂽ�f�[�^�t�@�C����ǂݍ��݁A������`�t�@�C�����g�p���Ċe�s��CSV�`���ɕϊ����A
    �w�肳�ꂽ�o�̓t�@�C���ɏ������݂܂��B

.DESCRIPTION
    ���̓f�[�^�t�@�C���ƒ�`�t�@�C����ǂݍ��݁A��`�t�@�C���Ɋ�Â��ĕ�����𕪊����܂��B
    ������A�e�s��CSV�`���ɕϊ����āA�w�肳�ꂽ�o�̓t�@�C���Ɍ��ʂ��������݂܂��B

.PARAMETER DataFilePath
    ��������f�[�^�t�@�C���p�X�B
    
.PARAMETER DefinitionFilePath
    �����񕪊����s�����߂̒�`�t�@�C���̃p�X�B�e�s�ɐ������L�ڂ���A�����̒������w�肵�܂��B

.PARAMETER OutputFilePath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X�B�������ꂽ���ʂ�CSV�`���ŕۑ��B

.EXAMPLE
    Convert-String-CSVFile -DataFilePath "string.txt" -DefinitionFilePath "definition.txt" -OutputFilePath "output.csv"
    ���̗�ł́A`string.txt` �� `definition.txt` ���g�p���ăf�[�^���������A
    ���ʂ� `output.csv` �ɏ������݂܂��B

.NOTES
    �f�[�^�t�@�C��.txt �e�s���ꕶ�����B
    abbccc
    deefff
    ghhiii

    ������`�t�@�C��.txt �e�s�̍��v�l�̓f�[�^�t�@�C����s���̕���������v���邱�ƁB
    1
    2
    3

    "Error! : Wrong definition. Does not match data."
    ��L�̃G���[�ɂȂ�ꍇ�A������`�t�@�C���ƃf�[�^�ɕs��v�����邩�m�F���邱�ƁB
    �����Ӂ@�t�@�C�������s�͉��s�����ł��邱�ƁB
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
    ��������w�肳�ꂽ�����_�ŕ������A�J���}��؂�̌��ʂ�Ԃ��B

.DESCRIPTION
    �w�肳�ꂽ������ `$String` ���A�z��œn���ꂽ�����_ `$SplitPoints`
    �Ɋ�Â��ĕ������܂��B
    �����_�́A������̊e��������؂邽�߂̃C���f�b�N�X���w�肵�܂��B
    �����_�̍��v��������̒����ƈ�v���Ȃ��ꍇ�Afalse���Ԃ����B
    ���ׂĂ̕������J���}��؂�Ō������ĕԂ��܂��B

.PARAMETER String
    ��������Ώۂ̕�����B

.PARAMETER SplitPoints
    ������𕪊����邽�߂̈ʒu���w�肷�鐮���̔z��ł��B�e�����́A�������镔���̒������w��B

.EXAMPLE
    $result = Split-String -String "abbccc" -SplitPoints 1, 2, 3
    # ����: "a,bb,ccc"

    ���̗�ł́A������ "abbccc" �𕪊��_ `[1, 2, 3]` �ɏ]���ĕ������A
    ���ʂƂ��� "a,bb,ccc" ���Ԃ���܂��B
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
    �w�肳�ꂽ������ƕ����|�C���g�̍��v����v���邩���e�X�g�B

.DESCRIPTION
    ���̊֐��́A`$SplitPoints` �z��̍��v�l�� `$String` �̒�����
    ��v���邩�ǂ������m�F���܂��B
    ��v����� `$true`�A��v���Ȃ��ꍇ�� `$false` ��Ԃ��܂��B

.PARAMETER String
    �`�F�b�N����Ώۂ̕�����B������̒����ƕ����|�C���g�̍��v����v���邩�m�F�B

.PARAMETER SplitPoints
    ������𕪊�����ʒu���w�肷�鐮���̔z��B���̔z��̍��v�l�� 
    `$String` �̒����ƈ�v���邩���e�X�g�B

.EXAMPLE
    # ������ "abbccc" �ƕ����|�C���g [1, 2, 3] ���w�肵�āA���v����v���邩���e�X�g
    Test-SplitPoint -String "abbccc" -SplitPoints [1, 2, 3]
    # �o��: $true (���v 1 + 2 + 3 = 6, ������̒����� 6)

.EXAMPLE
    # ������ "abbccc" �ƕ����|�C���g [1, 2, 4] ���w�肵�āA���v����v���邩���e�X�g
    Test-SplitPoint -String "abbccc" -SplitPoints [1, 2, 4]
    # �o��: $false (���v 1 + 2 + 4 = 7, ������̒����� 6)

.NOTES
    ���̊֐��́A������̒����ƕ����|�C���g�̍��v����v���邩�ǂ����݂̂��`�F�b�N���܂��B
    ����������ۂɕ������鏈���͍s���܂���B
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

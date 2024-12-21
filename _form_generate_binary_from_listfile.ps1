
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




function Convert-Binary {
    param (
        [string]$filePath
    )
    $current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $filePath = $current_dir + "\numberslist.txt"
    $numberslist = Read-NumbersList -filePath $filePath
    
    Write-Output $lines

    $pack10_all = ""
    foreach($numbers in $numberslist){
        $pack10_all += Convert-Pack10 -numbers $numbers
    }

    $now = Get-Date -Format "yyyyMMdd-HHmmss"
    $current_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $savepath = $current_dir + "\pack10_all_" + $now + ".dat"
    $pack10_all | Out-File -FilePath $savepath -Encoding UTF8
    Write-Output $pack10_all
}


# form --------------------------------------------------------------------
   
Add-Type -AssemblyName 'System.Windows.Forms'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'generate binary from listfile'
$form.Size = New-Object System.Drawing.Size(430, 160)

$label = New-Object System.Windows.Forms.Label
$label.Text = 'test definition xlsxfile'
$label.Location = New-Object System.Drawing.Point(10, 15)
$label.Size = New-Object System.Drawing.Size(350, 20)
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 38)
$textBox.Size = New-Object System.Drawing.Size(350, 30)
$form.Controls.Add($textBox)

$openButton = New-Object System.Windows.Forms.Button
$openButton.Text = '...'
$openButton.Location = New-Object System.Drawing.Point(370, 35)
$openButton.Size = New-Object System.Drawing.Size(30, 25)
$openButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = 'Excel Files (*.xlsx)|*.xlsx'
    if ($dialog.ShowDialog() -eq 'OK') {
        $textBox.Text = $dialog.FileName
    }
})
$form.Controls.Add($openButton)

$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Text = 'generate'
$generateButton.Location = New-Object System.Drawing.Point(300, 80)
$generateButton.Size = New-Object System.Drawing.Size(100, 25)
$generateButton.Add_Click({
    # ここで生成処理を実装
    [System.Windows.Forms.MessageBox]::Show('generate!!!!')
})
$form.Controls.Add($generateButton)

$form.ShowDialog()


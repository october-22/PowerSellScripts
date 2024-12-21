<#
.SYNOPSIS
    0埋め文字列をリスト生成する。

.DESCRIPTION
    入力された整数から0埋め文字列を返す。

.PARAMETER ZeroCount
    整数値　0の数を指定

.EXAMPLE
    Get-ZeroFillString -count $Count
    入力 : 3 出力 "000"

.NOTES
    バージョン 1.0
#>

function Get-ZeroFillString {
    param (
        [int]$ZeroCount
    )
    
    $formatString = "{0:D$ZeroCount}"
    $formattedString = $formatString -f 0
    return $formattedString
}



function Show-Dialog(){    
    Add-Type -AssemblyName 'System.Windows.Forms'

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'generate test pattern table'
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
}



if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    #$ColumnData = Get-ZeroFillString -ZeroCount 3
    #Write-Output $ColumnData

    #Show-Dialog
}    
    
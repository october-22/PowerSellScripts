. $PSScriptRoot\functions_binary.ps1


# form ------------------------------------------------------
   
Add-Type -AssemblyName 'System.Windows.Forms'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'generate binary from test pattern'
$form.Size = New-Object System.Drawing.Size(420, 150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

$label = New-Object System.Windows.Forms.Label
$label.Text = 'test pattern file (.txt)'
$label.Location = New-Object System.Drawing.Point(10, 15)
$label.Size = New-Object System.Drawing.Size(350, 20)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(10, 38)
$textbox.Size = New-Object System.Drawing.Size(350, 30)

$button_open = New-Object System.Windows.Forms.Button
$button_open.Text = '...'
$button_open.Location = New-Object System.Drawing.Point(370, 35)
$button_open.Size = New-Object System.Drawing.Size(30, 25)

$button_run = New-Object System.Windows.Forms.Button
$button_run.Text = 'run'
$button_run.Location = New-Object System.Drawing.Point(320, 80)
$button_run.Size = New-Object System.Drawing.Size(80, 25)

# event ----------------------------------------------------

$button_open.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = 'Text Files (*.txt)|*.txt'
    if ($dialog.ShowDialog() -eq 'OK') {
        $textbox.Text = $dialog.FileName
    }
})

$button_run.Add_Click({ 
    $test_pattern_file = $textbox.Text
    $lines_ = Get-Content $test_pattern_file

    if ([string]::IsNullOrWhiteSpace($test_pattern_file)) {
        [System.Windows.Forms.MessageBox]::Show("not path is not specified.", "Error")
        return
    }
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog

    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $outputFile = $saveFileDialog.FileName
        try {
            $binary_line = Convert-Binary-From-TestPattern -TestPattern $lines_
            [System.IO.File]::WriteAllBytes($outputFile, $binary_line)
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
    $label,
    $textbox,
    $button_open,
    $button_run
))

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()


<#
.SYNOPSIS
    ���x���t���̃e�L�X�g�{�b�N�X

.DESCRIPTION
    ���x���ƃe�L�X�g�{�b�N�X���܂ރp�l���𐶐��B 
    $Label�ɂ͎w�肳�ꂽ�e�L�X�g���\���B

.PARAMETER Label
    �\�����郉�x���e�L�X�g�B

.PARAMETER X
    �p�l���̍������X���W�B

.PARAMETER Y
    �p�l���̍������Y���W�B

.OUTPUTS
    [PSCustomObject]
        - Panel: �p�l���I�u�W�F�N�g
        - TextBox: �e�L�X�g�{�b�N�X�I�u�W�F�N�g

.EXAMPLE
    $widget = Widget-TextBox -Label "Name" -X 10 -Y 20
    $form.Controls.Add($widget.Panel)
    Write-Host $widget.TextBox.Text
#>
function New-Widget-TextBox() {
    param (
        [string]$Label,
        [int]$X,
        [int]$Y
    )
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size(90, 25)

    $label_ = New-Object System.Windows.Forms.Label
    $label_.Text = $Label + " : "
    $label_.Location = New-Object System.Drawing.Point(0, 5)
    $label_.Size = New-Object System.Drawing.Size(60, 25)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(60, 2)
    $textbox.Size = New-Object System.Drawing.Size(25, 25)

    $panel.Controls.AddRange(@($label_, $textbox))

    return [PSCustomObject]@{
        Panel   = $panel
        TextBox = $textbox
    }
}

<#
.SYNOPSIS
    ���x���t���̃`�F�b�N�{�b�N�X

.DESCRIPTION
    ���x���ƃ`�F�b�N�{�b�N�X���܂ރp�l���𐶐��B 
    $Label�ɂ͎w�肳�ꂽ�e�L�X�g���\���B

.PARAMETER Label
    �\�����郉�x���e�L�X�g�B

.PARAMETER X
    �p�l���̍������X���W�B

.PARAMETER Y
    �p�l���̍������Y���W�B

.OUTPUTS
    [PSCustomObject]
        - Panel: �p�l���I�u�W�F�N�g
        - CheckBox: �`�F�b�N�{�b�N�X�I�u�W�F�N�g

.EXAMPLE
    $widget = Widget-CheckBox -Label "Name" -X 10 -Y 20
    $form.Controls.Add($widget.Panel)
    Write-Host $widget.CheckBox.Checked
#>
function New-Widget-CheckBox() {
    param (
        [string]$Label,
        [int]$X,
        [int]$Y
    )
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size(90, 25)

    $label_ = New-Object System.Windows.Forms.Label
    $label_.Text = $Label + " : "
    $label_.Location = New-Object System.Drawing.Point(0, 5)
    $label_.Size = New-Object System.Drawing.Size(60, 25)

    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point(60, 0)
    $checkbox.Size = New-Object System.Drawing.Size(25, 25)

    $panel.Controls.AddRange(@($label_, $checkbox))

    return [PSCustomObject]@{
        Panel   = $panel
        CheckBox = $checkbox
    }
}

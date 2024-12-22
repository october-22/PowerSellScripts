<#
.SYNOPSIS
    ラベル付きのテキストボックス

.DESCRIPTION
    ラベルとテキストボックスを含むパネルを生成。 
    $Labelには指定されたテキストが表示。

.PARAMETER Label
    表示するラベルテキスト。

.PARAMETER X
    パネルの左上隅のX座標。

.PARAMETER Y
    パネルの左上隅のY座標。

.OUTPUTS
    [PSCustomObject]
        - Panel: パネルオブジェクト
        - TextBox: テキストボックスオブジェクト

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
    ラベル付きのチェックボックス

.DESCRIPTION
    ラベルとチェックボックスを含むパネルを生成。 
    $Labelには指定されたテキストが表示。

.PARAMETER Label
    表示するラベルテキスト。

.PARAMETER X
    パネルの左上隅のX座標。

.PARAMETER Y
    パネルの左上隅のY座標。

.OUTPUTS
    [PSCustomObject]
        - Panel: パネルオブジェクト
        - CheckBox: チェックボックスオブジェクト

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

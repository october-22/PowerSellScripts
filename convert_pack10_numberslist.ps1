. .\Desktop\pack10\convert_pack10.ps1
. .\Desktop\pack10\read_numberslist.ps1

<#
numberslist.txtから、連結されたpack10進数を生成する。
#>


if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    
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
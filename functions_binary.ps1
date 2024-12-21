<#
.SYNOPSIS
    10進数をPack10形式に変換

.DESCRIPTION
    入力された10進数をPack10形式で2進数に変換出力する。
    出力された使用領域が8bitで割り切れない場合、1111(F)を追加し、byte単位とする。

.PARAMETER Data
    1単位のstring型を指定。複数の値は処理できない。
    例 : "20241231" 0～9までの数値のみを使用した文字列

.EXAMPLE
    Convert-BinaryData-Pack10 -Data "20241231"
    出力：バイナリデータ 20 24 12 31 
#>
function Convert-BinaryData-Pack10 {
    param (
        [string]$Data
    )
    $pack10 = ""
    foreach ($char in $Data.ToCharArray()) {
        $binary_string = [convert]::ToString([string]$char, 2)
        $pack10 += "{0:D4}" -f [int]$binary_string
    }
    if ($pack10.Length % 8 -ne 0) {
        $pack10 += "1111"
    }
    return Convert-BinaryData -BinaryString $pack10
}

<#
.SYNOPSIS
    バイナリ文字列を8ビットごとに分割し、それぞれをバイトに変換してバイト配列を返します。

.DESCRIPTION
    この関数は、バイナリ文字列（`0` と `1` のみからなる文字列）を8ビット単位に分割し、それぞれをバイトに変換します。返される結果は、バイト型の配列です。
    バイナリ文字列の長さは8ビットの倍数である必要があります。

.PARAMETER BinaryString
    変換するバイナリ文字列。8ビットごとに分割され、各部分がバイトに変換されます。
    例: "011000010110001001100011"（"abc" のバイナリ表現）

.EXAMPLE
    $binaryString = "011000010110001001100011"  # バイナリ文字列 (例: "abc")
    $bytes = Convert-BinaryData -BinaryString $binaryString
    $bytes  # 結果: [97, 98, 99] (ASCIIコードで "a", "b", "c")

.NOTES
    バイナリ文字列の長さが8の倍数でない場合は、エラーが発生する可能性があります。
    必要に応じて、バイナリ文字列が8ビットの倍数であることを確認してください。
#>
function Convert-BinaryData() {
    param (
        [string]$BinaryString
    )
    $byteStrings = @()
    for ($i = 0; $i -lt $BinaryString.Length; $i += 8) {
        $byteStrings += $BinaryString.Substring($i, 8)
    }
    $bytes = @()
    foreach ($byteString in $byteStrings) {
        $byte = [Convert]::ToByte($byteString, 2)
        $bytes += $byte
    }
    return $bytes
}


if ($MyInvocation.InvocationName -eq $PSCommandPath) {
    
    # test Convert-BinaryData-Pack10
    <#
    $bytes = Convert-BinaryData-Pack10 -Data "20241231"
    $savepath = [System.Environment]::GetFolderPath('Desktop') + "\test.bin"
    [System.IO.File]::WriteAllBytes($savepath, $bytes)
    #>

    # test Convert-BinaryData 
    <#
    $binaryString = "011000010110001001100011"
    $bytes = Convert-BinaryData -BinaryString $binaryString
    $bytes
    #>    
}
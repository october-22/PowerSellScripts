<#
.SYNOPSIS
    10進数をPack10形式に変換

.DESCRIPTION
    入力された10進数をPack10形式で2進数に変換出力する。
    出力された使用領域が8bitで割り切れない場合、1111(F)を追加し、byte単位とする。

.PARAMETER Data
    1単位のstring型を指定。複数の値は処理できない。
    例 : "20241231" 0～9までの数値のみを使用した文字列であること。
    それ以外のアルファベット、空白、小数点、負数、""(長さ0の文字列) はErrorを返す。
    
.EXAMPLE
    Convert-BinaryData-Pack10 -Data "20241231"
    出力：バイナリデータ 20 24 12 31 
#>
function Convert-BinaryData-Pack10 {
    param (
        [string]$Data
    )
   if (-not ([long]::TryParse($Data, [ref]$null) -and [long]$Data -ge 0)) {
        throw "function_binary.ps1 Convert-BinaryData-Pack10 : 入力値に圧縮不可文字列が存在します。"
    }
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
    二進数を模した文字列を8ビットごとに分割し、それぞれをバイトに変換して
    バイト配列を返します。

.DESCRIPTION
    この関数は、バイナリ文字列（`0` と `1` のみからなる文字列）を
    8ビット単位に分割し、それぞれをバイトに変換します。返される結果は、
    バイト型の配列です。
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
    if ($BinaryString.Length % 8 -ne 0) {
        throw "functions_binary.ps1 Convert-BinaryData : バイナリデータが8の倍数ではありません。"
    }
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


<#
.SYNOPSIS
    テストパターンからバイナリデータを生成。

.DESCRIPTION
    配列に格納された各行をカンマ区切りで分割、
    特定の条件に基づいてバイナリデータを生成します。　

.PARAMETER TestPattern
    配列化されたパターンデータ
    - 数値、もしくは、半角空白(空白00100000は、上位4bitを使用して表現されるため、
      pack10圧縮不可"p"の指定は出来ない)
    - 要素2は、"456,p"とされている。csvデータとして解釈され"p"はpack10として
      圧縮処理される。
    ["123", "456,p", "789"]

.PARAMETER Encode
    指定無はデフォルト "euc-jp" 

.EXAMPLE
    $lines = Get-Content $test_pattern_file
    Convert-BinaryData-From-TestPattern -TestPattern $lines
#>
function Convert-BinaryData-From-TestPattern {
    param (
        [string[]]$TestPattern,
        [string]$Encode = "euc-jp"
    )
    $lines = $TestPattern
    $binary_line = @()

    foreach ($line in $lines) {
        $values = $line -split ","
        if($values.Length -eq 2){
            if($values[1] -eq "p"){
                $binary_data = Convert-BinaryData-Pack10 -Data $values[0]    
            } else {
                return "Invalid value"　# "p" 以外の値
            }
        } else {
            $binary_data = [System.Text.Encoding]::GetEncoding($Encode).GetBytes($values[0])
        }
        $binary_line += $binary_data
    }
    $crlf = [byte[]](0x0D, 0x0A)
    return $binary_line + $crlf
}


<#
.SYNOPSIS
    文字列型配列各要素を一行のバイナリデータに変換する。

.DESCRIPTION
    バイナリデータ変換には、Pack10圧縮後バイナリ化と通常のバイナリ化の二種がある。
    $Futterの値に"p"があった場合のみPack10圧縮を行う。
    行全体をバイナリ形式として結合、末尾に改行コード(\r\n)を付加して返します。

.PARAMETER Strings
    変換対象となる文字列型配列。注意：0-9までのstring型整数と半角空白のみ
    通常、テストパターンテーブルの各行を渡す。

.PARAMETER Options
    各行データ($Strings)に対する処理方法を示す配列。
    通常、テストパターンテーブルのフッターを渡す。
    - `"p"`: Pack10圧縮処理を適用。
    - その他: 指定したエンコーディング($Encode)を使用して変換。

.PARAMETER Encode
    エンコーディング形式を指定(デフォルト:"euc-jp")

.OUTPUTS
    [byte[]]
    バイナリ形式に変換されたデータ行。末尾に改行コード (\r\n) 付加。

.EXAMPLE
    $Row = @("123", "abc", "456")
    $Futter = @("p", "", "p")
    $binaryLine = Convert-Binary-Line -Row $Row -Futter $Futter -Encode "utf-8"
#>
function Convert-BinaryData-OneLine() {
    param (
        [string[]]$Strings,
        [string[]]$Options,
        [string]$Encode = "euc-jp"
    )
    $binary_line = @()
    for ($i = 0; $i -lt $Strings.Count; $i++){
        $string = $Strings[$i]
        $option = $Options[$i]     
        if ($option -eq "p") {
            $binary_data = Convert-BinaryData-Pack10 -Data $string
        }else{
            $binary_data = [System.Text.Encoding]::GetEncoding($Encode).GetBytes($string)        
        }
        $binary_line += $binary_data     
    }
    $crlf = [byte[]](0x0D, 0x0A)
    return $binary_line + $crlf
}



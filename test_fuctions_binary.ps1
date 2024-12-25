. $PSScriptRoot\functions_binary.ps1
. $PSScriptRoot\functions_test.ps1

function Test-Convert-BinaryData(){
    $testCases = @(
        @{Input = "000000010000001000000011"; Output = @(1, 2, 3)}, #"123"
        @{Input = "011000010110001001100011"; Output = @(97, 98, 99)}, #"abc"
        @{Input = "001000000010000000100000"; Output = @(32, 32, 32)}, #"   " space 
        @{Input = "00000001000000100000001";  Output = "バイナリデータが8の倍数ではありません"}
    )
    foreach ($case in $testCases) {
        $input_ = $case.Input
        $output_ = $case.Output
        try {
            $result_ = Convert-BinaryData -BinaryString $input_
            if (-not (Compare-Object $result_ $output_)) {
                Show-Passed -In $input_ -Out $output_
            } else {
                Show-Failed -In $input_ -Out $output_ -Result $result_    
            }
        } catch {
            if ($_.Exception.Message -match $output_) {
                Show-Passed -In $input_ -Out $output_
            }else{
                Show-Error -In $input_ -Out $output_ -Result $_.Exception.Message
            }
        }
    }   
}

function Test-Convert-BinaryData-Pack10 {
    $testCases = @(
        @{Input = "20241231"; Output = [byte[]]@(0x20, 0x24, 0x12, 0x31) },
        @{Input = "1234567890"; Output = [byte[]]@(0x12, 0x34, 0x56, 0x78, 0x90) },
        @{Input = "12345"; Output = [byte[]]@(0x12, 0x34, 0x5F) },
        @{Input = "abc"; Output = "圧縮不可文字列" },
        @{Input = "12.3"; Output = "圧縮不可文字列" },
        @{Input = "-1"; Output = "圧縮不可文字列" },
        @{Input = " "; Output = "圧縮不可文字列" },
        @{Input = "0"; Output = [byte[]]@(0x0F) },
        @{Input = "00"; Output = [byte[]]@(0x00) },
        @{Input = ""; Output = "圧縮不可文字列"}
    )
    foreach ($case in $testCases) {
        $input_ = $case.Input
        $output_ = $case.Output
        try {
            $result_ = Convert-BinaryData-Pack10 -Data $input_
            if (-not (Compare-Object $result_ $output_)) {
                Show-Passed-BytesHex -In $input_ -Out $output_
            } else {
                Show-Failed-BytesHex -In $input_ -Out $output_ -Result $result_
            }
        } catch {
            if ($_.Exception.Message -match $output_) {
                Show-Passed -In $input_ -Out $output_
            }else{
                Show-Error -In $input_ -Out $output_ -Result $result_
            }
        }
    }
}

function Test-Convert-BinaryData-From-TestPattern {
    $testCases = @(
        @{Input = @("1", "2", "3"); Output = [byte[]]@(0x31, 0x32, 0x33, 0x0D, 0x0A) }, # 改行コード 0x0D, 0x0A
        @{Input = @("1", "2,p", "3"); Output = [byte[]]@(0x31, 0x2F, 0x33, 0x0D, 0x0A) }, # "2" がpack10圧縮　00101111　
        @{Input = @("1", "2,", "3"); Output = [byte[]]@(0x31, 0x32, 0x33, 0x0D, 0x0A) },
        @{Input = @("2024", "09", "17"); Output = [byte[]]@(0x32, 0x30, 0x32, 0x34, 0x30, 0x39, 0x31, 0x37, 0x0D, 0x0A)}, 
        @{Input = @(); Output = [byte[]]@(0x0D, 0x0A)} 
    )
    foreach ($case in $testCases) {
        $input_ = $case.Input
        $output_ = $case.Output
        try {
            $result_ = Convert-BinaryData-From-TestPattern -TestPattern $input_
            if (-not (Compare-Object $result_ $output_)) {
                Show-Passed-BytesHex -In $input_ -Out $output_
            } elseif ($result_ -eq "Invalid value"){ # Case3
                Show-Passed-BytesHex -In $input_ -Out $output_
            } else {
                Show-Failed-BytesHex -In $input_ -Out $output_ -Result $result_
            }
        } catch {
            Show-Error -In $input_ -Out $output_ -Result $result_
        }
    }
}

function Test-Convert-BinaryData-OneLine {
    $testCases = @(
        @{Input1 = @("1", "2", "3"); Input2 = @("", "", ""); Output = [byte[]]@(0x31, 0x32, 0x33, 0x0D, 0x0A) },
        @{Input1 = @("1", "2", "3"); Input2 = @("", "p", ""); Output = [byte[]]@(0x31, 0x2F, 0x33, 0x0D, 0x0A) } 
    )
    foreach ($case in $testCases) {
        $input1_ = $case.Input1 # Strings
        $input2_ = $case.Input2 # Options
        $output_ = $case.Output
        try {
            $result_ = Convert-BinaryData-OneLine -Strings $input1_ -Options $input2_ 
            if (-not (Compare-Object $result_ $output_)) {
                Show-Passed-BytesHex -In $input1_ + " : " + $input2_ -Out $output_
            } else {
                Show-Failed-BytesHex -In $input1_ + " : " + $input2_ -Out $output_ -Result $result_
            }
        } catch {
            Show-Error-BytesHex -In $input1_ + " : " + $input2_ -Out $output_ -Result $result_
        }
    }
}

Test-Convert-BinaryData-Pack10
Test-Convert-BinaryData
Test-Convert-BinaryData-From-TestPattern
Test-Convert-BinaryData-OneLine
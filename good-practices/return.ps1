Clear-Host
$tmpFile = 'd:\temp\tmp.mp4'

function Get-Obj {
    [byte[]]$payload = [System.IO.File]::ReadAllBytes($tmpFile)
    $payload
}

function Get-Wrapped {
    [byte[]]$payload = [System.IO.File]::ReadAllBytes($tmpFile)
    @{ wrap = $payload }
}

function Get-Operator {
    [byte[]]$payload = [System.IO.File]::ReadAllBytes($tmpFile)
    ,$payload
}

function Get-WriteOutput {
    [byte[]]$payload = [System.IO.File]::ReadAllBytes($tmpFile)
    Write-Output $payload -NoEnumerate
}

Measure-Command {
    [byte[]]$out1 = Get-Obj
    Write-Host "Size: $($out1.Length)"
}

Measure-Command {
    $out2 = Get-Wrapped
    Write-Host "Size: $($out2.wrap.Length)"
}

Measure-Command {
    $out3 = Get-Operator
    Write-Host "Size: $($out3.Length)"
}

Measure-Command {
    $out4 = Get-WriteOutput
    Write-Host "Size: $($out4.Length)"
}

# OUTPUT for 6.5 MB file

##### Get-Obj #####
# Size: 6 439 243
# TotalSeconds      : 2.4369009
# TotalMilliseconds : 2436.9009

##### Get-Wrapped #####
# Size: 6 439 243
# TotalSeconds      : 0.0087145
# TotalMilliseconds : 8.7145

##### Get-Operator #####
# Size: 6 439 243
# TotalSeconds      : 0.025268
# TotalMilliseconds : 25.268

##### Get-WriteOutput #####
# Size: 6 439 243
# TotalSeconds      : 0.0205171
# TotalMilliseconds : 20.5171
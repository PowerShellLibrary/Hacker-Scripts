$HostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
$Uri = "http://someonewhocares.org/hosts/hosts"
$ValidationToken = "### someonewhocares"
$ValidationTokenEnd = "### someonewhocares-end"

function Get-NewHostsContent() {
    $hostsExtension = Invoke-WebRequest -Uri $Uri -UseBasicParsing
    $hostsExtension.Content -split "`n" | ? { Test-LineCorrect $_ }
}

function Test-LineCorrect ($line) {
    $_.StartsWith("127.0.0.1") -eq $true -or $_.StartsWith("#<") -or $_.StartsWith("#</")
}

[System.Collections.ArrayList]$lines = Get-Content -Path $HostsFilePath
$start = $lines.IndexOf($ValidationToken)
$end = $lines.IndexOf($ValidationTokenEnd)

if ($start -eq -1 -and $end -ne -1) {
    Write-Error "Incorrect hosts file structure. Missing $ValidationToken"
    exit
}

if ($start -ne -1 -and $end -eq -1) {
    Write-Error "Incorrect hosts file structure. Missing $ValidationTokenEnd"
    exit
}

if ($start -eq -1 -and $end -eq -1) {
    Write-Host "Initializing hosts - missing extension"
    $lines += $ValidationToken
    Get-NewHostsContent | % { $lines += $_ }
    $lines += $ValidationTokenEnd
}
else {
    Write-Host "Updating hosts"
    $lines.RemoveRange($start + 1, $end - $start - 1)
    $approvedLines = Get-NewHostsContent
    $lines.InsertRange($start + 1, $approvedLines)
}
[System.IO.File]::WriteAllLines($HostsFilePath, $lines)
$HostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
$Uri = "http://someonewhocares.org/hosts/hosts"
$ValidationToken = "### someonewhocares"
$ValidationTokenEnd = "### someonewhocares-end"

function Get-OldHostsContent() {
    [System.Collections.ArrayList]$lines = Get-Content -Path $HostsFilePath
    $start = $lines.IndexOf($ValidationToken)
    $end = $lines.IndexOf($ValidationTokenEnd)
    $lines.RemoveRange($start, $end - $start + 1)
    $lines
}

function Test-LineCorrect ($line) {
    $_.StartsWith("127.0.0.1") -eq $true
}

$newContent = Get-OldHostsContent
if ($newContent[$newContent.Length - 1] -ne $ValidationToken) {
    $newContent += $ValidationToken
}

$hostsExtension = Invoke-WebRequest -Uri $Uri -UseBasicParsing
$hostsExtension.Content -split "`n" | `
    ? { Test-LineCorrect $_ } | `
    % { $newContent += $_.ToString() }

if ($newContent[$newContent.Length - 1] -ne $ValidationTokenEnd) {
    $newContent += $ValidationTokenEnd
}

[System.IO.File]::WriteAllLines($HostsFilePath, $newContent)
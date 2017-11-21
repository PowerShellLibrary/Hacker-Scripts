$HostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
$Uri = "http://someonewhocares.org/hosts/hosts"
$ValidationToken = "### someonewhocares"

function Get-OldHostsContent() {
    $lines = Get-Content -Path $HostsFilePath
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $currentLine = $lines[$i].ToString()
        $currentLine
        if ($currentLine.StartsWith($ValidationToken)) {
            return
        }
    }
}

function Test-LineCorrect ($line) {
    $_.StartsWith("127.0.0.1") -eq $true
}

$newContent = Get-OldHostsContent
if ($newContent[$newContent.Length-1] -ne $ValidationToken) {
    $newContent += $ValidationToken
}

$hostsExtension = Invoke-WebRequest -Uri $Uri -UseBasicParsing
$hostsExtension.Content -split "`n" | `
    ? { Test-LineCorrect $_ } | `
    % { $newContent += $_.ToString() }

[System.IO.File]::WriteAllLines($HostsFilePath, $newContent)
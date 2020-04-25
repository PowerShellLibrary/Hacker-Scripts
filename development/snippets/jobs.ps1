$Block = {
    Param([string] $text)
    Write-Host "[start] $text"
    Start-Sleep -Seconds 4
    Write-Host "[end]   $text"
}

$jobs = @()
$jobs += Start-Job -Scriptblock $Block -ArgumentList "1st"
Start-Sleep -Seconds 2
$jobs += Start-Job -Scriptblock $Block -ArgumentList "2nd"
Clear-Host
While ($(Get-Job -State Running).count -gt 0) {
    start-sleep -Milliseconds 500
    $jobs | % {
        Receive-Job -Job $_
    }
}

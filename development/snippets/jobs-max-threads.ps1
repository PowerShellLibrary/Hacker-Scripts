$Block = {
    Param([string] $text)
    Write-Host "[start] $text"
    Start-Sleep -Seconds 4
    Write-Host "[end]   $text"
}

function Show-Jobs {
    param ($jobs)
    $jobs | % { Receive-Job -Job $_ }
}

Clear-Host
$jobs = @()
$MaxThreads = 4
1..50 | % {
    #Start jobs. Max 4 jobs running simultaneously.
    While ($(Get-Job -state running).count -ge $MaxThreads) {
        Start-Sleep -Milliseconds 100
        Show-Jobs $jobs
    }
    $jobs += Start-Job -Scriptblock $Block -ArgumentList $_
}

While ($(Get-Job -State Running).count -gt 0) {
    start-sleep -Milliseconds 100
    Show-Jobs $jobs
}
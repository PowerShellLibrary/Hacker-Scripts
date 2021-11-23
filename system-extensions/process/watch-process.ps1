$processToWatch = "Everything"
while (1 -eq 1) {
    $procs = Get-Process | ? { $_.name -eq $processToWatch }
    if ($procs.length -gt 0) {
        Write-Host "Found $($procs.length) occurrences of $processToWatch"
        while (1 -eq 1) {
            [console]::beep(500, 300)
            Start-Sleep -Seconds 1
        }
    }
}
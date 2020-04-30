Measure-Command { $(1..10000) | Out-Null } | Select-Object -Property TotalMilliseconds
Measure-Command { $(1..10000) > $null } | Select-Object -Property TotalMilliseconds
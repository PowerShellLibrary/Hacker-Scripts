# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arithmetic_operators?view=powershell-7.2
Clear-Host
$combinations = @(
    @{l = 1; r = 1 }
    @{l = 0; r = 0 }
    @{l = 0; r = 1 }
    @{l = 1; r = 0 }
)
Write-Host "`nband" -ForegroundColor Yellow
$combinations | % {
    $l = $_.l
    $r = $_.r
    Write-Host "$l `t$r `t=> $($l -band $r)"
}
Write-Host "`nbor" -ForegroundColor Yellow
$combinations | % {
    $l = $_.l
    $r = $_.r
    Write-Host "$l `t$r `t=> $($l -bor $r)"
}

Write-Host "`nbxor" -ForegroundColor Yellow
$combinations | % {
    $l = $_.l
    $r = $_.r
    Write-Host "$l `t$r `t=> $($l -bxor $r)"
}

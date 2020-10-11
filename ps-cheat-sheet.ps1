Clear-Host

Write-Host "Get-Alias dir, cls" -ForegroundColor Green
Get-Alias dir, cls

Write-Host "Get-Command -Name get-* -Module NullKit" -ForegroundColor Green
Get-Command -Name get-* -Module NullKit

Write-Host "Get-Command -Module NullKit" -ForegroundColor Green
Get-Command -Module NullKit

Write-Host "Get-Command | Group-Object Verb | Sort-Object Count -Descending" -ForegroundColor Green
Get-Command | Group-Object Verb | Sort-Object Count -Descending

Write-Host "Get-Command | Group-Object Noun | Sort-Object Name" -ForegroundColor Green
Get-Command | Group-Object Noun | Sort-Object Name | Sort-Object Count -Descending | Select-Object -First 10

Write-Host "[System.DateTime] | Get-Member -MemberType Method Get*" -ForegroundColor Green
[System.DateTime] | Get-Member -MemberType Method Get*

Write-Host Get-ItemProperty -ForegroundColor Green
Get-Item "C:\Windows\System32\drivers\etc\hosts" | Get-ItemProperty | Format-List -Property *

Write-Host "Get-Module -ListAvailable" -ForegroundColor Green
Get-Module -ListAvailable

Write-Host Get-WindowsOptionalFeature -ForegroundColor Green
Get-WindowsOptionalFeature -Online -FeatureName *iis*
#Enable-WindowsOptionalFeature
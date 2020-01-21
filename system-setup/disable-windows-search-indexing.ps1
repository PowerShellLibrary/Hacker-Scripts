Get-Service -Name "*WSearch*" | Set-Service -StartupType Disabled
Get-Service -Name "*WSearch*" | Stop-Service
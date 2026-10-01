# Disable Windows  Service

# Example : Disable Windows Search Service (WSearch)
Get-Service -Name "*WSearch*" | Set-Service -StartupType Disabled
Get-Service -Name "*WSearch*" | Stop-Service
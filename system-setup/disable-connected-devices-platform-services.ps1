# Potential problems:
# WON'T WORK
# - timeline WIN+TAB
# MIGHT NOT WORK
# - clipboard history sharing between devices
# - Bluetooth file sharing
# - Windows Night Light

Clear-Host
$Error.Clear()

function Disable-CDPUserSvcViaRegistry {
    $baseRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
    $cdpServices = Get-ChildItem -Path $baseRegistryPath | Where-Object { $_.Name -match "CDPUserSvc" }

    foreach ($service in $cdpServices) {
        Write-Host "Processing service: $($service.PSChildName)" -ForegroundColor Yellow
        try {
            # Set the 'Start' value to 4 (Disabled) at the root of the service key
            Set-ItemProperty -Path $service.PSPath -Name "Start" -Value 4 -ErrorAction Stop
            Write-Host "`tSuccessfully disabled service: $($service.PSChildName)" -ForegroundColor Green
        }
        catch {
            Write-Host "`tFailed to modify service: $($service.PSChildName). Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Disable and stop CDPUserSvc
Get-Service -Name 'CDPUserSvc*' | ForEach-Object {
    Stop-Service -Name $_.Name -Force
    try {
        Set-Service -Name $_.Name -StartupType Disabled -ErrorAction Stop
    }
    catch  [Microsoft.PowerShell.Commands.ServiceCommandException] {
        Disable-CDPUserSvcViaRegistry
    }
}

# Disable and stop CDPSvc
Write-Host "Processing service: CDPSvc" -ForegroundColor Yellow
Stop-Service -Name CDPSvc -Force

try {
    Set-Service -Name CDPSvc -StartupType Disabled
    Write-Host "`tSuccessfully disabled service: CDPSvc" -ForegroundColor Green

}
catch  [Microsoft.PowerShell.Commands.ServiceCommandException] {
    write-host "`tFailed to modify service: CDPSvc. Error: $($_.Exception.Message)" -ForegroundColor Red
}
function Restart-WiFi {
    $ssid = netsh wlan show interfaces | ? { $_.Contains(" SSID ") }

    $connectionProfile = Get-NetConnectionProfile -IPv4Connectivity Internet | ? { $ssid.Contains($_.Name) } | Select-Object -First 1
    $ssid = $connectionProfile.Name
    $interface = $connectionProfile.InterfaceAlias

    Write-Host "Disconnecting interface: $interface" -ForegroundColor Green
    netsh wlan disconnect
    Start-Sleep -Seconds 2
    Write-Host "Connecting to SSID: $ssid on interface: $interface" -ForegroundColor Green
    netsh wlan connect interface=$interface name=$ssid
}
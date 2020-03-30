function Restart-WiFi {
    <#
.SYNOPSIS
Restats WiFi connection

.DESCRIPTION
Check if there is any active wlan interface and restarts its connection.

.EXAMPLE
Restart-WiFi
Restat WiFi interface if there is any currently active.

#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()

    process {
        $ssid = netsh wlan show interfaces | ? { $_.Contains(" SSID ") }
        if ($ssid) {
            $connectionProfile = Get-NetConnectionProfile -IPv4Connectivity Internet | ? { $ssid.Contains($_.Name) } | Select-Object -First 1
            $ssid = $connectionProfile.Name
            $interface = $connectionProfile.InterfaceAlias

            if ($PSCmdlet.ShouldProcess("$interface")) {
                Write-Host "Disconnecting interface: $interface" -ForegroundColor Green
                netsh wlan disconnect
                Start-Sleep -Seconds 2
                Write-Host "Connecting to SSID: $ssid on interface: $interface" -ForegroundColor Green
                netsh wlan connect interface=$interface name=$ssid
            }
        }
        else {
            Write-Host "Couldn't find active wlan itnerface" -ForegroundColor Red
        }
    }
}
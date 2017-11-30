$DNS = ("8.8.8.8", "8.8.4.4")

$interfaces = Get-NetIPInterface
$interfaces
$ifIndex = Read-Host 'ifIndex: '
$interface = $interfaces | ? { $_.ifIndex -eq "$ifIndex" }
if ($interface) {
    Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses $DNS
}
else {
    Write-Error "Could not find network inteface with a given index"
}

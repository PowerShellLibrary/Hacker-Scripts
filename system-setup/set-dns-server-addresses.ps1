Write-Host '1: Cloudflare'
Write-Host '2: Google'
$dnsProviderIndex = Read-Host 'DNS provider: '
if ($dnsProviderIndex -eq 2) {
    $DNS = ("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844")
}
else {
    $DNS = ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001")
}

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

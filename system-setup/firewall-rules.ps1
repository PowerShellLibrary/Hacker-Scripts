# Block a ABCD.exe from accessing the Internet using Windows Defender Firewall
$exePath = "C:\Users\Alan\AppData\Local\Programs\ABCD\ABCD.exe"

# Add outbound rule to block ABCD.exe
New-NetFirewallRule -DisplayName "[Block] ABCD Out" -Direction Outbound -Program $exePath -Action Block

# Add inbound rule to block ABCD.exe
New-NetFirewallRule -DisplayName "[Block] ABCD In" -Direction Inbound -Program $exePath -Action Block

# Enable rules
Get-NetFirewallRule -DisplayName "[Block] ABCD" | Set-NetFirewallRule -Enabled True

# Disable the inbound rule
Get-NetFirewallRule -DisplayName "*Block* ABCD In" | Set-NetFirewallRule -Enabled False

#  Remove rules
Get-NetFirewallRule -DisplayName '*ABCD*' | Remove-NetFirewallRule
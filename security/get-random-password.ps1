# continuous ASCII table
Get-Random -Minimum 32 -Maximum 123 -Count 20 | % { [char]$_ } | Join-String

# selected ASCII table chunks
$chars = 48..57 + 65..90 + 97..122
1..20 | % { $chars | Get-Random } | % { [char]$_ } | Join-String
function Get-CommonString {
    <#
.SYNOPSIS
Gets common part of two strings

.DESCRIPTION
Searches for common part of two strings, starting from the beginning

.PARAMETER Word1
First word

.PARAMETER Word2
Second Word

.EXAMPLE
Get-CommonString  "website" "web"
Output: 'web'

#>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Word1,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Word2
    )
    $common = $null
    $index = 0
    $same = $true
    do {
        if ($Word1[$index] -eq $Word2[$index]) {
            $common += $Word1[$index]
            $index++
        }
        else {
            $same = $false
        }
    } while ($same -and $index -lt $Word1.Length -and $index -lt $Word2.Length)
    $common
}
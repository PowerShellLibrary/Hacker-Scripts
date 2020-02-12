# Expand-Emoji "Hey. This is emoji test \uD83D\uDE42"
# Hey. This is emoji test 🙂
function Expand-Emoji {
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$String
    )
    [regex]::Unescape($String)
}
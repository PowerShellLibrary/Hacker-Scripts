# https://discord.com/developers/docs/resources/webhook#execute-webhook

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function Push-DiscordMessage {
    [CmdletBinding()]
    param (
        [string]$hookUrl,
        $payload
    )

    process {
        Invoke-RestMethod -Uri $hookUrl -Method Post -Body ($payload | ConvertTo-Json -Depth 4) -ContentType 'Application/Json'
    }
}

$hookUrl = 'https://discord.com/api/webhooks/XXXXXXX/YYYYYYY'
$content = @"
:green_circle: Server [YVES] is now ONLINE
*$(Get-Date)*
"@

$imgUrl = "https://avatars.githubusercontent.com/u/6848691"
$payload = @{
    content    = $content;
    username   = "Alan" ;
    avatar_url = $imgUrl;
    embeds     = @(
        @{title = 'Header1'; thumbnail = @{ url = $imgUrl } }
    )
}
Push-DiscordMessage $hookUrl $payload
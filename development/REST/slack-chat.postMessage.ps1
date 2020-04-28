# https://api.slack.com/methods/chat.postMessage/test

$headers = @{'Content-Type' = 'application/json' }
$payload = @{ "text" = "This is sparta!" }

Invoke-WebRequest -Uri "https://hooks.slack.com/services/XXXXXXX/YYYYYYY/ZZZZZZ" `
    -Method Post `
    -Headers $headers `
    -Body ($payload | ConvertTo-Json ) | Out-Null
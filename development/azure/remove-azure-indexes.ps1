# configuration
$apiKey = "[_API_KEY_]"
$serviceName = "[_SERVICE_NAME_]"
$apiVer = "2015-02-28-Preview"

$headers = @{'Content-Type' = 'application/json'; 'api-key' = $apiKey }
$baseUrl = "https://$($serviceName).search.windows.net/indexes"

function Get-Index {
    param ()
    $response = Invoke-WebRequest -Method Get -Uri "$baseUrl/?api-version=$apiVer" -Headers $headers
    $indexList = $response.Content | ConvertFrom-Json
    $indexList[0].value
}

function Remove-Index {
    param ([string]$iName)
    $remUrl = "$baseUrl/$iName/?api-version=$apiVer"
    Write-Host "Removing index: $iName" -ForegroundColor Yellow
    $response = Invoke-WebRequest -Method Delete -Uri $remUrl -Headers $headers
    $response.StatusCode -eq 204
}

(Get-Index).name | ? { $_.StartsWith("test-index-") } | % {
    if (Remove-Index $_) {
        Write-Host "[OK]" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR]" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}
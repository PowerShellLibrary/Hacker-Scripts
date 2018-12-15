param(
    [parameter(Mandatory = $true)]
    [string]$SourceIdentifier
)

$eventSubscribers = Get-EventSubscriber
Write-Host "Before [$($eventSubscribers.Count)]" -ForegroundColor Red

$events = @("HC::FileDeleted:$SourceIdentifier", "HC::FileCreated:$SourceIdentifier", "HC::FileChanged:$SourceIdentifier")
foreach ($eventName in $events) {
    $eSub = Get-EventSubscriber | ? { $_.SourceIdentifier -eq $eventName }
    Write-Host "Get-EventSubscriber: $eventName"
    if ($eSub) {
        Unregister-Event $eventName
        Write-Host "Unregister-Event $eventName" -ForegroundColor Yellow
    }
}

$count = $eventSubscribers.Count
$eventSubscribers = Get-EventSubscriber
if ($eventSubscribers.Count -lt $count) {
    Write-Host "After [$($eventSubscribers.Count)]" -ForegroundColor Green
}else {
    Write-Host "None unregistered." -ForegroundColor Green
}
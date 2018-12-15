param(
    [parameter(Mandatory = $true, Position = 0)]
    [string]$SourceIdentifier,
    [parameter(Mandatory = $true, Position = 1)]
    [string]$Source,
    [parameter(Mandatory = $true, Position = 2)]
    [string]$Destination,
    [parameter(Mandatory = $false, Position = 3)]
    [string]$Filter = "*.*"
)

$data = @{ src = $Source; dst = $Destination }
$fsw = New-Object IO.FileSystemWatcher $Source, $Filter -Property @{IncludeSubdirectories = $true; NotifyFilter = [IO.NotifyFilters]"FileName, LastWrite"}

$action = {
    $src = $event.MessageData.src
    $dst = $event.MessageData.dst
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    Write-Host "The file "$name" was $changeType at $timeStamp" -fore white
    Robocopy.exe $src $dst /MIR /Z /W:1 /R:1
}

Register-ObjectEvent $fsw Created -SourceIdentifier "HC::FileCreated:$SourceIdentifier" -Action $action -MessageData $data

Register-ObjectEvent $fsw Deleted -SourceIdentifier "HC::FileDeleted:$SourceIdentifier" -Action $action -MessageData $data

Register-ObjectEvent $fsw Changed -SourceIdentifier "HC::FileChanged:$SourceIdentifier" -Action $action -MessageData $data
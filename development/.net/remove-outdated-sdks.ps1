# Remove outdated .NET SDKs
# Usage: Run this script in PowerShell with administrative privileges

$all = Get-Item -Path "C:\Program Files\dotnet\shared\Microsoft.*.App\*"
$installed = $all.Name | select-Object -Unique
$installed | ForEach-Object {
    Write-Host "Installed SDK version: '$_'" -ForegroundColor Cyan
}

# let user pick a version from UI picker
$sdkVersion = $installed | Out-GridView -Title "Select SDK version to remove" -OutputMode Single
if (-not $sdkVersion) {
    Write-Host "No version selected. Operation cancelled." -ForegroundColor Red
    Exit
}

Clear-Host
Write-Host "Removing outdated SDKs for '$sdkVersion'" -ForegroundColor Green

$toRemove = Get-Item -Path "C:\Program Files\dotnet\shared\Microsoft.*.App\$sdkVersion"

if ($toRemove.Length -eq 0) {
    Write-Host "No outdated SDKs found" -ForegroundColor Green
    Exit
}

# confirm the removal - ask user to confirm
write-host "The following folders will be removed:" -ForegroundColor Yellow
$toRemove | ForEach-Object {
    write-host $_.FullName -ForegroundColor Yellow
}

Write-Host "WARNING: If you type 'Y', all folders listed above will be removed." -ForegroundColor Red
$confirmation = Read-Host "Are you Sure You Want To Proceed"
if ($confirmation -eq 'y') {
    $toRemove | % { $_.Delete($true) }
}else{
    Write-Host "Operation cancelled" -ForegroundColor Red
}
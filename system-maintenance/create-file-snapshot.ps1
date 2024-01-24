param(
    [parameter(Mandatory = $true, Position = 0)]
    [string]$fileToBackup,
    [parameter(Mandatory = $true, Position = 1)]
    [string]$backupFolderPath
)
Import-Module NullKit

$current = Get-Location
try {
    Set-Location $backupFolderPath
    if (!(Test-GitRepo)) {
        git init
    }

    if (Test-GitRepo) {
        Copy-Item -Path $fileToBackup -Destination $backupFolderPath -Force
        git add .
        $date = Get-Date
        git commit -m "$date"
    }
}
catch{
    Write-Error $_.Exception
}
finally {
    Set-Location $current
}

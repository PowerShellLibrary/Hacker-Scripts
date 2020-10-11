$url = "https://dl.teamviewer.com/download/TeamViewerPortable.zip"
$installationDir = "C:\TWPortable"
$dateTail = (Get-Date).ToString("yyyy-MM-dd")
$outFilePath = "$($env:TEMP)\TeamViewerPortable.zip"

Invoke-WebRequest -Uri $url -OutFile $outFilePath

if (Test-Path $installationDir) {
    Write-Host "Directory already exists" -ForegroundColor Yellow
    Rename-Item -Path $installationDir -NewName "TWPortable-$dateTail"
}
Expand-Archive -Path $outFilePath -DestinationPath $installationDir
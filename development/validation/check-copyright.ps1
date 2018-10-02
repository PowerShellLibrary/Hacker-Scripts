$StartPath = "C:\dlls"
$ExpectedCopyright = "© 2018 Alan Płócieniak. All rights reserved."

Get-ChildItem $StartPath | ? { $_.Extension -eq ".dll" } | % {
    $path = $_.FullName
    $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path)
    $copyright = $versioninfo.LegalCopyright
    if ($copyright -ne $ExpectedCopyright) {
        Write-Host $path -ForegroundColor Red
        Write-Host $copyright
    }
    else {
        Write-Host $path -ForegroundColor Green
    }
}
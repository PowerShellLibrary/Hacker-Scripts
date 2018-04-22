$filesLocation = "D:\test\"

$fileNames = Get-ChildItem -Path $filesLocation | Sort-Object -Property Name | % { $_.Name }
$concatenatedNames = $fileNames -join "+"

Set-Location $filesLocation
cmd /c copy /b $concatenatedNames out.ts
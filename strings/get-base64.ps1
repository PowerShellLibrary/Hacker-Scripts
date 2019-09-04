$filePath = "C:\hash\a.txt"
$fileContent = Get-Content $filePath
$fileContentBytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)

$fileContentEncoded | Set-Content ($filePath + ".b64")
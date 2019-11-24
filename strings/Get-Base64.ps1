function Get-Base64 {
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        $FilePath
    )
    $fileContent = Get-Content $FilePath
    $fileContentBytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
    $fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
    $fileContentEncoded | Set-Content ($FilePath + ".b64")
    $fileContentEncoded
}

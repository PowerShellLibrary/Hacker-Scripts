# Use case: modify media items without changing their visual content

# Usage: touch all PNG files in the images directory
# Get-ChildItem ".\themes\images\" -Filter *.png -Recurse | ForEach-Object { Touch-File $_.FullName }


function Touch-File {
    param ([string]$filePath)

    $bytes = [System.IO.File]::ReadAllBytes($filePath)

    # Append a harmless zero byte
    $bytes += 0x00

    [System.IO.File]::WriteAllBytes($filePath, $bytes)
}
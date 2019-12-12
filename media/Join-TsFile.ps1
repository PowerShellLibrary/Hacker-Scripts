function Join-TsFile {
    <#
.SYNOPSIS
Helper script for concatenating .ts files

.DESCRIPTION
This script will join *.ts files from a given directory or list of files passed as an argument

.PARAMETER FilesLocation
Location of the folder where your DLLs live.

.PARAMETER Files
Location of the folder where your DLLs live.

.PARAMETER OutFile
Location of the folder where your DLLs live.

.EXAMPLE
Join-TsFile "c:\test\"
Joins all *.ts files found in a "c:\test\" directory

.EXAMPLE
Join-TsFile -Files (gci "c:\test\2")
Joins all files passed as with Files argument
#>
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$FilesLocation,
        [Parameter(Mandatory = $false, Position = 1)]
        [System.IO.FileInfo[]]$Files,
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$OutFile = "out.ts"
    )

    $location = Get-Location
    try {
        if (![string]::IsNullOrWhiteSpace($FilesLocation)) {
            $fileNames = Get-ChildItem -Path $FilesLocation -Filter "*.ts" | Sort-Object -Property CreationTime | % { $_.Name }
        }
        if ($Files) {
            $fileNames = $Files.Name
            $tsFile = $Files | Select-Object -First 1
            $FilesLocation = $tsFile.Directory
        }
        $concatenatedNames = $fileNames -join "+"
        Set-Location $FilesLocation
        cmd /c copy /b $concatenatedNames $OutFile | Out-Null
    }
    finally {
        Set-Location $location
    }
}
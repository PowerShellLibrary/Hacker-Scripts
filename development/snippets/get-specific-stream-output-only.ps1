function Write-Messages {
        [CmdletBinding()]
        param()
        Write-Host "Host message"
        Write-Output "Output message"
        Write-Verbose "Verbose message"
        Write-Warning "Warning message"
        Write-Error "Error message"
        Write-Debug "Debug message"
        Write-Information "Information message"
}

# writes Error only
Write-Messages -Verbose -Debug  2>&1 | Out-File -FilePath .\OutputFile.txt

# writes Warning only
Write-Messages -Verbose -Debug  3>&1 | Out-File -FilePath .\OutputFile.txt

# writes Verbose only
Write-Messages -Verbose -Debug  4>&1 | Out-File -FilePath .\OutputFile.txt

# writes Debug only
Write-Messages -Verbose -Debug  5>&1 | Out-File -FilePath .\OutputFile.txt

# writes Information only
Write-Messages -Verbose -Debug  6>&1 | Out-File -FilePath .\OutputFile.txt

# writes Verbose and Debug
Write-Messages -Verbose -Debug  5>&1 4>&1 | Out-File -FilePath .\OutputFile.txt

# writes Verbose and Error from objec to a file
$outStream = $( . {
                Write-Messages -Verbose
                Write-Messages -Verbose
        } | Out-Null) 2>&1 4>&1
$outStream | Out-File -FilePath .\OutputFile.txt
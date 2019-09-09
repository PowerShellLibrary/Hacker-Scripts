function Remove-Comments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [System.IO.FileInfo]$file
    )

    begin {
        Write-Verbose "Cmdlet Remove-Comments - Begin"
    }

    process {
        Write-Verbose "Cmdlet Remove-Comments - Process"
        Write-Host $file.FullName -ForegroundColor Green
        $content = Get-Content $file.FullName
        $stop = $false
        $contentWithoutComments = $content | % {
            if ($_.Contains("/**")) {
                $stop = $true
            }
            if ($stop -eq $false) {
                if (!$_.Trim().StartsWith("//")) {
                    $_
                }
            }
            if ($stop -and $_.Contains("*/")) {
                $stop = $false
            }
        }
        Set-Content -Value $contentWithoutComments -Path $file.FullName
    }

    end {
        Write-Verbose "Cmdlet Remove-Comments - End"
    }
}

Get-ChildItem -Path "C:\repo\Hacker-Scripts\scripts" | % {
    Remove-Comments $_
}

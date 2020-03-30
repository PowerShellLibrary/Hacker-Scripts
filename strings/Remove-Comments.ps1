function Remove-Comments {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [System.IO.FileInfo]$File
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
        if ($PSCmdlet.ShouldProcess("$($file.FullName)")) {
            Set-Content -Value $contentWithoutComments -Path $file.FullName
        }
    }

    end {
        Write-Verbose "Cmdlet Remove-Comments - End"
    }
}
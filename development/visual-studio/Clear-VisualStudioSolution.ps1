function Clear-VisualStudioSolution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$StartPath
    )

    begin {
        Write-Verbose "Cmdlet Clear-VisualStudioSolution - Begin"
        . "$PSScriptRoot\Resolve-MsBuild.ps1"
        $MSBuildCall = Resolve-MsBuild
    }

    process {
        Write-Verbose "Cmdlet Clear-VisualStudioSolution - Process"
        Get-ChildItem -Path $StartPath -Recurse -ErrorAction SilentlyContinue | ? { $_.Extension -eq ".csproj" } | % {
            & $MSBuildCall $_.FullName /t:clean -verbosity:n
        }
    }

    end {
        Write-Verbose "Cmdlet Clear-VisualStudioSolution - End"
    }
}
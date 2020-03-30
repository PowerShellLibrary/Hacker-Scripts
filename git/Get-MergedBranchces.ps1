function Get-MergedBranchces {
    <#
.SYNOPSIS
Helper script for listing merged branches

.DESCRIPTION
This script will return all branches names that were already merged to the current branch

.PARAMETER Branches
Collection of excluded branches

.EXAMPLE
Get-MergedBranchces
Gets all merged branches except default branches: master, develop

.EXAMPLE
Get-MergedBranchces -Branches naster,feature1
Gets all merged branches except specified branches: master, feature1
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Branches = @("master", "develop")
    )

    process {
        $testIsInWorkFree = git rev-parse --is-inside-work-tree
        if ($testIsInWorkFree) {
            git branch --merged | % { $_.TrimStart([string]::Empty) } | ? { $Branches.Contains($_) -eq $false } | ? { -not($_.StartsWith("*")) }
        }
        else {
            Write-Host "This is not a git repository."
        }
    }
}
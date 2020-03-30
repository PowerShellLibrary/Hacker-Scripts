function Get-MergedRemoteBranchces {
    <#
.SYNOPSIS
Helper script for listing merged remote branches

.DESCRIPTION
This script will return all remote branches names that were already merged to the current branch

.PARAMETER Branches
Collection of excluded branches

.EXAMPLE
Get-MergedRemoteBranchces
Gets all merged remote branches except default branches: master, develop, HEAD

.EXAMPLE
Get-MergedRemoteBranchces -Branches naster,feature1
Gets all merged remote branches except specified branches: master, feature1
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Origin = "origin",
        [Parameter(Mandatory = $false)]
        [string]$Branch = "master",
        [Parameter(Mandatory = $false)]
        [string[]]$Branches = @("master", "develop", "HEAD")
    )

    process {
        function Test-Any() {
            begin { $any = $false }
            process { $any = $true }
            end { $any }
        }

        if (!$Branches.Contains($Branch)) {
            $Branches += ($Branch)
        }
        $testIsInWorkFree = git rev-parse --is-inside-work-tree
        if ($testIsInWorkFree) {
            git branch -r --merged $Origin/$Branch | % { $_.TrimStart([string]::Empty) } | ? {
                $b = $_
                !($Branches | ? { $b.StartsWith("$Origin/$($_)") } | Test-Any)
            }
        }
        else {
            Write-Host "This is not a git repository."
        }
    }
}
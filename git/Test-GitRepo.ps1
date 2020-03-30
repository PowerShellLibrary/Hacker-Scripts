function Test-GitRepo {
    <#
.SYNOPSIS
Helper script for listing merged branches

.DESCRIPTION
This script will return all branches names that were already merged to the current branch

.PARAMETER Branches
Collection of excluded branches

.EXAMPLE
Test-GitRepo
Gets all merged branches except default branches: master, develop
#>

    [CmdletBinding()]
    param()

    process {
        $testIsInWorkFree = git rev-parse --is-inside-work-tree
        $testIsInWorkFree -eq "true"
    }
}
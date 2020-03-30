function Remove-MergedBranches {
    <#
.SYNOPSIS
Helper script for removing merged branches

.DESCRIPTION
This script will remove all branches which were already merged to the current branch

.PARAMETER Branches
Collection of excluded from removing branches

.EXAMPLE
.\Remove-MergedBranches.ps1
Removes all merged branches except default branches: master, develop

.EXAMPLE
.\Remove-MergedBranches.ps1 -Branches naster,feature1
Removes all merged branches except specified branches: master, feature1
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Branches = @("master", "develop")
    )

    process {
        . $PSScriptRoot\Get-MergedBranchces.ps1 $Branches | % {
            $branch = $_
            if ($PSCmdlet.ShouldProcess($branch)) {
                git branch -d $branch
            }
        }
    }
}
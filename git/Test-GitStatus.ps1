function Test-GitStatus {
    <#
.SYNOPSIS
Scans git directories and displays status

.DESCRIPTION
Scans git directories and displays git status.
It provides following information:
- OK            - if repo is clean
- NOT_GIT       - if folder is not a git repo
- HAS_WORKING   - if there are any active changes (working changes)
- STASH         - if repository has any stasches

.PARAMETER DirectoryPath
Root dir containing other git repo folders

.EXAMPLE
Test-GitStatus
Iterates through folders in a current directory and displays git status of each repo

.EXAMPLE
Test-GitStatus c:\repo
Iterates through folders from a 'c:\repo' directory and displays git status of each repo
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$DirectoryPath
    )

    begin {
        Import-Module posh-git
    }

    process {
        if (!$DirectoryPath) {
            $DirectoryPath = Get-Location
        }
        $revertPath = Get-Location

        try {
            Get-ChildItem $DirectoryPath | ? { $_.PSIsContainer } | % {
                $dir = $_.FullName

                Set-Location $dir
                $git = Get-GitStatus

                if (!$git.GitDir) {
                    Write-Host "[NOT_GIT]`t`t$dir" -ForegroundColor Red
                }
                else {
                    if ($git.HasWorking) {
                        Write-Host "[HAS_WORKING]`t$dir" -ForegroundColor Yellow
                    }
                    else {
                        $stash = git stash list
                        if ($null -ne $stash -and $stash.Count -gt 0) {
                            Write-Host "[STASH]`t`t`t$dir" -ForegroundColor DarkYellow
                        }
                        else {
                            Write-Host "[OK]`t`t`t$dir" -ForegroundColor Green
                        }
                    }
                }
            }
        }
        finally {
            Set-Location $revertPath
        }
    }
}
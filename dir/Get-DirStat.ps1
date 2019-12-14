function Get-DirStat {
    <#
.SYNOPSIS
Gets folders report

.PARAMETER Path
Folder path that will be exposed via SymbolicLink

.EXAMPLE
Get-DirStat "c:\repo"
This command displays report for all folders in "c:\repo"

.EXAMPLE
Get-DirStat
This command displays report for all folders in a current directory
#>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false, Position = 0)]
        [string]$Path
    )

    process {
        $fso = new-object -com Scripting.FileSystemObject
        Get-ChildItem -Directory -Path $Path `
        | Select-Object @{l = 'Size'; e = { $fso.GetFolder($_.FullName).Size } }, FullName `
        | Sort-Object Size -Descending `
        | Format-Table @{l = 'Size [MB]'; e = { '{0:N2}    ' -f ($_.Size / 1MB) } }, FullName
    }
}
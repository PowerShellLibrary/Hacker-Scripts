function Get-CmdletTemplate {
    <#
.SYNOPSIS
[PURPOSE OF CMDLET]

.DESCRIPTION
[SHORT DESCRIPTION]

.PARAMETER Arg1
[PURPOSE OF Arg1]

.PARAMETER Arg2
[PURPOSE OF Arg2]

.EXAMPLE
Get-CmdletTemplate 1 2
[ACTION DESCRIPTION]

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Arg1,
        [Parameter(Mandatory = $false, Position = 1)]
        [System.IO.FileInfo[]]$Arg2
    )
    #  [CODE]
}
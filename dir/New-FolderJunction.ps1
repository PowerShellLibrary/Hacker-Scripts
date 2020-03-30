function New-FolderJunction {
    <#
.SYNOPSIS
Helper script for creating SymbolicLink aka folder junction

.PARAMETER Source
Folder path that will be exposed via SymbolicLink

.PARAMETER Destination
Location of the SymbolicLink (endpoint)

.EXAMPLE
New-FolderJunction "c:\repo\serialization" "c:\sites\website1\Data\serialization"

Creates a junction for "c:\repo\serialization" folder in "c:\sites\website1\Data\serialization".
Serialization data from the repository will be available in the website.
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [string]$Source,
        [parameter(Mandatory = $true, Position = 1)]
        [string]$Destination
    )

    process {
        if ($PSCmdlet.ShouldProcess("$Source")) {
            New-Item -Path $Destination -ItemType SymbolicLink -Value $Source
        }
    }
}
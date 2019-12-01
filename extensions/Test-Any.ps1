function Test-Any {
    <#
.SYNOPSIS
Linq.Enumerable.Any Method for PowerShell

.DESCRIPTION
Check predicate and returns either true or false depending on the result

.PARAMETER FilterScript
Predicate to be executed on an item

.EXAMPLE
1..4 | Test-Any { $_ -gt 5 }
Displays False

.EXAMPLE
1..4 | Test-Any { $_ -gt 2 }
Displays True

#>
    param( $FilterScript = $null )
    process {
        if ($FilterScript | Invoke-Expression) {
            $true;
            break
        }
    }
    end {
        $false
    }
}
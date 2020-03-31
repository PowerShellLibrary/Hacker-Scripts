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
This command displays false because there no item greater than 5 in the collection

.EXAMPLE
1..4 | Test-Any { $_ -gt 2 }
This command displays true because there is an item greater than 2 in the collection

#>
    param( $FilterScript = $null )
    begin {
        $flag = $false
    }

    process {
        if (!$flag) {
            if ($FilterScript | Invoke-Expression) {
                $flag = $true;
                return
            }
        }
    }
    end {
        $flag
    }
}
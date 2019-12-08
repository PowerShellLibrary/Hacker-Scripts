function Skip-While {
    <#
.SYNOPSIS
Linq.Enumerable.SkipWhile Method for PowerShell

.DESCRIPTION
Skips all items until first will be valid for a predicator

.PARAMETER Predicate
Predicate to be executed on an item

.EXAMPLE
"a","aa","aaa" | Skip-While { $_.Length -lt 3 }
aaa

.EXAMPLE
1..10 | Skip-While { $_ -ne 8 }
8
9
10

#>
    param( $Predicate = $null )
    begin {
        $skip = $true
    }
    process {
        if ( $skip ) {
            $skip = $Predicate | Invoke-Expression
        }
        if ( -not $skip ) {
            $input
        }
    }
}
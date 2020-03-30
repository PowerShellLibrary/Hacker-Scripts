$Public = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.ps1" -Exclude "Run-PSScriptAnalyzer.ps1" | ? { $_.Name[0].Equals($_.Name.ToUpper()[0]) }

Foreach ($import in $Public) {
    try {
        . $import.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
Export-ModuleMember -Function $Public.Basename
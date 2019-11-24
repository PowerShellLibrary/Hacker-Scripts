$Public = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.ps1" | ? { $_.Name[0].Equals($_.Name.ToUpper()[0]) }

#Dot source the files
Foreach ($import in $Public) {
    try {
        . $import.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
Export-ModuleMember -Function $Public.Basename
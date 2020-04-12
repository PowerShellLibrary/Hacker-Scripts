# configuration
$targetFramework = "net48"
$startPath = "C:\repo\src"
# configuration - END

Clear-Host
Get-ChildItem -Path $startPath -Recurse -ErrorAction SilentlyContinue | ? { $_.Extension -eq ".csproj" } | % {
    Write-Host "Processing $_" -ForegroundColor Green
    [xml]$xmlDoc = Get-Content $_.FullName
    [System.Xml.XmlNode]$node = $xmlDoc.Project.PropertyGroup.ChildNodes | ? { $_.Name -eq "TargetFramework" }
    if ($node.InnerText -ne $targetFramework) {
        Write-Host "`tChanking value from '$($node.InnerText)' to '$targetFramework'" -ForegroundColor DarkCyan
        $node.InnerText = $targetFramework
        $xmlDoc.Save($_.FullName)
    }
}
$startPath = "C:\repo\src"

Clear-Host
Get-ChildItem -Path $startPath -Recurse -ErrorAction SilentlyContinue | ? { $_.Extension -eq ".csproj" } | ? { $_.Name.EndsWith(".Tests.csproj" ) -ne $true } | % {
    Write-Host "Processing $_" -ForegroundColor Green
    [xml]$xmlDoc = Get-Content $_
    $node = $xmlDoc.Project.PropertyGroup | ? { $_.Condition -and $_.Condition.Contains("Release") }
    $escrowNode = $node.Clone()
    $escrowNode.Condition = $escrowNode.Condition.Replace("Release", "Escrow")
    $xmlDoc.Project.InsertAfter($escrowNode, $node) | Out-Null

    $configurationParent = $xmlDoc.Project.PropertyGroup | ? { $_.Condition -eq $null }

    $configurationsNode = $xmlDoc.CreateElement("Configurations")
    $configurationsNode.InnerXml = "Debug;Release;Escrow"
    $configurationParent.AppendChild($configurationsNode)
    $xmlDoc.Save($_.FullName)
}
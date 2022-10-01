# Modifies access control lists (ACL) for a given directory
$repoPath = "C:\repo\Hacker-Scripts"
$user = "VICTORINOX\Alan"

# checks current access
$ACL = Get-Acl -Path $repoPath
Write-Host "ACL.Owner: " $ACL.Owner -ForegroundColor Yellow

# updates access
$owner = New-Object System.Security.Principal.Ntaccount($user)
$ACL.SetOwner($owner)
Set-Acl -Path $repoPath -AclObject $ACL
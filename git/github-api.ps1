Clear-Host
$PersonalAccessToken = "github_pat_[your_personal_access_token]"

$GitHubApiUrl = "https://api.github.com/user/repos"
# $GitHubApiUrl = "https://api.github.com/orgs/PowerShellLibrary/repos"
# $GitHubApiUrl = "https://api.github.com/repositories"

$Headers = @{
    Authorization = "token $PersonalAccessToken"
    "User-Agent"  = "PowerShell" # GitHub API requires a User-Agent header
}

$response = Invoke-RestMethod -Uri $GitHubApiUrl -Method Get -Headers $Headers
$response

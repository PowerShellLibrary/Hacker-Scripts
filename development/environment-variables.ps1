# Environment Variable Lifetimes

# 1. Session ($env:VARIABLE)
$env:MY_VAR = "value1"
Write-Host $env:MY_VAR

# 1.1. Environment variable with dynamic key
$key = "MY_VAR"
Set-Item "env:$key" "value2"

# 2. Process-Level Inheritance
#   when you set an environment variable in PowerShell,
#   it is inherited by child processes (like dotnet run, git, or other spawned applications).

# 3. Permanent Environment Variables (Registry)
[System.Environment]::SetEnvironmentVariable("MY_VAR", "value1", "User")
Write-Host $env:MY_VAR

# 4. Environment Variables in GitHubs Actions
# Environment variables set during one step are not automatically available in subsequent steps in GitHub Actions.
# To persist environment variables between steps, you need to explicitly use the GITHUB_ENV file.
$value = "value1"
echo "$key=$value" >> $env:GITHUB_ENV
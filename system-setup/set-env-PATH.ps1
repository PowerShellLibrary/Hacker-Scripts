# This script will add a tool folder path to the system environment variable (PATH)
$tool = "C:\tools\dsc"
$PATH = [Environment]::GetEnvironmentVariable("PATH")
[Environment]::SetEnvironmentVariable("PATH", "$PATH;$tool", [System.EnvironmentVariableTarget]::Machine)
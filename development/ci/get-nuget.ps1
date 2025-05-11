$nugetVersion = "6.7.0"  # Change to your required version
$nugetUrl = "https://dist.nuget.org/win-x86-commandline/v$nugetVersion/nuget.exe"
Invoke-WebRequest -Uri $nugetUrl -OutFile "nuget.exe"
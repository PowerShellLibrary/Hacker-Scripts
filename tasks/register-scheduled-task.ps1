$name = [guid]::NewGuid()
$trigger = New-ScheduledTaskTrigger -Once -At 9am
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# inline script
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& { Write-Host 1 }"'
# file script
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoLogo -WindowStyle hidden -file C:\script.ps1'

$task = Register-ScheduledTask `
    -TaskName $name `
    -Description "Background task" `
    -Trigger $trigger `
    -Action $action `
    -TaskPath '\Alan\jobs' `
    -Principal $principal

Write-Host "Created: $($task.TaskName) under $($task.TaskPath)"

# display tasks in folder
Get-ScheduledTask -TaskPath "\Alan\*"
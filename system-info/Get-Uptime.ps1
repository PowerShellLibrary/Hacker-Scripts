function Get-Uptime {
    <#
.SYNOPSIS
Information about system run time

.DESCRIPTION
Returns and TimeSpan object with run time information. It check the last day when system was booted and compares it with localdate

.EXAMPLE
Get-Uptime
Returns 'System.TimeSpan' object with information about operting system running time

.EXAMPLE
Get-Uptime | Select-Object -Property TotalHours
Returns total number of hours after operating system was booted for the last time
#>
    param ()

    $data = Get-CimInstance -ClassName win32_operatingsystem | Select-Object LastBootUpTime, LocalDateTime
    $data.LocalDateTime - $data.LastBootUpTime
}
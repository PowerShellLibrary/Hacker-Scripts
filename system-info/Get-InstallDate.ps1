function Get-InstallDate {
    <#
.SYNOPSIS
Returns system installation date.

.DESCRIPTION
Returns DateTime with operating system installation date. Date will change during feature updates

.EXAMPLE
Get-Uptime
Returns 'System.DateTime' object with date when operatin system was installed
#>
    param ()
    $data = Get-CimInstance -ClassName win32_operatingsystem | Select-Object InstallDate
    $data.InstallDate
}
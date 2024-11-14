# Focus Assist Off
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("(^{ESC})")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("(Focus Assist)")
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Milliseconds 700
[System.Windows.Forms.SendKeys]::SendWait("{TAB}{TAB} ")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("(%{F4})")
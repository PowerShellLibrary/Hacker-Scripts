set /p Input=Enter URL:
set /p Delay=Enter Delay [sec]:
powershell "while(1 -eq 1){ Invoke-WebRequest '%Input%' | Select-Object -Property StatusCode, Content ; Start-Sleep -Seconds %Delay% }"
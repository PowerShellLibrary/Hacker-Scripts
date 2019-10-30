set /p Input=Enter delay in minutes:
set /a result=%Input%*60
timeout /t %result%
%windir%\system32\rundll32.exe powrprof.dll,SetSuspendState
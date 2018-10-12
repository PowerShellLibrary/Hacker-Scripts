set /p Input=Enter delay in minutes:
set /a result=%Input%*60
timeout /t %result%
shutdown -h
# The system has resumed from sleep
Check what woke the system up last time and any active wake timers

```powershell
powercfg /waketimers
powercfg /lastwake
```

### Example output:
```powershell
powercfg /waketimers
Timer set by [PROCESS] \Device\HarddiskVolume3\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe expires at 4:00:00 AM
```

This is the executable for the Start Menu Experience, which handles the Start menu in Windows 10 and Windows 11.

Expires at 4:00:00 AM: This indicates the time when the wake event is scheduled to occur.

To disable wake timers completely for your power plan, you can go to **Power Options** in the **Control Panel**, select `Change plan settings > Change advanced power settings`, and under Sleep, set **Allow** wake timers to **Disable**.
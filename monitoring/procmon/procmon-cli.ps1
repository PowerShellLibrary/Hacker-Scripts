# This script is used to start Process Monitor in the background with a specific configuration file.
# https://learn.microsoft.com/en-us/sysinternals/downloads/procmon

procmon.exe /Quiet /Minimized /LoadConfig ProcmonConfigurationObsidian.pmc /Backingfile MonitorLog.pml

# Configuration File: ProcmonConfigurationObsidian.pmc

# Monitoring Activities
#   Show Process and Thread Activity
#   Show Network Activity

# Capture Events (Drop filtered events)
#   Filters
#    - ✅Process Name is Obsidian.exe
#    - ❌Operation is NOT Thread Create
#    - ❌Operation is NOT Thread Exit
#    - ❌Operation is NOT Load Image
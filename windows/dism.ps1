# DISM.ps1 - Analyze and clean up the Windows Component Store (WinSxS) using DISM tool.

DISM /Online /Cleanup-Image /AnalyzeComponentStore
# Deployment Image Servicing and Management tool
# Version: 10.0.19041.3636

# Image Version: 10.0.19045.6937

# [==========================100.0%==========================]

# Component Store (WinSxS) information:

# Windows Explorer Reported Size of Component Store : 13.46 GB

# Actual Size of Component Store : 13.12 GB

#     Shared with Windows : 6.33 GB
#     Backups and Disabled Features : 6.79 GB
#     Cache and Temporary Data :  0 bytes

# Date of Last Cleanup : 2026-02-24 00:13:11

# Number of Reclaimable Packages : 1
# Component Store Cleanup Recommended : Yes

# The operation completed successfully.

DISM /Online /Cleanup-Image /StartComponentCleanup
# Deployment Image Servicing and Management tool
# Version: 10.0.19041.3636

# Image Version: 10.0.19045.6937

# [==========================100.0%==========================]
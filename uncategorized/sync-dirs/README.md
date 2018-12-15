# Dir Sync
Helper to keep directories synchronized.

Script will create a `IO.FileSystemWatcher` and observe following events.

- FileDeleted
- FileCreated
- FileChanged

If any of those events will occur, defined action will be triggered.

## Scripts

- unregister-watcher.ps1 - used to unregister handlers
- register-watcher.ps1 - used to register handlers

# Usage

### register example
```powershell
.\register-watcher.ps1 -SourceIdentifier GitBackupHandler -Source "C:\src" -Destination "D:\backup"
```

### unregister example
```powershell
.\unregister-watcher.ps1 -SourceIdentifier GitBackupHandler
```

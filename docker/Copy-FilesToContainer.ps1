# Copies files from the host to a running Docker container using Base64 encoding to handle file content safely.
# Usage:
# Copy-FilesToContainer `
#     -ContainerId $ContainerId `
#     -Source      '.\ci\pester\external' `
#     -Destination 'C:\inetpub\wwwroot\App_Data\External'
#
# Note: Requires PowerShell both on the host and in the container.
# Workaround for `docker cp` limitations: "Error response from daemon: filesystem operations against a running Hyper-V container are not supported"

function Copy-FilesToContainer {
    param(
        [string]$ContainerId,
        [string]$Source,
        [string]$Destination
    )

    $files = Get-ChildItem -LiteralPath $Source -File

    docker exec $ContainerId powershell -c "New-Item -ItemType Directory -Force -Path '$Destination' | Out-Null"

    foreach ($file in $files) {
        $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))
        $dest = Join-Path $Destination $file.Name

        docker exec $ContainerId powershell -c "[IO.File]::WriteAllBytes('$dest', [Convert]::FromBase64String('$b64'))"

        Write-Host "Pushed $($file.Name)" -ForegroundColor Green
    }

    Write-Host "`nDone. $($files.Count) file(s) pushed to '$Destination'." -ForegroundColor Cyan
}
function Get-FolderSize($folder) {
    $files = Get-ChildItem $folder.FullName -Recurse | ? { ! $_.PSIsContainer }  | ? { $_.Length -ne $null}
    $size = $files | Measure-Object -Property length -Sum
    ($size.sum / 1MB)
}

function Get-FoldersToRemove {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$StartPath
    )

    begin {
        Write-Verbose "Cmdlet Get-FoldersToRemove - Begin"
        $foldersToRemove = @()
    }

    process {
        Write-Verbose "Cmdlet Get-FoldersToRemove - Process"
        Get-ChildItem -Path $StartPath -Recurse -ErrorAction SilentlyContinue | ? { $_.Extension -eq ".csproj" } | % {
            Write-Verbose "[CSPROJ]: $($_.FullName)"

            $binPath = "$($_.Directory)/bin"
            if (Test-Path $binPath) {
                Write-Verbose "`t[BIN]:`t`t $binPath"
                $binFolder = Get-Item -Path $binPath
                $foldersToRemove += $binFolder
            }

            $objPath = "$($_.Directory)/obj"
            if (Test-Path $objPath) {
                Write-Verbose "`t[OBJ]:`t`t $objPath"
                $objFolder = Get-Item -Path $objPath
                $foldersToRemove += $objFolder
            }

            [xml]$csproj = Get-Content -Path $_.FullName
            if ($csproj.Project.ItemGroup.None.Include | ? { $_ -eq "packages.config" }) {
                $prjcRelativePath = $csproj.Project.ItemGroup.Reference.HintPath |  ? { $_ -ne $null -and $_.Length -gt 0 } |  ? { $_.Contains("\packages\") } | Select-Object -First 1
                if ($prjcRelativePath -ne $null) {


                    $path = [System.IO.Path]::GetFullPath((Join-Path  $_.DirectoryName $prjcRelativePath ))
                    if (Test-Path $path) {
                        $dllFile = Get-Item -Path $path
                        $packagesFolder = $dllFile

                        while ($packagesFolder.Name -ne "packages" -and $packagesFolder.Parent -ne $packagesFolder) {
                            $packagesFolder = Get-Item $packagesFolder.PSParentPath
                        }

                        if ($foldersToRemove.Length -eq 0 -or ($foldersToRemove.FullName.Contains($packagesFolder.FullName) -eq $false)) {
                            Write-Verbose "`t[PACKAGES]:`t $packagesFolder"
                            $foldersToRemove += $packagesFolder
                        }
                    }
                }
            }
        }
        $foldersToRemove
    }

    end {
        Write-Verbose "Cmdlet Get-FoldersToRemove - End"
    }
}

function Clear-VisualStudioProjectFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [string]$StartPath
    )

    begin {
        Write-Verbose "Cmdlet Clear-VisualStudioProjectFolder - Begin"
    }

    process {
        Write-Verbose "Cmdlet Clear-VisualStudioProjectFolder - Process"
        $memoryToRelease = 0
        $foldersToRemove = Get-FoldersToRemove $StartPath
        $foldersToRemove | % {$memoryToRelease += Get-FolderSize $_ }
        $foldersToRemove | Sort-Object -Property LastWriteTime -Descending | Format-Table FullName, LastWriteTime, @{Expression = { "{0:N2}" -f (Get-FolderSize $_) }; Label = "Size [MB]" } -AutoSize

        Write-Host ("Memory to release {0:N2}" -f $memoryToRelease + " MB") -ForegroundColor Green

        if ($memoryToRelease -eq 0) {
            Exit
        }

        Write-Host "WARNING: If you type 'Y', all folders listed above will be moved removed." -ForegroundColor Red
        $confirmation = Read-Host "Are you Sure You Want To Proceed"
        if ($confirmation -eq 'y') {
            $foldersToRemove | % { $_.Delete($true) }
        }
    }

    end {
        Write-Verbose "Cmdlet Clear-VisualStudioProjectFolder - End"
    }
}

Clear-VisualStudioProjectFolder "C:\repo\"
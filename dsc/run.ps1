$validation = dsc config test -f .\validate.dsc.yml -o json | ConvertFrom-Json
foreach ($r in $validation.results) {
    if ($r.result.inDesiredState -eq $false) {
        throw "[FAIL] $($r.name) [$($r.type)]"
    }
}

Get-ChildItem .\steps -Filter '*.dsc.yml' -Recurse | ForEach-Object {
    $step = $_.FullName
    Write-Host "[INFO] Running step: $step" -ForegroundColor DarkGray
    $test = dsc config test -f $step -o json | ConvertFrom-Json
    $test.results | % {
        if ($_.result.inDesiredState -eq $true) {
            Write-Host "[OK] $($_.name) [$($_.type)]" -ForegroundColor Green
        }
        else {
            Write-Host "[APPLY] $($_.name) [$($_.type)]" -ForegroundColor Yellow
        }
    }

    [bool[]]$states = $test.results.result.inDesiredState
    if ( $states.Contains($false)) {
        $setResult = dsc config set -f $step -o json | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0) {
            throw "[FATAL] Couldn't set the desired state for $step"
        }
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "[PASS] All resources are in desired state" -ForegroundColor Green
}
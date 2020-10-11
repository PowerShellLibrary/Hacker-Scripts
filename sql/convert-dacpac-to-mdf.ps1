##################################### Configuration ####################################
$sqlInstallationBinFolder = "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin"
$sqlUser = "sa"
$sqlPassword = "Wsadzec1"
$serverName = "VICTORINOX"
# Optional
$dbLocation = $PSScriptRoot
# Const
$tempDbNamePrefix = "PoweShellTransformation."
########################################################################################

function Test-SQLConnection {
    [OutputType([bool])]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        $ConnectionString
    )
    try {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
        $sqlConnection.Open();
        $sqlConnection.Close();

        return $true;
    }
    catch {
        return $false;
    }
}

if (-not (Test-Path $sqlInstallationBinFolder)) {
    Write-Host "Incorrect sqlInstallationBinFolder: $sqlInstallationBinFolder" -ForegroundColor Red
    exit
}

if (-not (Test-Path "$sqlInstallationBinFolder\SqlPackage.exe")) {
    Write-Host "Could not find SqlPackage.exe: $sqlInstallationBinFolder\SqlPackage.exe" -ForegroundColor Red
    exit
}

if (-not (Test-SQLConnection "Data Source=$serverName;database=master;User ID=$sqlUser;Password=$sqlPassword;")) {
    Write-Host "Could not connect to a database. Check credentials" -ForegroundColor Red
    exit
}


if (-not(Test-Path "$dbLocation\mdf")) {
    New-Item -ItemType directory -Path "$dbLocation\mdf"
}

$start = Get-Date
Get-ChildItem -Path $dbLocation | ? { $_.Extension -eq ".dacpac" } | % {
    $name = $tempDbNamePrefix + $_.Name.Replace(".dacpac", "")
    $srcPath = $_.FullName

    # publish db from script
    Write-Host "Processing $($_.Name)" -ForegroundColor Green
    & "$sqlInstallationBinFolder\SqlPackage.exe" /action:Publish /SourceFile:$srcPath /TargetServerName:$serverName /TargetDatabaseName:$name /TargetUser:$sqlUser /TargetPassword:$sqlPassword

    # get database files paths
    $query = "select name, physical_name from sys.master_files where name like '$name%'"
    $paths = Invoke-Sqlcmd -ServerInstance $serverName -Database "master" -Query $query -Username $sqlUser -Password $sqlPassword | % { $_.physical_name }

    # detach database
    $query = "sp_detach_db '$name', 'true';"
    Invoke-Sqlcmd -ServerInstance $serverName -Database "master" -Query $query -Username $sqlUser -Password $sqlPassword

    # move mdf and ldf files
    $paths | % { Move-Item -Path $_ -Destination "$dbLocation\mdf" -Force }
}

# set file names
Get-ChildItem -Path "$dbLocation\mdf" | % {
    $newName = $_.Name.Replace("_Primary", "").Replace($tempDbNamePrefix, [string]::Empty)
    Rename-Item -Path $_.FullName -NewName $newName
}
$end = Get-Date
$end - $start
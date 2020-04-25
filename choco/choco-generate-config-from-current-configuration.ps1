$packages = clist -lo
$match = $packages | ? { $_ -like "* packages installed." }
$count = $packages.IndexOf($match)
$packages | Select-Object -First $count | % {
    $i = $_.IndexOf(" ")
    "choco install " + $_.Substring(0, $i) + " -y" >> "$PSScriptRoot\choco.conf.bat"
}
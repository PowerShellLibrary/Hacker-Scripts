Get-ChildItem "D:\___to backup\" | % {
    $date = $_.LastWriteTime.ToString("yyyy-MM-dd")
    $name = $_.Name
    $_ | Rename-Item -NewName "$date-$name"
}
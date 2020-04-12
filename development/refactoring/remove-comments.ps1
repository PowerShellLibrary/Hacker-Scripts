$startPath = C:\repo\src

Import-Module NullKit
Get-ChildItem -Path $startPath -Filter "*.cs" -r `
    | ? { ! $_.PSIsContainer } `
    | % { Remove-Comments $_ }
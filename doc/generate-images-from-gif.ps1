Get-Item C:\1.gif | ConvertTo-Png
Get-Item C:\1.gif | ConvertTo-Image -Format Jpeg

Get-ChildItem C:\test -Filter "*.gif" | ConvertTo-Png
Get-ChildItem C:\test -Filter "*.gif" | ConvertTo-Image -Format Png
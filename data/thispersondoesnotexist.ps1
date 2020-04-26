1..100 | % {
    Invoke-WebRequest -Uri "https://thispersondoesnotexist.com/image" -OutFile "D:\avatars\$([guid]::NewGuid()).jpg"
    Start-Sleep -Seconds 1
}
# Event Viewver log entry
# Level     Data and Time           Source                                  EventID     Task Category
# Warning	04-Dec-18 4:01:03 PM	CertificateServicesClient-AutoEnrollment     64     None
#
# Event content
# Certificate for local system with Thumbprint 3f ca 6f fa df 41 a3 6a 3b 5b c1 16 5c 7b ed 95 8c 49 65 50 is about to expire or already expired.

$thumbprint = "3f ca 6f fa df 41 a3 6a 3b 5b c1 16 5c 7b ed 95 8c 49 65 50"
$thumbprint = $thumbprint.ToUpperInvariant().Replace(" ", [string]::Empty)

Set-Location CERT:\\
[System.Security.Cryptography.X509Certificates.X509Certificate2]$cert = Get-ChildItem -Recurse | ? {  $_.Thumbprint -eq $thumbprint } | Select-Object -First 1
if ($cert) {
    Write-Host "`nFriendlyName:" -ForegroundColor Green
    $cert.FriendlyName
    Write-Host "`nSubject:" -ForegroundColor Green
    $cert.Subject
    Write-Host "`nIssuer:" -ForegroundColor Green
    $cert.Issuer
    Write-Host "`nThumbprint:" -ForegroundColor Green
    $cert.Thumbprint
    Write-Host "`nNotBefore:" -ForegroundColor Green
    $cert.NotBefore
    Write-Host "`nNotAfter:" -ForegroundColor Green
    $cert.NotAfter
    $valid = $cert.Verify()
    Write-Host "`nVerify() => $($valid)" -ForegroundColor Green
    if($valid){
        Write-Host "`nNothing to fix" -ForegroundColor Green
    }else{
        Write-Host "`nNot VALID" -ForegroundColor Red
        Write-Host "`nTry to reset or dispose cert. First make sure that you've got other certificate issued from the same issuer"
        Write-Host "`nUse `$cert.Reset() or `$cert.Dispose()"
        # $cert.Reset()
        # $cert.Dispose()
    }
}else {
    Write-Host "Cannot find certificate with a given Thumbprint '$thumbprint'" -ForegroundColor Yellow
}
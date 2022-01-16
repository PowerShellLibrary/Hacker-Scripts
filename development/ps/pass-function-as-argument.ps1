function Invoke-Func($text, $predicate) {
    if ($predicate.Invoke($text) -eq $true) {
        Write-Host "Valid`t [$text]" -ForegroundColor Green
    }
    else {
        Write-Host "Invalid`t [$text]" -ForegroundColor Red
    }
}

function Test-Text($str) {
    $str.StartsWith("A")
}

Invoke-Func "ABC" ${function:Test-Text}
Invoke-Func "XYZ" ${function:Test-Text}
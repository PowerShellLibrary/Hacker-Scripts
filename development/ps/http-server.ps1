$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()

if ($http.IsListening) {
    write-host " HTTP Server Ready!  " -ForegroundColor White -BackgroundColor Green
    write-host "now try going to $($http.Prefixes)" -f 'y'
    write-host "then try going to $($http.Prefixes)other/path" -f 'y'
}

Start-Process 'http://localhost:8080/'
Start-Process 'http://localhost:8080/some/form'

try {
    while ($http.IsListening) {
        $contextTask = $http.GetContextAsync()
        while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { }
        $context = $contextTask.GetAwaiter().GetResult()

        # ROUTE EXAMPLE 1
        # http://127.0.0.1/
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/') {
            write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'

            [string]$html = "<h1>A Powershell Webserver</h1><p>home page</p>"

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html) # convert htmtl to bytes
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) #stream to broswer
            $context.Response.OutputStream.Close() # close the response
        }

        # ROUTE EXAMPLE 2
        # http://127.0.0.1/some/form'
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/some/form') {
            write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'

            [string]$html = "
        <h1>A Powershell Webserver</h1>
        <form action='/some/post' method='post'>
            <p>A Basic Form</p>
            <p>fullname</p>
            <input type='text' name='fullname'>
            <p>message</p>
            <textarea rows='4' cols='50' name='message'></textarea>
            <br>
            <input type='submit' value='Submit'>
        </form>
        "
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()
        }

        # ROUTE EXAMPLE 3
        # http://127.0.0.1/some/post'
        if ($context.Request.HttpMethod -eq 'POST' -and $context.Request.RawUrl -eq '/some/post') {

            $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()

            write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
            Write-Host $FormContent -f 'Green'

            [string]$html = "<h1>A Powershell Webserver</h1><p>Post Successful!</p>"

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()
        }
    }
}
finally {
    $http.Stop()
}
<#
.SYNOPSIS
    Scrapes Geekbench 6 CPU search results and exports to CSV.

.DESCRIPTION
    Iterates all result pages for a given search query, parses the Bootstrap
    div-based layout (no <table>/<tr> present), and writes:
      System, CPU, Uploaded, Uploader, Platform,
      Single-Core, Multi-Core, ResultId, URL

.PARAMETER Query
    Search query string (default: "Dell OptiPlex")

.PARAMETER OutputFile
    Destination CSV path (default: .\geekbench_results.csv)

.PARAMETER MaxPages
    Stop after this many pages. 0 = unlimited (default: 0)

.PARAMETER DelaySeconds
    Polite delay between requests in seconds (default: 1.5)

.EXAMPLE
    .\Get-GeekbenchResults.ps1 -Query "Dell OptiPlex" -OutputFile "optiplex.csv"

.EXAMPLE
    .\Get-GeekbenchResults.ps1 -Query "Apple M3" -MaxPages 5
#>

[CmdletBinding()]
param(
    [string]  $Query = "Dell OptiPlex",
    [string]  $OutputFile = ".\geekbench_results.csv",
    [int]     $MaxPages = 0,
    [double]  $DelaySeconds = 1.5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web   # for HtmlDecode

# ---------------------------------------------------------------------------
# Helper - strip all HTML tags from a fragment and collapse whitespace
# ---------------------------------------------------------------------------
function Strip-Html ([string]$Html) {
    $s = [System.Web.HttpUtility]::HtmlDecode($Html)
    $s = $s -replace '<[^>]+>', ' '
    $s = $s -replace '\s+', ' '
    return $s.Trim()
}

# ---------------------------------------------------------------------------
# Helper - update the progress bar
# ---------------------------------------------------------------------------
function Update-Progress {
    param(
        [string] $Query,
        [int]    $Page,
        [int]    $EffectiveTotal,   # 0 = unknown
        [int]    $ResultsSoFar
    )

    if ($EffectiveTotal -gt 0) {
        $pct = [int](($Page - 1) / $EffectiveTotal * 100)
        $status = "Page $Page of $EffectiveTotal  -  $ResultsSoFar results collected"
    }
    else {
        $pct = -1    # indeterminate marquee
        $status = "Page $Page (total unknown)  -  $ResultsSoFar results collected"
    }

    Write-Progress `
        -Activity        "Scraping Geekbench: $Query" `
        -Status          $status `
        -PercentComplete $pct
}

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
$BaseUrl = "https://browser.geekbench.com"
$Headers = @{
    "Accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    "Accept-Language" = "en-US,en;q=0.5"
    "DNT"             = "1"
}
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
"AppleWebKit/537.36 (KHTML, like Gecko) " +
"Chrome/124.0.0.0 Safari/537.36"

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
$allResults = [System.Collections.Generic.List[PSCustomObject]]::new()
$page = 1
$totalPages = 0    # 0 = not yet known
$effectiveOf = 0    # whichever is smaller: totalPages or MaxPages

Write-Host ""
Write-Host "Geekbench Scraper" -ForegroundColor Cyan
Write-Host "  Query      : $Query"
Write-Host "  Output     : $OutputFile"
Write-Host "  Max pages  : $(if ($MaxPages -eq 0) { 'unlimited' } else { $MaxPages })"
Write-Host "  Delay      : ${DelaySeconds}s"
Write-Host ""

while ($true) {

    $encodedQuery = [uri]::EscapeDataString($Query)
    $url = "${BaseUrl}/search?page=${page}&q=${encodedQuery}&utf8=%E2%9C%93"

    Update-Progress -Query $Query -Page $page -EffectiveTotal $effectiveOf -ResultsSoFar $allResults.Count

    try {
        $response = Invoke-WebRequest `
            -Uri            $url `
            -UseBasicParsing `
            -UserAgent      $UserAgent `
            -Headers        $Headers `
            -TimeoutSec     30
    }
    catch {
        Write-Progress -Activity "Scraping Geekbench: $Query" -Completed
        Write-Warning "  Request failed on page $page`: $_"
        break
    }

    $html = $response.Content

    # ------------------------------------------------------------------
    # Detect last page number from pagination links (first page only)
    # ------------------------------------------------------------------
    if ($totalPages -eq 0) {
        $pageNums = [regex]::Matches($html, '[?&]page=(\d+)') |
        ForEach-Object { [int]$_.Groups[1].Value }
        if ($pageNums.Count -gt 0) {
            $totalPages = ($pageNums | Measure-Object -Maximum).Maximum
            $effectiveOf = if ($MaxPages -gt 0 -and $MaxPages -lt $totalPages) { $MaxPages } else { $totalPages }
            # Immediately refresh bar now that we know the ceiling
            Update-Progress -Query $Query -Page $page -EffectiveTotal $effectiveOf -ResultsSoFar $allResults.Count
        }
    }

    # ------------------------------------------------------------------
    # Parse result cards
    # ------------------------------------------------------------------

    $cardPattern = "(?s)<div class='col-12 list-col'>(.*?)</div>\s*</div>\s*</div>"
    $cardMatches = [regex]::Matches($html, $cardPattern)

    if ($cardMatches.Count -eq 0) {
        Write-Progress -Activity "Scraping Geekbench: $Query" -Completed
        Write-Warning "  No result cards found on page $page."
        Write-Warning "  Response length: $($html.Length) chars."
        Write-Warning "  First 500 chars: $($html.Substring(0, [Math]::Min(500,$html.Length)))"
        break
    }

    $pageCount = 0

    foreach ($card in $cardMatches) {
        $c = $card.Groups[1].Value

        # System name & result URL
        $linkMatch = [regex]::Match($c, "(?s)<a\s+href=""(/v6/cpu/(\d+))""[^>]*>(.*?)</a>")
        if (-not $linkMatch.Success) { continue }

        $resultPath = $linkMatch.Groups[1].Value
        $resultId = $linkMatch.Groups[2].Value
        $systemName = Strip-Html $linkMatch.Groups[3].Value
        $resultUrl = $BaseUrl + $resultPath

        # CPU model
        $cpuMatch = [regex]::Match($c, "(?s)<span class='list-col-model'>(.*?)</span>")
        $cpuInfo = if ($cpuMatch.Success) { Strip-Html $cpuMatch.Groups[1].Value } else { '' }

        # Uploaded date + optional uploader / Platform  (two list-col-text spans)
        $allTextSpans = [regex]::Matches($c, "(?s)<span class='list-col-text'>(.*?)</span>")
        if ($allTextSpans.Count -lt 2) { continue }

        $uploadedRaw = $allTextSpans[0].Groups[1].Value
        $dateMatch = [regex]::Match($uploadedRaw, '\b([A-Za-z]{3}\s+\d{1,2},\s+\d{4})\b')
        $uploaded = if ($dateMatch.Success) { $dateMatch.Groups[1].Value } else { Strip-Html $uploadedRaw }
        $uploaderMatch = [regex]::Match($uploadedRaw, 'href="/user/([^"]+)"')
        $uploader = if ($uploaderMatch.Success) { $uploaderMatch.Groups[1].Value } else { '' }
        $platform = Strip-Html $allTextSpans[1].Groups[1].Value

        # Single-Core / Multi-Core scores
        $scoreSpans = [regex]::Matches($c, "(?s)<span class='list-col-text-score'>(.*?)</span>")
        if ($scoreSpans.Count -lt 2) { continue }

        $singleCore = Strip-Html $scoreSpans[0].Groups[1].Value
        $multiCore = Strip-Html $scoreSpans[1].Groups[1].Value
        if ($singleCore -notmatch '^\d+$' -or $multiCore -notmatch '^\d+$') { continue }

        $allResults.Add([PSCustomObject]@{
                System        = $systemName
                CPU           = $cpuInfo
                Uploaded      = $uploaded
                Uploader      = $uploader
                Platform      = $platform
                'Single-Core' = [int]$singleCore
                'Multi-Core'  = [int]$multiCore
                ResultId      = $resultId
                URL           = $resultUrl
            })

        $pageCount++
    }

    Write-Verbose "  Page $page`: parsed $pageCount card(s)  (total so far: $($allResults.Count))"

    # ------------------------------------------------------------------
    # Pagination
    # ------------------------------------------------------------------
    $atMaxPages = ($MaxPages -gt 0 -and $page -ge $MaxPages)
    $atLastPage = ($totalPages -gt 0 -and $page -ge $totalPages)

    if ($atMaxPages -or $atLastPage) {
        Write-Progress -Activity "Scraping Geekbench: $Query" -Completed
        Write-Host "  Reached $(if ($atMaxPages) { "MaxPages limit ($MaxPages)" } else { "last page ($totalPages)" })." -ForegroundColor Cyan
        break
    }

    if ($pageCount -eq 0) {
        Write-Progress -Activity "Scraping Geekbench: $Query" -Completed
        Write-Host "  No results on page $page - assuming end of data." -ForegroundColor Yellow
        break
    }

    $page++
    Start-Sleep -Seconds $DelaySeconds
}

# ---------------------------------------------------------------------------
# Export
# ---------------------------------------------------------------------------
if ($allResults.Count -eq 0) {
    Write-Warning "No results collected - CSV not written."
    exit 1
}

$allResults | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Done!  $($allResults.Count) results  ->  $OutputFile" -ForegroundColor Cyan
Write-Host ""

$fmt = "{0,-55} SC={1,5}  MC={2,6}  [{3}]"
Write-Host "--- Score summary: $Query ---" -ForegroundColor Yellow
$allResults | ForEach-Object {
    $fmt -f $_.System, $_.'Single-Core', $_.'Multi-Core', $_.Platform
} | Write-Host
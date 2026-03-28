# Get-GeekbenchResults

PowerShell scraper for [Geekbench Browser](https://browser.geekbench.com) CPU search results. Exports all pages of a search query to CSV.

> No official API exists — this scrapes the public search UI.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Windows 10+ (uses `System.Web` for HTML decoding)
- Network access to `browser.geekbench.com`

## Usage

```powershell
.\Get-GeekbenchResults.ps1 [[-Query] <string>] [[-OutputFile] <string>] [[-MaxPages] <int>] [[-DelaySeconds] <double>]
```

### Parameters

| Parameter      | Default                   | Description                                             |
| -------------- | ------------------------- | ------------------------------------------------------- |
| `Query`        | `Dell OptiPlex 3000`      | Search string, same as the Geekbench Browser search box |
| `OutputFile`   | `.\geekbench_results.csv` | Path for the output CSV                                 |
| `MaxPages`     | `0` (unlimited)           | Stop after N pages. Useful for testing                  |
| `DelaySeconds` | `1.5`                     | Pause between page requests                             |

### Examples

```powershell
# Scrape all results for a query
.\Get-GeekbenchResults.ps1 -Query "Dell OptiPlex 3000" -OutputFile "optiplex.csv"

# Test with just the first page
.\Get-GeekbenchResults.ps1 -Query "Dell OptiPlex 3000" -MaxPages 1

# Different system, custom output path
.\Get-GeekbenchResults.ps1 -Query "Apple M4" -OutputFile "C:\data\m4.csv"

# Verbose mode — prints per-page counts alongside the progress bar
.\Get-GeekbenchResults.ps1 -Query "Intel Core i5-12500T" -Verbose
```

## Output

CSV with one row per result:

| Column        | Example                                         |
| ------------- | ----------------------------------------------- |
| `System`      | `Dell Inc. OptiPlex 3000`                       |
| `CPU`         | `Intel Core i5-12500T 2000 MHz (6 cores)`       |
| `Uploaded`    | `Mar 26, 2026`                                  |
| `Uploader`    | `user1` (empty if anonymous)                    |
| `Platform`    | `Windows` / `Linux` / `macOS`                   |
| `Single-Core` | `2287`                                          |
| `Multi-Core`  | `7855`                                          |
| `ResultId`    | `17292002`                                      |
| `URL`         | `https://browser.geekbench.com/v6/cpu/17292002` |

A summary table is also printed to the console on completion.

## Notes

- The script only scrapes **Geekbench 6 CPU** results. GPU (`v6/compute`) and Geekbench AI results are separate search categories not covered here.
- Be considerate with `-DelaySeconds`. The default 1.5s is intentionally polite.

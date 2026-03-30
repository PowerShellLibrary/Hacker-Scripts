#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generates a self-contained HTML icon preview page from a folder of SVGs.

.DESCRIPTION
    Scans a directory for .svg files, inlines their content into a single
    HTML file with a searchable, filterable grid. No external dependencies.

.PARAMETER IconsPath
    Path to the folder containing .svg files. Defaults to current directory.

.PARAMETER OutputFile
    Path for the generated HTML file. Defaults to .\icon-preview.html

.PARAMETER Recurse
    If set, scans subdirectories recursively.

.PARAMETER Filter
    Optional wildcard filter for icon names, e.g. "folder_type_*"

.EXAMPLE
    .\New-IconPreview.ps1 -IconsPath ".\icons" -OutputFile ".\preview.html"

.EXAMPLE
    .\New-IconPreview.ps1 -IconsPath "C:\vscode-icons\icons" -Recurse -Filter "folder_*"
#>

[CmdletBinding()]
param(
  [string] $IconsPath = ".",
  [string] $OutputFile = ".\icon-preview.html",
  [switch] $Recurse,
  [string] $Filter = "*.svg"
)

# ── Resolve paths ─────────────────────────────────────────────────────────────

$IconsPath = Resolve-Path $IconsPath | Select-Object -ExpandProperty Path
$OutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)

Write-Host "Scanning: $IconsPath" -ForegroundColor Cyan

# ── Collect SVG files ─────────────────────────────────────────────────────────

$getParams = @{
  Path    = $IconsPath
  Filter  = $Filter
  File    = $true
  Recurse = $Recurse.IsPresent
}

$svgFiles = Get-ChildItem @getParams | Sort-Object Name

if ($svgFiles.Count -eq 0) {
  Write-Warning "No SVG files found in '$IconsPath' with filter '$Filter'"
  exit 1
}

Write-Host "Found $($svgFiles.Count) SVG files" -ForegroundColor Green

# ── Build icon data array ─────────────────────────────────────────────────────

$iconObjects = foreach ($file in $svgFiles) {
  $raw = Get-Content $file.FullName -Raw -Encoding UTF8

  # Strip XML declaration and DOCTYPE if present
  $raw = $raw -replace '^\s*<\?xml[^?]*\?>\s*', ''
  $raw = $raw -replace '<!DOCTYPE[^>]*>\s*', ''
  $raw = $raw.Trim()

  # Derive a friendly display label from the filename convention:
  #   folder_type_flutter  ->  "folder/ flutter"
  #   file_type_ts         ->  "file/ ts"
  $label = $file.BaseName `
    -replace '^folder_type_open_', 'folder/ ' `
    -replace '^folder_type_', 'folder/ ' `
    -replace '^file_type_', 'file/ '   `
    -replace '^folder_', 'folder/ ' `
    -replace '^file_', 'file/ '

  # Relative sub-path for tooltip when using -Recurse
  $relPath = $file.FullName.Substring($IconsPath.Length).TrimStart('\', '/')

  # Plain hashtable — ConvertTo-Json handles all escaping for us
  [ordered]@{
    label = $label
    name  = $file.BaseName
    path  = $relPath
    svg   = $raw
  }
}

# Serialize to JSON — correctly escapes quotes, backslashes, unicode, etc.
# This also avoids any PS/JS ${...} collision inside the here-string.
$jsonData = $iconObjects | ConvertTo-Json -Compress -Depth 3
$jsIconsArray = "const ICONS = $jsonData;"

$totalCount = $svgFiles.Count
$generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm"
$sourceDir = $IconsPath

# ── HTML ──────────────────────────────────────────────────────────────────────
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Icon Preview — $totalCount icons</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&family=Syne:wght@400;700;800&display=swap');

  :root {
    --bg:        #0d0f11;
    --surface:   #151820;
    --border:    #1e2430;
    --accent:    #5b8dee;
    --accent2:   #c778dd;
    --text:      #c8cdd8;
    --muted:     #4a5168;
    --label:     #7eb3f7;
    --hover-bg:  #1a1f2e;
    --card-size: 120px;
  }

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: 'JetBrains Mono', monospace;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
  }

  header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: var(--bg);
    border-bottom: 1px solid var(--border);
    padding: 16px 24px;
    display: flex;
    gap: 16px;
    align-items: center;
    flex-wrap: wrap;
  }

  .header-title {
    font-family: 'Syne', sans-serif;
    font-weight: 800;
    font-size: 1.1rem;
    color: #fff;
    letter-spacing: -0.02em;
    flex-shrink: 0;
  }
  .header-title span { color: var(--accent); }

  .search-wrap { flex: 1; min-width: 180px; position: relative; }
  .search-wrap svg {
    position: absolute;
    left: 10px; top: 50%;
    transform: translateY(-50%);
    opacity: .4;
    pointer-events: none;
  }
  #search {
    width: 100%;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-family: inherit;
    font-size: .8rem;
    padding: 7px 12px 7px 32px;
    outline: none;
    transition: border-color .15s;
  }
  #search:focus { border-color: var(--accent); }
  #search::placeholder { color: var(--muted); }

  .filters { display: flex; gap: 6px; flex-shrink: 0; }
  .pill {
    cursor: pointer;
    font-family: inherit;
    font-size: .72rem;
    padding: 5px 12px;
    border-radius: 999px;
    border: 1px solid var(--border);
    background: transparent;
    color: var(--muted);
    transition: all .15s;
  }
  .pill:hover  { border-color: var(--accent); color: var(--accent); }
  .pill.active { background: var(--accent); border-color: var(--accent); color: #fff; }

  .stats {
    padding: 10px 24px;
    font-size: .72rem;
    color: var(--muted);
    display: flex;
    gap: 16px;
    border-bottom: 1px solid var(--border);
    flex-wrap: wrap;
  }
  .stats strong { color: var(--text); }

  main { padding: 20px 24px; }

  #grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(var(--card-size), 1fr));
    gap: 10px;
  }

  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 12px 8px 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    cursor: default;
    transition: border-color .12s, background .12s, transform .12s;
    position: relative;
    overflow: hidden;
  }
  .card:hover {
    border-color: var(--accent);
    background: var(--hover-bg);
    transform: translateY(-2px);
  }
  .card:hover .copy-btn { opacity: 1; }

  .icon-wrap {
    width: 40px; height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .icon-wrap svg, .icon-wrap img {
    width: 100%; height: 100%;
    object-fit: contain;
  }

  .card-label {
    font-size: .62rem;
    color: var(--label);
    text-align: center;
    line-height: 1.3;
    word-break: break-all;
    max-width: 100%;
  }
  .card-label .prefix { color: var(--muted); display: block; font-size: .58rem; }
  .card-label .name   { color: var(--text); }

  .copy-btn {
    position: absolute;
    top: 5px; right: 5px;
    background: var(--border);
    border: none;
    border-radius: 4px;
    color: var(--muted);
    font-family: inherit;
    font-size: .6rem;
    padding: 2px 6px;
    cursor: pointer;
    opacity: 0;
    transition: opacity .12s, color .12s;
  }
  .copy-btn:hover  { color: var(--accent2); }
  .copy-btn.copied { color: #6bcb77; opacity: 1; }

  #empty {
    display: none;
    padding: 60px 0;
    text-align: center;
    color: var(--muted);
    font-size: .85rem;
    grid-column: 1 / -1;
  }

  .size-btns { display: flex; gap: 4px; }
  .size-btn {
    background: transparent;
    border: 1px solid var(--border);
    border-radius: 4px;
    color: var(--muted);
    font-family: inherit;
    font-size: .7rem;
    padding: 4px 8px;
    cursor: pointer;
    transition: all .12s;
  }
  .size-btn:hover, .size-btn.active { border-color: var(--accent2); color: var(--accent2); }

  ::-webkit-scrollbar       { width: 6px; }
  ::-webkit-scrollbar-track { background: var(--bg); }
  ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }

  footer {
    padding: 20px 24px;
    font-size: .65rem;
    color: var(--muted);
    border-top: 1px solid var(--border);
    margin-top: 20px;
  }
  kbd {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 3px;
    padding: 1px 5px;
  }
</style>
</head>
<body>

<header>
  <div class="header-title">&#x25C8; Icon<span>Preview</span></div>

  <div class="search-wrap">
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
    </svg>
    <input id="search" type="text" placeholder="Search icons..." autocomplete="off" spellcheck="false">
  </div>

  <div class="filters">
    <button class="pill active" data-filter="all">all</button>
    <button class="pill" data-filter="folder">folders</button>
    <button class="pill" data-filter="file">files</button>
  </div>

  <div class="size-btns">
    <button class="size-btn"        data-size="90"  title="Small">S</button>
    <button class="size-btn active" data-size="120" title="Medium">M</button>
    <button class="size-btn"        data-size="160" title="Large">L</button>
  </div>
</header>

<div class="stats">
  <div>Source: <strong>$sourceDir</strong></div>
  <div>Total: <strong id="count-total">$totalCount</strong> &nbsp;&middot;&nbsp; Showing: <strong id="count-shown">$totalCount</strong></div>
  <div>Generated: <strong>$generatedAt</strong></div>
</div>

<main>
  <div id="grid">
    <div id="empty">No icons match your search.</div>
  </div>
</main>

<footer>
  Hover a card to reveal the copy button &nbsp;&middot;&nbsp;
  Press <kbd>/</kbd> to focus search &nbsp;&middot;&nbsp; <kbd>Esc</kbd> to clear
</footer>

<script>
$jsIconsArray

(function () {
  var grid        = document.getElementById('grid');
  var searchInput = document.getElementById('search');
  var emptyMsg    = document.getElementById('empty');
  var countTotal  = document.getElementById('count-total');
  var countShown  = document.getElementById('count-shown');
  var pills       = document.querySelectorAll('.pill');
  var sizeBtns    = document.querySelectorAll('.size-btn');

  var activeFilter = 'all';
  var searchTerm   = '';

  function buildCards() {
    var existing = grid.querySelectorAll('.card');
    for (var i = 0; i < existing.length; i++) {
      grid.removeChild(existing[i]);
    }

    var term = searchTerm.toLowerCase();

    var filtered = ICONS.filter(function (icon) {
      var matchSearch = !term || icon.name.toLowerCase().indexOf(term) !== -1;
      var matchFilter =
        activeFilter === 'all' ||
        (activeFilter === 'folder' && icon.name.indexOf('folder') === 0) ||
        (activeFilter === 'file'   && icon.name.indexOf('file')   === 0);
      return matchSearch && matchFilter;
    });

    countShown.textContent    = filtered.length;
    emptyMsg.style.display    = filtered.length === 0 ? 'block' : 'none';

    var frag = document.createDocumentFragment();

    for (var j = 0; j < filtered.length; j++) {
      var icon = filtered[j];

      var card = document.createElement('div');
      card.className = 'card';
      card.title     = icon.path || icon.name;

      // Split "folder/ flutter" into prefix + main name
      var slashIdx = icon.label.indexOf('/ ');
      var prefix   = slashIdx !== -1 ? icon.label.slice(0, slashIdx + 2) : '';
      var namePart = slashIdx !== -1 ? icon.label.slice(slashIdx + 2)    : icon.label;

      var iconWrap = document.createElement('div');
      iconWrap.className = 'icon-wrap';
      iconWrap.innerHTML = icon.svg;

      var labelDiv = document.createElement('div');
      labelDiv.className = 'card-label';

      if (prefix) {
        var prefixSpan = document.createElement('span');
        prefixSpan.className   = 'prefix';
        prefixSpan.textContent = prefix;
        labelDiv.appendChild(prefixSpan);
      }

      var nameSpan = document.createElement('span');
      nameSpan.className   = 'name';
      nameSpan.textContent = namePart;
      labelDiv.appendChild(nameSpan);

      var copyBtn = document.createElement('button');
      copyBtn.className   = 'copy-btn';
      copyBtn.title       = 'Copy filename';
      copyBtn.textContent = 'copy';

      // IIFE to capture icon.name per iteration
      (function (btn, iconName) {
        btn.addEventListener('click', function () {
          navigator.clipboard.writeText(iconName).then(function () {
            btn.textContent = 'copied!';
            btn.classList.add('copied');
            setTimeout(function () {
              btn.textContent = 'copy';
              btn.classList.remove('copied');
            }, 1200);
          });
        });
      }(copyBtn, namePart));

      card.appendChild(iconWrap);
      card.appendChild(labelDiv);
      card.appendChild(copyBtn);
      frag.appendChild(card);
    }

    grid.appendChild(frag);
  }

  searchInput.addEventListener('input', function () {
    searchTerm = searchInput.value;
    buildCards();
  });

  for (var p = 0; p < pills.length; p++) {
    (function (pill) {
      pill.addEventListener('click', function () {
        for (var k = 0; k < pills.length; k++) { pills[k].classList.remove('active'); }
        pill.classList.add('active');
        activeFilter = pill.getAttribute('data-filter');
        buildCards();
      });
    }(pills[p]));
  }

  for (var s = 0; s < sizeBtns.length; s++) {
    (function (btn) {
      btn.addEventListener('click', function () {
        for (var k = 0; k < sizeBtns.length; k++) { sizeBtns[k].classList.remove('active'); }
        btn.classList.add('active');
        document.documentElement.style.setProperty('--card-size', btn.getAttribute('data-size') + 'px');
      });
    }(sizeBtns[s]));
  }

  document.addEventListener('keydown', function (e) {
    if (e.key === '/' && document.activeElement !== searchInput) {
      e.preventDefault();
      searchInput.focus();
    }
    if (e.key === 'Escape') {
      searchInput.value = '';
      searchTerm = '';
      buildCards();
    }
  });

  countTotal.textContent = ICONS.length;
  buildCards();
}());
</script>
</body>
</html>
"@

# ── Write output ──────────────────────────────────────────────────────────────

$html | Set-Content -Path $OutputFile -Encoding UTF8 -NoNewline

$sizeKb = [math]::Round((Get-Item $OutputFile).Length / 1KB, 1)
Write-Host ""
Write-Host "Done!  $OutputFile  ($sizeKb KB)" -ForegroundColor Green
Write-Host "Open:  Invoke-Item '$OutputFile'"  -ForegroundColor DarkGray
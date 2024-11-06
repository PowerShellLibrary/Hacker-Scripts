$kmlPath = 'C:\big.kml'
$max = 240
$partsFolder = "$PSScriptRoot\parts"

[xml]$doc = Get-Content -Path $kmlPath
mkdir $partsFolder -ErrorAction SilentlyContinue | Out-Null
$i = 1
do {
    [xml]$clone = $doc.Clone()
    $clone.ChildNodes[0].Encoding = $null

    # remove everything except max number count (i.e 240, 480, 720)
    $clone.kml.Document.Folder.Placemark | Select-Object -Skip ($max * $i) | % {
        $clone.kml.Document.Folder.RemoveChild($_) | Out-Null
    }

    # buffering - selecting last max number count
    while ($clone.kml.Document.Folder.Placemark.Count -gt $max) {
        $clone.kml.Document.Folder.Placemark | Select-Object -First 1 | % {
            $clone.kml.Document.Folder.RemoveChild($_) | Out-Null
        }
    }

    $clone.Save("$partsFolder\_part2_$($i).kml")
    $i++
}
while ($max * $i -le $doc.kml.Document.Folder.Placemark.Count)
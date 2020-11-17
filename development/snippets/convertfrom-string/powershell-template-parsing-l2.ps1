$template = @'
    {Name*:Bearded Keltir}([int]{Level:1}) Bearded Keltir location on the map	{Type:Passive}	{[int]Low:8}-{High:12}	{Chance:70.00}%
    {Name*:Elpy}(1) Bearded Keltir location on the map	{Type:Agressive}	{[int]Low:8}-{High:1244}	{Chance:100.00}
'@
$testText = @'
    Bearded Keltir (1) Bearded Keltir location on the map	Passive	8-12	70.00%
    Elpy (1) Elpy location on the map	Passive	3-12	70.00%
    Gremlin (1) Gremlin location on the map	Passive	7-13	100.00%
    Grey Elpy (1) Grey Elpy location on the map	Aggresive	8-12	70.00%
    Young Brown Keltir (1) Young Brown Keltir location on the map	Passive	8-12	70.00%
    Young Grey Keltir (1) Young Grey Keltir location on the map	Passive	8-12	70.00%
    Young Keltir (1) Young Keltir location on the map	Passive	8-12	70.00%
    Young Prairie Keltir (1) Young Prairie Keltir location on the map	Passive	8-12	70.00%
    Young Red Keltir (1) Young Red Keltir location on the map	Passive	8-12	70.00%
    Brown Keltir (2) Brown Keltir location on the map	Passive	2-13	70.00%
    Grey Keltir (2) Grey Keltir location on the map	Passive	1-13	70.00%
'@

$testText | `
    ConvertFrom-String -TemplateContent $template |`
    ? { [int]$_.Level -lt 68 } | `
    Sort-Object -Property Low -Descending | Format-Table
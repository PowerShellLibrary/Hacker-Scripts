$system32 = $Env:windir + "\System32"
(Get-ChildItem $system32 -Filter *.msc).Name
$template = @'
    {[string]Name*:Phoebe Cat}, {[string]phone:425-123-6789}, {[int]age:6}
    {[string]Name*:Lucky}, {[string]phone:(206) 987-4321}, {[int]age:12}
'@

$testText = @'
    Phoebe Cat, 425-123-6789, 6
    Lucky Shot, (206) 987-4321, 12
    Elephant Wise, 425-888-7766, 87
    Wild Shrimp, (111)  222-3333, 1
'@

$testText | ConvertFrom-String -TemplateContent $template
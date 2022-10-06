# This is an example how to use Excel application using PowerShell (see \.test folder)
#
#   Documentation
# - https://docs.microsoft.com/en-us/office/vba/api/excel.worksheet.saveas
# - https://docs.microsoft.com/en-us/office/vba/api/excel.worksheet.range
# - https://docs.microsoft.com/en-us/office/vba/api/excel.range.copy
# - https://docs.microsoft.com/en-us/office/vba/api/excel.sheets.select

# test file
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$excelFile = "$scriptPath\..\.test\excel.xlsx"

# open Excel application
$Excel = New-Object -ComObject Excel.Application
# set visibility - show/hide window (background)
$Excel.Visible = $true
# open file
$wb = $Excel.Workbooks.Open($excelFile)

# add new sheet
$ns = $wb.Worksheets.Add()
# give it a name
$ns.Name = "test"

# select newly created empty sheet by index
$wsEmpty = $wb.Worksheets.Item(1)
$wsEmpty.Activate()
# select cells (desitnation for copy action) - specify region
$dst = $wsEmpty.Range("A1:B2")
# select cells (desitnation for copy action) - invoke selection
$dst.select() | Out-Null

# switch to data sheet
$wsData = $wb.Worksheets.Item(2)
$wsData.Activate()
# find index (when number of rows is different)
$maxIndex = 6..38 | ? { $wsData.Cells.Item($_, 1).Value2 -eq $null } | Measure-Object -Minimum | % { $_.Minimum - 1 }
$max = "K$maxIndex"
# specify region for copy operation
$data = $wsData.Range("A4:$max")

# select region
$data.select() | Out-Null
# copy to destination (empty)
$data.copy($dst) | Out-Null

# switch to new/empty sheet
$wsEmpty.Activate()
# remove first row two times (i.e. column descriptors). For columns removal use '$wsEmpty.Columns(3).Delete()'
1..2 | % { $wsEmpty.Rows(1).Delete() | Out-Null }

# save file as csv
$wsEmpty.SaveAs("$scriptPath\..\.test\excel.csv", 6)
# close excel application
$Excel.Quit()
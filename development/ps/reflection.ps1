# constructor
$constructorInfo = [System.IO.FileInfo].GetConstructor([string].AsType())
$constructorInfo = [System.IO.FileInfo].GetConstructor("public,instance", $types)
$constructorInfo.Invoke('C:\Windows')

# private field
$obj = [System.IO.FileInfo]::new('C:\Windows')
$field = [System.IO.FileInfo].GetField("_name", "nonpublic,instance")
# longer version
$field = [System.IO.FileInfo].GetField("_name", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
$field.GetValue($obj)

# private method - static
$obj = $null
$privMethod = [System.DateTime].GetMember("DateToTicks", "nonpublic,static")
$privMethod.Invoke($obj, @(2023, 10, 10))

# private method - instance
$obj = [System.DateTime]::Now
$privMethod = [System.DateTime].GetMember("GetDatePart", "nonpublic,instance")
$privMethod.Invoke($obj, @(0))

# private method - args requirements
$privMethod = [System.DateTime].GetMethod("DateToTicks", "nonpublic,static", $null, @([int], [int], [int]), @())
$privMethod.Invoke($obj, @(2023, 10, 10))
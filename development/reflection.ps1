# get field value form private static field
$info = $type.GetField("_controlSources", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
$info.GetValue($null);

# get private field value form object $single
$info = $type.GetField("m_cache", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
$info.GetValue($single);
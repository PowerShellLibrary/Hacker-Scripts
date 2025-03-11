# Workaround to call to a generic method OfType<T>() in PowerShell, when PowerShell cannot figure out <T> from the context

# Method 1 - using OfType<T> method
[System.Linq.Enumerable]::OfType[int](@(1, 2, 'a'))

# Method 2 - using reflection
$method = [System.Linq.Enumerable].GetMethod('OfType')
$genericMethod = $method.MakeGenericMethod([int])
$genericMethod.Invoke($null, @(, @(1, 2, 'a')))

# Example of using Distinct method
[System.Linq.Enumerable]::Distinct([int[]]@(1, 2, 3, 1, 2))
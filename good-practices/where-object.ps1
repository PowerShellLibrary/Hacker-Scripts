# BAD
$array = @(1, 2, 3, 1, 3, 4) | Where-Object { $_ -eq 1 }

# GOOD - x17 faster
$array = @(
    foreach ($i in @(1, 2, 3, 1, 3, 4)) {
        if ($i -eq 1) {
            $i
        }
    }
)
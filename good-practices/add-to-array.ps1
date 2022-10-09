# Adding to an array with += is much slower:

$list = @()
Measure-Command {
    foreach ($number in $(1..10000)) {
        $list += $number
    }
}

# than capturing the output of the loop directly:

Measure-Command {
    $list = foreach ($number in $(1..10000)) {
        $number
    }
}


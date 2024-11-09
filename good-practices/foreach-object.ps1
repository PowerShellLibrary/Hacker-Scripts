# BAD
@(1, 2, 3) | Foreach-Object {
    # do stuff
}

# GOOD - 2x faster
foreach ($i in @(1, 2, 3)) {
    # do stuff
}
git rev-list --objects --all |
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
  sed -n 's/^blob //p' |
  awk '$2 >= 2^20' |
  sort --numeric-sort --key=2 |
  cut -c 1-12,41- |
  $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest

# example output
# 22c19f287836  1.0MiB images/posts/1.gif
# 0e15a02b835a  1.2MiB images/posts/2.gif
# f48d3086bf1d  1.5MiB images/posts/3.gif
# eecf2e1d46a7  1.6MiB images/posts/4.gif
# a267f286e7f2  1.7MiB images/posts/5.gif
# 225cba92676b  3.4MiB images/posts/6.gif

# to find commits with SHA use
# git log --raw --all --find-object=225cba92676b

# to find all files with given extension
# git log --all --full-history -- *.gif
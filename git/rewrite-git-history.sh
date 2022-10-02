# usage
#1. create run.sh
#2. paste content
#3. open bash
#4. run 'bash run'

#!/bin/sh
git filter-branch --env-filter '
OLD_EMAIL="incorrect@gmail.com"
CORRECT_NAME="Alan NULL"
CORRECT_EMAIL="alan-null@outlook.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
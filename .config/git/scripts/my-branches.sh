#!/usr/bin/env bash
 
# Colors matching git branch -a output
RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'
 
ME=$(git config user.email)
CURRENT=$(git symbolic-ref --short HEAD 2>/dev/null)
 
# Local branches authored by me, sorted descending by committer date
LOCAL=$(git for-each-ref --sort=-committerdate refs/heads/ \
  --format='%(refname:short) %(authoremail)' \
  | awk -v me="<$ME>" '$2 == me { print $1 }')
 
# Remote branches authored by me, sorted descending by committer date
REMOTE=$(git for-each-ref --sort=-committerdate refs/remotes/ \
  --format='%(refname:short) %(authoremail)' \
  | awk -v me="<$ME>" '$2 == me { print $1 }')
 
# Print local branches
while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  if [[ "$branch" == "$CURRENT" ]]; then
    echo -e "${GREEN}* $branch${RESET}"
  else
    echo "  $branch"
  fi
done <<< "$LOCAL"
 
# Print remote branches
while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  echo -e "  ${RED}$branch${RESET}"
done <<< "$REMOTE"

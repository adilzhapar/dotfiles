#!/bin/bash

set -e

file_pattern=$1

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'


function main {
    for rev in `revisions`; do
        echo -e "${BLUE}`number_of_lines` ${CYAN}`commit_description`"
    done
}

function revisions {
	git rev-list HEAD | head -n 20
}

function number_of_lines {
	#git ls-tree -r $rev |
	#grep "$file_pattern" | 
	#awk '{print $3}' | # text-processing tool that reads input line by line and lets you filter, transform
	#xargs git show  | # executes commands from standard input
	#wc -l # words count -lines
	local pattern=${file_pattern:-.}
    	git diff $rev^ $rev -- "$pattern" | wc -l


}



function commit_description {
	git log --oneline -1 $rev
}

main

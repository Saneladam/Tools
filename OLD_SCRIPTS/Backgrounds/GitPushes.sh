#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Mon 22. Dec 2025
#
# Purpose:      Automatices the git pushes on certain directories to have a 
#               backup. 
# =============================================================================

commit_date="$(date)"
commit_string="Automtic Commit on ${commit_date}"

git_push() {
    local Directory="$1"
    cd "$Directory" || { echo "Cannot cd into $dir"; return; }
    git pull 
    git add .
    git commit -m "$commit_string" || echo "No changes to commit in $Directory"
    git push
}

DIRECTORIES=(
"$HOME/Lecture"
"$HOME/Scripts"
"$HOME/.config/dotfiles"
"$HOME/Documents/MasterThesis"
"$HOME/Documents/Notes"
"$HOME/Documents/Solar"
)

for dir in "${DIRECTORIES[@]}"; do
    git_push "$dir"
done


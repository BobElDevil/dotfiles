alias gitoneline="git log --graph --decorate --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitonelineall="git log --graph --decorate --branches --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitpretty="git log --graph --decorate --name-status"
alias gitprettyall="git log --graph --decorate --name-status --all"
alias gitreset="git reset HEAD\^" # convenience function to go back one commit
alias gitpush="git push -u origin HEAD"

readonly WIP_MSG="WIP DO NOT COMMIT"

function gitwip() {
  prevMsg=`git show -s --format=%s`
  if [ "$prevMsg" = "$WIP_MSG" ]; then
    echo "Amending previous commit..."
    git commit -a --amend --no-edit --no-verify
  else
    echo "Creating wip commit"
    git commit -a -m "$WIP_MSG" --no-verify
  fi
}


function gitbootstrap() {
     # remove any stale temp branch if needed
     git branch -D updatebases_temp &>/dev/null || true
     # checkout a temporary branch in case we're currently on main
     git checkout -b updatebases_temp
     git fetch --all
     echo "Updating main..."
     git show-ref --verify --quiet "refs/remotes/origin/main"
     if [ $? -ne 0 ]; then
       echo "Remote branch not found for 'main'"
       return
     fi

     # verify it can be fast forwarded
     git merge-base --is-ancestor "main" "origin/main"
     if [ $? -ne 0 ]; then
       echo "main cannot be fast-forwarded to origin/main, you'll need to manually update your branch"
     else
       # Change the branch ref to point to the new one
       echo "Updating 'main' to 'origin/main'"
       git update-ref "refs/heads/main" "origin/main"
     fi

     echo "Checking out main"
     git checkout main 
     git branch -D updatebases_temp

     echo "Syncing aviator stacks"
     av sync --push="no" --all --prune="yes"
     if [ $? -ne 0 ]; then
       echo "Aviator sync failed, bailing out so you can resolve"
       return
     fi

     gitcleanup
}

function gitcleanup() { 
    echo "=== Cleaning Local Branches ========="
    except_branches=('"\*"' '"\+"' '" main$"')
    command="git branch --merged"
    for branch in $except_branches; do
        command="$command | grep -v $branch"
    done
    command="$command | xargs -n 1 git branch -d"
    eval $command

    echo "=== Cleaning Local Branches With Empty Merges ==="
    command="git branch"
    for branch in $except_branches; do
        command="$command | grep -v $branch"
    done
    localBranches=(`eval $command`)
    for branch in $localBranches; do
        mergeBase=`git merge-base HEAD $branch`
        git merge-tree "$mergeBase" HEAD "$branch" | grep -v "changed in both" | grep -v "  base" | grep -v "  our" | grep -v "  their" | read
        if [ $? -ne 0 ]; then
            git branch -D $branch
        fi
    done

    echo "Tidying aviator stacks"
    av tidy

    echo "=== Remaining Branches =============="
    git branch
}

function gitmergebase() {
    branchName=$1
    if [ -z "$branchName" ]; then
        echo "Error: Need to specify a branch to check against"
        return
    fi
    echo "=== Merge Base With '$branchName' ==="
    mergeBase=`git merge-base HEAD $branchName`
    git merge-tree "$mergeBase" HEAD "$branchName"
}


function gitnewbranch() {
    branchName=$1
    if [ -z "$branchName" ]; then
        echo "Error: Need to specify a branch name"
        return
    fi

    av branch --parent main "$1"
}
    

alias gitoneline="git log --graph --decorate --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitonelineall="git log --graph --decorate --all --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitpretty="git log --graph --decorate --name-status"
alias gitprettyall="git log --graph --decorate --name-status --all"
alias gitreset="git reset HEAD\^" # convenience function to go back one commit
alias gitpush="git push -u origin HEAD"
alias gitwip="git commit --no-verify -a -m 'WIP DO NOT COMMIT'"

function gitbootstrap() {
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
     git sync --trunk --no-push --all --prune

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

    git stackbranch  --parent main "$1"
}
    

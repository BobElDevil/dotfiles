alias gitoneline="git log --graph --decorate --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitonelineall="git log --graph --decorate --all --pretty=format:\"%C(auto)%h%d %Cblue%an%Creset: %C(auto)%s\""
alias gitpretty="git log --graph --decorate --name-status"
alias gitprettyall="git log --graph --decorate --name-status --all"
alias gitreset="git reset HEAD\^" # convenience function to go back one commit
alias gitpush="git push -u origin HEAD"
alias gitwip="git commit --no-verify -a -m 'WIP DO NOT COMMIT'"
alias cdroot="cd $(git root)"

# Todo Make these legit 'aliases', with inline shell scripts
function gitmergecommit() { git log $1..HEAD --ancestry-path --merges --reverse }
function gitmerged() { git branch --merged $@ | sed -e '/^*/d' | sed -e '/^+/d' }
function gitshowsvn() { git show `git svn find-rev r$1` }
function gitsvnrebase() {
    if [[ $1 != "-l" ]]; then
        git svn fetch;
    fi
    git for-each-ref --shell --format='git co %(refname:short); git svn rebase -l;' refs/heads | \
        while read entry
        do
            eval "$entry"
        done
}

function gitupdatebases() {
     git fetch --all
     basis_branches=($(git for-each-ref --format='%(refname:short)' refs/heads/))
     # checkout a temporary branch in case we're currently on a basis branch
     git checkout -b updatebases_temp
     for branch in $basis_branches; do
         echo "Checking $branch"
         # verify it exists
         git show-ref --verify --quiet "refs/remotes/origin/$branch"
         if [ $? -ne 0 ]; then
             echo "Remote branch not found for '$branch'"
             continue
         fi
 
         # verify it can be fast forwarded
         git merge-base --is-ancestor "$branch" origin/"$branch"
         if [ $? -ne 0 ]; then
             echo "$branch cannot be fast-forwarded to origin/$branch, you'll need to manually update your branch"
             continue
         fi
 
         # Change the branch ref to point to the new one
         echo "Updating '$branch' to 'origin/$branch'"
         git update-ref refs/heads/"$branch" origin/"$branch"
     done

     # TODO: Be fancy and lookup the worktrees in 'refs/worktrees', and create a special branch for each one
     ## Unconditionally set the worktree branch to the latest main
     #git show-ref --verify --quiet refs/heads/worktree
     #if [ $? -ne 0 ]; then
     #  echo "Creating worktree branch off of origin/main"
     #  git branch worktree origin/main
     #else
     #  echo "Updating 'worktree' to 'origin/main'"
     #  git update-ref refs/heads/worktree origin/main
     #fi

     git checkout -
     git branch -d updatebases_temp

    if [ "$#" -gt 0 ]; then
        echo "Running git rebase $@"
        git rebase "$@"
    fi
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


function gitcopybranch() {
    nameRef=$(git name-rev HEAD --name-only)
    echo "Copied '$nameRef' to pasteboard!"
    echo -n "$nameRef" | pbcopy
}

function gitbootstrap() {
    gitupdatebases
    git co main
    gitcleanup
    if [ -n "$1" ]; then
        git co -b "$1"
    fi
} 

function gitnewbranch() {
    branchName=$1
    if [ -z "$branchName" ]; then
        echo "Error: Need to specify a branch name"
        return
    fi
  
    git co -b "$1" main
}
    

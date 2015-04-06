1. Use [git stash](http://www.kernel.org/pub/software/scm/git/docs/git-stash.html) to save your changes and get back to clean working copy.

2. Enable [git rerere](http://www.kernel.org/pub/software/scm/git/docs/git-rerere.html) to ease your merges.

3. Put an empty .keepme file into an empty directory you want to commit to git.

4. If you need a decent mergetool, use p4merge or diffmerge. See [here](http://blog.logicalrand.com/2008/9/9/use-p4merge-or-diffmerge-with-git-mergetool-on-os-x).

5. After hard rebase it is useful to check diffs to non-rebased version -- so you see if you messed up the rebase. If you did not create a backup branch before rebase, you may find old branch in history: `git log <branch-name>@{N}`. `<branch-name>@{0}` is the current branch. You may also insert date/time queries, like `<branch-name>@{"yesterday"}`. Also using `ORIG_HEAD` instead of branch name may help.
# How to merge contributed branch to master

## 1. Please check that the branch is in the good shape

```
  $ git fetch origin
  $ gitk origin/<branch-name>
```

Rewriting master's history is not an option on a public project, so you would have only one shot.

## 2. Update your master

```
  $ git fetch origin
  $ git checkout master

  # OUCH! Be careful with the next line, you would lose any changes to master
  # Uncommitted changes are lost permanently
  # (use git stash to save them and to get clean working copy)
  # Committed changes may be restored (git help reflog), but it is not pleasant.

  $ git reset --hard origin/master
```

Note: `git merge origin/master` would do instead. But the hard reset
ensures you did not do any work in the master branch.

## 3. Merge branch to master

### Canonical way

```
  $ git checkout <branch-name>
  $ git rebase master # so it would be merged without conflicts

  # WARNING: The next line changes published history of the branch
  $ git push origin +<branch-name> # update branch in main repo to current state

  $ git checkout master
  $ git merge <branch-name>
```

### Shortcut

If you're sure all would be fine, you may use a shortcut:

```
  $ git checkout master

  # If next line brings unresolved conflicts,
  # it is *cleaner* to start from scratch (reset master again)
  # and to go on explicit process.
  # Though no big harm in resolving conflict and continuing.
  $ git merge <branch-name>
```

## 4. Push master back to origin

```
  $ git push origin master
```

# See also

  * LuaAlchemyDevelopmentModel
  * CodingGuidelines
  * ContributorsGitWorkflow
  * GitTipsAndTricks
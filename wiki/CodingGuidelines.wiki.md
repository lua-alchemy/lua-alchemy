# Whitespaces

Following these rules would lead to less conflicts on merge:

1. Use spaces, no tabs.

Perferably two spaces per indent. **Never** mix tabs with spaces in indentation on single line.

2. Use Unix line endings (LF), not Windows (CRLF).

**Never** mix different line endings in a file.

It is recommended to configure related Git options as follows:

```
  $ git config core.autocrlf input 
  $ git config core.safecrlf auto
```

See [git config docs](http://www.kernel.org/pub/software/scm/git/docs/git-config.html) for motivation.

3. Do trim trailing spaces on save.

If you're on Eclipse, [AnyEdit tools plugin](http://andrei.gmxhome.de/anyedit/) could be helpful.

# Git usage

When committing code to Git, you're encouraged to follow these guidelines:

1. Commit message **must** begin with a single short (less than 50 character) line summarizing the change, optionally followed by a blank line and then a more thorough description.

2. Avoid committing broken code. It greatly simplifies work with bug searching tools like `git bisect`.

3. Make smaller commits, it really helps with merging.
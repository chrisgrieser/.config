# Completions for zsh

## Get completions from `--help` files

```bash
# example
compdef _gnu_generic fzf
```

Source: <https://github.com/junegunn/fzf/issues/3349#issuecomment-1619425209>

## Make a command inherit the completions of another command

```bash
function my_func {
	echo "Hello world."
}
compdef _grep my_func
```

Aliases use the completions as if they are expanded

```bash
alias gd='git diff'
# `gd` automatically uses completions as if it was `git diff`
```

### Inherit completions from a git sub-command
There are completion functions such as `_git-log`, but those
are stored in `_git` and are as such only available after `_git` was used at
least once. Thus, this one will not work:

```bash
function gl {
	git log …
}
compdef _git-log gl
```

The solution is to add a file `_gl` to `$FPATH`, since files in `$FPATH` do are
able to use functions from other completions files. (Note that the `#compdef
cmd-name` at the top is required.)

```bash
#compdef gl
_git-log
```

## Search for completion files
- [zsh-completions](https://github.com/zsh-users/zsh-completions/tree/master/src)
  (However, many of those are already included in zsh by default.)
- Code search on GitHub, e.g.,
  `https://github.com/search?q=path%3A%2F_pdfgrep%24%2F&type=code`.

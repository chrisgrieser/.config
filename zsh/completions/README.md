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

function log {
	git log --oneline
}
compdef _git-log log
```

Aliases use the completions as if they are expanded

```bash
alias gd='git diff'
# `gd` automatically uses completions as if it was `git diff`
```

## Repository of zsh completion files
<https://github.com/zsh-users/zsh-completions/tree/master/src>

However, many of those are already included in zsh by default, apparently.

## Code search via GitHub
Search for something like, such as <https://github.com/search?q=path%3A%2F_pdfgrep%24%2F&type=code>

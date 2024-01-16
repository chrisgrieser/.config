# GUARD
# don't show the intro messages on terminals with lower height (e.g. embedded ones)
[[ $LINES -gt 20 ]] || return 0
#───────────────────────────────────────────────────────────────────────────────

_separator
fortune -n270 -s
_separator
echo
_magic_dashboard

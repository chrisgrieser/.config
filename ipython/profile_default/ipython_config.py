# Configuration file for ipython.
c = get_config()  # noqa # type: ignore

# ──────────────────────────────────────────────────────────────────────────────

c.TerminalInteractiveShell.confirm_exit = False
c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.separate_in = ""  # no linebreak after output

# enable vi mode
c.InteractiveShell.editing_mode = "vi"  
# FIX <Esc> taking too ling to get to normal mode https://github.com/ipython/ipython/issues/13443
c.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False

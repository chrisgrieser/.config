# Configuration file for ipython.

c = get_config()  # noqa # type: ignore

c.TerminalInteractiveShell.confirm_exit = False
c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.separate_in = ''  # no linebreak after output

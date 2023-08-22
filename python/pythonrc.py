# disabline writing `.python-history` file https://unix.stackexchange.com/a/297834
import readline
readline.write_history_file = lambda *args: None

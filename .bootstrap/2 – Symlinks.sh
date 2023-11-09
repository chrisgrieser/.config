# CREATE SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
ln -sf "$HOME/.config/zsh/.zshenv" ~

# Espanso
espanso_dir="$HOME/Library/Application Support/espanso"
[[ -e "$espanso_dir" ]] && rm -rf "$espanso_dir"
ln -sf "$HOME/.config/espanso/" "$espanso_dir"

# Browser PWAs
[[ -e ~"/Applications/$BROWSER_APP Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER_APP Apps.localized"
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER_APP Apps.localized/" ~"/Applications/$BROWSER_APP Apps.localized"

# Jupyter Lab
# HACK since `JUPYTERLAB_SETTINGS_DIR` not working…
jupyter_dir="$HOME/Library/Application Support/jupyterlab-desktop/lab/user-settings"
[[ -e "$jupyter_dir" ]] && rm -rf "$jupyter_dir"
ln -sf "$HOME/.config/jupyter/lab/user-settings" "$jupyter_dir"

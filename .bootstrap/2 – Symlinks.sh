# CREATE SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
ln -sf "$HOME/.config/zsh/.zshenv" ~

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$HOME/.config/espanso/" "$ESPANSO_DIR"

# Browser PWAs
[[ -e ~"/Applications/$BROWSER_APP Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER_APP Apps.localized"
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER_APP Apps.localized/" ~"/Applications/$BROWSER_APP Apps.localized"

# Jupyter Lab
# HACK since `JUPYTERLAB_SETTINGS_DIR` not working…
ln -sf "$HOME/.config/jupyter/lab/user-settings" \
	"$HOME/Library/Application Support/jupyterlab-desktop/lab/user-settings"

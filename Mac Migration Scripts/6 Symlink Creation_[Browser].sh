cd ~/Desktop || return 1

# -------------------

DOTFILE_FOLDER=~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/"
[[ -e ~/.zshrc ]] && rm -rf ~/.zshrc
ln -sf "$DOTFILE_FOLDER/zsh/.zshrc" ~
[[ -e ~/.zprofile ]] && rm -rf ~/.zprofile
ln -sf "$DOTFILE_FOLDER/zsh/.zprofile" ~
[[ -e ~/.zsh_history ]] && rm -rf ~/.zsh_history
ln -sf "$DOTFILE_FOLDER/zsh/.zsh_history" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zlogin" ~

ln -sf "$DOTFILE_FOLDER/.searchlink" ~
ln -sf "$DOTFILE_FOLDER/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/.stylelintrc.json" ~
ln -sf "$DOTFILE_FOLDER/.gitconfig" ~
ln -sf "$DOTFILE_FOLDER/.eslintrc.json" ~
ln -sf "$DOTFILE_FOLDER/.gitignore_global" ~
ln -sf "$DOTFILE_FOLDER/pandoc" ~/.pandoc
ln -sf "$DOTFILE_FOLDER/.markdownlintrc" ~

ln -sf "$DOTFILE_FOLDER/.pylintrc" ~
ln -sf "$DOTFILE_FOLDER/.flake8" ~
ln -sf "$DOTFILE_FOLDER/.vimrc" ~

# .config
[[ -e ~/.config ]] && rm -rf ~/.config
ln -sf "$DOTFILE_FOLDER/.config/" ~/.config

# Hammerspoon
[[ -e ~/.hammerspoon ]] && rm -rf ~/.hammerspoon
ln -sf "$DOTFILE_FOLDER/hammerspoon" ~/.hammerspoon

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# Sublime
SUBLIME_USER_DIR=~"/Library/Application Support/Sublime Text/Packages/User"
[[ -e "$SUBLIME_USER_DIR" ]] && rm -rf "$SUBLIME_USER_DIR"
ln -sf "$DOTFILE_FOLDER/Sublime User Folder/" "$SUBLIME_USER_DIR"
rm -rf ~"/Library/Application Support/Sublime Text/Installed Packages/CSS3.sublime-package"
ln -sf "$DOTFILE_FOLDER/Sublime Packages/CSS3.sublime-package" ~"/Library/Application Support/Sublime Text/Installed Packages"

# -------------------
# Special Cases
# -------------------
# Obsidian vimrc
OBSI_ICLOUD=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/'
ln -sf "$DOTFILE_FOLDER/obsidian.vimrc" "$OBSI_ICLOUD/Main Vault/Meta"
ln -sf "$DOTFILE_FOLDER/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Main Vault/Meta"
ln -sf "$DOTFILE_FOLDER/obsidian.vimrc" "$OBSI_ICLOUD/Development/Meta"
ln -sf "$DOTFILE_FOLDER/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/pandoc/README.md" "$OBSI_ICLOUD/Main Vault/Knowledge Base/Pandoc.md"

# Brave
BROWSER="Brave Browser"
rm -rf ~"/Applications/$BROWSER Apps.localized"
ln -sf "$DOTFILE_FOLDER/../$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

# VLC
rm -rf ~"/Library/Preferences/org.videolan.vlc/vlcrc"
mkdir -p ~"/Library/Preferences/org.videolan.vlc/"
ln -sf "$DOTFILE_FOLDER/vlcrc" ~"/Library/Preferences/org.videolan.vlc/vlcrc"


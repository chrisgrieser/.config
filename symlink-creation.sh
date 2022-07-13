# create all symlinks in the appropriate locations for everything
#-------------------------------------------------------------------------------
DOTFILE_FOLDER="$(dirname "$0")"

# zsh
[[ -e ~/.zshrc ]] && rm -rf ~/.zshrc
ln -sf "$DOTFILE_FOLDER/zsh/.zshrc" ~
[[ -e ~/.zprofile ]] && rm -rf ~/.zprofile
ln -sf "$DOTFILE_FOLDER/zsh/.zprofile" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zlogin" ~

# other dotfiles
ln -sf "$DOTFILE_FOLDER/.searchlink" ~
ln -sf "$DOTFILE_FOLDER/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/.stylelintrc.json" ~
ln -sf "$DOTFILE_FOLDER/.gitconfig" ~
ln -sf "$DOTFILE_FOLDER/.eslintrc.json" ~
ln -sf "$DOTFILE_FOLDER/.gitignore_global" ~
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc
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

# Brave
BROWSER="Brave Browser"
rm -rf ~"/Applications/$BROWSER Apps.localized"
ln -sf "$DOTFILE_FOLDER/../$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

#-------------------------------------------------------------------------------
# already set up, no need to run again.
# Only left here for reference, or when dotfile folder location changes
#-------------------------------------------------------------------------------

# to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/private dotfiles/private.lua" "$DOTFILE_FOLDER/hammerspoon/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/private dotfiles/private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"

# Obsidian vimrc
# OBSI_ICLOUD=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/'
# ln -sf "$DOTFILE_FOLDER/obsidian.vimrc" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian.vimrc" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/pandoc/README.md" "$OBSI_ICLOUD/Main Vault/Knowledge Base/Pandoc.md"

# YAMLlint
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/.config/karabiner/assets/complex_modifications"
ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/config/"
ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/match/"

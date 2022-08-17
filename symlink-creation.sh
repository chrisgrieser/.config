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
ln -sf "$DOTFILE_FOLDER/.vimrc" ~
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc

# linter rcfiles
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.stylelintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.eslintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.markdownlintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.pylintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.flake8" ~

# .config
[[ -e ~/.config ]] && rm -rf ~/.config
ln -sf "$DOTFILE_FOLDER/.config/" ~/.config

# Hammerspoon
[[ -e ~/.hammerspoon ]] && rm -rf ~/.hammerspoon
ln -sf "$DOTFILE_FOLDER/hammerspoon" ~/.hammerspoon

# Marta
ln -sf /Applications/Marta.app/Contents/Resources/launcher /opt/homebrew/bin/marta
[[ -e ~"/Library/Application Support/org.yanex.marta" ]] && rm -rf ~"/Library/Application Support/org.yanex.marta"
ln -sf ~"/dotfiles/Marta" ~"/Library/Application Support/org.yanex.marta"

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
[[ -e "$ESPANSO_DIR" ]] && rm -rf "$ESPANSO_DIR"
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# Sublime
SUBLIME_USER_DIR=~"/Library/Application Support/Sublime Text/Packages/User"
[[ -e "$SUBLIME_USER_DIR" ]] && rm -rf "$SUBLIME_USER_DIR"
ln -sf "$DOTFILE_FOLDER/Sublime User Folder/" "$SUBLIME_USER_DIR"
[[ -e ~"/Library/Application Support/Sublime Text/Installed Packages/CSS3.sublime-package" ]] && rm -rf ~"/Library/Application Support/Sublime Text/Installed Packages/CSS3.sublime-package"
ln -sf "$DOTFILE_FOLDER/Sublime Packages/CSS3.sublime-package" ~"/Library/Application Support/Sublime Text/Installed Packages"

# Brave
BROWSER="Brave Browser"
[[ -e ~"/Applications/$BROWSER Apps.localized" ]] && rm -rf ~"/Applications/$BROWSER Apps.localized"
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

# Übersicht
# [[ -e ~"/Library/Application Support/Übersicht/widgets/" ]] && rm -rf ~"/Library/Application Support/Übersicht/widgets/"
# ln -sf "$DOTFILE_FOLDER/ubersicht" ~"/Library/Application Support/Übersicht/widgets"

#-------------------------------------------------------------------------------
# already set up, no need to run again.
# Only left here for reference, or when dotfile folder location changes
#-------------------------------------------------------------------------------

# # to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/hammerspoon-private.lua" "$DOTFILE_FOLDER/hammerspoon/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/espanso-private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify-tui-client.yml" "$DOTFILE_FOLDER/.config/spotify-tui/client.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify_token_cache.json" "$DOTFILE_FOLDER/.config/spotify-tui/.spotify_token_cache.json"

# Obsidian vimrc
# OBSI_ICLOUD=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/'
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/pandoc/README.md" "$OBSI_ICLOUD/Main Vault/Knowledge Base/Pandoc.md"

# YAMLlint
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/.config/karabiner/assets/complex_modifications"
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/config/"
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/match/"

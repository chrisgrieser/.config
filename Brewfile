# DOCS https://docs.brew.sh/Brew-Bundle-and-Brewfile
#───────────────────────────────────────────────────────────────────────────────

# FORMULAE
brew "bat"
brew "eza"
brew "felixkratz/formulae/sketchybar"
brew "fzf"
brew "gh"
brew "git-delta"
brew "just"
brew "less"
brew "mas"
brew "neovim"
brew "node"
brew "pandoc"
brew "pass"
brew "pinentry-mac"
brew "ripgrep"
brew "starship"
brew "yq"
brew "zsh-autocomplete"
brew "zsh-autopair"
brew "zsh-autosuggestions"
brew "zsh-history-substring-search"
brew "zsh-syntax-highlighting"

# CASKS
cask "alfred"
cask "alt-tab"
cask "appcleaner"
cask "brave-browser"
cask "espanso"
cask "font-jetbrains-mono-nerd-font"
cask "hammerspoon"
cask "karabiner-elements"
cask "microsoft-word"
cask "mimestream"
cask "neovide"
cask "obsidian", greedy: true
cask "replacicon"
cask "slack"
cask "wezterm"
cask "zoom"

# MAC APP STORE
mas "Folder Preview", id: 6698876601
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274

# BUG Peek not available anymore? https://apps.apple.com/us/app/peek-a-quick-look-extension/id1554235898?mt=12
# mas "Peek", id: 1554235898
brew "syntax-highlight"

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
if system("scutil --get ComputerName | grep -q Home")
	brew "spotify_player"
	brew "yt-dlp"
	cask "anki"
	cask "bettertouchtool"
	cask "catch"
	cask "cleanshot"
	cask "iina"
	cask "steam"
	cask "transmission"
elsif system("scutil --get ComputerName | grep -q Office")
	cask "cleanshot"
elsif system("scutil --get ComputerName | grep -q Mother")
	cask "iina"
	cask "steam"
	cask "transmission"
end

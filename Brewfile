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
brew "yt-dlp"
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
mas "Peek", id: 1554235898

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
if system("scutil --get ComputerName | grep Home")
	 cask "anki"
	 cask "bettertouchtool"
	 cask "catch"
	 brew "spotify_player"
	 cask "iina"
	 cask "steam"
	 cask "transmission"
	 cask "cleanshot"
elsif system("scutil --get ComputerName | grep Office")
	 cask "cleanshot"
elsif system("scutil --get ComputerName | grep Mother")
	 cask "iina"
	 cask "steam"
	 cask "transmission"
end

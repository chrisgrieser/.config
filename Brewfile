# DOCS https://docs.brew.sh/Brew-Bundle-and-Brewfile
#───────────────────────────────────────────────────────────────────────────────

brew "bat"
brew "eza"
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
brew "felixkratz/formulae/sketchybar", restart_service: true

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

mas "Folder Preview", id: 6698876601
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274
mas "Peek", id: 1554235898

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
if system("scutil --get ComputerName | grep -q 'Home'")
  cask "anki"
  cask "bettertouchtool"
  cask "catch"
  brew "spotify_player"
  cask "iina"
  cask "steam"
	cask "transmission"
	cask "cleanshot"
elsif system("scutil --get ComputerName | grep -q 'Office'")
	cask "cleanshot"
elsif system("scutil --get ComputerName | grep -q 'Mother'")
	cask "iina"
	cask "steam"
	cask "transmission"
end

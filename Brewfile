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

cask "syntax-highlight" # Peek not available anymore? https://apps.apple.com/us/app/peek-a-quick-look-extension/id1554235898?mt=12
cask "qlmarkdown"

# CASKS
cask "alfred"
cask "alt-tab"
cask "appcleaner"
cask "brave-browser"
cask "espanso"
cask "font-jetbrains-mono-nerd-font"
cask "hammerspoon", postinstall: "defaults write org.hammerspoon.Hammerspoon MJConfigFile \"$HOME/.config/hammerspoon/init.lua\""
cask "karabiner-elements"
cask "microsoft-word"
cask "mimestream"
cask "neovide"
cask "obsidian", greedy: true # greedy for installer version
cask "replacicon"
cask "slack"
cask "wezterm"
cask "zoom"
cask "sioyek"

# MAC APP STORE
brew "mas"
mas "Folder Preview", id: 6698876601
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS

computer_name = `scutil --get ComputerName`

if computer_name.include?("Home")
	brew "spotify_player"
	brew "yt-dlp"
	cask "bettertouchtool"
	cask "catch"
	cask "cleanshot"
	cask "iina"
	cask "steam"
	cask "transmission"
elsif computer_name.include?("Office")
	cask "cleanshot"
elsif computer_name.include?("Mother")
	cask "iina"
	cask "steam"
	cask "transmission"
end

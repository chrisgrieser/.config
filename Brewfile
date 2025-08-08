# DOCS https://docs.brew.sh/Brew-Bundle-and-Brewfile
#───────────────────────────────────────────────────────────────────────────────

# CLI
brew "bat"
brew "eza"
brew "felixkratz/formulae/sketchybar"
brew "fzf"
brew "gh"
brew "git-delta"
brew "just"
brew "less" # higher version than builtin one -> enables use of `lesskey` file
brew "mas"
brew "neovim"
brew "node"
brew "pandoc"
brew "pass"
brew "pinentry-mac"
brew "python@3.13"
brew "ripgrep"
brew "starship"
brew "yq"
brew "zsh-autocomplete"
brew "zsh-autopair"
brew "zsh-autosuggestions"
brew "zsh-history-substring-search"
brew "zsh-syntax-highlighting"

# APPS
cask "alfred"
cask "alt-tab"
cask "signal"
cask "appcleaner"
cask "brave-browser"
cask "espanso"
cask "font-jetbrains-mono-nerd-font"
cask "hammerspoon", postinstall: "defaults write org.hammerspoon.Hammerspoon MJConfigFile \"$HOME/.config/hammerspoon/init.lua\""
cask "karabiner-elements"
cask "microsoft-word", greedy: true # greedy since we uninstall the auto-updater
cask "mimestream"
cask "neovide-app"
cask "obsidian", greedy: true # greedy for installer version
cask "replacicon"
cask "slack"
cask "wezterm"
cask "zoom"
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274

# QUICKLOOK
cask "betterzip"
cask "qlmarkdown"
cask "syntax-highlight" # `Peek` not available anymore https://apps.apple.com/us/app/peek-a-quick-look-extension/id1554235898?mt=12

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
computerName = `scutil --get ComputerName`

if computerName.include?("Home")
	brew "spotify_player"
	brew "yt-dlp"
	brew "ffmpeg" # recommended for `yt-dlp`
	cask "bettertouchtool"
	cask "catch"
	cask "cleanshot"
	cask "iina"
	cask "steam"
	cask "transmission"
	cask "qlvideo" # provides preview icons for `mkv`
elsif computerName.include?("Office")
	cask "cleanshot" # only license for 2 devices
elsif computerName.include?("Mother")
	cask "iina"
	cask "steam"
	cask "transmission"
	cask "qlvideo" # provides preview icons for `mkv`
end

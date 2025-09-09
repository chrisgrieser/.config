# DOCS https://docs.brew.sh/Brew-Bundle-and-Brewfile
#───────────────────────────────────────────────────────────────────────────────

# CLI
brew "bat"
brew "eza"
brew "fzf"
brew "gh"
brew "git-delta"
brew "just"
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
tap "charmbracelet/tap" ; brew "charmbracelet/tap/crush"
tap "felixkratz/formulae"; brew "felixkratz/formulae/sketchybar"

# APPS
cask "alfred"
cask "appcleaner"
cask "brave-browser"
cask "espanso"
cask "font-jetbrains-mono-nerd-font"
cask "hammerspoon", postinstall: "defaults write org.hammerspoon.Hammerspoon MJConfigFile \"$HOME/.config/hammerspoon/init.lua\""
cask "karabiner-elements"
cask "microsoft-word", greedy: true # greedy since we uninstall the auto-updater
cask "mimestream"
cask "monodraw"
cask "neovide-app"
cask "obsidian", greedy: true # greedy for installer version
cask "replacicon"
cask "signal"
cask "slack"
cask "tabtab" # alt-tab not working https://github.com/neovide/neovide/issues/3182
cask "wezterm"
cask "zoom"
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274
mas "Easy CSV Editor", id: 1171346381

# QUICKLOOK
cask "betterzip"
mas "iPreview", id: 1519213509
cask "syntax-highlight" # `Peek` not available anymore https://apps.apple.com/us/app/peek-a-quick-look-extension/id1554235898?mt=12

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
computerName = `scutil --get ComputerName`

if computerName.include?("Home")
	brew "yt-dlp" ; brew "ffmpeg" # `ffmpeg` recommended for `yt-dlp`
	cask "catch"
	cask "bettertouchtool"
end
if !computerName.include?("Office")
	cask "iina"
	cask "steam"
	cask "transmission"
	cask "qlvideo" # provides preview icons for `.mkv`
end

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
brew "neovim" ; brew "tree-sitter-cli" # `nvim-treesitter` requires the cli
brew "node"
brew "pandoc"
brew "pass"
brew "pinentry-mac"
brew "python" # installs most recent python version (macOS system python is only 3.9)
brew "ripgrep"
brew "starship"
brew "yq"
brew "zsh-autocomplete"
brew "zsh-autopair"
brew "zsh-autosuggestions"
brew "zsh-history-substring-search"
brew "zsh-syntax-highlighting"
tap "felixkratz/formulae"; brew "felixkratz/formulae/sketchybar"

# APPS
cask "alfred"
cask "alt-tab"
cask "appcleaner"
cask "betterzip"
cask "brave-browser"
cask "espanso"
cask "font-jetbrains-mono-nerd-font"
cask "hammerspoon", postinstall: 'defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"'
cask "karabiner-elements"
cask "microsoft-word"
cask "monodraw"
cask "neovide-app"
cask "obsidian"
cask "replacicon"
cask "signal"
cask "slack"
cask "wezterm"
cask "zoom"
cask "pdf-expert"
# mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274
mas "Markdown Preview", id: 6739955340 # quicklook markdown
mas "iPreview", id: 1519213509 # quicklook source files

#───────────────────────────────────────────────────────────────────────────────

# DEVICE-SPECIFIC INSTALLS
device = `scutil --get ComputerName`

if device.include?("Home")
	brew "yt-dlp" ; brew "ffmpeg" # `ffmpeg` recommended for `yt-dlp`
	cask "catch"
	cask "bettertouchtool"
end
if device.include?("Home") or device.include?("Mother")
	cask "iina"
	cask "steam"
	cask "transmission"
	cask "qlvideo" # provides preview icons for `.mkv`
end

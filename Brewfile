# DOCS https://docs.brew.sh/Brew-Bundle-and-Brewfile

#-CLIS--------------------------------------------------------------------------
brew "bat"
brew "eza"
brew "fzf"
brew "gh"
brew "git-delta"
brew "ripgrep"
brew "just"
brew "neovim"
brew "pandoc"
brew "pass"
brew "yq"

#-PACKAGES----------------------------------------------------------------------
brew "mas"
brew "node"
brew "python" # installs most recent python version (macOS system python is only 3.9)

#-ZSH---------------------------------------------------------------------------
brew "starship"
brew "zsh-autocomplete"
brew "zsh-autopair"
brew "zsh-autosuggestions"
brew "zsh-history-substring-search"
brew "zsh-syntax-highlighting"

#-APPS--------------------------------------------------------------------------
cask "alfred"
cask "alt-tab"
cask "appcleaner"
cask "betterzip"
cask "brave-browser"
cask "espanso"
cask "hammerspoon", postinstall: 'defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"'
cask "karabiner-elements"
cask "microsoft-word"
cask "neovide-app"
cask "obsidian", greedy: true # greedy for installer version
cask "replacicon"
cask "signal"
cask "slack"
cask "wezterm"
cask "zoom"
mas "Highlights", id: 1498912833
mas "Ivory", id: 6444602274
tap "felixkratz/formulae"; brew "felixkratz/formulae/sketchybar"

#-OTHER-------------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font"

tap "flewgg/tap" ; cask "flewgg/tap/unfold"
# mas "Glance 2", id: 1564688210 # quicklook for source code

# for languagetool browser extension; see https://dev.languagetool.org/http-server
brew "languagetool", postinstall: "sleep 1 ; brew services start languagetool"

# For Alfred Pass workflow
brew "pinentry-mac", postinstall: "defaults write org.gpgtools.common DisableKeychain -bool yes"

#-DEVICE-SPECIFIC INSTALLS------------------------------------------------------
device = `scutil --get ComputerName`

if device.include?("Home")
	cask "raspberry-pi-imager"
	cask "bettertouchtool"
	cask "catch"
	cask "ausweisapp" # pairing with phone app only works in private wifi
	brew "yt-dlp" ; brew "ffmpeg" # `ffmpeg` recommended for `yt-dlp`
end
if device.include?("Home") or device.include?("Office")
	cask "monodraw"
	cask "granola"
	cask "webex" # TEMP
end
if device.include?("Home") or device.include?("Mother")
	cask "iina"
	cask "steam"
	cask "transmission"
	# cask "qlvideo" # thumbnails not working: https://github.com/Marginal/QuickLookVideo/issues/173
end

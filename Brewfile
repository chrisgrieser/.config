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

# quicklook for source code
cask "glance-chamburr", postinstall: "xattr -rd com.apple.quarantine /Applications/Glance.app; qlmanage -r; sed -i '' 's/font-size: [0-9][0-9]px/font-size: 20px/' /Applications/Glance.app/Contents/PlugIns/QLPlugin.appex/Contents/Resources/shared-main.css"

# for languagetool browser extension; see https://dev.languagetool.org/http-server
brew "languagetool", postinstall: "sleep 1 ; brew services start languagetool"

# For Alfred Pass workflow
brew "pinentry-mac", postinstall: "defaults write org.gpgtools.common DisableKeychain -bool yes"

#-DEVICE-SPECIFIC INSTALLS------------------------------------------------------
device = `scutil --get ComputerName`

if device.include?("Home")
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
	# cask "qlvideo" # version 3 bugs
	cask "steam"
	cask "transmission"
end

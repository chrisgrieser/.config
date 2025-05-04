sudo -v # ask for credentials upfront
setopt INTERACTIVE_COMMENTS # for copy-pasting

dotfolder="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"
if [[ ! -d "$dotfolder" ]]; then
	echo "No folder named 'Dotfolder' found in iCloud."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# get dotfiles
cd ~ || return 1
[[ -e ~/.config ]] && rm -rfv ~/.config
git clone git@github.com:chrisgrieser/.config

# zsh (ZDOTDIR set in .zshenv for the remaining config)
ln -sf "$HOME/.config/zsh/.zshenv" ~
# shellcheck disable=1091
source "$HOME/.config/zsh/.zshrc"

#───────────────────────────────────────────────────────────────────────────────

echo "Enter a name for this device such as 'Chris iMac Home'. It is also used for the Brewfile."
echo "Name: "
read -r new_name
sudo scutil --set ComputerName "$new_name"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install # install core CLIs like `git` for homebrew

# Install Essential Apps first
brew install --no-quarantine alfred hammerspoon neovim wezterm karabiner-elements
brew install --no-quarantine --cask neovide

#───────────────────────────────────────────────────────────────────────────────

# GPG Keys & Passwords
brew install pinentry-mac pass
defaults write org.gpgtools.common DisableKeychain -bool yes # prevent from saving in the keychains

gpg --import "$dotfolder/Authentication/gpg-for-pass/private.key"
ln -sf "$HOME/.config/gpg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent # restart so the new gpg agent is recognized
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;

# FIX for gpg config on Intel Macs with different homebrew path
if [[ $(uname -p) == "i386" ]]; then
	mkdir -p /opt/homebrew/bin/
	ln -sf /usr/local/bin/pinentry-mac /opt/homebrew/bin/pinentry-mac
fi
git clone git@github.com:chrisgrieser/.password-store

#───────────────────────────────────────────────────────────────────────────────

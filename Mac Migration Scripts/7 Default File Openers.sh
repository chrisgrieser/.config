# https://github.com/Lord-Kamina/SwiftDefaultApps#how-to-find-out-file-uti
# ------------------------------------------------------------------------
brew install swiftdefaultappsprefpane --cask
open -a "System Preferences.app"

# to change:
# - Mail
# - Browser
# - public.data (files without extension)
# - shell script
# - applescript
# - pdf
# - md (Obsidian-Opener)

brew uninstall --zap swiftdefaultappsprefpane --cask

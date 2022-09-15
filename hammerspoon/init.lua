require("meta")
require("utils")
require("visuals")

require("window-management")
require("dark-mode")
require("layouts")
require("splits")

require("scroll-and-cursor")
require("system-and-cron")
require("filesystem-watchers")
if isIMacAtHome() then require("usb-watchers") end

require("app-specific-behavior")
require("twitterrific-controls")
require("hot-corner-action")
--------------------------------------------------------------------------------

holeCover() ---@diagnostic disable-line: undefined-global
systemStart() ---@diagnostic disable-line: undefined-global
--------------------------------------------------------------------------------
-- https://github.com/dbalatero/VimMode.spoon#configuration

VimMode = hs.loadSpoon('VimMode')
vim = VimMode:new()
vim:setAlertFont('Recursive')
	:bindHotKeys({ enter = {{'cmd'}, 'f19'} }) -- Karabiner: tap left-opt
	:enableBetaFeature('block_cursor_overlay')

	:disableForApp('Sublime Text')
	:disableForApp('alacritty')
	:disableForApp('Alacritty')
	:disableForApp('Obsidian')

--------------------------------------------------------------------------------

notify("Config reloaded")

require("meta")
require("utils")
require("visuals")
holeCover() ---@diagnostic disable-line: undefined-global

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

-- https://github.com/dbalatero/VimMode.spoon#configuration

VimMode = hs.loadSpoon('VimMode')
vim = VimMode:new()
vim:setAlertFont('SF Mono')
	:bindHotKeys({ enter = {{'cmd'}, 'f19'} }) -- Karabiner: tap left-opt
	:enableBetaFeature('block_cursor_overlay')

vim:disableForApp('Sublime Text')
	:disableForApp('alacritty')
	:disableForApp('Alacritty')
	:disableForApp('Obsidian')
	:disableForApp('ShortCat')
	:disableForApp('espanso')
	:disableForApp('Marta')
	:disableForApp('Finder')
	:disableForApp('Alfred')

--------------------------------------------------------------------------------

systemStart() ---@diagnostic disable-line: undefined-global

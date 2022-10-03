require("lua.meta")
require("lua.utils")
require("lua.visuals")

require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
require("lua.splits")

require("lua.scroll-and-cursor")
require("lua.system-and-cron")
require("lua.filesystem-watchers")
if isIMacAtHome() then require("lua.usb-watchers") end

require("lua.app-specific-behavior")
if not (isAtOffice()) then
	require("lua.twitterrific-controls")
	require("lua.hot-corner-action")
end


--------------------------------------------------------------------------------
-- https://github.com/dbalatero/VimMode.spoon#configuration

VimMode = hs.loadSpoon('VimMode')
vim = VimMode:new()
vim:setAlertFont('Input')
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
	:disableForApp('Neovide')

--------------------------------------------------------------------------------

holeCover()
systemStart()

-- https://www.hammerspoon.org/go/

--------------------------------------------------------------------------------

hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Hammerspoon itself & Helper Utilities
require("meta")
require("utils")

--------------------------------------------------------------------------------

-- Base
require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("window-management")
require("filesystem-watchers")
-- require("hot-corner-action")
require("usb-watchers")

-- app-specific
require("app-watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------
-- Startup
gitDotfileSync("wake")
reloadAllMenubarItems()
if isAtOffice() then systemWake() end

notify("Config reloaded")

--------------------------------------------------------------------------------

choices = {
	{
		["text"] = "First Choice",
		["subText"] = "This is the subtext of the first choice",
		["uuid"] = "0001"
	},
	{
		["text"] = "Second Option",
		["subText"] = "I wonder what I should type here?",
		["uuid"] = "Bbbb"
	},
		{ ["text"] = hs.styledtext.new("Third Possibility", {font={size=18}, color=hs.drawing.color.definedCollections.hammerspoon.green}),
		["subText"] = "What a lot of choosing there is going on here!",
		["uuid"] = "III3"
	},
}


testChooser = hs.chooser.new(function()
	notify ("test")
end)
testChooser:choices(choices)


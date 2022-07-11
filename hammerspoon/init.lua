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
require("system-states")
require("window-management")
require("filesystem-watchers")

-- app-specific
require("watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------
-- https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md

-- Spoons
require("vim-mode")

-- https://www.hammerspoon.org/Spoons/ColorPicker.html
hs.loadSpoon("ColorPicker")
spoon.ColorPicker:start()
hotkey(hyper, "P", function () spoon.ColorPicker.toggleColorSamples("Crayons") end)
-- spoon.ColorPicker:bindHotkeys({show={hyper, "U"}})

--------------------------------------------------------------------------------
notify("Config reloaded")

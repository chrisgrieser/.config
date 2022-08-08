require("utils")

switcher = hs.window.switcher.new()
switcher.ui.showThumbnails = false

hotkey({"alt"}, "tab", function() switcher:next() end)
hotkey({"alt", "shift"}, "tab", function() switcher:next() end)


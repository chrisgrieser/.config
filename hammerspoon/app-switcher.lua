require("utils")

switcher = hs.window.switcher.new()
switcher.ui.showThumbnails = false
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = false

hotkey({"alt"}, "tab", function() switcher:next() end)
hotkey({"alt", "shift"}, "tab", function() switcher:next() end)


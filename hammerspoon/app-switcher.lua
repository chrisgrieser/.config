require("utils")

switcher = hs.window.switcher.new()
switcher.ui.showThumbnails = false
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = true
switcher.ui.showSelectedThumbnail = false

hotkey({"cmd"}, "tab", function() switcher:next() end)
hotkey({"alt", "shift"}, "tab", function() switcher:next() end)


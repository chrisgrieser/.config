require("utils")

switcher = hs.window.switcher.new()
switcher.ui.showThumbnails = false
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = true
switcher.ui.showSelectedThumbnail = false
switcher.ui.onlyActiveApplication = false

hotkey({"alt"}, "tab", function() switcher:next() end)
hotkey({"alt", "shift"}, "tab", function() switcher:next() end)

-- tad slower than normal cmd+tab, also cannot be bound to cmd+tab apparently

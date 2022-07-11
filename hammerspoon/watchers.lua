require("utils")

-- FINDER: when activated
-- - Bring all windows forward
-- - hide sidebar
-- - enlarge window if it's too small
function finderWatcher(appName, eventType, appObject)
	if (eventType == hs.application.watcher.activated) then
		if (appName == "Finder") then
			appObject:selectMenuItem({"Window", "Bring All to Front"})
			appObject:selectMenuItem({"View", "Hide Sidebar"})

			local finderWin = appObject:focusedWindow()
			local isInfoWindow = finderWin:title():match(" Info$")
			if isInfoWindow then return end

			local win_h = finderWin:frame().h
			local max_h = finderWin:screen():frame().h
			local max_w = finderWin:screen():frame().w
			local target_w = 0.6 * max_w
			local target_h = 0.8 * max_h
			if (win_h / max_h) < 0.7 then
				finderWin:setSize({w = target_w, h = target_h})
			end
		end
	end
end
finderAppWatcher = hs.application.watcher.new(finderWatcher)
finderAppWatcher:start()

-- HIGHLIGHTS: Sync Dark & Light Mode
function highlightsWatcher(appName, eventType)
	if (eventType == hs.application.watcher.launching) then
		if (appName == "Highlights") then
			hs.applescript([[
				tell application "System Events"
					tell appearance preferences to set isDark to dark mode
					if (isDark is false) then set targetView to "Default"
					if (isDark is true) then set targetView to "Night"
					delay 0.5

					tell process "Highlights"
						set frontmost to true
						click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
					end tell
				end tell
			]])
		end
	end
end
highlightsAppWatcher = hs.application.watcher.new(highlightsWatcher)
highlightsAppWatcher:start()

-- BRAVE Bookmarks synced to Chrome Bookmarks (needed for Alfred)
function bookmarkSync()
	hs.execute([[
		BROWSER="BraveSoftware/Brave-Browser"
		mkdir -p "$HOME/Library/Application Support/Google/Chrome/Default"
		cp "$HOME/Library/Application Support/$BROWSER/Default/Bookmarks" "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
		cp "$HOME/Library/Application Support/$BROWSER/Local State" "$HOME/Library/Application Support/Google/Chrome/Local State"
	]])
	notify("Bookmarks synced")
end
BraveBookmarks = os.getenv("HOME") .. "/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks"
bookmarkWatcher = hs.pathwatcher.new(BraveBookmarks, bookmarkSync)
bookmarkWatcher:start()

-- HOT CORNER Use "Quick Note" as Pseudo Hot Corner Action
-- to trigger something else instead
function hotcornerWatcher(appName, eventType)
	if (eventType == hs.application.watcher.activated) then
		if (appName == "Notes") then
			hs.application("Notes"):kill9()
			hs.shortcuts.run("Keyboard on-screen")
		end
	end
end
hotcornerEmulation = hs.application.watcher.new(hotcornerWatcher)
hotcornerEmulation:start()

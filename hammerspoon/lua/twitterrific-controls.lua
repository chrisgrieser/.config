require("lua.utils")

function twitterrificAction (type)
	local previousApp = frontapp()
	openIfNotRunning("Twitterrific")
	local twitterrific = hs.application("Twitterrific")
	twitterrific:activate() -- needs activation, cause sending to app in background doesn't work w/ cmd

	if type == "link" then
		keystroke({}, "right")
	elseif type == "thread" then
		keystroke({}, "left")
	elseif type == "retweet" then
		keystroke({"cmd"}, "e")
	elseif type == "scrollup" then
		local prevMousePos = hs.mouse.absolutePosition()

		local f = twitterrific:mainWindow():frame()
		keystroke({"cmd"}, "1") -- properly up (to avoid clicking on tweet content)
		hs.eventtap.leftClick({ x = f.x + f.w * 0.04, y = f.y + 150 })
		keystroke({"cmd"}, "k") -- mark all as red
		keystroke({"cmd"}, "j") -- scroll up
		keystroke({}, "down") -- enable j/k movement

		hs.mouse.absolutePosition(prevMousePos)
		hs.application(previousApp):activate()
	end
end

function pagedownAction ()
	if appIsRunning("IINA") then
		keystroke({}, "right", 1, hs.application("IINA"))
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "down", 1, hs.application("Twitterrific"))
	elseif appIsRunning("Tweeten") then
		keystroke({}, "down", 1, hs.application("Tweeten"))
	end
end
function pageupAction ()
	if appIsRunning("IINA") then
		keystroke({}, "left", 1, hs.application("IINA"))
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "up", 1, hs.application("Twitterrific"))
	elseif appIsRunning("Tweeten") then
		keystroke({}, "up", 1, hs.application("Tweeten"))
	end
end
function homeAction ()
	if appIsRunning("IINA") then
		keystroke({}, "Space", 1, hs.application("IINA"))
	elseif appIsRunning("zoom.us") then
		alert("🔈/🔇") -- toggle mute
		keystroke({"shift", "command"}, "A", 1, hs.application("zoom.us"))
	elseif appIsRunning("Twitterrific") then
		twitterrificAction("scrollup")
	elseif appIsRunning("Tweeten") then
		keystroke({}, "left", 1, hs.application("Tweeten"))
	end
end
function endAction ()
	if appIsRunning("zoom.us") then
		alert("📹/⬛️") -- toggle video
		keystroke({"shift", "command"}, "V", 1, hs.application("zoom.us"))
	elseif appIsRunning("Twitterrific") then
		twitterrificAction("link")
	elseif appIsRunning("Tweeten") then
		keystroke({}, "right", 1, hs.application("Tweeten"))
	end
end
function shiftEndAction ()
	twitterrificAction("thread")
end
function shiftHomeAction ()
	if appIsRunning("Twitterrific") then
		twitterrificAction("retweet")
	elseif appIsRunning("Tweeten") then
		keystroke({}, "t", 1, hs.application("Tweeten")) -- retweet
	end
end

-- IINA: Full Screen when on projector
function iinaLaunch(appName, eventType, appObject)
	if not (eventType == aw.launched and appName == "IINA") then
		if isProjector() then
			-- going full screen needs a small delay
			runDelayed(0.4, function() appObject:selectMenuItem({"Video", "Enter Full Screen"}) end)
			runDelayed(0.8, function() appObject:selectMenuItem({"Video", "Enter Full Screen"}) end)
		end
	end
end
iinaAppLauncher = aw.new(iinaLaunch)
iinaAppLauncher:start()

--------------------------------------------------------------------------------
-- Hotkeys
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)
hotkey({}, "home", homeAction) -- also eject key for Apple Keyboards (via Karabiner)
hotkey({"shift"}, "home", shiftHomeAction)
hotkey({}, "end", endAction)
hotkey({"shift"}, "end", shiftEndAction)

--------------------------------------------------------------------------------
-- scroll up on launch
-- open both windows on launch
-- only active in office & when not using twitterrificScrollUp()
function twitterificAppActivated(appName, eventType)
	if not(appName == "Twitterrific" and eventType == aw.launched) then return end
	runDelayed(1, function() twitterrificAction("scrollup") end)
end
twitterificAppWatcher = aw.new(twitterificAppActivated)
twitterificAppWatcher:start()

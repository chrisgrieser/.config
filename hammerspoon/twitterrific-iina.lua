require("utils")

function twitterrificAction (type)
	twitterrificActionRunning = true
	local twitterrific = hs.application("Twitterrific")
	twitterrific:activate() -- needs activation, cause sending to app in background doesn't work w/ cmd

	if type == "link" then
		keystroke({}, "right")
	elseif type == "thread" then
		keystroke({}, "left")
	elseif type == "retweet" then
		keystroke({"cmd"}, "e")
	elseif type == "scrollup" then
		local previousApp = frontapp()
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

	twitterrificActionRunning = false
end

function pagedownAction ()
	if appIsRunning("IINA") then
		keystroke({}, "right", 1, hs.application("IINA"))
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "down", 1, hs.application("Twitterrific"))
	end
end
function pageupAction ()
	if appIsRunning("IINA") then
		keystroke({}, "left", 1, hs.application("IINA"))
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "up", 1, hs.application("Twitterrific"))
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
	end
end
function endAction ()
	if appIsRunning("zoom.us") then
		alert("📹/⬛️") -- toggle video
		keystroke({"shift", "command"}, "V", 1, hs.application("zoom.us"))
	elseif appIsRunning("Twitterrific") then
		twitterrificAction("link")
	end
end
function shiftEndAction ()
	twitterrificAction("thread")
end
function shiftHomeAction ()
	twitterrificAction("retweet")
end

-- IINA: Full Screen when on projector
function iinaLaunch(appName, eventType, appObject)
	if (eventType == aw.launched) then
		if (appName == "IINA") then
			local isProjector = hs.screen.primaryScreen():name() == "ViewSonic PJ"
			if isProjector then
				-- going full screen apparently needs a small delay
				runDelayed(0.8, function()
					appObject:selectMenuItem({"Video", "Enter Full Screen"})
				end)
			end
		end
	end
end
iinaAppLauncher = aw.new(iinaLaunch)
iinaAppLauncher:start()

--------------------------------------------------------------------------------
-- Hotkeys
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)
hotkey({}, "home", homeAction)
hotkey({"shift"}, "home", shiftHomeAction)
hotkey({}, "end", endAction)
hotkey({"shift"}, "end", shiftEndAction)


--------------------------------------------------------------------------------
-- raise all windows on activation,
-- open both windows on launch
-- only active in office & when not using twitterrificScrollUp()
function twitterificAppActivated(appName, eventType, appObject)
	if appName ~= "Twitterrific" or twitterrificActionRunning then return end

	if isAtOffice() then
		if (eventType == aw.launched) then
			runDelayed(1, function ()
				twitterrific = hs.application("Twitterrific")
				-- switch to list view has (to be done via keystroke, since headless)
				keystroke({"cmd"}, "T", twitterrific)
				keystroke({"cmd"}, "5", twitterrific)
				keystroke({}, "down", twitterrific)
				keystroke({}, "return", twitterrific)
			end)
		elseif (eventType == aw.activated) then
			appObject:getWindow("@pseudo_meta - List: _PKM & Obsidian Community"):raise()
			appObject:getWindow("@pseudo_meta - Home"):focus()
		end

	elseif isIMacAtHome() and (eventType == aw.launched) then
		runDelayed(1, function() twitterrificAction("scrollup") end)
	end

end
twitterrificActionRunning = false
twitterificAppWatcher = aw.new(twitterificAppActivated)
if isAtOffice() then twitterificAppWatcher:start() end

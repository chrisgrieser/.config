require("utils")

function twitterrificScrollUp ()
	-- needs activation, cause sending to app in background doesn't work w/ cmd
	local previousApp = hs.application.frontmostApplication():name()
	local prevMousePos = hs.mouse.absolutePosition()
	twitterrificScrolling = true

	local twitterrific = hs.application("Twitterrific")
	twitterrific:activate()
	local twitterrificWins = twitterrific:allWindows()

	for i = 1, #twitterrificWins do
		local f = twitterrificWins[i]:frame()
		local pos = {
			x = f.x + f.w * 0.5,
			y = f.y + 120,
		}
		hs.eventtap.leftClick(pos)
		keystroke({"cmd"}, "k") -- mark all as red
		keystroke({"cmd"}, "j") -- scroll up
		keystroke({}, "down") -- enable j/k movement
	end

	hs.mouse.absolutePosition(prevMousePos)
	hs.application(previousApp):activate()
	twitterrificScrolling = false
end

function pagedownAction ()
	if appIsRunning("IINA") then
		keystroke({}, "right", 1, hs.application("IINA"))
	else
		keystroke({}, "down", 1, hs.application("Twitterrific"))
	end
end
function pageupAction ()
	if appIsRunning("IINA") then
		keystroke({}, "left", 1, hs.application("IINA"))
	else
		keystroke({}, "up", 1, hs.application("Twitterrific"))
	end
end
function homeAction ()
	if appIsRunning("IINA") then
		keystroke({}, "Space", 1, hs.application("IINA"))
	elseif appIsRunning("zoom.us") then
		-- toggle mute
		alert("🔈/🔇")
		keystroke({"shift", "command"}, "A", 1, hs.application("zoom.us"))
	else
		twitterrificScrollUp()
	end
end

-- IINA: Full Screen when on projector
function iinaLaunch(appName, eventType, appObject)
	if (eventType == hs.application.watcher.launched) then
		if (appName == "IINA") then
			local isProjector = hs.screen.primaryScreen():name() == "ViewSonic PJ"
			if isProjector then
				-- going full screen apparently needs a small delay
				hs.timer.delayed.new(0.8, function()
					appObject:selectMenuItem({"Video", "Enter Full Screen"})
				end):start()
			end
		end
	end
end
iinaAppLauncher = hs.application.watcher.new(iinaLaunch)
iinaAppLauncher:start()

--------------------------------------------------------------------------------
-- raise all windows on activation,
-- open both windows on launch
-- only active in office & when not using twitterrificScrollUp()
function twitterificAppActivated(appName, eventType, appObject)
	if twitterrificScrolling or appName ~= "Twitterrific" then return end
	if (eventType == hs.application.watcher.launching) then
		runDelayed(1, function ()
			twitterrific = hs.application("Twitterrific")
			if #(twitterrific:allWindows()) > 1 then return end
			-- switch to list view has (to be done via keystroke, since headless)
			keystroke({"cmd"}, "T", twitterrific)
			keystroke({"cmd"}, "5", twitterrific)
			keystroke({}, "down", twitterrific)
			keystroke({}, "return", twitterrific)
		end)
	elseif (eventType == hs.application.watcher.activated) then
		appObject:getWindow("@pseudo_meta - List"):raise()
		appObject:getWindow("@pseudo_meta - Home"):focus()
	end
end
twitterrificScrolling = false
twitterificAppWatcher = hs.application.watcher.new(twitterificAppActivated)
if isAtOffice() then twitterificAppWatcher:start() end

--------------------------------------------------------------------------------
-- Hotkeys
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)
hotkey({}, "home", homeAction)

hotkey({"shift"}, "home", function ()
	hs.application("Twitterrific"):activate()
end)

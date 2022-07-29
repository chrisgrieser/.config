-- https://www.hammerspoon.org/docs/hs.menubar.html
-- https://www.hammerspoon.org/go/#simplemenubar
require("utils")
--------------------------------------------------------------------------------

-- this also determines the order of menubar items
function reloadAllMenubarItems ()
	setWeather()
	setCovidBar()
	updateDraftsMenubar()
	setFileHubCountMenuBar()
	updateDotfileSyncStatusMenuBar()
end

weatherUpdateMin = 15
weatherLocation = "Berlin"
covidUpdateHours = 12
covidLocationCode = "BE"
fileHubLocation = os.getenv("HOME").."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"
dotfileLocation = os.getenv("HOME").."/dotfiles/"

--------------------------------------------------------------------------------

weatherStatusBar = hs.menubar.new()
function setWeather()
	local _, weather = hs.http.get("https://wttr.in/" .. weatherLocation .. "?format=1", nil)
	if not (weather) then
		weatherStatusBar:setTitle("–")
		return
	end
	weather = (trim(weather)):gsub("+", "")

	weatherStatusBar:setTitle(weather)
end
weatherTimer = hs.timer.doEvery(weatherUpdateMin * 60, setWeather)
weatherTimer:start()
--------------------------------------------------------------------------------

-- German Covid-Numbers by the RKI → https://api.corona-zahlen.org/docs/
covidBar = hs.menubar.new()
function setCovidBar()
	local _, nationalDataJSON = hs.http.get("https://api.corona-zahlen.org/germany", nil)
	if not (nationalDataJSON) then
		covidBar:setTitle("–")
		return
	end
	local nationalNumbers = hs.json.decode(nationalDataJSON)
	local national_7D_incidence = math.floor(nationalNumbers.weekIncidence)
	local nationalR = nationalNumbers.r.rValue7Days.value
	covidBar:setTitle("🦠 "..national_7D_incidence.." ("..nationalR..")")
	covidBar:setClickCallback(function ()hs.urlevent.openURL("https://data.lageso.de/lageso/corona/corona.html#start") end)

	local _, stateDataJSON = hs.http.get("https://api.corona-zahlen.org/states/" .. covidLocationCode, nil)
	if not (stateDataJSON) then
		covidBar:setTooltip("not available")
		return
	end
	local stateNumbers = hs.json.decode(stateDataJSON)
	local stateName = stateNumbers.data[covidLocationCode].name
	local state_7D_incidence = math.floor(stateNumbers.data[covidLocationCode].weekIncidence)
	covidBar:setTooltip(stateName..": "..state_7D_incidence)
end
covidTimer = hs.timer.doEvery(covidUpdateHours * 60 * 60, setCovidBar)
covidTimer:start()

--------------------------------------------------------------------------------
dotfileSyncMenuBar = hs.menubar.new()
function updateDotfileSyncStatusMenuBar()
	local changes, success = hs.execute('git status --porcelain | wc -l | tr -d " "')
	changes = trim(changes)

	if tonumber(changes) == 0 or not(success) then
		dotfileSyncMenuBar:removeFromMenuBar() -- also removed clickcallback, which therefore has to be set again
	else
		dotfileSyncMenuBar:returnToMenuBar()
		dotfileSyncMenuBar:setTitle("🔁 "..changes)
		dotfileSyncMenuBar:setClickCallback(function ()
			local lastCommit = hs.execute('git log -1 --format=%ar')
			lastCommit = trim(lastCommit)
			local nextSync = math.floor(repoSyncTimer:nextTrigger() / 60)
			notify("last commit: "..lastCommit.."\n".."next sync: in "..tostring(nextSync).." min")
		end)
	end
end


dotfilesWatcher = hs.pathwatcher.new(dotfileLocation, updateDotfileSyncStatusMenuBar)
dotfilesWatcher:start()

--------------------------------------------------------------------------------
draftsCounterMenuBar = hs.menubar.new()
function updateDraftsMenubar()
	local excludeTag1 = "tasklist"
	local excludeTag2
	if isIMacAtHome() then excludeTag2 = "office"
	else excludeTag2 = "home" end

	local numberOfDrafts, success = hs.execute("python3 numberOfDrafts.py "..excludeTag1.." "..excludeTag2)
	numberOfDrafts = trim(numberOfDrafts)

	if tonumber(numberOfDrafts) == 0 or not(success) then
		draftsCounterMenuBar:removeFromMenuBar()
	else
		draftsCounterMenuBar:returnToMenuBar()
		draftsCounterMenuBar:setTitle("🔷 "..numberOfDrafts)
	end
end

function draftsWatcher(appName, eventType)
	if not(appName == "Drafts") then return end
	if not(eventType == hs.application.watcher.deactivated or eventType == hs.application.watcher.activated) then return end
	updateDraftsMenubar()
end
-- update when database changes or Drafts loses focus
draftsSqliteLocation = os.getenv("HOME").."/Library/Group Containers/GTFQ98J4YG.com.agiletortoise.Drafts/Changes.sqlite-shm"
draftsMenuBarWatcher1 = hs.pathwatcher.new(draftsSqliteLocation, updateDraftsMenubar)
draftsMenuBarWatcher1:start()
draftsMenuBarWatcher2 = hs.application.watcher.new(draftsWatcher)
draftsMenuBarWatcher2:start()

-- `hammerspoon://update-drafts-menubar` for Alfred when adding Drafts in the background
hs.urlevent.bind("update-drafts-menubar", function()
	updateDraftsMenubar()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

--------------------------------------------------------------------------------

fileHubCountMenuBar = hs.menubar.new()
function setFileHubCountMenuBar()
	local numberOfFiles, success = hs.execute('ls "'..fileHubLocation..'" | wc -l | tr -d " "')
	numberOfFiles = trim(numberOfFiles)

	if tonumber(numberOfFiles) == 0 or not(success) then
		fileHubCountMenuBar:removeFromMenuBar()
	else
		fileHubCountMenuBar:returnToMenuBar()
		fileHubCountMenuBar:setTitle("📂 "..numberOfFiles)
	end
end

-- update when folder changes
fileHubMenuBarWatcher = hs.pathwatcher.new(fileHubLocation, setFileHubCountMenuBar)
fileHubMenuBarWatcher:start()

--------------------------------------------------------------------------------

-- finderGitRepoBar = hs.menubar.new()
-- function finderGitRepoUpdate ()
-- 	local _, currentFinderPath = hs.osascript.applescript([[
-- 		tell application "Finder"
-- 			if (count windows) is 0 then return ""
-- 			set currentDir to target of Finder window 1 as alias
-- 			return POSIX path of currentDir
-- 		end tell
-- 	]])
-- 	local _, isGitRepo = hs.execute(' cd "'..currentFinderPath..'" ; git rev-parse --git-dir')

-- 	if isGitRepo and currentFinderPath and frontapp() == "Finder" then
-- 		local changes = hs.execute(' cd "'..currentFinderPath..'" ; git status --porcelain | wc -l')
-- 		changes = trim(changes)
-- 		finderGitRepoBar:returnToMenuBar()
-- 		finderGitRepoBar:setTitle("✴️ "..changes)
-- 	else
-- 		finderGitRepoBar:removeFromMenuBar()
-- 	end
-- end
-- wf = hs.window.filter
-- wf_finder2 = wf.new("Finder")
-- wf_finder2:subscribe(wf.windowFocused, finderGitRepoUpdate)
-- wf_finder2:subscribe(wf.windowCreated, finderGitRepoUpdate)
-- wf_finder2:subscribe(wf.windowTitleChanged, finderGitRepoUpdate)
-- wf_finder2:subscribe(wf.windowUnfocused, function() finderGitRepoBar:removeFromMenuBar() end)

--------------------------------------------------------------------------------
-- obsidianStatusBar = hs.menubar.new()
-- obsiWorkspaceJSON = os.getenv("HOME") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/.obsidian/workspace"
-- function obsidianCurrentFile()
-- 	local filename = hs.json.read(obsiWorkspaceJSON).lastOpenFiles[1]
-- 		:sub(0, -4) -- remove extension
-- 		:gsub(".*/", "") -- remove path
-- 	obsidianStatusBar:setTitle(filename)
-- end
-- obsidianCurrentFile()
-- obsiWatcher = hs.pathwatcher.new(obsiWorkspaceJSON, obsidianCurrentFile)
-- obsiWatcher:start()

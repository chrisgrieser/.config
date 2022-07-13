-- https://www.hammerspoon.org/docs/hs.menubar.html
-- https://www.hammerspoon.org/go/#simplemenubar
require("utils")
--------------------------------------------------------------------------------

function reloadAllMenubarItems ()
	setWeather()
	setCovidBar()
	updateDotfileSyncStatusMenuBar()
	updateDraftsMenubar()
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
		weatherStatusBar:setTitle("")
		return
	end
	local _, weatherLong = hs.http.get("https://wttr.in/" .. weatherLocation .. "?format=4", nil)
	weather = weather:gsub("\n", ""):gsub("+", "")
	weatherLong = weatherLong:gsub("\n", ""):gsub("+", "")

	weatherStatusBar:setTitle(weather)
	weatherStatusBar:setTooltip(weatherLong)
end
weatherTimer = hs.timer.doEvery(weatherUpdateMin * 60, setWeather)
weatherTimer:start()
--------------------------------------------------------------------------------

-- German Covid-Numbers by the RKI → https://api.corona-zahlen.org/docs/
covidBar = hs.menubar.new()
function setCovidBar()
	local _, nationalDataJSON = hs.http.get("https://api.corona-zahlen.org/germany", nil)
	if not (nationalDataJSON) then
		covidBar:setTitle("")
		return
	end
	local nationalNumbers = hs.json.decode(nationalDataJSON)
	local national_7D_incidence = math.floor(nationalNumbers.weekIncidence)
	local nationalR = nationalNumbers.r.rValue7Days.value
	covidBar:setTitle("🦠 "..national_7D_incidence.." ("..nationalR..")")

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
draftsCounterMenuBar = hs.menubar.new()
function updateDraftsMenubar()
	local excludeTag1 = "tasklist"
	local excludeTag2
	if isIMacAtHome() then
		excludeTag2 = "office"
	else
		excludeTag2 = "home"
	end
	local numberOfDrafts, success = hs.execute("python3 numberOfDrafts.py "..excludeTag1.." "..excludeTag2)
	numberOfDrafts = numberOfDrafts:gsub("\n", "")
	if tonumber(numberOfDrafts) == 0 or not(success) then
		draftsCounterMenuBar:setTitle("")
		return
	end

	local draftsIcon
	if isDarkMode() then
		draftsIcon = "drafts-menubar-white.tiff"
	else
		draftsIcon = "drafts-menubar-black.tiff"
	end
	draftsCounterMenuBar:setIcon(draftsIcon, false)

	draftsCounterMenuBar:setTitle(numberOfDrafts)
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

-- `hammerspoon://update-drafts-menubar` for Alfred Triggers (incl. Dark Mode Toggle)
hs.urlevent.bind("update-drafts-menubar",  function()
	updateDraftsMenubar()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

--------------------------------------------------------------------------------
dotfileSyncMenuBar = hs.menubar.new()
function updateDotfileSyncStatusMenuBar()
	local changes, success = hs.execute('git status --short | wc -l | tr -d " "')
	changes = changes:gsub("\n", "")
	if tonumber(changes) == 0 or not(success) then
		dotfileSyncMenuBar:setTitle("")
		return
	end
	dotfileSyncMenuBar:setTitle("🔁 "..changes)
end
dotfilesWatcher = hs.pathwatcher.new(dotfileLocation, updateDotfileSyncStatusMenuBar)
dotfilesWatcher:start()
-- also updated on gitDotfileSync()

--------------------------------------------------------------------------------

-- fileHubCountMenuBar = hs.menubar.new()
-- function setFileHubCountMenuBar()
-- 	local numberOfFiles, success = hs.execute('ls "'..fileHubLocation..'" | wc -l | tr -d " "')
-- 	numberOfFiles = numberOfFiles:gsub("\n", "")
-- 	if tonumber(numberOfFiles) == 0 or not(success) then
-- 		fileHubCountMenuBar:setTitle("")
-- 		return
-- 	end
-- 	fileHubCountMenuBar:setTitle("📂 "..numberOfFiles)
-- end
-- setFileHubCountMenuBar()

-- -- update when folder changes
-- fileHubMenuBarWatcher = hs.pathwatcher.new(fileHubLocation, setFileHubCountMenuBar)
-- fileHubMenuBarWatcher:start()

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

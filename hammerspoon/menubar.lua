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

covidIcon ="🦠"
draftsIcon ="☑️"
fileHubIcon ="📂"
syncIcon ="🔁"

--------------------------------------------------------------------------------

weatherStatusBar = hs.menubar.new()
function setWeather()
	local _, weather = hs.http.get("https://wttr.in/" .. weatherLocation .. "?format=1", nil)
	if not(weather) or weather:find("Unknown") then
		weatherStatusBar:setTitle("🌦 –")
		weatherStatusBar:setClickCallback(setWeather) -- i.e. self-update
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
	if not(nationalDataJSON) then
		covidBar:setTitle(covidIcon.." –")
		covidBar:setClickCallback(setCovidBar) -- i.e. self-update
		return
	end
	local nationalNumbers = hs.json.decode(nationalDataJSON)
	if not(nationalNumbers.weekIncidence) then
		covidBar:setTitle(covidIcon.." –")
		covidBar:setClickCallback(setCovidBar) -- i.e. self-update
		return
	end
	local national_7D_incidence = math.floor(nationalNumbers.weekIncidence)
	local nationalR = nationalNumbers.r.rValue7Days.value
	covidBar:setTitle(covidIcon.." "..national_7D_incidence.." ("..nationalR..")")
	covidBar:setClickCallback(function ()hs.urlevent.openURL("https://data.lageso.de/lageso/corona/corona.html#start") end)
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
		dotfileSyncMenuBar:setTitle(syncIcon.." "..changes)
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
		draftsCounterMenuBar:setTitle(draftsIcon.." "..numberOfDrafts)
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
hs.urlevent.bind("update-drafts-menubar", updateDraftsMenubar)

--------------------------------------------------------------------------------

fileHubCountMenuBar = hs.menubar.new()
function setFileHubCountMenuBar()
	local numberOfFiles, success = hs.execute('ls "'..fileHubLocation..'" | wc -l | tr -d " "')
	numberOfFiles = trim(numberOfFiles)

	if tonumber(numberOfFiles) == 0 or not(success) then
		fileHubCountMenuBar:removeFromMenuBar()
	else
		fileHubCountMenuBar:returnToMenuBar()
		fileHubCountMenuBar:setTitle(fileHubIcon.." "..numberOfFiles)
	end
end

-- update when folder changes
fileHubMenuBarWatcher = hs.pathwatcher.new(fileHubLocation, setFileHubCountMenuBar)
fileHubMenuBarWatcher:start()

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

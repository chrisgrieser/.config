-- https://www.hammerspoon.org/docs/hs.menubar.html
-- https://www.hammerspoon.org/go/#simplemenubar
require("utils")
--------------------------------------------------------------------------------

function reloadAllMenubarItems ()
	setWeather()
	setCovidBar()
	setFileHubCountMenuBar()
	setDraftsCounterMenuBar()
end

weatherUpdateMin = 15
weatherLocation = "Berlin"
covidUpdateHours = 12
covidLocationCode = "BE"
fileHubLocation = os.getenv("HOME").."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

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
setWeather()
weatherTimer = hs.timer.doEvery(weatherUpdateMin * 60, setWeather)
weatherTimer:start()
--------------------------------------------------------------------------------

-- German Covid-Numbers by the RKI → https://api.corona-zahlen.org/docs/
covidBar = hs.menubar.new()
function setCovidBar()
	local _, nationalDataJSON = hs.http.get("https://api.corona-zahlen.org/germany", nil)
	if not (nationalDataJSON) then
		covidBar.setTitle("")
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
setCovidBar()
covidTimer = hs.timer.doEvery(covidUpdateHours * 60 * 60, setCovidBar)
covidTimer:start()

--------------------------------------------------------------------------------

fileHubCountMenuBar = hs.menubar.new()
function setFileHubCountMenuBar()
	local numberOfFiles, success = hs.execute('ls "'..fileHubLocation..'" | wc -l | tr -d " "')
	numberOfFiles = numberOfFiles:gsub("\n", "")
	if tonumber(numberOfFiles) == 0 or not(success) then
		fileHubCountMenuBar:setTitle("")
		return
	end
	fileHubCountMenuBar:setTitle("📂 "..numberOfFiles)
end
setFileHubCountMenuBar()

-- update when folder changes
fileHubMenuBarWatcher = hs.pathwatcher.new(fileHubLocation, setFileHubCountMenuBar)
fileHubMenuBarWatcher:start()

--------------------------------------------------------------------------------
draftsCounterMenuBar = hs.menubar.new()
function setDraftsCounterMenuBar()
	local numberOfDrafts, success = hs.execute("python3 numberOfDrafts.py")
	numberOfDrafts = numberOfDrafts:gsub("\n", "")
	if tonumber(numberOfDrafts) == 0 or not(success) then
		draftsCounterMenuBar:setTitle("")
		return
	end
	draftsCounterMenuBar:setTitle("☑️ "..numberOfDrafts)
	notify("test")
end
setDraftsCounterMenuBar()

-- update when database changes
draftsSqliteLocation = os.getenv("HOME").."/Library/Group Containers/GTFQ98J4YG.com.agiletortoise.Drafts/DraftStore.sqlite"
draftsMenuBarWatcher = hs.pathwatcher.new(draftsSqliteLocation, setDraftsCounterMenuBar)
draftsMenuBarWatcher:start()

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

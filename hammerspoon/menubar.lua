require("utils")
require("system-and-cron")
--------------------------------------------------------------------------------

-- this also determines the order of menubar items
function reloadAllMenubarItems ()
	setWeather()
	setCovidBar()
	updateDraftsMenubar()
	setFileHubCountMenuBar()
	updateDotfileSyncStatusMenuBar()
	updateVaultSyncStatusMenuBar()
end

-- ununsed, but these two can be used to style the emojis in the menubar
-- function notoEmoji(emojiStr)
-- 	return hs.styledtext.new(emojiStr, {font="Noto Emoji"})
-- end

-- function helvetica(str)
-- 	return hs.styledtext.new(str, {font="Helvetica"})
-- end

--------------------------------------------------------------------------------

weatherUpdateMin = 15
weatherLocation = "Berlin"
covidUpdateHours = 12
covidLocationCode = "BE"
fileHubLocation = home.."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

covidIcon ="🦠"
draftsIcon ="☑️"
fileHubIcon ="📂"
-- dotfiles and vault icon defined in system-and-cron.lua

--------------------------------------------------------------------------------

weatherStatusBar = hs.menubar.new()
function setWeather()
	local _, weather = hs.http.get("https://wttr.in/"..weatherLocation.."?format=1", nil)
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
	local displayText = " "..national_7D_incidence.." ("..nationalR..")"
	covidBar:setTitle(covidIcon..displayText)
	covidBar:setClickCallback(function ()hs.urlevent.openURL("https://data.lageso.de/lageso/corona/corona.html#start") end)
end
covidTimer = hs.timer.doEvery(covidUpdateHours * 60 * 60, setCovidBar)
covidTimer:start()

--------------------------------------------------------------------------------
dotfileSyncMenuBar = hs.menubar.new()
function updateDotfileSyncStatusMenuBar()
	-- no cd necessary cause hammerspoon is already in dotfile repo
	local changes, success = hs.execute('git status --porcelain | wc -l | tr -d " "')
	changes = trim(changes)

	if tonumber(changes) == 0 or not(success) then
		dotfileSyncMenuBar:removeFromMenuBar() -- also removes clickcallback, which therefore has to be set again
	else
		dotfileSyncMenuBar:returnToMenuBar()
		dotfileSyncMenuBar:setTitle(dotfileIcon.." "..changes) ---@diagnostic disable-line: undefined-global
		dotfileSyncMenuBar:setClickCallback(function ()
			local changedFiles = hs.execute('git status --porcelain') -- no need for cd, since hammerspoon config is inside dotfile directory already
				:gsub('"','')
				:gsub("(.. )[^\n]+/(.-)\n", "%1%2\n") -- only filenames and git status
				:gsub("\n ", "\n") -- remove leading spaces
			notify(changedFiles)
		end)
	end
end

dotfilesWatcher = hs.pathwatcher.new(dotfileLocation, updateDotfileSyncStatusMenuBar) ---@diagnostic disable-line: undefined-global
dotfilesWatcher:start()

--------------------------------------------------------------------------------

vaultSyncMenuBar = hs.menubar.new()
function updateVaultSyncStatusMenuBar()
	local changes, success = hs.execute('cd "'..vaultLocation..'" ; git status --porcelain | wc -l | tr -d " "') ---@diagnostic disable-line: undefined-global
	changes = trim(changes)

	if tonumber(changes) == 0 or not(success) then
		vaultSyncMenuBar:removeFromMenuBar() -- also removes clickcallback, which therefore has to be set again
	else
		vaultSyncMenuBar:returnToMenuBar()
		vaultSyncMenuBar:setTitle(vaultIcon.." "..changes) ---@diagnostic disable-line: undefined-global
		vaultSyncMenuBar:setClickCallback(function ()
			local changedFiles = hs.execute('cd "'..vaultLocation..'" ; git status --porcelain') ---@diagnostic disable-line: undefined-global
				:gsub('"','')
				:gsub("(.. )[^\n]+/(.-)\n", "%1%2\n") -- only filenames and git status
				:gsub("\n ", "\n") -- remove leading spaces
			notify(changedFiles)
		end)
	end
end

vaultWatcher = hs.pathwatcher.new(vaultLocation, updateVaultSyncStatusMenuBar) ---@diagnostic disable-line: undefined-global
vaultWatcher:start()

--------------------------------------------------------------------------------
draftsCounterMenuBar = hs.menubar.new()
function updateDraftsMenubar()
	local excludeTag1 = "tasklist"
	local excludeTag2
	if isAtOffice() then excludeTag2 = "home"
	else excludeTag2 = "office" end

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

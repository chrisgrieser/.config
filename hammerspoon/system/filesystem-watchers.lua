local M = {}
--------------------------------------------------------------------------------

-- CONFIG
local home = os.getenv("HOME")
local browserConfigs = home .. "/.config/browser-extensions/"
local backupFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/backups/"

--------------------------------------------------------------------------------

local u = require("meta.utils")
local pathw = hs.pathwatcher.new
hs.fs.mkdir(browserConfigs)
hs.fs.mkdir(backupFolder)

---AUTO-FILE FROM DESKTOP-------------------------------------------------------
M.pathw_desktop = pathw(home .. "/Desktop/", function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby

	for _, path in pairs(paths) do
		local parent, name = path:match("(.+)/(.+)")
		parent = parent:sub(#(home .. "/Desktop/"))
		local ext = name:match("%.([^.]-)$")

		-- HACK only downloaded files get quarantined, so this method detects downloads
		local exists, msg = pcall(hs.fs.xattr.get, path, "com.apple.quarantine")
		local isDownloaded = exists and msg ~= nil
		local success, errmsg

		-- REMOVE ALFREDWORKFLOWS & ICAL
		if (ext == "alfredworkflow" or ext == "ics") and isDownloaded then
			-- delay, since Apple Calendar/Alfred need the file to exist while adding it
			u.defer(60, function() os.remove(path) end)

		-- ADD BIBTEX ENTRIES TO LIBRARY
		elseif ext == "bib" and isDownloaded then
			local bibEntry = u.readFile(path)
			if bibEntry and #bibEntry < 10000 then -- prevent large libraries from being automatically merged
				bibEntry = bibEntry:gsub("\n?$", "\n")
				local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"
				u.writeToFile(libraryPath, bibEntry, true)
				hs.open(libraryPath)
				os.remove(path)
			end

		---BROWSER EXTENSION SETTING BACKUPS--------------------------------------
		elseif name == "Redirector.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ Redirector settings backed up.") end
		elseif name == "obsidian-web-clipper-settings.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ Obsidian web clipper settings backed up.") end
		elseif name:find("vimium_c.*%.json") then
			success, errmsg = os.rename(path, browserConfigs .. "vimium-c-settings.json")
			if success then u.notify("✅ Vimium-c settings backed up.") end
		elseif name:find("Inoreader Feeds.*%.xml") then

		---APP AND SERVICE BACKUPS------------------------------------------------
		elseif name == "following_accounts.csv" then
			success, errmsg = os.rename(path, backupFolder .. "Mastodon/" .. name)
			if success then u.notify("✅ Mastodon followings backed up.") end
			success, errmsg = os.rename(path, backupFolder .. "Inoreader Feeds.opml")
			if success then u.notify("✅ Inoreader feeds backed up.") end
		elseif name == "Catch.xml" then
			success, errmsg = os.rename(path, backupFolder .. "Catch Feeds.xml")
			if success then u.notify("✅ Catch feeds backed up.") end
		elseif name == "mailFilters.xml" then
			success, errmsg = os.rename(path, backupFolder .. "Gmail Filters.xml")
			if success then u.notify("✅ Gmail filters backed up.") end
		elseif ext == "icbu" then
			success, errmsg = os.rename(path, backupFolder .. "/Calendar/" .. name)
			if success then u.notify("✅ Calendar data backed up.") end

		---RECEIPTS---------------------------------------------------------------
		elseif name:find("Rechnung_" .. ("%d"):rep(16) .. "_" .. ("%d"):rep(10)) then
			-- Vodafone
			local year = os.date("%Y")
			-- stylua: ignore
			local receiptPath = ("%s/Documents/Wohnung/laufende Kosten/Vodafone/%s/"):format(home, year)
			success, errmsg = hs.fs.mkdir(receiptPath)
			u.defer(1, function() os.rename(path, receiptPath .. "/" .. name) end) -- delay ensures folder is created
			u.openUrlInBg(receiptPath)

		---BANKING----------------------------------------------------------------
		elseif name:find("[%d-]_Kontoauszug_.*%.pdf$") or name:find("^Direkt_Depot_.*%.pdf$") then
			local year = (name:match("_20%d%d") or name:match("^%d%d%d%d") or ""):gsub("^_", "")
			if year ~= nil then
				local folder = name:find("Depot") and "Depot" or "Geldkonten"
				-- stylua: ignore
				local bankPath = ("%s/Documents/Finanzen/Vermögen (ING-DiBa)/%s/%s"):format(home, folder, year)
				success, errmsg = hs.fs.mkdir(bankPath) -- create directory in case of new year
				u.defer(1, function() os.rename(path, bankPath .. "/" .. name) end) -- delay ensures folder is created
				u.openUrlInBg(bankPath)
			end
		elseif name:find("^Umsatzanzeige_.*%.csv$") then
			local bankPath = home .. "/Documents/Finanzen/Vermögen (ING-DiBa)/Umsatz/csv/"
			os.rename(path, bankPath .. "/" .. name)
		elseif name:find("Depotuebersicht.*%.pdf") or name:find("Depotuebersicht.*%.csv") then
			local bankPath = home .. "Documents/Finanzen/Vermögen (ING-DiBa)/Depot/Depotübersicht/" -- typos: ignore-line
			os.rename(path, bankPath .. "/" .. name)

		---STEAM GAME SHORTCUTS---------------------------------------------------
		elseif name:find("%.app$") and not isDownloaded and parent == "" then
			-- parent condition prevents downloads of apps in nested folders to be moved
			local gameFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Apps/Games/"
			success, errmsg = os.rename(path, gameFolder .. name)
		end

		---NOTIFY-----------------------------------------------------------------
		if success == false then
			u.notify(("⚠️ Failed to move: %q; %s"):format(name, errmsg or ""))
		end
	end
end):start()

--------------------------------------------------------------------------------
return M

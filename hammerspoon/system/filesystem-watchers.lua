local M = {}
local home = os.getenv("HOME")
--------------------------------------------------------------------------------

-- CONFIG
local browserConfigs = home .. "/.config/browser-extension-configs/"
local backupFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/backups/"

--------------------------------------------------------------------------------

local u = require("meta.utils")
local pathw = hs.pathwatcher.new
hs.fs.mkdir(browserConfigs)
hs.fs.mkdir(backupFolder)

--------------------------------------------------------------------------------

-- move iPhone scans from iCloud root to Desktop
local icloud = home .. "/Library/Mobile Documents/com~apple~CloudDocs"
M.pathw_icloud = pathw(icloud, function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby
	hs.fnutils.each(paths, function(path)
		local parent, name = path:match("(.*)/(.+)")
		if not (parent == icloud and name:match("^Scanned Document ?%d*%.pdf$")) then return end
		os.rename(path, home .. "/Desktop/" .. name)
	end)
end):start()

-- AUTO-FILE FROM DESKTOP
M.pathw_desktop = pathw(home .. "/Desktop/", function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby

	for _, path in pairs(paths) do
		local name = path:match(".*/(.+)")
		local ext = name:match("%.([^.]-)$")

		-- HACK only downloaded files get quarantined, thus this detects downloads
		local exists, msg = pcall(hs.fs.xattr.get, path, "com.apple.quarantine")
		local isDownloaded = exists and msg ~= nil
		local success, errmsg

		-- REMOVE ALFREDWORKFLOWS & ICAL
		if (ext == "alfredworkflow" or ext == "ics") and isDownloaded then
			-- delay, so auto-open from the browser is triggered first, and since
			-- Apple Calendar needs the file to exist before adding it
			u.defer(60, function() os.remove(path) end)

		-- ADD BIBTEX ENTRIES TO LIBRARY
		elseif ext == "bib" and isDownloaded then
			local bibEntry = u.readFile(path)
			if bibEntry then
				bibEntry = bibEntry:gsub("\n?$", "\n")
				local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"
				u.writeToFile(libraryPath, bibEntry, true)
				hs.open(libraryPath)
				os.remove(path)
			end

		---BROWSER EXTENSION SETTING BACKUPS--------------------------------------
		elseif name == "ublacklist-settings.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ ublacklist settings backed up.") end
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
			if success then u.notify("✅ Mastodon follows backed up.") end
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

		---BANKING----------------------------------------------------------------
		elseif name:find("[%d-]_Kontoauszug_%d.*%.pdf$") or name:find(".*_zu_Depot_%d.*%.pdf$") then
			local year = name:match("^%d%d%d%d") -- first year-digits in filename
			if not year then return end -- file lacks year

			local folder = name:find("Kontoauszug") and "DKB Geldkonten" or "DKB Depot"
			local bankPath = ("%s/Documents/Finanzen/Vermögen (DKB)/%s/%s"):format(home, folder, year)

			success, errmsg = hs.fs.mkdir(bankPath) -- create directory in case of new year
			u.defer(1, function() os.rename(path, bankPath .. "/" .. name) end) -- delay ensures folder is created
			u.openUrlInBg(bankPath)

		---STEAM GAME SHORTCUTS---------------------------------------------------
		elseif name:find("%.app$") and not isDownloaded then
			local gameFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Apps/Games/"
			success, errmsg = os.rename(path, gameFolder .. name)

		---AUTO-INSTALL OBSIDIAN ALPHA--------------------------------------------
		elseif name:find("%.asar%.gz$") and isDownloaded then
			hs.execute(([[
				cd %q || exit 1
				mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
				cd "$HOME/Library/Application Support/obsidian/"
				rm obsidian-*.*.*.asar
				gunzip obsidian-*.*.*.asar.gz
				killall Obsidian
				while pgrep -xq "Obsidian" ; do sleep 0.1; done
				open -a "Obsidian"
			]]):format(home .. "/Desktop/"))
			u.closeBrowserTabsWith("https://cdn.discordapp.com/attachments")
		end

		---NOTIFY-----------------------------------------------------------------
		if success == false then
			u.notify(("⚠️ Failed to move: %q; %s"):format(name, errmsg or ""))
		end
	end
end):start()

--------------------------------------------------------------------------------
return M

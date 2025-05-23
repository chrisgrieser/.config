local M = {}

local u = require("meta.utils")

local home = os.getenv("HOME")
local pathw = hs.pathwatcher.new
--------------------------------------------------------------------------------

-- CONFIG
local browserConfigs = home .. "/.config/+ browser-extension-configs/"

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

		-- VARIOUS BACKUP
		elseif name == "ublacklist-settings.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ ublacklist settings backed up.") end
		elseif name == "Redirector.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ Redirector settings backed up.") end
		elseif name:find("vimium_c.*%.json") then
			success, errmsg = os.rename(path, browserConfigs .. "vimium-c-settings.json")
			if success then u.notify("✅ Vimium-c settings backed up.") end
		elseif name:find("Inoreader Feeds .*%.xml") then
			local backupPath = home
				.. "/Library/Mobile Documents/com~apple~CloudDocs/Backups/Inoreader Feeds.opml"
			success, errmsg = os.rename(path, backupPath)
			if success then u.notify("✅ Inoreader feeds backed up.") end
		elseif name == "obsidian-web-clipper-settings.json" then
			success, errmsg = os.rename(path, browserConfigs .. name)
			if success then u.notify("✅ Obsidian web clipper settings backed up.") end
		elseif ext == "icbu" then
			-- private, thus not in dotfiles repo
			local backupPath = home
				.. "/Library/Mobile Documents/com~apple~CloudDocs/Backups/Calendar/"
			success, errmsg = os.rename(path, backupPath .. name)
			if success then u.notify("✅ Calendar data backed up.") end

		-- BANKING
		elseif
			name:find("[%d-]_Kontoauszug_.*%.pdf$")
			or name:find("[%d-]_Kosteninformation_.*%.pdf$")
			or name:find("[%d-]_Abrechnung_.*%.pdf$")
			or name:find("[%d-]_Ertragsabrechnung_.*%.pdf$")
			or name:find("[%d-]_Depotauszug_.*%.pdf$")
			or name:find("[%d-]_Kapi?talmaßnahme_.*%.pdf$") -- SIC sometimes missing `i` typo from DKB
		then
			local folder = name:find("Kontoauszug") and "DKB Girokonto" or "DKB Depot"
			local year = name:match("^%d%d%d%d")
			local bankPath = ("%s/Documents/Finanzen/%s/%s"):format(home, folder, year)
			success, errmsg = hs.fs.mkdir(bankPath)
			u.defer(1, function() os.rename(path, bankPath .. "/" .. name) end) -- delay ensures folder is created
			u.openUrlInBg(bankPath)

		-- STEAM GAME SHORTCUTS
		elseif name:find("%.app$") and not isDownloaded then
			local gameFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Games/"
			success, errmsg = os.rename(path, gameFolder .. name)
			if success then
				-- open folders to copy icon
				hs.open(gameFolder)
				hs.open(home .. "/Library/Application Support/Steam/steamapps/common")
			end

		-- AUTO-INSTALL OBSIDIAN ALPHA
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

		--------------------------------------------------------------------------
		-- NOTIFY
		if success == false then
			u.notify(("⚠️ Failed to move: %q; %s"):format(name, errmsg or ""))
		end
	end
end):start()

--------------------------------------------------------------------------------
return M

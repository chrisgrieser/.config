local M = {}

local u = require("meta.utils")

local home = os.getenv("HOME")
local pathw = hs.pathwatcher.new
--------------------------------------------------------------------------------

-- CONFIG
local browserConfigs = home .. "/.config/+ browser-extension-configs/"
local desktop = home .. "/Desktop/"

M.pathw_desktop = pathw(desktop, function(paths, _)
	if not u.screenIsUnlocked() then return end -- prevent iCloud sync triggering in standby

	for _, path in pairs(paths) do
		local name = path:match(".*/(.+)")
		local ext = name:match("%.([^.]-)$")

		-- HACK only downloaded files get quarantined, thus this detects downloads
		local exists, msg = pcall(hs.fs.xattr.get, path, "com.apple.quarantine")
		local isDownloaded = exists and msg ~= nil
		local success

		-- 1. REMOVE ALFREDWORKFLOWS & ICAL
		if (ext == "alfredworkflow" or ext == "ics") and isDownloaded then
			-- delay, so auto-open from the browser is triggered first, and since
			-- Apple Calendar needs the file to exist before adding it
			u.defer(30, function() os.remove(path) end)

		-- 2. ADD BIBTEX ENTRIES TO LIBRARY
		elseif ext == "bib" and isDownloaded then
			local bibEntry = u.readFile(path)
			if bibEntry then
				bibEntry = bibEntry:gsub("\n?$", "\n")
				local libraryPath = home .. "/.config/pandoc/main-bibliography.bib"
				u.writeToFile(libraryPath, bibEntry, true)
				hs.open(libraryPath)
				os.remove(path)
			end

		-- 3. BACKUP BROWSER SETTINGS
		elseif name == "violentmonkey" then
			success = os.rename(path, browserConfigs .. "violentmonkey")
			if success then
				-- needs to be zipped again, since browser auto-opens all zip files
				hs.execute(([[
					cd "%s/violentmonkey" || exit 1
					zip --recurse-paths ../violentmonkey.zip .
					cd .. && rm -rf ./violentmonkey
				]]):format(browserConfigs))
				u.app("Brave Browser"):activate()
			end
		elseif name == "ublacklist-settings.json" then
			success = os.rename(path, browserConfigs .. name)
		elseif name:find("my%-ublock%-backup_.*%.txt") then
			success = os.rename(path, browserConfigs .. "ublock-settings.json")
		elseif name:find("adg_ext_settings_.*%.json") then
			success = os.rename(path, browserConfigs .. "adguard-settings.json")
		elseif name:find("stylus%-.*%.json") then
			success = os.rename(path, browserConfigs .. "stylus.json")
		elseif name:find("vimium_c.*%.json") then
			success = os.rename(path, browserConfigs .. "vimium-c-settings.json")
		elseif name:find("Inoreader Feeds .*%.xml") then
			local backupPath = home
				.. "/Library/Mobile Documents/com~apple~CloudDocs/Backups/Inoreader Feeds.opml"
			success = os.rename(path, backupPath)
		elseif name == "obsidian-web-clipper-settings.json" then
			success = os.rename(path, browserConfigs .. name)

		-- 4. BANKING
		elseif
			name:find("[%d-]_Kontoauszug_.*%.pdf$")
			or name:find("[%d-]_Kosteninformation_.*%.pdf$")
			or name:find("[%d-]_Abrechnung_.*%.pdf$")
			or name:find("[%d-]_Ertragsabrechnung_.*%.pdf$")
			or name:find("[%d-]_Depotauszug_.*%.pdf$")
			or name:find("[%d-]_Kapi?talmaßnahme_.*%.pdf$") -- SIC missing `i` typo from DKB
		then
			local folder = name:find("Kontoauszug") and "DKB Girokonto & Kreditkarte" or "DKB Depot"
			local year = name:match("^%d%d%d%d")
			local bankPath = ("%s/Documents/Finanzen/%s/%s"):format(home, folder, year)
			hs.fs.mkdir(bankPath)
			u.defer(1, function() os.rename(path, bankPath .. "/" .. name) end) -- delay ensures folder is created
			u.openUrlInBg(bankPath)

		-- 5. STEAM GAME SHORTCUTS
		elseif name:find("%.app$") and not isDownloaded then
			local gameFolder = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Games/"
			success = os.rename(path, gameFolder .. name)
			if success then
				-- open folders to copy icon
				hs.open(gameFolder)
				hs.open(home .. "/Library/Application Support/Steam/steamapps/common")
			end

		-- 6. AUTO-INSTALL OBSIDIAN ALPHA
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
			]]):format(desktop))
			u.closeBrowserTabsWith("https://cdn.discordapp.com/attachments")
		end

		if success == false then u.notify("⚠️ Failed to move file: " .. name) end
	end
end):start()

--------------------------------------------------------------------------------
return M

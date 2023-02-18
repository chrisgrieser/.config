require("lua.utils")
--------------------------------------------------------------------------------
-- CONFIG (not local vars for longevity)
DotfilesFolder = Getenv("DOTFILE_FOLDER")
FileHub = Getenv("WD")
Home = Getenv("HOME")

--------------------------------------------------------------------------------

-- Bookmarks synced to Chrome Bookmarks (needed for Alfred)
local browserFolder = Home .. "/Library/Application Support/BraveSoftware/Brave-Browser/"
BookmarkWatcher = Pw(
	browserFolder .. "Default/Bookmarks",
	function()
		hs.execute("BROWSER_FOLDER='" .. browserFolder .. "' ; " .. [[
		mkdir -p "$HOME/Library/Application Support/Google/Chrome/Default"
		cp "$BROWSER_FOLDER/Default/Bookmarks" "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
		cp "$BROWSER_FOLDER/Local State" "$HOME/Library/Application Support/Google/Chrome/Local State"
	]])
	end
):start()

--------------------------------------------------------------------------------

-- Download Folder Badge
-- requires "fileicon" being installed
local downloadFolder = Home .. "/Downloaded"
DownloadFolderWatcher = Pw(
	downloadFolder,
	function()
		hs.execute("zsh ./helpers/download-folder-badge/download-folder-icon.sh " .. downloadFolder)
	end
):start()

--------------------------------------------------------------------------------

-- FONT rsync (for both directions)
-- (symlinking the Folder somehow does not work properly, therefore rsync)
local fontLocation = DotfilesFolder .. "/fonts/" -- source folder needs trailing "/" to copy contents (instead of the folder)
FontsWatcher1 = Pw(Home .. "/Library/Fonts", function()
	hs.execute([[rsync --archive --update --delete "$HOME/Library/Fonts/" "]] .. fontLocation .. [["]])
	Notify("Fonts synced.")
end):start()
FontsWatcher2 = Pw(fontLocation, function()
	hs.execute([[rsync --archive --update --delete "]] .. fontLocation .. [[" "$HOME/Library/Fonts"]])
	Notify("Fonts synced.")
end):start()

--------------------------------------------------------------------------------

-- Redirects TO File Hub
local scanFolder = Home .. "/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
ScanFolderWatcher = Pw(scanFolder, function()
	hs.execute("mv '" .. scanFolder .. "'/* '" .. FileHub .. "'")
	Notify("Scan moved to File Hub")
end):start()

local systemDownloadFolder = Home .. "/Downloads/"
SystemDlFolderWatcher = Pw(systemDownloadFolder, function(files)
	-- Stats Update file can directly be trashed
	for _, filePath in pairs(files) do
		if filePath:find("Stats%.dmg$") then
			os.rename(filePath, os.getenv("HOME").."/.Trash/Stats.dmg")
			return	
		end
	end
	-- otherwise move to filehub
	hs.execute("mv '" .. systemDownloadFolder .. "'/* '" .. FileHub .. "'")
	Notify("Download moved to File Hub.")
end):start()

local draftsIcloud = Home .. "/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/"
DraftsIcloudWatcher = Pw(draftsIcloud, function(files)
	for _, filePath in pairs(files) do
		if filePath:sub(-3) ~= ".md" or filePath:find("Inbox") then return end
		hs.execute("mv '" .. draftsIcloud .. "'/*.md '" .. FileHub .. "'")
		Notify("Drafts doc moved to File Hub.")
	end
end):start()

--------------------------------------------------------------------------------

-- Redirects FROM File Hub
local browserSettings = DotfilesFolder .. "/browser-extension-configs/"
FileHubWatcher = Pw(FileHub, function(paths)
	for _, file in pairs(paths) do
		local function isInSubdirectory(f, folder) -- (instead of directly in the folder)
			local _, fileSlashes = f:gsub("/", "")
			local _, folderSlashes = folder:gsub("/", "")
			return fileSlashes > folderSlashes
		end

		if isInSubdirectory(file, FileHub) then return end
		local fileName = file:gsub(".*/", "")

		-- delete alfredworkflows and ics
		if fileName:sub(-15) == ".alfredworkflow" or fileName:sub(-4) == ".ics" then
			RunWithDelays(3, function() os.rename(file, Home .. "/.Trash/" .. fileName) end)

		-- ublacklist
		elseif fileName == "ublacklist-settings.json" then
			os.rename(file, browserSettings .. fileName)
			Notify(fileName .. " filed away.")

			-- vimium-c
		elseif fileName:match("vimium_c") then
			os.rename(file, browserSettings .. "vimium-c-settings.json")
			Notify("Vimium-C backup filed away.")

		-- adguard backup
		elseif fileName:match(".*_adg_ext_settings_.*%.json") then
			os.rename(file, browserSettings .. "adguard-settings.json")
			Notify("AdGuard backup filed away.")

		-- sponsor block
		elseif fileName:match("SponsorBlockConfig_.*%.json") then
			os.rename(file, browserSettings .. "SponsorBlockConfig.json")
			Notify("SpondorBlockConfig filed away.")

		-- tampermonkey backup
		elseif fileName:match("tampermonkey%-backup-.+%.txt") then
			os.rename(file, browserSettings .. "tampermonkey-settings.json")
			Notify("TamperMonkey backup filed away.")

		-- watch later .urls from the office
		elseif fileName:sub(-4) == ".url" and IsIMacAtHome() then
			os.rename(file, Home .. "/Downloaded/" .. fileName)
			Notify("Watch Later URL moved to Video Downloads.")

		-- visualised keyboard layouts
		elseif
			fileName:match("base%-keyboard%-layout%.%w+")
			or fileName:match("app%-switcher%-layout%.%w+")
			or fileName:match("vimrc%-remapping%.%w+")
			or fileName:match("marta%-key%-bindings%.%w+")
			or fileName:match("hyper%-bindings%-layout%.%w+")
			or fileName:match("single%-keystroke%-bindings%.%w+")
		then
			os.rename(file, DotfilesFolder .. "/visualized-keyboard-layout/" .. fileName)
			Notify("Visualized Keyboard Layout filed away.")

			-- Finder vim mode
		elseif fileName:match("finder%-vim%-cheatsheet%.%w+") then
			os.rename(
				file,
				Home .. "/Library/Mobile Documents/com~apple~CloudDocs/Repos/finder-vim-mode/" .. fileName
			)
			Notify("Finder Vim Layout filed away.")
		end
	end
end):start()

--------------------------------------------------------------------------------
-- auto-install Obsidian Alpha builds as soon as the file is downloaded
ObsiAlphaWatcher = Pw(FileHub, function(files)
	for _, file in pairs(files) do
		-- needs delay and crdownload check, since the renaming is sometimes not picked up by hammerspoon
		if not (file:match("%.crdownload$") or file:match("%.asar%.gz$")) then return end
		RunWithDelays(0.5, function()
			hs.execute([[cd "]] .. FileHub .. [[" || exit 1
				test -f obsidian-*.*.*.asar.gz || exit 1
				killall Obsidian
				mv obsidian-*.*.*.asar.gz "$HOME/Library/Application Support/obsidian/"
				cd "$HOME/Library/Application Support/obsidian/"
				rm obsidian-*.*.*.asar
				gunzip obsidian-*.*.*.asar.gz
				while pgrep -q "Obsidian" ; do sleep 0.1; done
				sleep 0.2
				open -a "Obsidian"]])
			-- close the created tab
			Applescript([[
				tell application "Vivaldi"
					set window_list to every window
					repeat with the_window in window_list
						set tab_list to every tab in the_window
						repeat with the_tab in tab_list
							set the_url to the url of the_tab
							if the_url contains ("https://cdn.discordapp.com/attachments") then
								close the_tab
							end if
						end repeat
					end repeat
				end tell
			]])
		end)
	end
end):start()

require("lua.utils")
local fileHub = home .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"
local pw = hs.pathwatcher.new
--------------------------------------------------------------------------------

-- BRAVE Bookmarks synced to Chrome Bookmarks (needed for Alfred)
browserFolder = home .. "/Library/Application Support/BraveSoftware/Brave-Browser/"
function bookmarkSync()
	hs.execute("BROWSER_FOLDER='" .. browserFolder .. "' ; " .. [[
		mkdir -p "$HOME/Library/Application Support/Google/Chrome/Default"
		cp "$BROWSER_FOLDER/Default/Bookmarks" "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
		cp "$BROWSER_FOLDER/Local State" "$HOME/Library/Application Support/Google/Chrome/Local State"
	]])
	notify("Bookmarks synced.")
end

bookmarkWatcher = pw(browserFolder .. "Default/Bookmarks", bookmarkSync)
bookmarkWatcher:start()

--------------------------------------------------------------------------------

-- Download Folder Badge
downloadFolder = home .. "/Downloaded"
function downloadFolderBadge()
	-- requires "fileicon" being installed
	hs.execute("zsh ./helpers/download-folder-badge/download-folder-icon.sh " .. downloadFolder)
end

downloadFolderWatcher = pw(downloadFolder, downloadFolderBadge)
downloadFolderWatcher:start()

--------------------------------------------------------------------------------

-- FONT rsync (for both directions)
-- - symlinking the Folder somehow does not work properly, therefore rsync
-- - source folder needs trailing "/" to copy contents (instead of the folder)
fontsWatcher1 = pw(home .. "/Library/Fonts", function()
	hs.execute('rsync --archive --update --delete "$HOME/Library/Fonts/" "$HOME/dotfiles/Fonts"')
	notify("Fonts synced.")
end)
fontsWatcher2 = pw(home .. "/dotfiles/Fonts", function()
	hs.execute('rsync --archive --update --delete "$HOME/dotfiles/Fonts/" "$HOME/Library/Fonts"')
	notify("Fonts synced.")
end)
fontsWatcher1:start()
fontsWatcher2:start()

--------------------------------------------------------------------------------

-- Redirects TO File Hub
scanFolder = home .. "/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
scanFolderWatcher = pw(scanFolder, function()
	hs.execute("mv '" .. scanFolder .. "'/* '" .. fileHub .. "'")
	notify("Scan moved to File Hub.")
end)
scanFolderWatcher:start()

systemDownloadFolder = home .. "/Downloads/"
systemDlFolderWatcher = pw(systemDownloadFolder, function()
	hs.execute("mv '" .. systemDownloadFolder .. "'/* '" .. fileHub .. "'")
	notify("Download moved to File Hub.")
end)
systemDlFolderWatcher:start()

draftsIcloud = home .. "/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/"
draftsIcloudWatcher = pw(draftsIcloud, function(files)
	for _, file in pairs(files) do
		if file:sub(-3) ~= ".md" then return end
		hs.execute("mv '" .. draftsIcloud .. "'/*.md '" .. fileHub .. "'")
		notify("Drafts doc moved to File Hub.")
	end
end)
draftsIcloudWatcher:start()

--------------------------------------------------------------------------------

-- Redirects FROM File Hub
function fromFileHub(files)
	for _, file in pairs(files) do
		local function isInSubdirectory(f, folder) -- (instead of directly in the folder)
			local _, fileSlashes = f:gsub("/", "")
			local _, folderSlashes = folder:gsub("/", "")
			return fileSlashes > folderSlashes
		end

		if isInSubdirectory(file, fileHub) then return end
		local fileName = file:gsub(".*/", "")

		-- delete alfredworkflows and ics
		if fileName:sub(-15) == ".alfredworkflow" or fileName:sub(-4) == ".ics" then
			runDelayed(3, function() hs.execute('mv -f "' .. file .. '" "$HOME/.Trash"') end)

			-- vimium backup
		elseif fileName == "vimium-options.json" then
			hs.execute('mv -f "' .. file .. '" "$HOME/dotfiles/Browser Extension Settings/"')
			notify("Vimium backup filed away.")

			-- ublocklist backup
		elseif fileName == "ublacklist-settings.json" then
			hs.execute('mv -f "' .. file .. '" "$HOME/dotfiles/Browser Extension Settings/"')
			notify("uBlacklist backup filed away.")

			-- adguard backup
		elseif fileName:match(".*_adg_ext_settings_.*%.json") then
			hs.execute('mv -f "' .. file .. '" "$HOME/dotfiles/Browser Extension Settings/adguard-settings.json"')
			notify("AdGuard backup filed away.")

			-- tampermonkey backup
		elseif fileName:match("tampermonkey%-backup-.+%.txt") then
			hs.execute('mv -f "' .. file .. '" "$HOME/dotfiles/Browser Extension Settings/tampermonkey-settings.json"')
			notify("TamperMonkey backup filed away.")

			-- watch later .urls from the office
		elseif fileName:sub(-4) == ".url" and isIMacAtHome() then
			hs.execute('mv -f "' .. file .. '" "$HOME/Downloaded/" ')
			notify("Watch Later URL moved to Video Downloads.")

			-- visualised keyboard layouts
		elseif fileName:match("base%-keyboard%-layout%.%w+") or fileName:match("app%-switcher%-layout%.%w+") or
			fileName:match("vimrc%-remapping%.%w+") or fileName:match("marta%-key%-bindings%.%w+") or
			fileName:match("hyper%-bindings%-layout%.%w+") or fileName:match("single%-keystroke%-bindings%.%w+") then
			hs.execute('mv -f "' .. file .. '" "$HOME/dotfiles/visualized keyboard layout/"')
			notify("Visualized Keyboard Layout filed away.")

		end
	end
end

fileHubWatcher = pw(fileHub, fromFileHub)
fileHubWatcher:start()

--------------------------------------------------------------------------------
-- auto-install Obsidian Alpha builds as soon as the file is downloaded
function installObsiAlpha(files)
	for _, file in pairs(files) do
		-- needs delay and crdownload check, since the renaming is sometimes not picked up by hammerspoon
		if not (file:match("%.crdownload$") or file:match("%.asar%.gz$")) then return end
		runDelayed(0.5, function()
			hs.execute(
				'cd "' .. fileHub .. [[" || exit 1
				test -f obsidian-*.*.*.asar.gz || exit 1
				gunzip obsidian-*.*.*.asar.gz
				mv obsidian-*.*.*.asar "$HOME/Library/Application Support/obsidian/"
				killall "Obsidian" && sleep 1 && open -a "Obsidian" ]]
			)
			-- close the created tab
			applescript [[
				tell application "Brave Browser"
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
			]]
		end)
	end
end

obsiAlphaWatcher = pw(fileHub, installObsiAlpha)
obsiAlphaWatcher:start()

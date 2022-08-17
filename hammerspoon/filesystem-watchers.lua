require("utils")

home = os.getenv("HOME")
fileHub = home.."/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"

--------------------------------------------------------------------------------

-- BRAVE Bookmarks synced to Chrome Bookmarks (needed for Alfred)
browserFolder=os.getenv("HOME").."/Library/Application Support/BraveSoftware/Brave-Browser/"
function bookmarkSync()
	hs.execute("BROWSER_FOLDER='"..browserFolder.."' ; "..
		[[mkdir -p "$HOME/Library/Application Support/Google/Chrome/Default"
		cp "$BROWSER_FOLDER/Default/Bookmarks" "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
		cp "$BROWSER_FOLDER/Local State" "$HOME/Library/Application Support/Google/Chrome/Local State"
	]])
	log ("🔖 Bookmark Sync ("..deviceName()..")", "./logs/some.log")
end
bookmarkWatcher = hs.pathwatcher.new(browserFolder.."Default/Bookmarks", bookmarkSync)
bookmarkWatcher:start()

--------------------------------------------------------------------------------

-- Download Folder Badge
downloadFolder=home.."Downloaded"
function downloadFolderBadge ()
	-- requires "fileicon" being installed
	hs.execute("folder='"..downloadFolder.."' ; "..
		[[export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
		icons_path="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Custom Icons/Download Folder"
		itemCount=$(ls "$folder" | wc -l)
		itemCount=$((itemCount-1)) # reduced by one to account for the "?Icon" file in the folder

		cache_location="/Library/Caches/dlFolderLastChange"  # cache necessary to prevent recursion of icon change triggering pathwatcher again
		test ! -e "$cache_location" || touch "$cache_location"
		if test $itemCount -gt 0 ; then
			echo "badge" > "$cache_location"
		fi
		last_change=$(cat "$cache_location")

		if test $itemCount -gt 0 && test -z "$last_change" ; then  # using test instead of square brackets cause lua
			fileicon set "$folder" "$icons_path/with Badge.icns"
			echo "badge" > "$cache_location"
			killall Dock
		elif test $itemCount -eq 0 && test -n "$last_change" ; then
			fileicon set "$folder" "$icons_path/without Badge.icns"
			echo "" > "$cache_location"
			killall Dock
		fi
	]])
end
downloadFolderWatcher = hs.pathwatcher.new(downloadFolder, downloadFolderBadge)
if isIMacAtHome() then downloadFolderWatcher:start() end

--------------------------------------------------------------------------------

-- Redirects TO File Hub
scanFolder = home.."/Library/Mobile Documents/iCloud~com~geniussoftware~GeniusScan/Documents/"
scanFolderWatcher = hs.pathwatcher.new(scanFolder, function ()
	hs.execute("mv '"..scanFolder.."'/* '"..fileHub.."'")
end)
scanFolderWatcher:start()

systemDownloadFolder = home.."/Downloads/"
systemDlFolderWatcher = hs.pathwatcher.new(systemDownloadFolder, function ()
	hs.execute("mv '"..systemDownloadFolder.."'/* '"..fileHub.."'")
end)
systemDlFolderWatcher:start()

draftsIcloud = home.."/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/"
draftsIcloudWatcher = hs.pathwatcher.new(draftsIcloud, function ()
	hs.execute("mv '"..draftsIcloud.."'/*.md '"..fileHub.."'")
end)
draftsIcloudWatcher:start()

--------------------------------------------------------------------------------

-- Redirects FROM File Hub
function fromFileHub(files)
	for _,file in pairs(files) do
		local function isInSubdirectory (f, folder) -- (instead of directly in the folder)
			local _, fileSlashes = f:gsub("/", "")
			local _, folderSlashes = folder:gsub("/", "")
			return fileSlashes > folderSlashes
		end
		if isInSubdirectory(file, fileHub) then return end
		local fileName = file:gsub(".*/","")

		-- delete alfredworkflows and ics
		if fileName:sub(-15) == ".alfredworkflow" or fileName:sub(-4) == ".ics" then
			runDelayed(3, function () hs.execute('mv -f "'..file..'" "$HOME/.Trash"') end)

		-- vimium backup
		elseif fileName == "vimium-options.json" then
			hs.execute('mv -f "'..file..'" "$HOME/dotfiles/Browser Extension Settings/"')

		-- watch later .urls from the office
		elseif fileName:sub(-4) == ".url" and isIMacAtHome() then
			hs.execute('mv -f "'..file..'" "$HOME/Downloaded/" ')

		-- visualised keyboard layouts
		elseif fileName:match("base%-keyboard%-layout%.%w+") or fileName:match("app%-switcher%-layout%.%w+") or fileName:match("vimrc%-remapping%.%w+") or fileName:match("marta%-key%-bindings%.%w+") or fileName:match("hyper%-bindings%-layout%.%w+") or fileName:match("single%-keystroke%-bindings%.%w+") then
			hs.execute('mv -f "'..file..'" "$HOME/dotfiles/visualized keyboard layout/"')

		end
	end
end
fileHubWatcher = hs.pathwatcher.new(fileHub, fromFileHub)
fileHubWatcher:start()

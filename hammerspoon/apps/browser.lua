local M = {} -- persist from garbage collector
--------------------------------------------------------------------------------

-- BOOKMARKS SYNCED TO CHROME BOOKMARKS
-- so Alfred can pick up the Bookmarks without extra keyword

-- INFO The pathwatcher is triggered by changes of the *target*, while this
-- function touches the *symlink itself* due to `-h`. Thus, there is no need to
-- configure the symlink target here.

local chromeBookmarks = os.getenv("HOME")
	.. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

local function touchSymlink() hs.execute(("touch -h %q"):format(chromeBookmarks)) end

-- sync on system start & when bookmarks are changed
if require("meta.utils").isSystemStart() then touchSymlink() end
M.pathw_bookmarks = hs.pathwatcher.new(chromeBookmarks, touchSymlink):start()

--------------------------------------------------------------------------------
return M

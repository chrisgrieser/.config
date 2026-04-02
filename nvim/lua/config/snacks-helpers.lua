local M = {}
--------------------------------------------------------------------------------

function M.toggleInvisibleChars()
	-- toggle invisible chars, disable when leaving buffer
	local function reEnable()
		vim.opt_local.listchars = vim.b.indent_prevListChars
		Snacks.indent.enable()
		vim.api.nvim_del_autocmd(vim.b.indent_autocmdId)
	end

	if Snacks.indent.enabled then
		vim.b.indent_prevListChars = vim.opt_local.listchars:get()
		-- stylua: ignore
		vim.opt_local.listchars:append { tab = " ", space = "·", trail = "·", lead = "·" }
		Snacks.indent.disable()
		vim.b.indent_autocmdId = vim.api.nvim_create_autocmd("BufLeave", {
			callback = reEnable,
			buffer = 0,
		})
	else
		reEnable()
	end
end

---@param cmd string
---@return { keys: { [string]: table } }
function M.createScratchRunKeymap(cmd)
	local function runner(self) ---@param self { buf: number } -- passed by snacks
		vim.cmd("silent! update") -- save before running
		local filepath = vim.api.nvim_buf_get_name(self.buf)
		local result = vim.system({ cmd, filepath }):wait()

		local out = vim.trim((result.stdout or "") .. "\n" .. (result.stderr or ""))
		local icon = Snacks.util.icon(vim.bo[self.buf].ft, "filetype")
		local level = vim.log.levels[result.code == 0 and "INFO" or "WARN"]

		vim.notify(out, level, { title = cmd, icon = icon, ft = "text" })
	end

	return {
		keys = {
			run = { "<CR>", runner, desc = ("run (%s)"):format(cmd) },
		},
	}
end

function M.ensureLuarcForScratch()
	local scratchRoot = vim.fn.stdpath("data") .. "/scratch" -- default root
	vim.fn.mkdir(scratchRoot, "p")
	local luarc = io.open(scratchRoot .. "/.luarc.jsonc", "w")
	assert(luarc, "Could not create luarc for lua scratch")
	luarc:write([[ {
	"runtime.version": "LuaJIT",
	"workspace.library": ["$VIMRUNTIME/lua", "${3rd}/luv/library"]
} ]])
	luarc:close()
end

function M.openNotif(idx)
	local maxWidth = 0.85
	local maxHeight = 0.85

	-- get notification
	if idx == "last" then idx = 1 end
	local history = Snacks.notifier.get_history {
		filter = function(notif) return notif.level ~= "trace" end,
		reverse = true,
	}
	if #history == 0 then
		local msg = "No notifications yet."
		vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
		return
	end
	local notif = assert(history[idx], "Notification not found.")
	Snacks.notifier.hide(notif.id)

	-- win properties
	local lines = vim.split(notif.msg, "\n")
	local title = vim.trim((notif.icon or "") .. " " .. (notif.title or ""))

	local minHeight = 5
	local height = math.min(#lines + 2, math.ceil(vim.o.lines * maxHeight))
	height = math.max(height, minHeight)
	local longestLine = vim.iter(lines):fold(0, function(acc, line)
		local len = #(line:gsub("\t", "    "))
		return math.max(acc, len)
	end)
	longestLine = math.max(longestLine, #title)
	local width = math.min(longestLine + 3, math.ceil(vim.o.columns * maxWidth))

	local overflow = #lines + 2 - height -- +2 for border
	local moreLines = overflow > 0 and ("↓ %d lines"):format(overflow) or ""
	local indexStr = ("(%d/%d)"):format(idx, #history)
	local footer = vim.trim(indexStr .. "   " .. moreLines)

	local levelCapitalized = notif.level:gsub("^%l", string.upper)
	local highlights = {
		"FloatBorder:SnacksNotifierBorder" .. levelCapitalized,
		"FloatTitle:SnacksNotifierTitle" .. levelCapitalized,
		"FloatFooter:SnacksNotifierFooter" .. levelCapitalized,
	}
	local winhighlights = table.concat(highlights, ",")

	-- create win with snacks API
	local win = Snacks.win {
		text = lines,
		height = height,
		width = width,
		title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
		footer = footer and " " .. footer .. " " or nil,
		footer_pos = footer and "right" or nil,
		border = vim.o.winborder --[[@as "rounded"|"single"|"double"]],
		bo = { ft = notif.ft or "markdown" }, -- `.bo.ft` instead of `.ft` needed for treesitter folding
		wo = {
			wrap = notif.ft ~= "lua",
			statuscolumn = " ", -- adds padding
			cursorline = true,
			winfixbuf = true,
			fillchars = "fold: ,eob: ",
			foldmethod = "expr",
			foldexpr = "v:lua.vim.treesitter.foldexpr()",
			winhighlight = winhighlights,
		},
		keys = {
			["<Tab>"] = function()
				if idx == #history then return end
				vim.cmd.close()
				M.openNotif(idx + 1)
			end,
			["<S-Tab>"] = function()
				if idx == 1 then return end
				vim.cmd.close()
				M.openNotif(idx - 1)
			end,
		},
	}
	vim.api.nvim_win_call(win.win, function()
		-- emphasize filenames in errors
		vim.fn.matchadd("DiagnosticInfo", [[[^/]\+\.lua:\d\+\ze:]])
	end)
end

---PICKER-----------------------------------------------------------------------

function M.importLuaModule()
	Snacks.picker.grep {
		title = "󰢱 Import module",
		cmd = "rg",
		args = { "--only-matching", "--no-config" },
		live = false,
		regex = true,
		search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
		ft = "lua",

		layout = { preset = "small_no_preview", layout = { width = 0.75 } },
		transform = function(item, ctx) -- ensure items are unique
			ctx.meta.done = ctx.meta.done or {}
			local import = item.text:gsub(".-:", "") -- different occurrences of same import
			if ctx.meta.done[import] then return false end
			ctx.meta.done[import] = true
		end,
		format = function(item, _picker) -- only display the grepped line
			local out = {}
			local line = item.line:gsub("^local ", "")
			Snacks.picker.highlight.format(item, line, out)
			return out
		end,
		confirm = function(picker, item) -- insert the line below the current one
			picker:close()
			vim.cmd.normal { "o", bang = true }
			vim.api.nvim_set_current_line(item.line)
			vim.cmd.normal { "==l", bang = true }
		end,
	}
end

---@param dir string?
function M.betterFileOpen(dir)
	if not dir then dir = vim.uv.cwd() end
	assert(dir and dir ~= "/", "No cwd set.")

	local changedFiles = {}
	local gitDir = Snacks.git.get_root(dir)
	if gitDir then
		local args = { "git", "-C", gitDir, "status", "--porcelain", "--ignored" }
		local gitStatus = vim.system(args):wait().stdout or ""
		local changes = vim.split(gitStatus, "\n", { trimempty = true })
		changedFiles = vim.iter(changes):fold({}, function(acc, line)
			local relPath = line:sub(4):gsub("^.+ -> ", "") -- `gsub` for renames
			local absPath = gitDir .. "/" .. relPath
			local change = line:sub(1, 2)
			if change == "??" then change = " A" end -- just nicer highlights for untracked
			acc[absPath] = change
			return acc
		end)
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	Snacks.picker.files {
		cwd = dir,
		title = "󰝰 " .. vim.fs.basename(dir),
		transform = function(item, _ctx) -- exclude the current file
			local itemPath = Snacks.picker.util.path(item)
			if itemPath == currentFile then return false end
		end,
		format = function(item, picker) -- add git status highlights
			local itemPath = Snacks.picker.util.path(item)
			item.status = changedFiles[itemPath]
			if vim.startswith(item.file, ".") then item.status = "!!" end -- hidden files
			return Snacks.picker.format.file(item, picker)
		end,
	}
end

function M.browseProject()
	local projectsFolder = vim.g.localRepos -- CONFIG

	local projects = vim.iter(vim.fs.dir(projectsFolder)):fold({}, function(acc, item, type)
		if type == "directory" then table.insert(acc, item) end
		return acc
	end)

	if #projects == 0 then
		vim.notify("No projects found.", vim.log.levels.WARN)
	elseif #projects == 1 then
		M.betterFileOpen(projectsFolder .. "/" .. projects[1])
	else
		vim.ui.select(projects, { prompt = " Select project" }, function(project)
			if project then M.betterFileOpen(projectsFolder .. "/" .. project) end
		end)
	end
end

--------------------------------------------------------------------------------
return M

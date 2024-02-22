-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual
-- configuration. Every function is self-contained (except the helper
-- functions here), and should be binded to a keymap.
--------------------------------------------------------------------------------
local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

---@param msg string
---@param title string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(title, msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = title })
end

--------------------------------------------------------------------------------

---Convenience wrapper around `:cdo` (simplified nvim-spectre)
function M.globalSubstitute()
	vim.ui.input({
		prompt = " Search Globally:",
		default = vim.fn.expand("<cword>"),
	}, function(input)
		if not input then return end

		-- search
		local ignoreCaseBefore = vim.o.ignorecase
		vim.o.ignorecase = false
		vim.cmd(("silent! vimgrep /%s/g **/*"):format(input)) -- vimgrep = internal search = no dependency

		-- replace
		vim.defer_fn(function()
			vim.fn.setqflist({}, "a", { title = input })

			-- GUARD
			local qf = vim.fn.getqflist { items = true }
			if #qf.items == 0 then
				notify("Global Search", ("No match found for %q"):format(input), "warn")
				return
			end

			-- preview search results
			local height = math.min(20, #qf.items + 1)
			vim.cmd("copen " .. tostring(height))

			-- prefill & position cursor in cmdline
			local cmd = (":cdo s/%s//"):format(input)
			vim.api.nvim_feedkeys(cmd, "i", true)
			local left = vim.api.nvim_replace_termcodes("<Left>", true, false, true)
			vim.defer_fn(function() vim.api.nvim_feedkeys(left, "i", false) end, 100)

			-- leave cmdline
			vim.api.nvim_create_autocmd("CmdlineLeave", {
				once = true,
				callback = function()
					vim.defer_fn(function()
						vim.cmd.cclose()
						vim.cmd.cfirst() -- move cursor back
						vim.cmd.cexpr("[]") -- clear quickfix
						vim.cmd.cfdo("silent update")
						vim.o.ignorecase = ignoreCaseBefore
					end, 1)
				end,
			})
		end, 1)
	end)
end

--------------------------------------------------------------------------------

function M.openAlfredPref()
	local parentFolder = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not parentFolder:find("Alfred%.alfredpreferences") then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowId
	vim.fn.system { "open", uri }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	vim.fn.system { "open", "-a", "Alfred Preferences" }
end

--- open the next regex at https://regex101.com/
function M.openAtRegex101()
	local lang = vim.bo.filetype
	local text, pattern, replace, flags

	if lang == "javascript" or lang == "typescript" then
		vim.cmd.TSTextobjectSelect("@regex.outer")
		normal('"zy')
		vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
		text = vim.fn.getreg("z")
		pattern = text:match("/(.*)/")
		flags = text:match("/.*/(%l*)") or "gm"
		replace = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')
	elseif lang == "python" then
		normal('"zyi"vi"') -- yank & reselect inside quotes
		pattern = vim.fn.getreg("z")
		local flagInLine = vim.api.nvim_get_current_line():match("re%.([MIDSUA])")
		flags = flagInLine and "g" .. flagInLine:gsub("D", "S"):lower() or "g"
	else
		notify("", "Unsupported filetype.", "warn")
		return
	end

	-- `+` is the only character regex101 does not escape on its own. But for it
	-- to work, `\` needs to be escaped as well (SIC)
	pattern = pattern:gsub("%+", "%%2B"):gsub("\\", "%%5C")

	-- DOCS https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = ("https://regex101.com/?regex=%s&flags=%s&flavor=%s%s"):format(
		pattern,
		flags,
		lang,
		(replace and "&subst=" .. replace or "")
	)
	vim.fn.system { "open", url }
end

-- simple task selector from makefile
function M.selectMake()
	-- GUARD
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile)
	if not fileExists then
		notify("", "Makefile not found", "warn")
		return
	end

	local recipes = {}
	for line in io.lines(makefile) do
		local recipe = line:match("^[%w_-]+")
		if recipe then table.insert(recipes, recipe) end
	end

	vim.ui.select(recipes, {
		prompt = " make",
		kind = "make-selector",
	}, function(selection)
		if not selection then return end
		vim.cmd("silent! update")
		vim.cmd.lmake(selection)
	end)
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (Requires `expr = true` for the keymap.)
function M.toggleOrIncrement()
	-- CONFIG 
	local bool = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js/ts
	}

	local cword = vim.fn.expand("<cword>")
	local toggle
	for word, opposite in pairs(bool) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return "mzciw" .. toggle .. "<Esc>`z" end
	end
	return "<C-a>"
end

-- 1. in addition to toggling case of letters, also toggls some common characters
-- 2. does not mvoe the cursor to the left, useful for vertical changes
function M.betterTilde()
	local toggleSigns = {
		["'"] = '"',
		["+"] = "-",
		["!"] = "=", -- for != and ==
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		["<"] = ">",
	}
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)

	local changeTo
	for left, right in pairs(toggleSigns) do
		if charUnderCursor == left then changeTo = right end
		if charUnderCursor == right then changeTo = left end
	end
	if changeTo then
		normal("r" .. changeTo)
	else
		normal("v~") -- (`v~` instead of `~h` so dot-repetition also doesn't move the cursor)
	end
end

function M.gotoProject()
	-- CONFIG
	local projectFolder = vim.env.LOCAL_REPOS 

	---@param folder string
	local function browseProject(folder)
		require("telescope.builtin").find_files {
			prompt_title = "Project: " .. vim.fs.basename(folder),
			cwd = folder,
		}
	end

	local handler = vim.loop.fs_scandir(projectFolder)
	if not handler then return end
	local folders = {}
	repeat
		local file, type = vim.loop.fs_scandir_next(handler)
		if type == "directory" then table.insert(folders, projectFolder .. "/" .. file) end
	until not file

	-- GUARD
	if #folders == 0 then
		notify("", "No projects found.", "warn")
	elseif #folders == 1 then
		browseProject(folders[1])
	else
		vim.ui.select(folders, {
			prompt = " Select project:",
			format_item = function(folder) return vim.fs.basename(folder) end,
		}, function(selection)
			if selection then browseProject(selection) end
		end)
	end
end

--------------------------------------------------------------------------------
return M

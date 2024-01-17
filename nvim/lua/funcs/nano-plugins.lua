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
-- very simplified version of harpoon.nvim / other.nvim
function M.gotoAnchorFile()
	local anchorFiles = {
		{ "init.lua", "main.py", "main.ts" },
		{ "README.md" },
	}

	-- determine if currently on an anchorfile
	local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
	local idx = 0
	for i = 1, #anchorFiles do
		if vim.tbl_contains(anchorFiles[i], filename) then
			idx = i
			break
		end
	end
	local startIdx = idx

	-- find next anchorfile, skipping lists if they are not found in cwd
	local foundFile, checkedAllLists
	local listsChecked = 0
	repeat
		idx = math.fmod(idx, #anchorFiles) + 1
		if idx == startIdx then break end
		foundFile = vim.fs.find(anchorFiles[idx], { type = "file" })[1]
		if foundFile then
			vim.cmd.edit(foundFile)
			return
		end
		listsChecked = listsChecked + 1
		checkedAllLists = listsChecked == #anchorFiles
	until foundFile or checkedAllLists

	if foundFile then
		vim.cmd.edit(foundFile)
	else
		notify("Goto Anchor File", "No next anchor file found.", "info")
	end
end

--------------------------------------------------------------------------------

-- simplified yank history
function M.pasteFromNumberReg()
	local regs = {}
	for i = 0, 9 do
		table.insert(regs, { number = i, content = vim.fn.getreg(i) })
	end
	local pickers = require("telescope.pickers")
	local telescopeConf = require("telescope.config").values
	local actionState = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local finders = require("telescope.finders")
	local previewers = require("telescope.previewers")
	local currentFt = vim.bo.filetype

	pickers
		.new({}, {
			prompt_title = "󰅍 Select Register",
			sorter = telescopeConf.generic_sorter {},
			finder = finders.new_table {
				results = regs,
				entry_maker = function(reg)
					local firstLine = vim.split(reg.content, "\n")[1]
					local trimmed = vim.trim(firstLine):sub(1, 40)
					local display = reg.number .. ". " .. trimmed
					return { value = reg, ordinal = reg.content, display = display }
				end,
			},

			previewer = previewers.new_buffer_previewer {
				define_preview = function(self, entry)
					local regContent = entry.value.content
					local lines = vim.split(regContent, "\n")
					local bufnr = self.state.bufnr
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
					vim.api.nvim_buf_set_option(bufnr, "filetype", currentFt)
				end,
			},

			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					local reg = actionState.get_selected_entry().value.number
					actions.close(prompt_bufnr)
					normal('"' .. reg .. "p")
				end)
				return true
			end,
		})
		:find()
end

function M.openAlfredPref()
	local parentFolder = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not parentFolder:find("Alfred%.alfredpreferences") then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	vim.fn.system { "open", "alfredpreferences://navigateto/workflows>workflow>" .. workflowId }
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
		local recipe = line:match("^[%w_]+")
		if recipe then table.insert(recipes, recipe) end
	end

	vim.ui.select(recipes, { prompt = " make" }, function(selection)
		if not selection then return end
		vim.cmd("silent! update")
		vim.cmd.lmake(selection)
	end)
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (Requires `expr = true` for the keymap.)
function M.toggleOrIncrement()
	local cword = vim.fn.expand("<cword>")
	local bool = {
		["true"] = "false",
		["True"] = "False", -- capitalized for python
	}
	local toggle
	for word, opposite in pairs(bool) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return "mzciw" .. toggle .. "<Esc>`z" end
	end
	return "<C-a>"
end

-- simplified implementation of neogen.nvim
-- * requires nvim-treesitter-textobjects
-- * lsp usually provides better prefills for docstrings
function M.docstring()
	local function leaveVisualMode()
		local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
		vim.api.nvim_feedkeys(escKey, "nx", false)
	end

	local supportedFts = { "lua", "python", "javascript" }
	if not vim.tbl_contains(supportedFts, vim.bo.filetype) then
		notify("", "Unsupported filetype.", "warn")
		return
	end

	local ft = vim.bo.filetype
	vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	if ft == "python" then
		indent = indent .. (" "):rep(4)
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
		vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
		vim.cmd.startinsert()
	elseif ft == "lua" then
		vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { "---" })
		vim.api.nvim_win_set_cursor(0, { ln, 0 })
		vim.cmd.startinsert { bang = true }
		-- HACK to trigger the `@param;@return` luadoc completion from lua-ls
		vim.defer_fn(function()
			require("cmp").complete()
			require("cmp").confirm { select = true }
		end, 150)
		vim.defer_fn(vim.api.nvim_del_current_line, 900) -- remove `---comment`
		vim.defer_fn(leaveVisualMode, 1200)
	elseif ft == "javascript" then
		normal("t)") -- go to parameter, since cursor has to be on diagnostic for code action
		vim.lsp.buf.code_action {
			filter = function(action) return action.title == "Infer parameter types from usage" end,
			apply = true,
		}
		-- goto docstring (delayed, so code action can finish first)
		vim.defer_fn(function()
			vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
			normal("t}")
		end, 100)
	end
end

-- 1. in addition to toggling case of letters, also toggls some common characters
-- 2. does not mvoe the cursor to the left, useful for vertical changes
function M.betterTilde()
	local toggleSigns =
		{ ["'"] = '"', ["+"] = "-", ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }
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

---simplified implementation of tabout.nvim
---(should be mapped in insert-mode to `<Tab>`)
function M.tabout()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local charsBefore = line:sub(1, col)
	local onlyWhitespaceBeforeCursor = charsBefore:match("^%s*$")
	local frontOfMarkdownList = vim.bo.ft == "markdown" and charsBefore:match("^[%s-*+]*$")

	if onlyWhitespaceBeforeCursor or frontOfMarkdownList then
		-- using feedkeys instead of `expr = true`, since the cmp mapping
		-- does not work with `expr = true`
		local keyCode = vim.api.nvim_replace_termcodes("<C-t>", true, false, true)
		vim.api.nvim_feedkeys(keyCode, "i", false)
	elseif vim.bo.ft == "gitcommit" then
		vim.cmd.startinsert { bang = true }
	else
		local closingPairs = "[%]\"'`)}>]"
		local nextClosingPairPos = line:find(closingPairs, col + 1)
		if not nextClosingPairPos then return end

		vim.api.nvim_win_set_cursor(0, { row, nextClosingPairPos })
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

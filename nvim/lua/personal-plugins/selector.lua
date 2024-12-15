-- INFO
-- simple UI for `vim.ui.select`
--------------------------------------------------------------------------------

local config = {
	win = {
		relative = "cursor",
		row = 2,
		col = 0,
		border = vim.g.borderStyle,
		showKindInFooter = true,
	},
	keymaps = {
		confirm = "<CR>",
		abort = { "<Esc>", "q" },
		next = "<Tab>",
		prev = "<S-Tab>",
		inspect = "?",
	},

	-- extra customization of `vim.lsp.buf.code_action`
	codeaction = {
		icon = "󱐋",
		format_item = function(item) return ("%s [%s]"):format(item.action.title, item.action.kind) end,
	},

	-- automatically direct to telescope under certain conditions
	telescopeRedirect = {
		ifKindMatchesPattern = { "^tinygit" },
		ifMoreItemsThan = 10,
		opts = { -- accepts the common telescope picker config
			layout_config = {
				horizontal = { width = 0.7 },
			},
		},
	},
}

local pluginName = "Selector"
--------------------------------------------------------------------------------

local M = {}

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
local function notify(msg, level, opts)
	if not level then level = "info" end
	local defaultOpts = { title = pluginName }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts or {})
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

local function lnum() return vim.api.nvim_win_get_cursor(0)[1] end

---@class (exact) SelectorOpts
---@field prompt? string nvim spec
---@field kind? string nvim spec
---@field format_item? fun(item: any): string nvim spec
---@field footer? string specific to this plugin

--------------------------------------------------------------------------------

---@param items any[]
---@param opts SelectorOpts
---@param on_choice fun(item: any, idx?: integer)
local function telescopeRedirect(items, opts, on_choice)
	local installed, _ = pcall(require, "telescope")
	if not installed then
		notify("telescope.nvim is not installed.", "warn")
		return
	end

	-- DOCS https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#first-picker
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local actionState = require("telescope.actions.state")

	pickers
		.new(config.telescopeRedirect.opts, {
			prompt_title = opts.prompt:gsub(":%s*$", ""),
			sorter = conf.generic_sorter(config.telescopeRedirect.opts),

			finder = finders.new_table {
				results = items,
				entry_maker = function(entry)
					local display = opts.format_item and opts.format_item(entry) or entry
					return { value = entry, display = display, ordinal = display }
				end,
			},
			attach_mappings = function(promptBufnr, _map)
				actions.select_default:replace(function()
					actions.close(promptBufnr)
					local selection = actionState.get_selected_entry()
					on_choice(selection.value, selection.index)
				end)
				return true -- `true` = keep other mappings from the user
			end,
		})
		:find()
end

--------------------------------------------------------------------------------

---@param items any[]
---@param opts SelectorOpts
---@param on_choice fun(item: any, idx?: integer)
function M.selector(items, opts, on_choice)
	if #items == 0 then
		notify("No items to select from.", "warn")
		return
	end

	-- OPTIONS
	assert(type(on_choice) == "function", "`on_choice` must be a function.")
	local defaultOpts = { format_item = function(i) return i end, prompt = "Select", kind = nil }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts) ---@type SelectorOpts
	opts.prompt = opts.prompt:gsub(":%s*$", "") -- trim trailing `:` from prmpt

	if opts.kind == "codeaction" then
		opts.prompt = vim.trim(config.codeaction.icon .. " " .. opts.prompt)
		opts.format_item = config.codeaction.format_item or function(i) return i.action.title end
	end

	-- REDIRECT TO TELESCOPE
	local fallbackKind = vim.iter(config.telescopeRedirect.ifKindMatchesPattern)
		:any(function(p) return (opts.kind and opts.kind:find(p)) ~= nil end)
	local fallbackMore = #items > config.telescopeRedirect.ifMoreItemsThan
	if fallbackKind or fallbackMore then
		telescopeRedirect(items, opts, on_choice)
		return
	end

	-- PARAMETERS
	local choices = vim.tbl_map(opts.format_item, items)
	assert(type(choices[1]) == "string", "`opts.format_item` must return a string.")
	local longestChoice = vim.iter(choices):fold(0, function(acc, c) return math.max(acc, #c) end)
	local width = math.max(longestChoice, #opts.prompt, #opts.kind) + 2
	local height = #choices
	local footer = (config.win.showKindInFooter and opts.kind) and " " .. opts.kind .. " " or nil

	-- CREATE WINDOW
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, choices)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		relative = config.win.relative,
		row = config.win.row,
		col = config.win.col,
		width = width,
		height = height,
		title = " " .. opts.prompt .. " ",
		footer = footer and { { footer, "NonText" } } or nil,
		footer_pos = footer and "right" or nil,
		border = config.win.border,
		style = "minimal",
	})
	vim.wo[winid].statuscolumn = " " -- = left-padding
	vim.wo[winid].cursorline = height > 1
	vim.wo[winid].colorcolumn = ""
	vim.wo[winid].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].filetype = pluginName
	vim.wo[winid].sidescrolloff = 0

	-- highlighting
	pcall(vim.treesitter.start, bufnr, "markdown")
	vim.wo[winid].conceallevel = 3
	vim.wo[winid].concealcursor = "nvic"

	-- KEYMAPS
	local function map(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true }) end
	for _, key in ipairs(config.keymaps.abort) do
		map(key, vim.cmd.bwipeout)
	end
	map(config.keymaps.next, function()
		local cmd = lnum() == height and "gg" or "j"
		vim.cmd.normal { cmd, bang = true }
	end)
	map(config.keymaps.prev, function()
		local cmd = lnum() == 1 and "G" or "k"
		vim.cmd.normal { cmd, bang = true }
	end)
	map(config.keymaps.inspect, function()
		local out = vim.inspect(items[lnum()])
		notify(out, "debug", { title = "Inspect", ft = "lua" })
	end)
	map(config.keymaps.confirm, function()
		local ln = lnum() -- needs to be saved before deleting buffer
		vim.cmd.bwipeout()
		on_choice(items[ln], ln)
	end)

	-- UNMOUNT
	vim.api.nvim_create_autocmd("WinLeave", {
		desc = "Selector: Close window",
		once = true,
		callback = function()
			local curWin = vim.api.nvim_get_current_win()
			if curWin == winid then vim.api.nvim_buf_delete(bufnr, { force = true }) end
		end,
	})
end

vim.ui.select = M.selector

--------------------------------------------------------------------------------
return M

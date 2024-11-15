--[[ INFO
A simple wrapper for the task runner `just`
https://github.com/casey/just

USAGE
- `require("justice").just()`
- Navigate the window via `<Tab>` & `<S-Tab>`, select with `<CR>`.
- Quick-select recipes via keys shown at the left of the window.
]]
--------------------------------------------------------------------------------

local config = {
	recipes = {
		hide = { "release", "run-fzf" }, -- for recipes that require user input
		streaming = { "run-streaming" }, -- streams output, e.g. for progress bars. Requires `snacks.nvim`.
		quickfix = { "check-tsc" }, -- runs sync and sends output to quickfix
		commentMaxLen = 35, -- recipe comments are truncated if longer
	},
	keymaps = {
		closeWin = { "q", "<Esc>" },
		quickSelect = { "j", "a", "s" },
		next = "<Tab>",
		prev = "<S-Tab>",
		runRecipe = "<CR>",
		showRecipe = "<Space>",
		showVariables = "?", -- shows `just --evaluate` output
	},
	highlights = {
		quickSelect = "Conditional",
		icons = "Function",
	},
}

--------------------------------------------------------------------------------

---@class Recipe
---@field name string
---@field comment string
---@field quickfix boolean
---@field streaming boolean

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
local function notify(msg, level, opts)
	if not level then level = "info" end
	if not opts then opts = {} end
	opts.id = "just-recipe" -- replaces via `snacks.nvim`
	opts.title = opts.title and "Just: " .. opts.title or "Just"
	vim.notify(vim.trim(msg), vim.log.levels[level:upper()], opts)
end

--------------------------------------------------------------------------------

---@param recipe Recipe
local function runRecipe(recipe)
	-- 1) QUICKFIX
	if recipe.quickfix then
		local prev = vim.opt_local.makeprg:get() ---@diagnostic disable-line: unused-local,undefined-field
		vim.opt_local.makeprg = "just"
		vim.cmd.make(recipe.name)
		vim.opt_local.makeprg = prev

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		return
	end

	notify("Running…", nil, op{ title = recipe.name }-- FIX also fixes snacks.nvim loop-backback error

	-- 2) STREAMING
	if package.loaded["snacks"] and recipe.streaming then
		local function bufferedOut(_, data)
			if not data then return end
			-- severity not determined by stderr, since many CLIs send non-errors via stderr
			local severity = data:find("error") and "error" or "info"
			notify(data, severity, { title = recipe.name })
		end
		vim.system(
			{ "just", recipe.name },
			{ stdout = bufferedOut, stderr = bufferedOut },
			vim.schedule_wrap(function() vim.cmd.checktime() end)
		)
		return
	end

	-- 3) DEFAULT
	vim.system(
		{ "just", recipe.name },
		{},
		vim.schedule_wrap(function(out)
			local text = (out.stdout or "") .. (out.stderr or "")
			local severity = out.code == 0 and "info" or "error"
			notify(text, severity, { title = recipe.name })
			vim.cmd.checktime()
		end)
	)
end

---@param recipe Recipe
local function showRecipe(recipe)
	local stdout = vim.system({ "just", "--show", recipe.name }):wait().stdout or "Error"
	notify(stdout, "trace", {
		timeout = 10 * 1000, -- longer, so user can read it
		title = recipe.name,
		ft = "just",
	})
end

---@param recipes Recipe[]
local function select(recipes)
	local ns = vim.api.nvim_create_namespace("just-recipes")

	local title = "  Justfile "
	local content = vim.tbl_map(function(r)
		if not r.comment then return r.name end
		local max = config.recipes.commentMaxLen
		if #r.comment > max then r.comment = r.comment:sub(1, max) .. "…" end
		return r.name .. "  " .. r.comment
	end, recipes)

	-- calculate window size
	local longestRecipe = math.max(unpack(vim.tbl_map(function(r)
		local iconWidth = (r.streaming or r.quickfix) and 2 or 0
		return #r + iconWidth
	end, content)))
	local signcolumnWidth = 2
	local winWidth = math.max(longestRecipe, vim.api.nvim_strwidth(title)) + signcolumnWidth + 1
	local winHeight = #recipes

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = (vim.o.lines - winHeight) / 2,
		col = (vim.o.columns - winWidth) / 2,
		width = winWidth,
		height = winHeight,
		title = title,
		title_pos = "center",
		border = vim.g.borderStyle or "single",
		style = "minimal",
	})
	vim.wo[winnr].sidescrolloff = 0
	vim.wo[winnr].winfixbuf = true
	vim.wo[winnr].cursorline = true
	vim.wo[winnr].colorcolumn = ""
	vim.bo[bufnr].modifiable = false

	-- highlight comments and add icons
	for i = 1, #recipes do
		if recipes[i].comment then
			vim.api.nvim_buf_add_highlight(bufnr, ns, "Comment", i - 1, #recipes[i].name, -1)
		end
		if recipes[i].streaming or recipes[i].quickfix then
			local icon = recipes[i].streaming and "ﲋ" or ""
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name, {
				virt_text = { { " " .. icon .. " ", config.highlights.icons } },
				virt_text_pos = "inline",
			})
		end
	end

	-- general keymaps
	local opts = { buffer = bufnr, nowait = true }
	for _, key in pairs(config.keymaps.closeWin) do
		vim.keymap.set("n", key, vim.cmd.close, opts)
	end
	vim.keymap.set("n", config.keymaps.next, "j", opts)
	vim.keymap.set("n", config.keymaps.prev, "k", opts)
	vim.keymap.set("n", config.keymaps.runRecipe, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		runRecipe(recipes[lnum])
		vim.cmd.close()
	end, opts)
	vim.keymap.set("n", config.keymaps.showRecipe, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		showRecipe(recipes[lnum])
	end, opts)
	vim.keymap.set("n", config.keymaps.showVariables, function()
		local out = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
		notify(out, nil, { title = "Variables" })
	end, opts)

	-- quick-select keymaps
	for i = 1, #recipes do
		local recipe = recipes[i] -- save since `i` changes
		local key = config.keymaps.quickSelect[i] or " "
		vim.keymap.set("n", key, function()
			runRecipe(recipe)
			vim.cmd.close()
		end, opts)
		vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
			virt_text = { { key .. " ", config.highlights.quickSelect } },
			virt_text_pos = "inline",
		})
	end
end

---@nodiscard
---@return Recipe[]?
local function getRecipes()
	vim.cmd("silent! update") -- in case the user is working on the justfile itself

	local cmd = { "just", "--list", "--unsorted", "--list-heading=", "--list-prefix=" }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end
	local stdout = vim.split(result.stdout, "\n", { trimempty = true })

	local recipes = vim.iter(stdout)
		:map(function(line)
			local name, comment = line:match("(%S+)%s*# (.+)")
			if not comment then name = line:match("%S+") end
			return {
				name = name,
				comment = comment,
				streaming = vim.tbl_contains(config.recipes.streaming, name),
				quickfix = vim.tbl_contains(config.recipes.quickfix, name),
			}
		end)
		:filter(function(r) return not vim.tbl_contains(config.recipes.hide, r.name) end)
		:totable()
	return recipes
end

-----------------------------------------------------------------------------
local M = {}

function M.just()
	local recipes = getRecipes()
	if recipes then select(recipes) end
end

--------------------------------------------------------------------------------
return M

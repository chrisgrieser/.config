--[[ INFO
A simple wrapper for the task runner `just`
https://github.com/casey/just

USAGE
- `require("justice").just()`
- Navigate the window via `<Tab>` & `<S-Tab>`, select with `<CR>`.
- Quick-select recipes via keys shown at the left of the window.

REQUIREMENTS
- nvim 0.10+
- optional: snacks.nvim (for streaming output)
- optional: `just` Treesitter parser (`:TSInstall just`)
]]
--------------------------------------------------------------------------------

local config = {
	recipes = {
		quickfix = { "check-tsc" }, -- runs synchronously and sends output to quickfix list
		streaming = { "run-streaming" }, -- streams output, e.g. for progress bars (requires `snacks.nvim`)
		hidden = { "release", "run-fzf" }, -- for recipes that require user input
		commentMaxLen = 35, -- truncate recipe comments if longer
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		runRecipe = "<CR>",
		closeWin = { "q", "<Esc>", "<D-w>" },
		quickSelect = { "j", "a", "s", "d", "f" },
		showRecipe = "<Space>",
		showVariables = "?", -- shows output of `just --evaluate`
	},
	highlights = {
		quickSelect = "Conditional",
		icons = "Function",
	},
	icons = {
		just = "󱁤",
		streaming = "ﲋ",
		quickfix = "",
		hidden = "󰈉",
	},
}

--------------------------------------------------------------------------------

---@class Recipe
---@field name string
---@field comment string
---@field type "streaming"|"quickfix"|"hidden"|nil
---@field displayText string

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
local function notify(msg, level, opts)
	if not level then level = "info" end
	if not opts then opts = {} end
	opts.id = "just-recipe" -- `snacks.nvim` replaces notifications of same id
	opts.icon = config.icons.just
	opts.title = opts.title and "Just: " .. opts.title or "Just"
	vim.notify(vim.trim(msg), vim.log.levels[level:upper()], opts)
end

---@return integer
---@nodiscard
local function lnum() return vim.api.nvim_win_get_cursor(0)[1] end

--------------------------------------------------------------------------------

---@param recipe Recipe
local function runRecipe(recipe)
	vim.cmd("silent! update")

	-- 1) QUICKFIX
	if recipe.type == "quickfix" then
		local prev = vim.opt_local.makeprg:get() ---@diagnostic disable-line: unused-local,undefined-field
		vim.opt_local.makeprg = "just"
		vim.cmd.make(recipe.name)
		vim.opt_local.makeprg = prev

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		return
	end

	notify("Running…", nil, { title = recipe.name }) -- FIX also fixes snacks.nvim loop-backback error

	-- 2) STREAMING
	if package.loaded["snacks"] and recipe.type == "streaming" then
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
		title = recipe.name,
		ft = "just",
		keep = function() return true end,
	})
end

local function showVariables()
	local stdout = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
	notify(stdout, "trace", {
		title = "Variables",
		ft = "just",
		keep = function() return true end,
	})
end

---@nodiscard
---@return Recipe[]?
local function getRecipes()
	-- in case user is currently editing a Justfile
	if vim.bo.filetype == "just" then vim.cmd("silent! update") end

	local cmd = { "just", "--list", "--unsorted", "--list-heading=", "--list-prefix=" }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end
	local stdout = vim.split(result.stdout, "\n", { trimempty = true })

	local recipes = vim.iter(stdout)
		:map(function(line)
			local name, comment = line:match("^(%S+)%s*# (.+)")
			if comment then
				local max = config.recipes.commentMaxLen
				if #comment > max then comment = comment:sub(1, max) .. "…" end
			end
			if not name then name = line:match("^%S+") end
			local displayText = vim.trim(name .. "  " .. (comment or ""))

			local type
			if vim.tbl_contains(config.recipes.streaming, name) then type = "streaming" end
			if vim.tbl_contains(config.recipes.quickfix, name) then type = "quickfix" end
			if vim.tbl_contains(config.recipes.hidden, name) then type = "hidden" end

			return { name = name, comment = comment, type = type, displayText = displayText }
		end)
		:totable()
	return recipes
end

local function selectRecipe()
	local ns = vim.api.nvim_create_namespace("just-recipes")
	local title = (" %s Justfile "):format(config.icons.just)

	-- get recipes
	local allRecipes = getRecipes()
	if not allRecipes then return end
	local recipes = vim.tbl_filter(function(r) return r.type ~= "hidden" end, allRecipes)
	if #recipes == 0 then
		notify("Justfile has no recipes.", "warn")
		return
	end
	local hiddenCount = #allRecipes - #recipes

	-- calculate window size
	local longestRecipe = math.max(unpack(vim.tbl_map(function(r)
		local iconWidth = r.type and #config.icons[r.type] + 2 or 0
		return #r.displayText + iconWidth
	end, recipes)))
	local quickKeyWidth = 2
	local winWidth = math.max(longestRecipe, vim.api.nvim_strwidth(title)) + quickKeyWidth + 1
	local winHeight = #recipes

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	local lines = vim.tbl_map(function(r) return r.displayText end, recipes)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	local footer = (" %d %s "):format(hiddenCount, config.icons.hidden)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = (vim.o.lines - winHeight) / 2,
		col = (vim.o.columns - winWidth) / 2,
		width = winWidth,
		height = winHeight,
		border = vim.g.borderStyle or "single",
		style = "minimal",
		title = title,
		title_pos = "center",
		footer = hiddenCount > 0 and { { footer, "Comment" } } or nil,
		footer_pos = hiddenCount > 0 and "right" or nil,
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
		if recipes[i].type then
			local icon = config.icons[recipes[i].type]
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name, {
				virt_text = { { " " .. icon .. " ", config.highlights.icons } },
				virt_text_pos = "inline",
			})
		end
	end

	-- general keymaps
	local function closeWin()
		vim.cmd.close()
		local ok, snacks = pcall(require, "snacks")
		if ok then snacks.notifier.hide("just-recipe") end
	end
	local opts = { buffer = bufnr, nowait = true }
	local optsExpr = { buffer = bufnr, nowait = true, expr = true }
	for _, key in pairs(config.keymaps.closeWin) do
		vim.keymap.set("n", key, closeWin, opts)
	end
	vim.keymap.set("n", config.keymaps.next, function()
		if lnum() == #recipes then return "gg" end -- wrap
		return "j"
	end, optsExpr)
	vim.keymap.set("n", config.keymaps.prev, function()
		if lnum() == 1 then return "G" end -- wrap
		return "k"
	end, optsExpr)
	vim.keymap.set("n", config.keymaps.runRecipe, function()
		runRecipe(recipes[lnum()])
		closeWin()
	end, opts)
	vim.keymap.set("n", config.keymaps.showRecipe, function() showRecipe(recipes[lnum()]) end, opts)
	vim.keymap.set("n", config.keymaps.showVariables, showVariables, opts)

	-- quick-select keymaps
	for i = 1, #recipes do
		local recipe = recipes[i] -- save since `i` changes
		local key = config.keymaps.quickSelect[i] or " "
		vim.keymap.set("n", key, function()
			runRecipe(recipe)
			vim.cmd.close()
		end, opts)
		vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
			virt_text = {
				{ key, config.highlights.quickSelect },
				{ " " },
			},
			virt_text_pos = "inline",
		})
	end
end

-----------------------------------------------------------------------------
local M = {}
M.just = selectRecipe
return M

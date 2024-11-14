--[[ DOCS
A simple wrapper for the task runner `just`
https://github.com/casey/just

USAGE
- `require("justice").just()`
- Navigate the window via `<Tab>` & `<S-Tab>`, select with `<CR>`.
- Quick-select recipes via keys shown at the left of the window.

REQUIREMENTS:
- nvim 0.10+
- optional: snacks.nvim (for buffered output)
]]
--------------------------------------------------------------------------------

local config = {
	hideInRecipeSelection = { "release" }, -- for recipes that require user input
	outputInQuickfix = { "check-tsc" }, -- run recipes synchronously & unbuffered
	closeWinKeys = { "q", "<Esc>" },

	-- Overwrites the quick-select key for the 1st recipe.
	-- (For instance, if your keymap is `<leader>j`, you can set this to "j" for
	-- quicker access to it via `<leader>jj`.)
	firstRecipeQuickKey = "j",
}

--------------------------------------------------------------------------------

---@param recipe string
local function run(recipe)
	if not recipe then return end

	-- 1) MAKEPRG: sync, unbuffered, & quickfix
	-- (`makeprg` sends output to the quickfix list)
	if vim.tbl_contains(config.outputInQuickfix, recipe) then
		local prev = vim.opt_local.makeprg:get() ---@diagnostic disable-line: unused-local,undefined-field
		vim.opt_local.makeprg = "just"
		vim.cmd.make(recipe)
		vim.opt_local.makeprg = prev

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		return
	end

	-- 2) SYSTEM CALL: async & buffered
	-- (being buffered is relevant for things like progress bars)
	if package.loaded["snacks"] then -- REQUIRED `snacks.nvim`, to replace prev notice via `id`
		local buffer = ""
		local function bufferedOut(severity)
			return function(_, data)
				if not data then return end
				buffer = buffer .. data:gsub("\n$", "")
				local opts = { title = "Just: " .. recipe, id = "just-recipe" }
				vim.notify(buffer, vim.log.levels[severity], opts)
			end
		end
		vim.system(
			{ "just", recipe },
			{ stdout = bufferedOut("INFO"), stderr = bufferedOut("ERROR") },
			vim.schedule_wrap(function() vim.cmd.checktime() end)
		)
		return
	end

	-- 3) SYSTEM CALL: async & unbuffered
	-- (this is mostly just the fallback)
	vim.system(
		{ "just", recipe },
		{},
		vim.schedule_wrap(function(out)
			local text = vim.trim((out.stdout or "") .. (out.stderr or ""))
			local severity = out.code == 0 and "INFO" or "ERROR"
			vim.notify(text, vim.log.levels[severity], { title = "Just: " .. recipe })
			vim.cmd.checktime()
		end)
	)
end

---@param recipes string[]
local function select(recipes)
	local ns = vim.api.nvim_create_namespace("just-recipes")

	local title = "  Just Recipes "
	local longestRecipe = math.max(unpack(vim.tbl_map(function(r) return #r end, recipes)))
	local winWidth = math.max(longestRecipe, vim.api.nvim_strwidth(title))

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, recipes)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "cursor",
		row = 0,
		col = 0,
		width = winWidth,
		height = #recipes,
		title = title,
		border = "single",
		style = "minimal",
	})
	vim.wo[winnr].sidescrolloff = 0
	vim.wo[winnr].winfixbuf = true
	vim.wo[winnr].cursorline = true
	vim.bo[bufnr].modifiable = false

	-- GENERAL KEYMAPS
	for _, key in pairs(config.closeWinKeys) do
		vim.keymap.set("n", key, vim.cmd.close, { buffer = bufnr, nowait = true })
	end
	vim.keymap.set("n", "<Tab>", function()
		if vim.api.nvim_win_get_cursor(0)[1] == #recipes then return "gg" end
		return "j"
	end, { buffer = bufnr, nowait = true, expr = true })
	vim.keymap.set("n", "<S-Tab>", function()
		if vim.api.nvim_win_get_cursor(0)[1] == 1 then return "G" end
		return "k"
	end, { buffer = bufnr, nowait = true, expr = true })
	vim.keymap.set("n", "<CR>", function()
		local idx = vim.api.nvim_win_get_cursor(0)[1]
		run(recipes[idx])
		vim.cmd.close()
	end, { buffer = bufnr, nowait = true })

	-- QUICK-SELECT KEYMAPS
	local usedChars = vim.deepcopy(config.closeWinKeys)
	local idx = 0
	vim.iter(recipes):each(function(recipe)
		idx = idx + 1
		local charNum = 0
		local char
		if config.firstRecipeQuickKey and idx == 1 then char = config.firstRecipeQuickKey end
		while char == nil or vim.tbl_contains(usedChars, char) do
			charNum = charNum + 1
			char = recipe:sub(charNum, charNum)
			if char == "" then return end -- skip if no letter available
		end
		table.insert(usedChars, char)

		vim.keymap.set("n", char, function()
			run(recipe)
			vim.cmd.close()
		end, { buffer = bufnr, nowait = true })
		vim.api.nvim_buf_set_extmark(bufnr, ns, idx - 1, 0, {
			sign_text = char:upper(),
			sign_hl_group = "CursorLineNr",
		})
	end)
end

-----------------------------------------------------------------------------
local M = {}

function M.just()
	vim.cmd("silent! update")

	local result = vim.system({ "just", "--summary", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR, { title = "Just" })
		return
	end
	local recipes = vim.iter(vim.split(vim.trim(result.stdout), " "))
		:filter(function(r) return not vim.tbl_contains(config.hideInRecipeSelection, r) end)
		:totable()

	select(recipes)
end

--------------------------------------------------------------------------------
return M

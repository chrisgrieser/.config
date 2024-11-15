--[[ INFO
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
	recipes = {
		hide = { "release" }, -- for recipes that require user input
		useQuickfix = { "check-tsc" }, -- also run synchronously & unbuffered
		commentMaxLen = 35,
	},
	keymaps = {
		closeWin = { "q", "<Esc>" },
		quickSelect = { "j", "a", "s", "d", "f" },
	},
}

--------------------------------------------------------------------------------

---@alias Recipe { name: string, comment: string }

---@param recipe string
local function run(recipe)
	if not recipe then return end

	-- 1) MAKEPRG: sync, unbuffered, & quickfix
	-- (`makeprg` sends output to the quickfix list)
	if vim.tbl_contains(config.recipes.useQuickfix, recipe) then
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

---@param recipes { name: string, comment: string }[]
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
	local longestRecipe = math.max(unpack(vim.tbl_map(function(r) return #r end, content)))
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

	-- highlight comments
	for ln = 1, #recipes do
		if recipes[ln].comment then
			local colStart = #recipes[ln].name + 2
			vim.api.nvim_buf_add_highlight(bufnr, ns, "Comment", ln - 1, colStart, -1)
		end
	end

	-- general keymaps
	local opts = { buffer = bufnr, nowait = true }
	for _, key in pairs(config.keymaps.closeWin) do
		vim.keymap.set("n", key, vim.cmd.close, opts)
	end
	vim.keymap.set("n", "<Tab>", "j", opts)
	vim.keymap.set("n", "<S-Tab>", "k", opts)
	vim.keymap.set("n", "<CR>", function()
		local i = vim.api.nvim_win_get_cursor(0)[1]
		run(recipes[i].name)
		vim.cmd.close()
	end, opts)

	-- quick-select keymaps
	local i = 0
	for _, key in pairs(config.keymaps.quickSelect) do
		i = i + 1
		if i > #recipes then break end
		local recipe = recipes[i].name
		local hlgroup = vim.tbl_contains(config.recipes.useQuickfix, recipe) and "WarningMsg"
			or "CursorLineNr"
		vim.keymap.set("n", key, function()
			run(recipe)
			vim.cmd.close()
		end, opts)
		vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
			virt_text = { { key .. " ", hlgroup } },
			virt_text_pos = "inline",
		})
	end
end

---@nodiscard
---@return Recipe[]?
local function getRecipes()
	vim.cmd("silent! update") -- in case the user is working on the justfile itself

	local result = vim.system({ "just", "--list", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR, { title = "Just" })
		return
	end
	local stdout = vim.split(result.stdout, "\n", { trimempty = true })
	table.remove(stdout, 1) -- remove header

	local recipes = vim.iter(stdout)
		:map(function(line)
			local name, comment = line:match("^%s*(%S+)%s*# (.+)$")
			if not comment then name = line:match("%S+") end
			return { name = name, comment = comment }
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

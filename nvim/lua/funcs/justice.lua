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
		commentMaxLen = 35,
	},
	keymaps = {
		closeWin = { "q", "<Esc>" },
		quickSelect = { "j", "a", "s", "d", "f", "k" },
	},
	highlights = {
		quickSelect = "Conditional",
		icons = "Function",
	},
}

--------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("just-recipes")
---@alias Recipe { name: string, comment: string, quickfix: boolean, streaming: boolean }

---@param recipe string
local function run(recipe)
	if not recipe then return end

	-- 1) QUICKFIX
	if vim.tbl_contains(config.recipes.quickfix, recipe) then
		local prev = vim.opt_local.makeprg:get() ---@diagnostic disable-line: unused-local,undefined-field
		vim.opt_local.makeprg = "just"
		vim.cmd.make(recipe)
		vim.opt_local.makeprg = prev

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		return
	end

	local opts = { title = "Just: " .. recipe, id = "just-recipe" }
	vim.notify("Running…", nil, opts) -- FIX also fixes loop-backback error

	-- 2) STREAMING
	if package.loaded["snacks"] and vim.tbl_contains(config.recipes.streaming, recipe) then
		local function bufferedOut(_, data)
			if not data then return end
			-- severity not determined by stderr, since many CLIs send non-errors via stderr
			local severity = data:find("error") and "ERROR" or "INFO"
			vim.notify(vim.trim(data), vim.log.levels[severity], opts)
		end
		vim.system(
			{ "just", recipe },
			{ stdout = bufferedOut, stderr = bufferedOut },
			vim.schedule_wrap(function() vim.cmd.checktime() end)
		)
		return
	end

	-- 3) DEFAULT
	vim.system(
		{ "just", recipe },
		{},
		vim.schedule_wrap(function(out)
			local text = vim.trim((out.stdout or "") .. (out.stderr or ""))
			local severity = out.code == 0 and "INFO" or "ERROR"
			vim.notify(text, vim.log.levels[severity], opts)
			vim.cmd.checktime()
		end)
	)
end

---@param recipes Recipe[]
local function select(recipes)
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

		vim.keymap.set("n", key, function()
			run(recipe)
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
		vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR, { title = "Just" })
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

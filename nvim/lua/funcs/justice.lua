--[[ DOCS
A simple wrapper for the task runner `just`
https://github.com/casey/just

REQUIREMENTS:
- nvim 0.10+
- which-key.nvim
- optional: snacks.nvim (for buffered output)
]]
--------------------------------------------------------------------------------

local config = {
	hideInRecipeSelection = { "release" }, -- for recipes that require user input
	outputInQuickfix = { "check-tsc" }, -- run recipes synchronously & unbuffered
	quickKeys = "jasdf", -- for quick selection via which-key
	leaderKey = "<leader>j",
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

---@return string[]|false
local function getRecipes()
	vim.cmd("silent! update")

	local result = vim.system({ "just", "--summary", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR, { title = "Just" })
		return false
	end
	local recipes = vim.iter(vim.split(vim.trim(result.stdout), " "))
		:filter(function(r) return not vim.tbl_contains(config.hideInRecipeSelection, r) end)
		:totable()

	return recipes
end

--------------------------------------------------------------------------------

---@return wk.Spec
local function getWhichkeySpec()
	local spec = vim.iter(getRecipes() or {})
		:map(function(recipe)
			return recipe
		end)
		:totable()
	return spec
end

local ok, whichkey = pcall(require, "which-key")
if not ok then
	vim.notify("which-key.nvim not found", vim.log.levels.ERROR, { title = "Just" })
	return
end
whichkey.add {
	{ config.leaderKey, group = " Just", mode = { "n", "x" }, expand = getWhichkeySpec },
}

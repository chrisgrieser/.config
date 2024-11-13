--[[ INFO
A simple wrapper for the task runner `just`
https://github.com/casey/just

USAGE
-- select a recipe via `vim.ui.select`
require("funcs.just").just()

-- run the 1st recipe of the Justfile
require("funcs.just").just(1)

-- run the `n`-th recipe of the Justfile
require("funcs.just").just(n)

REQUIREMENTS:
- nvim 0.10+
- optional: snacks.nvim (buffered output)
- optional: dressing.nvim (nicer `vim.ui.select`)
]]
--------------------------------------------------------------------------------

local config = {
	hideRecipesInSelection = { "release" }, -- since my `release` tasks require user input
	outputRecipesInQuickfix = { "check-tsc" },
}

--------------------------------------------------------------------------------

---@param recipe string
local function run(recipe)
	if not recipe then return end

	-- 1) MAKEPRG: sync, unbuffered, & quickfix
	-- (`makeprg` sends output to the quickfix list)
	if vim.tbl_contains(config.outputRecipesInQuickfix, recipe) then
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
	vim.system({ "just", recipe }, {}, vim.schedule_wrap(function(out)
		local text = vim.trim((out.stdout or "") .. (out.stderr or ""))
		local severity = out.code == 0 and "INFO" or "ERROR"
		vim.notify(text, vim.log.levels[severity], { title = "Just: " .. recipe })
		vim.cmd.checktime()
	end))
end

-----------------------------------------------------------------------------
local M = {}

---Simple taskrunner using `just`
---@param recipeIndex? number
function M.just(recipeIndex)
	vim.cmd("silent! update")

	local result = vim.system({ "just", "--summary", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR, { title = "Just" })
		return
	end
	local recipes = vim.iter(vim.split(vim.trim(result.stdout), " "))
		:filter(function(r) return not vim.tbl_contains(config.hideRecipesInSelection, r) end)
		:totable()

	if type(recipeIndex) == "number" then
		run(recipes[recipeIndex])
		return
	end

	vim.ui.select(recipes, { prompt = " Just Recipes", kind = "plain" }, run)
end

--------------------------------------------------------------------------------
return M

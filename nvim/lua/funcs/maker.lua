local M = {}

--------------------------------------------------------------------------------

---@return boolean whether the makefile exists
local function checkForMakefile()
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile) ~= nil
	if not fileExists then
		vim.notify("Makefile not found.", vim.log.levels.WARN, { title = "maker.nvim" })
		return false
	end
	return true
end

---Runs make, same as `:make` but does not fill the quickfix list. Useful make
--is only used as task runner
---@param recipe string execute named recipe. without recipe, runs make without arg, executing first recipe by default.
local function runMake(recipe)
	if not checkForMakefile() then return end

	-- using async jobstart in case of a slow recipe
	vim.fn.jobstart({ "make", "--silent", recipe }, {
		stdout_buffered = true,
		stderr_buffered = true,
		detach = true, -- run even when quitting nvim
		on_stdout = function(_, data)
			if data[1] == "" and #data == 1 then return end
			local output = table.concat(data, "\n"):gsub("%s*$", "")
			vim.notify(output, vim.log.levels.INFO, { title = "make " .. recipe })
		end,
		on_stderr = function(_, data)
			if data[1] == "" and #data == 1 then return end
			local output = table.concat(data, "\n"):gsub("%s*$", "")
			vim.notify(output, vim.log.levels.WARN, { title = "make " .. recipe })
		end,
	})
end

---Select a recipe from the makefile
---@param useFirst? any use the first recipe, like running `make` without argument
function M.make(useFirst)
	local makefile = vim.loop.cwd() .. "/Makefile"
	if not checkForMakefile() then return end

	local function getRecipe(line) return line:match("^[%w_]+") end

	local recipes = {}
	for line in io.lines(makefile) do
		if getRecipe(line) then
			line = line:gsub(":", "", 1) -- remove first colon
			table.insert(recipes, line)
		end
	end

	if useFirst then
		runMake(getRecipe(recipes[1]))
		return
	end

	-- colorize, e.g. comments in the same line
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "DressingSelect",
		once = true, -- do not affect other dressing selections
		callback = function()
			pcall(vim.api.nvim_buf_set_name, 0, "Makefile") -- for statusline plugins
			vim.bo.filetype = "make"
		end,
	})

	vim.ui.select(recipes, { prompt = " Select recipe:", kind = "make" }, function(selection)
		if not selection then return end
		runMake(getRecipe(selection))
	end)
end

--------------------------------------------------------------------------------

return M

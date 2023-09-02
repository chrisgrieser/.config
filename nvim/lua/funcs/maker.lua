local M = {}

--------------------------------------------------------------------------------

---@return boolean whether the makefile exists
local function checkForMakefile()
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile) ~= nil
	if not fileExists then
		vim.notify("Makefile not found.", vim.log.levels.WARN)
		return false
	end
	return true
end

---Runs make, same as `:make` but does not fill the quickfix list. Useful make
--is only used as task runner
---@param recipe? string execute named recipe. without recipe, runs make without arg, executing first recipe by default.
function M.make(recipe)
	if not checkForMakefile() then return end
	local output = vim.fn.system { "make", "--silent", recipe }
	if vim.v.shell_error ~= 0 then
		local title = recipe and recipe or "Error"
		vim.notify(title .."\n" .. output, vim.log.levels.ERROR)
	elseif output ~= "" then
		local title = recipe and recipe or "Make"
		vim.notify(title .. ":\n" .. output)
	end
end

---Select a recipe from the makefile
function M.selectMake()
	local makefile = vim.loop.cwd() .. "/Makefile"
	if not checkForMakefile() then return end

	-- color make comment
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "DressingSelect",
		once = true, -- do not affect other dressing selections
		callback = function()
			local winNs = 1
			vim.api.nvim_win_set_hl_ns(0, winNs)
			vim.fn.matchadd("MakeComment", "#.*$")
			vim.api.nvim_set_hl(winNs, "MakeComment", { link = "Comment" })
		end,
	})

	local recipes = {}
	for line in io.lines(makefile) do
		if line:find("^%w+") then
			line = line:gsub(":", "")
			table.insert(recipes, line)
		end
	end

	vim.ui.select(recipes, { prompt = " Select recipe:" }, function(recipe)
		if recipe == nil then return end
		recipe = recipe:match("^%w+") -- remove comment and ":"
		M.make(recipe)
	end)
end

--------------------------------------------------------------------------------

return M

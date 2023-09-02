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
---@param recipe string execute named recipe. without recipe, runs make without arg, executing first recipe by default.
local function runMake(recipe)
	if not checkForMakefile() then return end

	local output = vim.fn.system({ "make", "--silent", recipe }):gsub("%s+$", "")
	local success = vim.v.shell_error == 0
	local title = recipe .. ": "
	if output:find("[\n\r]") then title = title .. "\n" end -- format multi-line-output

	if success then
		if output == "" then output = "Done." end
		vim.notify(title .. output)
	else
		vim.notify("Error " .. title .. output, vim.log.levels.ERROR)
	end
end

---Select a recipe from the makefile
---@param useFirst? any use the first recipe, like running `make` without argument
function M.selectMake(useFirst)
	local makefile = vim.loop.cwd() .. "/Makefile"
	if not checkForMakefile() then return end

	local recipes = {}
	for line in io.lines(makefile) do
		if line:find("^[%w_]+") then
			line = line:gsub(":", "", 1) -- remove first colon
			table.insert(recipes, line)
		end
	end

	if useFirst then
		runMake(recipes[1])
		return
	end

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

	vim.ui.select(recipes, { prompt = " Select recipe:" }, function(recipe)
		if recipe == nil then return end
		recipe = recipe:match("^[%w_]+") -- remove comment and ":"
		runMake(recipe)
	end)
end

--------------------------------------------------------------------------------

return M

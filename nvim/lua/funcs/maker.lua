local M = {}

--------------------------------------------------------------------------------

---Select a recipe from the makefile
function M.make()
	local makefile = vim.loop.cwd() .. "/Makefile"

	local function getRecipe(line) return line:match("^[%w_]+") end

	local recipes = {}
	for line in io.lines(makefile) do
		if getRecipe(line) then
			line = line:gsub(":", "", 1) -- remove first colon
			table.insert(recipes, line)
		end
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
		vim.cmd.lmake(selection)
	end)
end

--------------------------------------------------------------------------------

return M

local M = {}
--------------------------------------------------------------------------------

-- TODO flags

--------------------------------------------------------------------------------

-- iterate lines and replace
local function substituteLines(lines, toSearch, toReplace)
	local newBufferLines = {}
	for _, line in pairs(lines) do
		local newLine = line:gsub(toSearch, toReplace) -- TODO different substitution engine here
		table.insert(newBufferLines, newLine)
	end
	return newBufferLines
end

---main function running the substitution
---@param opts table
local function executeSubstitution(opts)
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]
	local line1 = opts.line1
	local line2 = opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

	local newBufferLines = substituteLines(bufferLines, toSearch, toReplace)
	vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)
end

-- https://neovim.io/doc/user/map.html#%3Acommand-preview
local function previewSubstitution(opts, ns, preview_buf)
	if preview_buf then
		vim.notify("vim.opt.inccommand = 'split' has not been implemented yet", vim.log.levels.WARN)
		return
	end
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local line1 = opts.line1
	local line2 = opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
	local toSearch = input[1]
	local toReplace = input[2]

	-- preview for search (if no replacement value given yet)
	if not toReplace then
		for i, line in ipairs(bufferLines) do
			local start_idx, end_idx = line:find(toSearch)
			if start_idx then
				vim.api.nvim_buf_add_highlight(0, ns, "Substitute", line1 + i - 2, start_idx - 1, end_idx)
			end
		end

	-- preview for replacement (as soon as replacement value is found)
	else
		-- live preview the changes
		local newBufferLines = substituteLines(bufferLines, toSearch, toReplace)
		vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)

		-- add highlights for the replacement
		-- INFO uses indices from the search values, to not highlight existing
		-- instances of the replacement value in the buffer
		for i, line in ipairs(bufferLines) do
			local lineIdx = line1 + i - 2
			local startIdx, _ = line:find(toSearch)
			if startIdx then
				-- TODO make this work with dynamic length of replacement
				local endIdx = startIdx + #toReplace - 1 
				vim.api.nvim_buf_add_highlight(0, ns, "Substitute", lineIdx, startIdx - 1, endIdx)
			end
		end
	end

	-- Return the value of the preview type
	return 2
end

-- adds the usercommand as ":S" and ":LuaSubstitute"
function M.setup()
	vim.api.nvim_create_user_command("S", executeSubstitution, {
		nargs = "?",
		range = "%",
		addr = "lines",
		preview = previewSubstitution,
	})
	vim.api.nvim_create_user_command("LuaSubstitute", executeSubstitution, {
		nargs = "?",
		range = "%",
		addr = "lines",
		preview = previewSubstitution,
	})
end

return M

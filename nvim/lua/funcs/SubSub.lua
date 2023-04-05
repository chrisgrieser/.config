local M = {}
--------------------------------------------------------------------------------

-- iterate lines and replace
---@param lines string[]
---@param toSearch string
---@param toReplace string
---@nodiscard
---@return string[]
local function substituteLines(lines, toSearch, toReplace)
	local newBufferLines = {}
	for _, line in pairs(lines) do
		local newLine = line:gsub(toSearch, toReplace) -- TODO different substitution engine here
		table.insert(newBufferLines, newLine)
	end
	return newBufferLines
end

---process the parameters given in the user command (ranges, args, etc.)
---@param opts table
---@nodiscard
---@return integer start line of range
---@return integer end line of range
---@return string[] buffer lines
---@return string term to search
---@return string replacement
local function processParameters(opts)
	-- "trimempty" allows to leave out the first and third "/" from regular `:s`
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]

	local line1 = opts.line1
	local line2 = opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace
end

---main function running the substitution
---@param opts table
local function executeSubstitution(opts)
	local line1, line2, bufferLines, toSearch, toReplace = processParameters(opts)
	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", vim.log.levels.ERROR)
		return
	end

	local newBufferLines = substituteLines(bufferLines, toSearch, toReplace)
	vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)
end

-- https://neovim.io/doc/user/map.html#%3Acommand-preview
---@param opts table
---@param ns number namespace for the highlight
---@param preview_buf boolean true if inccommand=split. (Not implemented yet.)
---@return integer?
local function previewSubstitution(opts, ns, preview_buf)
	if preview_buf then
		vim.notify_once(
			"SubSub does not support 'inccommand=split' yet. Please use 'inccommand=unsplit'.",
			vim.log.levels.WARN
		)
		return
	end
	local line1, line2, bufferLines, toSearch, toReplace = processParameters(opts)

	-- live preview the changes
	if toReplace then
		local newBufferLines = substituteLines(bufferLines, toSearch, toReplace)
		vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)
	end

	-- Highlights
	-- if no replacement entered yet: highlight search term
	-- if replacement entered: highlight replacement
	for i, line in ipairs(bufferLines) do
		local startIdx, endIdx = line:find(toSearch)
		if startIdx then
			-- TODO make this work with dynamic length of replacement
			if toReplace then endIdx = startIdx + #toReplace - 1 end
			vim.api.nvim_buf_add_highlight(0, ns, "Substitute", line1 + i - 2, startIdx - 1, endIdx)
		end
	end

	return 2 -- return the value of the preview type
end

-- adds the usercommand as ":S" and ":Substitute"
function M.setup()
	local commands = { "S", "Substitute" }
	for _, cmd in pairs(commands) do
		vim.api.nvim_create_user_command(cmd, executeSubstitution, {
			nargs = "?",
			range = "%", -- defaults to whole buffer
			addr = "lines",
			preview = previewSubstitution,
		})
	end
end

return M

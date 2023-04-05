local M = {}
--------------------------------------------------------------------------------

-- iterate lines and replace

---@param lines string[]
---@param toSearch string
---@param toReplace string
---@param singleRepl boolean single replacement or not
---@nodiscard
---@return string[]
local function substituteLines(lines, toSearch, toReplace, singleRepl)
	local newBufferLines = {}
	local occurrences = singleRepl and 1 or nil
	for _, line in pairs(lines) do
		-- TODO different substitution engine here
		local newLine = line:gsub(toSearch, toReplace, occurrences)
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
---@return string|nil replacement
---@return boolean whether to search first or all occurrences in line
local function processParameters(opts)
	-- "trimempty" allows to leave out the first and third "/" from regular `:s`
	local input = vim.split(opts.args, "/", { trimempty = true, plain = false })
	local toSearch, toReplace, flags = input[1], input[2], input[3]
	local singleRepl = (flags and flags:find("g")) == nil

	local line1, line2 = opts.line1, opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace, singleRepl
end

---@param opts table
local function executeSubstitution(opts)
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts)
	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", vim.log.levels.ERROR)
		return
	end
	local newBufferLines = substituteLines(bufferLines, toSearch, toReplace, singleRepl)
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
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts)

	-- live preview the changes
	if toReplace then
		local newBufferLines = substituteLines(bufferLines, toSearch, toReplace, singleRepl)
		vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)
	end

	-- Highlights //
	for i, line in ipairs(bufferLines) do
		local matchesInLine = {}
		local startIdx, endIdx = 0, 0

		while true do
			startIdx, endIdx = line:find(toSearch, startIdx + 1)
			if not startIdx then break end
			table.insert(matchesInLine, { startPos = startIdx, endPos = endIdx })
			if singleRepl then break end -- only needs first match
		end

		for _, match in pairs(matchesInLine) do
			-- TODO make this work with dynamic length of replacement
			if toReplace then match.endPos = match.startPos + #toReplace - 1 end
			vim.api.nvim_buf_add_highlight(
				0,
				ns,
				"Substitute",
				line1 + i - 2,
				match.startPos - 1,
				match.endPos
			)
		end
	end

	return 2 -- return the value of the preview type
end

-- adds the usercommand
function M.setup()
	local commands = { "S", "SubSub" }
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

local M = {}
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

---@class hlPos Position of an highlight to apply
---@field startCol number
---@field endCol number

---more complicated than just running gsub on each line, since the shift in
---length needs to be determined for each substitution, for the preview highlight
---@param lines string[]
---@param toSearch string
---@param toReplace string
---@param singleRepl boolean single replacement or not
---@nodiscard
---@return table[hlPos[]] hlPosInAllLines
local function calcReplHighlights(lines, toSearch, toReplace, singleRepl)
	local hlPosInAllLines = {}

	-- iterate lines
	for _, line in pairs(lines) do
		-- find all startPositions in the line
		local startPositions = {}
		for col in line:gmatch("()" .. toSearch) do
			table.insert(startPositions, col)
			if singleRepl then break end
		end

		-- iterate matches in given line
		local hlPosInThisLine = {}
		local previousShift = 0
		for i, startPos in ipairs(startPositions) do
			local _, endPos = line:find(toSearch, startPos + 1)

			local lineWithSomeSubs = line:gsub(toSearch, toReplace, i)
			local diff = (#lineWithSomeSubs - #line) + previousShift
			startPositions = startPositions + previousShift
			endPos = endPos + previousShift + diff -- shift of end position due to replacement

			table.insert(hlPosInThisLine, { startCol = startPos, endCol = endPos })
			previousShift = previousShift + diff -- remember shift 
		end

		table.insert(hlPosInAllLines, hlPosInThisLine)
	end

	return hlPosInAllLines
end

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function performSubstitition(opts)
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts)
	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", vim.log.levels.ERROR)
		return
	end
	local newBufferLines = {}
	local occurrences = singleRepl and 1 or nil
	for _, line in pairs(bufferLines) do
		local newLine = line:gsub(toSearch, toReplace, occurrences)
		table.insert(newBufferLines, newLine)
	end
	-- INFO during previeing, this will only replace the values in the buffer
	-- preview, not the actual buffer
	vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, newBufferLines)
end

-- https://neovim.io/doc/user/map.html#%3Acommand-preview
---@param opts table
---@param ns number namespace for the highlight
---@param preview_buf boolean true if inccommand=split. (Not implemented yet.)
---@return integer? -- value of preview type
local function previewSubstitution(opts, ns, preview_buf)
	if preview_buf then
		vim.notify_once(
			"SubSub does not support 'inccommand=split' yet. Please use 'inccommand=unsplit'.",
			vim.log.levels.WARN
		)
		return
	end
	local line1, _, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts)

	-- NO REPLACE VALUE YET = ONLY SEARCH TERMS TO HIGHLIGHT
	if not toReplace then
		for i, line in ipairs(bufferLines) do
			-- only highlighting first match, since the g-flag can only be entered
			-- when there is a substitution value
			local startPos, endPos = line:find(toSearch)
			if startPos then
				-- stylua: ignore
				vim.api.nvim_buf_add_highlight(0, ns, "Substitute", line1 + i - 2, startPos - 1, endPos)
			end
		end

	-- WITH REPLACE VALUE: PREVIEW CHANGES & HIGHLIGHT THEM
	else
		-- preview the changes
		performSubstitition(opts)
		local shiftsInEveryLine = calcReplHighlights(bufferLines, toSearch, toReplace, singleRepl)

		-- iterate lines
		for i, shiftsInLine in pairs(hlPosInAllLines) do
			-- iterate positions to highlight in each line
			for _, hlPos in pairs(positionsInLine) do
				vim.api.nvim_buf_add_highlight(0, ns, "Substitute", line1 + i - 2, startPos - 1, endPos)
			end
		end
	end

	return 2 -- return the value of the preview type
end

-- adds the usercommand
function M.setup()
	local commands = { "S", "SubSub" }
	for _, cmd in pairs(commands) do
		vim.api.nvim_create_user_command(cmd, performSubstitition, {
			nargs = "?",
			range = "%", -- defaults to whole buffer
			addr = "lines",
			preview = previewSubstitution,
		})
	end
end

return M

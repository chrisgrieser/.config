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

---@param str string
---@param toSearch string lua pattern string
---@param singleRepl boolean true: first match, false: all matches
---@return integer[] startposition of matches
local function matchesInString(str, toSearch, singleRepl)
	local matches = {}
	for i in str:gmatch("()" .. toSearch) do
		table.insert(matches, i)
		if singleRepl then break end
	end
	return matches
end

--------------------------------------------------------------------------------

---more complecated than just running gsub on each line, since the shift in
---length needs to be determined for each substitution, for the preview highlight
---@param lines string[]
---@param toSearch string
---@param toReplace string
---@param singleRepl boolean single replacement or not
---@nodiscard
---@return table[integer[]] -- shiftsInEveryLine
local function calculateLineShifts(lines, toSearch, toReplace, singleRepl)
	local shiftsInEveryLine = {}

	-- iterate lines
	for _, line in pairs(lines) do
		local numOfMatches = 0
		for _ in line:gmatch("()" .. toSearch) do
			numOfMatches = numOfMatches + 1
			if singleRepl then break end
		end

		-- iterate matches in given line
		local shiftsInThisLine = {}
		local sum = 0 -- needed to factor in the previous shifts in the calculation of shifts
		for idx = 1, #numOfMatches, 1 do
			local lineWithSomeSubs = line:gsub(toSearch, toReplace, idx)
			local diff = #lineWithSomeSubs - #line - sum
			sum = sum + diff
			table.insert(shiftsInThisLine, diff)
		end

		table.insert(shiftsInEveryLine, shiftsInThisLine)
	end

	return shiftsInEveryLine
end

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function executeSubstitution(opts)
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
	local line1, _, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts)

	-- no replace value yet = only search terms to highlight
	if not toReplace then
		-- iterate lines
		for i, line in ipairs(bufferLines) do
			local matchesInLine = {}
			for startPos in line:gmatch("()" .. toSearch) do
				table.insert(matchesInLine, startPos)
				if singleRepl then break end
			end
			-- iterate matches in that line
			for _, match in pairs(matchesInLine) do
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
	else
		-- preview the changes
		executeSubstitution(opts)
		-- TODO get shifts and create highlights based on that
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

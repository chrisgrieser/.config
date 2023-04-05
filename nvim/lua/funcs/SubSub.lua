local M = {}
local warn = vim.log.levels.WARN
local delimiter = "/"
local hlgroup = "Substitute"
local regexFlavor, showNotification

--------------------------------------------------------------------------------

---function performing the actual string substitution
---@param inputLines string[]
---@param toSearch string
---@param toReplace string
---@param numOfReplacements integer|nil nil will perform all replacements
---@param language "lua"|"javascript"
---@nodiscard
---@return string[] outputLines
---@return integer totalReplacementCount
local function replace(inputLines, toSearch, toReplace, numOfReplacements, language)
	local outputLines = {}
	local totalReplacementCount = 0
	for _, line in pairs(inputLines) do
		local newLine, replMade
		if language == "lua" then
			newLine, replMade = line:gsub(toSearch, toReplace, numOfReplacements)
		elseif language == "javascript" then
		end
		totalReplacementCount = totalReplacementCount + replMade
		table.insert(outputLines, newLine)
	end
	return outputLines, totalReplacementCount
end

---function performing a search
---@param str string
---@param toSearch string
---@param fromIdx integer perform find from this index
---@param language "lua"|"javascript"
---@nodiscard
---@return integer startPos of match, nil if no match
---@return integer endPos of match, nil if no match
local function find(str, toSearch, fromIdx, language)
	local startPos, endPos
	if language == "lua" then
		startPos, endPos = str:find(toSearch, fromIdx)
	elseif language == "javascript" then
	end
	return startPos, endPos
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---process the parameters given in the user command (ranges, args, etc.)
---@param opts table
---@param curBufNum integer
---@nodiscard
---@return integer start line of range
---@return integer end line of range
---@return string[] buffer lines
---@return string term to search
---@return string|nil replacement
---@return boolean whether to search first or all occurrences in line
local function processParameters(opts, curBufNum)
	-- "trimempty" allows to leave out the first and third "/" from regular `:s`
	local input = vim.split(opts.args, delimiter, { trimempty = true, plain = false })
	local toSearch, toReplace, flags = input[1], input[2], input[3]
	local singleRepl = (flags and flags:find("g")) == nil

	local line1, line2 = opts.line1, opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(curBufNum, line1 - 1, line2, false)

	return line1, line2, bufferLines, toSearch, toReplace, singleRepl
end

--------------------------------------------------------------------------------

---more complicated than just running gsub on each line, since the shift in
---length needs to be determined for each substitution, for the preview highlight
---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function previewAndHighlightReplacements(opts, ns, curBufNum)
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts, curBufNum)
	if not toReplace then return end

	-- preview changes
	local numOfReplacement = singleRepl and 1 or nil
	local newBufferLines = replace(bufferLines, toSearch, toReplace, numOfReplacement, regexFlavor)
	vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)

	-- add highlights
	for i, line in ipairs(bufferLines) do
		local lineIdx = line1 + i - 2

		-- find all startPositions in the line
		local startPositions = {}
		local start = 0
		while true do
			start, _ = find(line, toSearch, start + 1, regexFlavor)
			if not start then break end
			table.insert(startPositions, start)
		end

		-- iterate matches in given line
		local previousShift = 0
		for ii, startPos in ipairs(startPositions) do
			local _, endPos = find(line, toSearch, startPos, regexFlavor)
			local lineWithSomeSubs = (replace({ line }, toSearch, toReplace, ii, regexFlavor))[1]
			local diff = (#lineWithSomeSubs - #line)
			startPos = startPos + previousShift
			endPos = endPos + diff -- shift of end position due to replacement
			previousShift = previousShift + diff -- remember shift for next iteration

			vim.api.nvim_buf_add_highlight(curBufNum, ns, hlgroup, lineIdx, startPos - 1, endPos)
		end
	end
end

---@param opts table
---@param ns integer namespace id to use for highlights
---@param curBufNum integer buffer id
local function highlightSearches(opts, ns, curBufNum)
	local line1, _, bufferLines, toSearch, _, _ = processParameters(opts, curBufNum)
	for i, line in ipairs(bufferLines) do
		-- only highlighting first match, since the g-flag can only be entered
		-- when there is a substitution value
		local startPos, endPos = find(line, toSearch, 1, regexFlavor)
		if startPos and endPos then
			vim.api.nvim_buf_add_highlight(0, ns, hlgroup, line1 + i - 2, startPos - 1, endPos)
		end
	end
end

--------------------------------------------------------------------------------

---the substitution to perform when the commandline is confirmed with <CR>
---@param opts table
local function confirmSubstitution(opts)
	local curBufNum = vim.api.nvim_get_current_buf()
	local line1, line2, bufferLines, toSearch, toReplace, singleRepl = processParameters(opts, curBufNum)

	if not toReplace then
		vim.notify("No replacement value given, cannot perform substitution.", warn)
		return
	end

	local numOfReplacement = singleRepl and 1 or nil
	local newBufferLines, totalReplacementCount =
		replace(bufferLines, toSearch, toReplace, numOfReplacement, regexFlavor)
	vim.api.nvim_buf_set_lines(curBufNum, line1 - 1, line2, false, newBufferLines)
	if showNotification then
		vim.notify("Replaced " .. tostring(totalReplacementCount) .. " instances.")
	end
end

-- https://neovim.io/doc/user/map.html#%3Acommand-preview
---@param opts table
---@param ns number namespace for the highlight
---@param preview_buf boolean true if inccommand=split. (Not implemented yet.)
---@return integer? -- value of preview type
local function previewSubstitution(opts, ns, preview_buf)
	if preview_buf then
		-- stylua: ignore
		vim.notify_once("'inccommand=split' is not supported yet. Please use 'inccommand=unsplit' instead.", warn)
		return
	end
	local curBufNum = vim.api.nvim_get_current_buf()

	local input = vim.split(opts.args, delimiter, { trimempty = true, plain = false })
	local hasReplacementValue = input[2]

	if not hasReplacementValue then
		highlightSearches(opts, ns, curBufNum)
	else
		previewAndHighlightReplacements(opts, ns, curBufNum)
	end

	return 2 -- return the value of the preview type
end

--------------------------------------------------------------------------------

---@class config
---@field regexFlavor "lua"|"javascript" default: lua
---@field showNotification boolean whether to show the "x replacements made" notice, default: true

---@param opts? config
function M.setup(opts)
	-- default values
	if not opts then opts = {} end
	regexFlavor = opts.regexFlavor or "lua"
	showNotification = opts.showNotification or true

	-- validation
	local supportedLangs = {
		lua = true,
		javascript = false,
	}
	if not supportedLangs[regexFlavor] then
		vim.notify(regexFlavor .. " is not supported as a regex flavor.", warn)
		return
	end

	-- setup user commands
	local commands = { "S", "SubSub" }
	for _, cmd in pairs(commands) do
		vim.api.nvim_create_user_command(cmd, confirmSubstitution, {
			nargs = "?",
			range = "%", -- defaults to whole buffer
			addr = "lines",
			preview = previewSubstitution,
		})
	end
end

--------------------------------------------------------------------------------

return M

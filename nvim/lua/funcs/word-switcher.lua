-- WORD DATABASE

-- INFO
-- 1) these words are checked for lowercase, Capitalcase, and UPPERCASE
-- since they are not language-specific keywords
-- 2) `false` as third list items indicates that the second element is *not*
-- exchanged with the first
local generalWords = {
	-- on/off
	{ "on", "off" },
	{ "yes", "no" },
	{ "y", "n" },
	{ "disable", "enable" },
	{ "disabled", "enabled" },
	{ "1", "0" },
	{ "true", "false" },

	-- opposites
	{ "show", "hide" },
	{ "min", "max" },
	{ "minimum", "maximum" },
	{ "increase", "decrease" },
	{ "increased", "decreased" },
	{ "always", "never" },
	{ "with", "without" },
	{ "next", "previous" },
	{ "inner", "outer" },
	{ "before", "after" },
	{ "low", "high" },
	{ "dark", "light" },
	{ "first", "last" },
	{ "up", "down" },
	{ "right", "left" },
	{ "black", "white" },
	{ "even", "odd" },
	{ "start", "end" },
	{ "more", "less", false },
	{ "less", "fewer", false },
	{ "fewer", "more", false },

	-- commonly switched between
	{ "red", "blue" }, -- e.g. when testing designs
	{ "read", "write" },
	{ "warn", "error" },
	{ "and", "or" },

	-- comparisons and operators
	{ "(", ")" },
	{ "[", "]" },
	{ "[[", "]]" },
	{ "{", "}" },
	{ "'", '"' },
	{ "<", ">" },
	{ "<=", ">=" },
	{ "==", "!=" },
	{ "+", "-" },
	{ "*", "/" },

	-- units
	{ "mins", "secs" }, -- not min, since conflict with min-max
	{ "years", "months", false },
	{ "months", "weeks", false },
	{ "weeks", "days", false },
	{ "days", "hours", false },
	{ "hours", "minutes", false },
	{ "minutes", "seconds", false },
	{ "seconds", "milliseconds", false },
	{ "milliseconds", "years", false },

	{ "GB", "MB", false },
	{ "MB", "KB", false },
	{ "KB", "B", false },
	{ "B", "GB", false },
}

-- INFO
-- 1) checks on these words are case-sensitive, since keywords are case-sensitive
-- 2) `false` as third list items indicates that the second element is *not*
-- exchanged with the first
-- 3) if the value is not table but a string, thiese means that the filetype
-- inherits the keywords of the named filetype
local filetypeSpecificWords = {
	typescript = "javascript",
	bash = "sh",
	zsh = "sh",
	fish = "sh",
	html = "css",
	css = {
		-- many common css terms already included in general words
		{ "padding", "margin" },
		{ "top", "bottom" },
		{ "relative", "absolute" },
		{ "width", "height" },
		{ "border", "outline" },
		{ "span", "div" },
	},
	lua = {
		{ "==", "~=" },
		{ "nil", "{}" },
		{ "lower", "upper" }, -- str:lower(), str:upper()
		{ "..", "+", false }, -- for type mixup (one-way so + and - can still be swapped)
		{ "if", "elseif", false },
		{ "elseif", "else", false },
		{ "else", "if", false },
		{ "pairs", "ipairs" },
		{ "find", "match" }, -- string.find and string.match
		{ "break", "return" }, -- javascript knows no `continue`
		{ "function", "local function", false },
		{ "not", "", false }, -- not way to toggle back
	},
	python = {
		{ "True", "False" },
		{ "print", "assert" },
	},
	markdown = {
		{ "Note", "Warning" }, -- github callouts
	},
	javascript = {
		{ "null", "undefined" },
		{ "if", "else if", false },
		{ "else", "else if", false },
		{ "var", "const", false }, -- don't switch back to var
		{ "const", "let" },
		{ "map", "forEach" },
		{ "replace", "replaceAll" },
		{ "includes", "match" },
		{ "===", "!==" },
		{ "&&", "||" },
		{ "continue", "break" }, 
		{ "default", "case" }, -- switch-case statements
		{ "debug", "trace", false }, -- console.log -> console.warn -> etc.
		{ "trace", "info", false },
		{ "info", "log", false },
		{ "log", "warn", false },
		{ "warn", "error", false },
		{ "error", "debug", false },
	},
	sh = {
		{ "lt", "gt" }, -- the leading `-` is ignored
		{ "eq", "nq" },
		{ "&&", "||" },
		{ "if", "elif", false },
		{ "elif", "else", false },
		{ "else", "if", false },
		{ "echo", "print" },
		{ "exit", "return" },
	},
}

--runs when no word to switch can be found under the cursor
local function fallbackFn()
	-- toggle capital/lowercase of word
	vim.cmd.normal { "mzlb~`z", bang = true }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- HELPERS

local M = {}

---check if input is equal to ifWord in lowercase, titlecase, or uppercase. If
---so, returns the thenWord in the same case, otherwise returns nil
---@param input string
---@param ifWord string
---@param thenWord string
---@return string|nil
local function checkAlternativeCasings(input, ifWord, thenWord)
	if input == ifWord:lower() then
		return thenWord:lower()
	elseif input == ifWord:upper() then
		return thenWord:upper()
	elseif input == ifWord:sub(1, 1) .. ifWord:sub(2) then
		return thenWord:sub(1, 1) .. thenWord:sub(2)
	end
	return nil
end

--------------------------------------------------------------------------------

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.switch()
	-- determine word to check
	local iskeywBefore = vim.opt.iskeyword:get() -- remove word-delimiters for <cword>
	vim.opt.iskeyword:remove { "_", "-", "." }

	local cword = vim.fn.expand("<cword>")
	local cBigword = vim.fn.expand("<cWORD>") -- check fo cWORD needed to retrieve non-alphanumeric strings (e.g. "&&")

	local alphaNumericUnderCursor = cBigword:find("[%a%d]")
	local word = alphaNumericUnderCursor and cword or cBigword
	local newWord = nil

	-----------------------------------------------------------------------------

	-- check for filetype specific words
	-- - first since higher priority than general words
	-- - literal matching, since filetype specific words are case-sensitive
	local ft = vim.bo.filetype
	if filetypeSpecificWords[ft] then
		-- filetype inherits words by other filetype
		if type(filetypeSpecificWords[ft]) == "string" then ft = tostring(filetypeSpecificWords[ft]) end
		---@diagnostic disable-next-line: assign-type-mismatch
		local wordList = filetypeSpecificWords[ft] ---@type table

		for _, pair in pairs(wordList) do
			if word == pair[1] then
				newWord = pair[2]
				break
			end
			local oneWay = pair[3] == false
			if not oneWay and word == pairs[2] then newWord = pairs[1] end
		end
	end

	-----------------------------------------------------------------------------
	-- check for general words
	-- - checking for different casing, since they are not keywords
	if not newWord then
		for _, pair in pairs(generalWords) do
			newWord = checkAlternativeCasings(word, pair[1], pair[2])
			if newWord then break end

			local oneWay = pair[3] == false
			if not oneWay then
				newWord = checkAlternativeCasings(word, pair[2], pair[1])
				if newWord then break end
			end
		end
	end

	-----------------------------------------------------------------------------

	if newWord then
		vim.fn.setreg("z", newWord)
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		fallbackFn()
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M

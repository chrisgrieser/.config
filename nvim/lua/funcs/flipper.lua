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
	{ "top", "bottom" },
	{ "up", "down" },
	{ "above", "below" },
	{ "vertical", "horizontal" },
	{ "width", "height" },
	{ "min", "max" }, 
	{ "minimum", "maximum" },
	{ "increase", "decrease" },
	{ "increased", "decreased" },
	{ "always", "never" },
	{ "with", "without" },
	{ "external", "internal" },
	{ "forwards", "backwards" },
	{ "next", "previous" },
	{ "inner", "outer" },
	{ "input", "output" },
	{ "before", "after" },
	{ "low", "high" },
	{ "dark", "light" },
	{ "odd", "even" },
	{ "first", "last" },
	{ "right", "left" },
	{ "black", "white" },
	{ "start", "end" },

	-- commonly switched between
	{ "red", "blue" }, -- e.g. when design-testing
	{ "read", "write" },
	{ "warning", "error" },
	{ "and", "or" },

	-- comparisons and operators
	{ "(", ")" },
	{ "[", "]" },
	{ "[[", "]]" },
	{ "{", "}" },
	{ "'", '"' },
	{ "==", "!=" },
	{ "+", "-" },
	{ "*", "/" },
	{ "<", ">" },
	{ "<=", ">=" },
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
		{ "relative", "absolute" },
		{ "border", "outline" },
		{ "span", "div" },
	},
	lua = {
		{ "==", "~=" },
		{ "nil", "{}" },
		{ "lower", "upper" }, -- str:lower(), str:upper()
		{ "if", "elseif" },
		{ "pairs", "ipairs" },
		{ "find", "match" }, -- string.find and string.match
		{ "break", "return" }, -- javascript knows no `continue`
		{ "function", "local function", false }, -- cannot switch back multi-word
		{ "print", "assert" },
	},
	python = {
		{ "print", "assert" },
	},
	markdown = {
		{ "Note", "Warning" }, -- github callouts
	},
	javascript = {
		{ "null", "undefined" },
		{ "if", "else if", false }, -- cannot switch back multi-word
		{ "var", "const", false }, -- don't switch back to var, since const/let are preferred
		{ "const", "let" },
		{ "parseInt", "parseFloat" },
		{ "map", "forEach" },
		{ "replace", "replaceAll" },
		{ "includes", "match" },
		{ "toUpperCase", "toLowerCase" },
		{ "===", "!==" },
		{ "&&", "||" },
		{ "continue", "break" },
		{ "default", "case" }, 
	},
	sh = {
		{ "lt", "gt" }, -- the leading `-` is ignored
		{ "eq", "nq" },
		{ "&&", "||" },
		{ ">", ">>" }, -- append/overwrite
		{ "if", "elif" },
		{ "echo", "print" },
		{ "exit", "return" },
		{ "head", "tail" },
		{ "bash", "zsh" }, -- e.g. for shebangs
	},
}

--------------------------------------------------------------------------------
-- HELPERS

---check if input is equal to ifWord in lowercase, Capitalcase, or UPPERCASE. If
---so, returns the thenWord in the same case, otherwise returns nil
---@param input string
---@param ifWord string
---@param thenWord string
---@nodiscard
---@return string|nil
local function checkAlternativeCasings(input, ifWord, thenWord)
	local function capitalcase(word) return word:sub(1, 1):upper() .. word:sub(2) end

	if input == ifWord:lower() then
		return thenWord:lower()
	elseif input == ifWord:upper() then
		return thenWord:upper()
	elseif input == (capitalcase(ifWord)) then
		return capitalcase(thenWord)
	end
	return nil
end

--------------------------------------------------------------------------------

local M = {}

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.flipWord()
	-- determine word to check
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." } -- remove word-delimiters for <cword>

	-- TODO more precise retrieval of word under cursor
	local cword = vim.fn.expand("<cword>")
	local cBigword = vim.fn.expand("<cWORD>") -- check of cWORD needed to retrieve non-alphanumeric strings (e.g. "&&")

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
			if not oneWay and word == pair[2] then newWord = pair[1] end
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
		-- TODO more precise replacement in the editor
		vim.fn.setreg("z", newWord)
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		vim.notify("No matching word found", vim.log.levels.WARN)
	end

	vim.opt.iskeyword = iskeywBefore -- restore
end

--------------------------------------------------------------------------------
return M

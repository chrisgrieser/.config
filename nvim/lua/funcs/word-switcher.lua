-- INFO `false` as third list items indicates that the second element is *not*
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
	{ "next", "previous" },
	{ "inner", "outer" },
	{ "before", "after" },
	{ "low", "high" },
	{ "dark", "light" },
	{ "first", "last" },
	{ "up", "down" },
	{ "right", "left" },
	{ "black", "white" },
	{ "more", "less", false },
	{ "less", "fewer", false },
	{ "fewer", "more", false },

	-- commonly switched between
	{ "red", "blue" }, -- e.g. when testing designs
	{ "read", "write" },
	{ "warn", "error" },
	{ "and", "or" },

	-- comparisons and operators
	{ "<", ">" },
	{ "<=", ">=" },
	{ "!=", "==" },
	{ "+", "-" },
	{ "*", "/" },

	-- units
	{ "mins", "secs" },
	{ "years", "months", false },
	{ "months", "weeks", false },
	{ "weeks", "days", false },
	{ "days", "hours", false },
	{ "hours", "minutes", false },
	{ "minutes", "seconds", false },
	{ "seconds", "milliseconds", false },
	{ "milliseconds", "years", false }, -- cycle back
}

local filetypeSpecificWords = {
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
	},
	markdown = {
		{ "Note", "Warning" }, -- github callouts
		{ "#", "##", false }, -- heading levels
		{ "##", "###", false }, 
		{ "###", "####", false }, 
		{ "####", "#####", false }, 
		{ "#####", "######", false }, 
		{ "#######", "#", false }, 
	},
	javascript = {
		{ "null", "undefined" },
		{ "if", "} else if", false },
		{ "else", "else if", false },
		{ "var", "const", false }, -- don't switch back to var!
		{ "const", "let" },
		{ "map", "forEach" },
		{ "replace", "replaceAll" },
		{ "includes", "match" },
		{ "===", "!==" },
		{ "&&", "||" },
		{ "continue", "break" }, -- loop
		{ "default", "case" }, -- switch-case statements

		-- console.log -> console.warn
		{ "debug", "trace", false },
		{ "trace", "info", false },
		{ "info", "log", false },
		{ "log", "warn", false },
		{ "warn", "error", false },
		{ "error", "debug", false },
	},
	sh = {
		{ "lt", "gt" },
		{ "eq", "nq" },
		{ "&&", "||" },
		{ "if", "elif", false },
		{ "elif", "else", false },
		{ "else", "if", false },
		{ "echo", "print" },
		{ "exit", "return" },
	},

	-- filetypes to link to another filetype
	typescript = "javascript",
	bash = "sh",
	zsh = "sh",
	fish = "sh",
}

--------------------------------------------------------------------------------

local function fallbackFn ()
	-- toggle capital/lowercase of word
	vim.cmd.normal { 'mzlb~`z', bang = true }
end

--------------------------------------------------------------------------------

local M = {}

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.switch()
	local ft = vim.bo.filetype
	local wordsToUse = {}

	if filetypeSpecificWords[ft] then
		-- filetype inherits words by other filetype
		if filetypeSpecificWords[ft] == "string" then ft = tostring(filetypeSpecificWords[ft]) end

		---@diagnostic disable-next-line: param-type-mismatch --- type match ensured above
		for _, v in pairs(filetypeSpecificWords[ft]) do
			table.insert(wordsToUse, v)
		end
	end

	-- INFO general words added *after* the filetype-specific words, so that the latter get priority
	for _, v in pairs(generalWords) do
		table.insert(wordsToUse, v)
	end

	-- remove word-delimiters for <cword>
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }

	local cword = vim.fn.expand("<cword>")
	local cBigword = vim.fn.expand("<cWORD>")

	local alphaNumericUnderCursor = cBigword:find("[%a%d]")
	local word = alphaNumericUnderCursor and cword or cBigword

	local newWord
	for _, pair in pairs(wordsToUse) do
		local oneWay = pair[3] == false
		if word == pair[1] then
			newWord = pair[2]
			break
		elseif word == pair[2] and not oneWay then
			newWord = pair[1]
			break
		end
	end

	local switchWordFound = newWord ~= nil
	if switchWordFound then
		vim.fn.setreg("z", newWord)
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		fallbackFn()
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M


-- INFO `false` indicates that the second element is not exchanged with the first
local generalWords = {
	{ "true", "false" },
	{ "on", "off" },
	{ "yes", "no" },
	{ "disable", "enable" },
	{ "disabled", "enabled" },

	{ "warn", "error" },
	{ "show", "hide" },
	{ "min", "max" },
	{ "read", "write" },
	{ "always", "never" },

	{ "next", "previous" },
	{ "inner", "outer" },
	{ "before", "after" },
	{ "low", "high" },
	{ "dark", "light" },

	{ "<=", ">=" },
	{ "!=", "==" },

	{ "years", "months", false },
	{ "months", "weeks", false },
	{ "weeks", "days", false },
	{ "days", "hours", false },
	{ "hours", "minutes", false },
	{ "minutes", "seconds", false },
	{ "mins", "secs" },
}

local filetypeSpecificWords = {
	css = {
		{ "padding", "margin" },
		{ "top", "bottom" },
		{ "right", "left" },
		{ "relative", "absolute" },
		{ "width", "height" },
		{ "black", "white" },
		{ "red", "blue" },
	},
	lua = {
		{ "if", "elseif", false },
		{ "and", "or" },
		{ "elseif", "else", false },
		{ "else", "if", false },
		{ "function", "local function", false },
		{ "pairs", "ipairs" },
		{ "find", "match" },
		{ "Notify", "print", false }, -- hammerspoon specific
	},
	python = {
		{ "True", "False" },
	},
	javascript = {
		{ "if", "} else if", false },
		{ "else", "else if", false },
		{ "var", "const", false },
		{ "const", "let" },
		{ "map", "forEach" },
		{ "replace", "replaceAll" },
		{ "===", "!==" },
	},
	sh = {
		{ "y", "n" },
		{ "lt", "gt" },
		{ "eq", "nq" },
		{ "&&", "||" },
		{ "if", "elif", false },
		{ "elif", "else", false },
		{ "else", "if", false },
		{ "echo", "print" },
		{ "exit", "return" },
		{ "1", "0" },
	},
	-- filetypes to link to another filetype
	typescript = "javascript",
	bash = "sh",
	zsh = "sh",
}

--------------------------------------------------------------------------------

local M = {}

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.switch()
	local ft = vim.bo.filetype
	local wordsToUse = {}
	for _, v in pairs(generalWords) do
		table.insert(wordsToUse, v)
	end

	if filetypeSpecificWords[ft] then
		-- filetype inherits word by other filetype
		if filetypeSpecificWords[ft] == "string" then ft = tostring(filetypeSpecificWords[ft]) end

		---@diagnostic disable-next-line: param-type-mismatch --- type match ensured above
		for _, v in pairs(filetypeSpecificWords[ft]) do
			table.insert(wordsToUse, v)
		end
	end

	-- remove word-delimiters for <cword>
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }

	local cword = vim.fn.expand("<cword>")
	local cBigword = vim.fn.expand("<cWORD>")
	
	local alphaNumericUnderCursor = cBigword:find("[%a%d]")
	local word = alphaNumericUnderCursor and cword or cBigword

	local newWord = nil
	for _, pair in pairs(wordsToUse) do
		if word == pair[1] then
			newWord = pair[2]
			break
		elseif word == pair[2] and pair[3] ~= false then
			newWord = pair[1]
			break
		end
	end

	local switchWordFound = newWord ~= nil
	if switchWordFound then
		vim.fn.setreg("z", newWord)
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		-- fallback to `~`
		vim.cmd.normal { "~", bang = true }
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M

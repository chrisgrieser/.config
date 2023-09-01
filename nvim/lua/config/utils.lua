local M = {}
--------------------------------------------------------------------------------

-- vim.env reads from .zshenv
M.vimDataDir = vim.env.DATA_DIR .. "/vim-data/"
M.linterConfigFolder = vim.env.DOTFILE_FOLDER .. "/_linter-configs/"

M.error = vim.log.levels.ERROR
M.warn = vim.log.levels.WARN
M.trace = vim.log.levels.TRACE
M.getCursor = vim.api.nvim_win_get_cursor
M.setCursor = vim.api.nvim_win_set_cursor

---runs :normal natively with bang
---@param cmdStr string
function M.normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@param str string
---@param filePath string line(s) to add
---@param mode "w"|"a" -- write or append
---@return string|nil error
---@nodiscard
function M.writeToFile(filePath, str, mode)
	local file, error = io.open(filePath, mode)
	if not file then return error end
	file:write(str .. "\n")
	file:close()
end

---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
---@param name string name of highlight group
---@param key "fg"|"bg"
---@nodiscard
---@return string|nil the value, or nil if hlgroup or key is not available
function M.getHighlightValue(name, key)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
	if not ok then return end
	local value = hl[key]
	if not value then return end
	return string.format("#%06x", value)
end

---reads a template to apply if the file is empty. Add to a filetype config to
---activate templates for it
---@param ext string extension of the skeleton
function M.applyTemplateIfEmptyFile(ext)
	-- prevent buggy duplicate application of template
	if vim.b.templateWasApplied then return end
	vim.b.templateWasApplied = true ---@diagnostic disable-line: inject-field

	vim.defer_fn(function()
		local filename = vim.fn.expand("%")
		local fileExists = vim.loop.fs_stat(filename) ~= nil
		if not fileExists then return end

		local skeletonFile = vim.fn.stdpath("config") .. "/templates/skeleton." .. ext
		local skeletonExists = vim.loop.fs_stat(skeletonFile) ~= nil
		if not skeletonExists then
			vim.notify("Skeleton file not found.", vim.log.levels.ERROR)
			return
		end

		local fileIsEmpty = vim.loop.fs_stat(filename).size < 4 -- account for linebreaks
		if not fileIsEmpty then return end

		vim.cmd("silent keepalt 0read " .. skeletonFile)
		M.normal("G")
	end, 1)
end

-- turns string into unicode smallcaps
function M.smallCaps(str)
	local smallCapsMap = {
		ᴀ = "a",
		ʙ = "b",
		ᴄ = "c",
		ᴅ = "d",
		ᴇ = "e",
		ғ = "f",
		ɢ = "g",
		ʜ = "h",
		ɪ = "i",
		ᴊ = "j",
		ᴋ = "k",
		ʟ = "l",
		ᴍ = "m",
		ɴ = "n",
		ᴏ = "o",
		ᴘ = "p",
		ǫ = "q",
		ʀ = "r",
		s = "s",
		ᴛ = "t",
		ᴜ = "u",
		ᴠ = "v",
		ᴡ = "w",
		x = "x",
		ʏ = "y",
		ᴢ = "z",
	}
	for i = 1, 10, 1 do
		
	end
end

--------------------------------------------------------------------------------

---Sets the global BorderStyle variable and the matching BorderChars Variable.
---See also https://neovim.io/doc/user/api.html#nvim_open_win()
---(BorderChars is needed for Harpoon and Telescope, both of which do not accept
---a Borderstyle string.)

M.borderStyle = "single"

if M.borderStyle == "single" then
	M.borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
	M.borderHorizontal = "─"
elseif M.borderStyle == "double" then
	M.borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
	M.borderHorizontal = "═"
elseif M.borderStyle == "rounded" then
	M.borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	M.borderHorizontal = "─"
end

--------------------------------------------------------------------------------

M.textobjectRemaps = {
	c = "}", -- curly brace
	r = "]", -- rectangular bracket
	m = "W", -- massive word
	q = '"', -- quote
	z = "'", -- single quote
	e = "`", -- template string / inline cod[e]
}

M.textobjectMaps = {
	["function"] = "f",
	["conditional"] = "o",
	["call"] = "l",
	["doubleSquareBracket"] = "R",
}

--------------------------------------------------------------------------------

return M

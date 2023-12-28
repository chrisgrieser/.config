local M = {}
local editSnippetIn = {}
--------------------------------------------------------------------------------

---@class (exact) snippetObj VSCode snippet json
---@field path string (key only set by this plugin)
---@field originalKey string (key only set by this plugin)
---@field prefix string|string[]
---@field body string|string[]
---@field description? string

--------------------------------------------------------------------------------

---@class (exact) pluginConfig
---@field snippetDir string

---@type pluginConfig
local defaultConfig = {
	snippetDir = vim.fn.stdpath("config") .. "/snippets",
}
local config = defaultConfig

--------------------------------------------------------------------------------

---@param filePath string
---@return string? -- content or error message
---@return boolean success
local function readFile(filePath)
	local file, err = io.open(filePath, "r")
	if not file then return err, false end
	local content = file:read("*a")
	file:close()
	return content, true
end

---@param str string
---@param filePath string
---@param mode "w"|"a" write or append
---@return string|nil -- error message
local function writeFile(mode, filePath, str)
	local file, _ = io.open(filePath, mode)
	if not file then return end
	file:write(str)
	file:close()
end

---@param path string
---@return table
local function readAndParseJson(path) return vim.json.decode(readFile(path) or "{}") or {} end

--------------------------------------------------------------------------------

---Tries to determine filetype based on input string. If input is neither a
---filetype nor a file extension known to nvim, returns false.
---@param input string
---@return string|false filetype
local function guessFileType(input)
	-- input is filetype
	local allKnownFts = vim.fn.getcompletion("", "filetype")
	if vim.tbl_contains(allKnownFts, input) then return input end

	-- input is file extension
	local matchedFt = vim.filetype.match { filename = "dummy." .. input }
	if matchedFt then return matchedFt end

	return false
end

---@param snip snippetObj snippet to update
---@param bodyLines string[]
local function updateSnippet(snip, bodyLines)
	local snippetsInFile = readAndParseJson(snip.path)

	local key = snip.originalKey
	local filepath = snip.path
	snip.originalKey = nil
	snip.path = nil
	snip.body = #bodyLines == 1 and bodyLines[1] or bodyLines
	snippetsInFile[key] = snip

	local jsonStr = vim.json.encode(snippetsInFile)
	assert(jsonStr, "snippet could not be written")
	writeFile("w", filepath, jsonStr)
end

---@param snip snippetObj
function editSnippetIn.popup(snip)
	local snipLines = snip.body
	if type(snipLines) == "string" then snipLines = { snipLines } end
	local displayName = snip.originalKey:sub(1, 25)
	local sourceFile = vim.fs.basename(snip.path):gsub("%.json$", "")

	-- create buffer and window
	local a = vim.api
	local bufnr = a.nvim_create_buf(false, true)
	a.nvim_buf_set_lines(bufnr, 0, -1, false, snipLines)
	a.nvim_buf_set_name(bufnr, displayName)
	local guessFt = guessFileType(sourceFile)
	if guessFt then a.nvim_buf_set_option(bufnr, "filetype", guessFt) end
	a.nvim_buf_set_option(bufnr, "buftype", "nofile")

	local width = 0.7
	local height = 0.5
	local winnr = a.nvim_open_win(bufnr, true, {
		relative = "win",
		-- centered window
		width = math.floor(width * a.nvim_win_get_width(0)),
		height = math.floor(height * a.nvim_win_get_height(0)),
		row = math.floor((1 - height) * a.nvim_win_get_height(0) / 2),
		col = math.floor((1 - width) * a.nvim_win_get_width(0) / 2),
		title = (" %s (%s) "):format(displayName, sourceFile),
		title_pos = "center",
		border = "rounded",
		style = "minimal",
		zindex = 1, -- below nvim-notify floats
	})
	a.nvim_win_set_option(winnr, "number", true)

	-- keymaps
	local function close()
		a.nvim_win_close(winnr, true)
		a.nvim_buf_delete(bufnr, { force = true })
	end
	vim.keymap.set("n", "q", close, { buffer = bufnr, nowait = true })
	vim.keymap.set("n", "<CR>", function()
		local editedLines = a.nvim_buf_get_lines(bufnr, 0, -1, false)
		updateSnippet(snip, editedLines)
		close()
	end, { buffer = bufnr, nowait = true })
end

---@param snip snippetObj
function editSnippetIn.editor(snip)
	local locationInFile = '"' .. snip.originalKey:gsub(" ", [[\ ]]) .. '":'
	vim.cmd(("edit +/%s %s"):format(locationInFile, snip.path))
end

--------------------------------------------------------------------------------

---Searches a folder of vs-code-like snippets in json format and opens the selected.
---@param editWhere? "popup"|"editor"
function M.snippetSearch(editWhere)
	if not editWhere then editWhere = "popup" end
	if not vim.tbl_contains(vim.tbl_keys(editSnippetIn), editWhere) then
		vim.notify("snippetSearch does not accept '" .. editWhere .. "'", vim.log.levels.ERROR)
		return
	end

	local allSnippets = {} ---@type snippetObj[]
	for name, _ in vim.fs.dir(config.snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then
			local filepath = config.snippetDir .. "/" .. name
			local snippetsInFileDict = readAndParseJson(filepath)

			-- convert dictionary to list for vim.ui.select
			local snippetsInFileList = {}
			for key, snip in pairs(snippetsInFileDict) do
				snip.path = filepath
				snip.originalKey = key
				table.insert(snippetsInFileList, snip)
			end
			vim.list_extend(allSnippets, snippetsInFileList)
		end
	end

	vim.ui.select(allSnippets, {
		prompt = "Select snippet",
		format_item = function(item)
			local snipname = item.prefix[1] or item.prefix
			local filename = item.path:match("([^/]+)%.json$")
			return ("%s\t\t(%s)"):format(snipname, filename)
		end,
		kind = "snippetList",
	}, function(snip)
		if not snip then return end
		editSnippetIn[editWhere](snip)
	end)
end

--------------------------------------------------------------------------------
return M

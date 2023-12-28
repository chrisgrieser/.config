local M = {}
local a = vim.api
--------------------------------------------------------------------------------

---@class (exact) snippetObj VSCode snippet json
---@field path? string
---@field originalKey? string original key of the snippet
---@field prefix string|string[]
---@field body string|string[]
---@field description? string

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

---Reads VS Code snippet json file, and also converts the object to an array of
---snippets, storing the filepath and the original key.
---@param snippetDir string
---@param filepath string
---@return snippetObj[] snippetsInFile returns empty table if file not readable
local function parseSnippetFile(snippetDir, filepath)
	local snippetsInFile = {}
	local path = snippetDir .. "/" .. filepath
	local snippets = vim.json.decode(readFile(path) or "{}") or {}
	for key, snip in pairs(snippets) do
		snip.path = path
		snip.originalKey = key
		table.insert(snippetsInFile, snip)
	end
	return snippetsInFile
end

---@param snip snippetObj
local function openFileAtSnippet(snip)
	local locationInFile = '"' .. snip.originalKey:gsub(" ", [[\ ]]) .. '":'
	vim.cmd(("edit +/%s %s"):format(locationInFile, snip.path))
end

---@param snip snippetObj
local function editSnippet(snip)
	local snipLines = snip.body
	if type(snipLines) == "string" then snipLines = { snipLines } end
	local displayName = snip.originalKey:sub(1, 25)
	local sourceFile = vim.fs.basename(snip.path):gsub("%.json$", "")

	local bufnr = a.nvim_create_buf(false, true)
	a.nvim_buf_set_lines(bufnr, 0, -1, false, snipLines)
	a.nvim_buf_set_name(bufnr, displayName)
	a.nvim_buf_set_option(bufnr, "filetype", sourceFile)
	
	local width = 0.8
	local height = 0.8
	local winnr = a.nvim_open_win(bufnr, true, {
		relative = "win",
		-- centered
		width = math.floor(width * a.nvim_win_get_width(0)),
		height = math.floor(height * a.nvim_win_get_height(0)),
		row = math.floor((1 - height) * a.nvim_win_get_height(0) / 2),
		col = math.floor((1 - width) * a.nvim_win_get_width(0) / 2),
		title = ("%s (%s) "):format(displayName, sourceFile),
		title_pos = "center",
		border = "rounded",
		style = "minimal",
		zindex = 1, -- below nvim-notify floats
	})
end

--------------------------------------------------------------------------------

---Searches a folder of vs-code-like snippets in json format and opens the selected.
---@param snippetDir string
function M.snippetSearch(snippetDir)
	local allSnippets = {} ---@type snippetObj[]
	for name, _ in vim.fs.dir(snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then
			local snippetsInFile = parseSnippetFile(snippetDir, name)

			vim.list_extend(allSnippets, snippetsInFile)
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
		-- openFileAtSnippet(snip)
		editSnippet(snip)
	end)
end

--------------------------------------------------------------------------------
return M

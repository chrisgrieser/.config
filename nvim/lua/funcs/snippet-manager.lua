local M = {}
--------------------------------------------------------------------------------

---@class (exact) snippetObj
---@field path? string path of VSCode snippet json
---@field key? string original key of VSCode snippet json
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

---@param str string
---@param filePath string
---@return string|nil -- error message
local function overwriteFile(filePath, str)
	local file, _ = io.open(filePath, "w")
	if not file then return end
	file:write(str)
	file:close()
end

--------------------------------------------------------------------------------

---@param snippetDir string
---@param filepath string
---@return snippetObj snippetsInFile
local function parseSnippetFile(snippetDir, filepath)
	local snippetsInFile = {}
	local path = snippetDir .. "/" .. filepath
	local snippets = vim.json.decode(readFile(path) or "{}") or {}
	for key, snip in pairs(snippets) do
		snip.path = path
		snip.key = key
		table.insert(snippetsInFile, snip)
	end
	return snippetsInFile
end

---Searches a folder of vs-code-like snippets in json format and opens the selected.
---@param snippetDir string
function M.snippetSearch(snippetDir)
	local allSnippets = {}
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
			return snipname .. "\t\t" .. filename
		end,
		kind = "snippetList",
	}, function(snip)
		if not snip then return end
		local locationInFile = '"' .. snip.key:gsub(" ", [[\ ]]) .. '":'
		vim.cmd(("edit +/%s %s"):format(locationInFile, snip.path))
	end)
end

--------------------------------------------------------------------------------
return M

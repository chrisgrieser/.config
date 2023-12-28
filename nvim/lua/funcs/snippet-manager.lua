local M = {}
--------------------------------------------------------------------------------

local function readFile(path)
	local file, _ = io.open(path, "r")
	if not file then return "" end
	local content = file:read("*a")
	file:close()
	return content
end

---Searches a folder of vs-code-like snippets in json format and opens the selected.
---@param snippetDir string
function M.snippetSearch(snippetDir)
	local allSnippets = {}
	for name, _ in vim.fs.dir(snippetDir, { depth = 2 }) do
		if name:find("%.json$") and name ~= "package.json" then
			local path = snippetDir .. "/" .. name
			local snippets = vim.json.decode(readFile(path) or "{}") or {}
			for key, snip in pairs(snippets) do
				snip.path = path
				snip.key = key
				table.insert(allSnippets, snip)
			end
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

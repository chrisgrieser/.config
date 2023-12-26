local function readFile(path)
	local file, _ = io.open(path, "r")
	if not file then return nil end
	local content = file:read("*a")
	file:close()
	return content
end

--------------------------------------------------------------------------------

local snippetDir = vim.fn.stdpath("config") .. "/snippets"
local allSnippets = {}
for name, type in vim.fs.dir(snippetDir, { depth = 2 }) do
	if type == "file" and name ~= "package.json" and name:find("%.json$") then
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
	format_item = function(item) return item.prefix[1] or item.prefix end,
	kind = "snippetList",
}, function(snip)
	if not snip then return end
	vim.cmd(("edit +/%s %s"):format(snip.key, snip.path))
end)

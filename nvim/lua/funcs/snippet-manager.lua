local M = {}
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
---@field editSnippetPopup { height: number, width: number, border: string, keymaps: table<string, string> }
---@field jsonFormatter string|string[]|false passed to vim.fn.system

---@type pluginConfig
local defaultConfig = {
	snippetDir = vim.fn.stdpath("config") .. "/snippets",
	editSnippetPopup = {
		height = 0.4, -- 0-1
		width = 0.6,
		border = "rounded",
		keymaps = {
			cancel = "q",
			confirm = "<CR>",
			delete = "<D-BS>",
		}
	},
	-- If `false`, the json will be written in minified format. Pass a json
	-- formatter like `jq` if you want the json written in prettified format. The
	-- json-string will be piped as stdin to the formatter. This can be useful
	-- for version-controlling your snippets.
	jsonFormatter = { "biome", "format", "--stdin-file-path=foo.json" },
	-- examples
	-- jsonFormatter = "jq",
	-- jsonFormatter = false,
	-- jsonFormatter = { "biome", "--stdin-file-path=foobar.json" },
}
local config = defaultConfig

---@param userConfig? pluginConfig
function M.setup(userConfig)
	config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
end

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

---@param path string
---@return table
local function readAndParseJson(path) return vim.json.decode(readFile(path) or "{}") or {} end

---@param msg string
---@param level? "info"|"warn"|"error"|"debug"|"trace"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Snippet Manager" })
end

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

---@param filepath string
---@param snippetsInFile snippetObj[]
local function writeAndFormatSnippetFile(filepath, snippetsInFile)
	local jsonStr = vim.json.encode(snippetsInFile)
	assert(jsonStr, "snippet could not be written")
	if config.jsonFormatter then
		jsonStr = vim.fn.system(config.jsonFormatter, jsonStr)
		if vim.v.shell_error ~= 0 then
			notify("JSON formatting exited with error. \nNo changes made.", "error")
			return
		end
	end

	overwriteFile(filepath, jsonStr)
end


---@param snip snippetObj snippet to update
---@param bodyLines string[]
local function updateSnippet(snip, bodyLines)
	local snippetsInFile = readAndParseJson(snip.path)

	-- delete the keys set by this plugin
	local key = snip.originalKey
	local filepath = snip.path
	snip.originalKey = nil
	snip.path = nil

	snip.body = #bodyLines == 1 and bodyLines[1] or bodyLines
	snippetsInFile[key] = snip

	writeAndFormatSnippetFile(filepath, snippetsInFile)
end

---@param snip snippetObj
local function deleteSnippet(snip)
	local snippetsInFile = readAndParseJson(snip.path)
	snippetsInFile[snip.originalKey] = nil -- = delete
	writeAndFormatSnippetFile(snip.path, snippetsInFile)
end

---@param snip snippetObj
local function editInPopup(snip)
	local a = vim.api
	local conf = config.editSnippetPopup

	local body = type(snip.body) == "string" and { snip.body } or snip.body ---@cast body string[]
	local prefix = type(snip.prefix) == "string" and { snip.prefix } or snip.prefix ---@cast prefix string[]
	local prefixCount = type(snip.prefix) == "string" and 1 or #prefix
	local snipLines = vim.list_extend(prefix, body)
	local displayName = snip.originalKey:sub(1, 25)
	local sourceFile = vim.fs.basename(snip.path)

	-- create buffer and window
	local bufnr = a.nvim_create_buf(false, true)
	a.nvim_buf_set_lines(bufnr, 0, -1, false, snipLines)
	a.nvim_buf_set_name(bufnr, displayName)
	local guessedFt = guessFileType(sourceFile:gsub("%.json$", ""))
	if guessedFt then a.nvim_buf_set_option(bufnr, "filetype", guessedFt) end
	a.nvim_buf_set_option(bufnr, "buftype", "nofile")

	local winnr = a.nvim_open_win(bufnr, true, {
		relative = "win",
		title = (" %s (%s) "):format(displayName, sourceFile),
		title_pos = "center",
		border = conf.border,
		-- centered window
		width = math.floor(conf.width * a.nvim_win_get_width(0)),
		height = math.floor(conf.height * a.nvim_win_get_height(0)),
		row = math.floor((1 - conf.height) * a.nvim_win_get_height(0) / 2),
		col = math.floor((1 - conf.width) * a.nvim_win_get_width(0) / 2),
		zindex = 1, -- below nvim-notify floats
	})
	a.nvim_win_set_option(winnr, "signcolumn", "no")

	-- highlight cursor positions like `$0` or `${1:foo}`
	vim.fn.matchadd("DiagnosticVirtualTextInfo", [[\$\d]])
	vim.fn.matchadd("DiagnosticVirtualTextInfo", [[\${\d:.\{-}}]])

	-- label "prefix #N"
	local ns = a.nvim_create_namespace("snippet-manager")
	for i = 1, prefixCount do
		local ln = i - 1
		a.nvim_buf_set_extmark(bufnr, ns, 0, ln, {
			virt_text = { { ("Prefix #%s"):format(i), "DiagnosticVirtualTextHint" } },
			virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "right_align",
		})
	end
	-- separator line
	local winWidth = a.nvim_win_get_width(winnr)
	a.nvim_buf_set_extmark(bufnr, ns, prefixCount - 1, 0, {
		virt_lines = {
			{ { ("═"):rep(winWidth), "FloatBorder" } },
		},
	})

	-- keymaps
	local function close()
		a.nvim_win_close(winnr, true)
		a.nvim_buf_delete(bufnr, { force = true })
	end
	vim.keymap.set("n", conf.keymaps.confirm, function()
		local editedLines = a.nvim_buf_get_lines(bufnr, 0, -1, false)
		updateSnippet(snip, editedLines)
		notify("Snippet updated.")
		close()
	end, { buffer = bufnr, nowait = true })
	vim.keymap.set("n", conf.keymaps.cancel, function()
		notify("Cancelled. Snippet not changed.")
		close()
	end, { buffer = bufnr, nowait = true })
	vim.keymap.set("n", conf.keymaps.delete, function()
		notify("Snippet deleted.")
		deleteSnippet(snip)
		close()
	end, { buffer = bufnr, nowait = true })
end

--------------------------------------------------------------------------------

---Searches a folder of vs-code-like snippets in json format and opens the selected.
function M.editSnippet()
	-- get all snippets
	local allSnippets = {} ---@type snippetObj[]
	for name, _ in vim.fs.dir(config.snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then
			local filepath = config.snippetDir .. "/" .. name
			local snippetsInFileDict = readAndParseJson(filepath)

			-- convert dictionary to array for `vim.ui.select`
			local snippetsInFileList = {} ---@type snippetObj[]
			for key, snip in pairs(snippetsInFileDict) do
				snip.path = filepath
				snip.originalKey = key
				table.insert(snippetsInFileList, snip)
			end
			vim.list_extend(allSnippets, snippetsInFileList)
		end
	end

	-- let user select
	vim.ui.select(allSnippets, {
		prompt = "Select snippet:",
		format_item = function(item)
			local snipname = item.prefix[1] or item.prefix
			local filename = vim.fs.basename(item.path):gsub("%.json$", "")
			return ("%s\t\t(%s)"):format(snipname, filename)
		end,
		kind = "snippet-manager.snippetSearch",
	}, function(snip)
		if not snip then return end
		editInPopup(snip)
	end)
end

function M.addNewSnippet()

	-- get all snippets JSON files
	local jsonFiles = {}
	for name, _ in vim.fs.dir(config.snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then
			table.insert(jsonFiles, name)
		end
	end

	-- let user select
	vim.ui.select(jsonFiles, {
		prompt = "Select snippet file:",
		format_item = function(item) return item:gsub("%.json$", "") end,
		kind = "snippet-manager.fileSelect",
	}, function(file)
		if not file then return end
		local snip = {
			path = config.snippetDir .. "/" .. file .. ".json",
		} 
		-- editInPopup(snip)
	end)
end

--------------------------------------------------------------------------------
return M

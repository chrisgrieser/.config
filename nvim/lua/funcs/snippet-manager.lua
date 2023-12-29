local M = {}
--------------------------------------------------------------------------------

---@class (exact) snippetObj VSCode snippet json
---@field fullPath string (key only set by this plugin)
---@field originalKey? string if not set, is a new snippet (key only set by this plugin)
---@field prefix string|string[]
---@field body string|string[]
---@field description? string

--------------------------------------------------------------------------------

---@class (exact) pluginConfig
---@field snippetDir string
---@field editSnippetPopup { height: number, width: number, border: string, keymaps: table<string, string> }
---@field jsonFormatter "yq"|"jq"|"none"

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
			openInFile = "<C-o>",
		},
	},
	-- `none` has no dependency, but writes a minified json file.
	-- `yq` and `jq` ensure formatted & sorted json files, which you might prefer
	-- for version-controlling your snippets. (Both are also available via Mason.)
	jsonFormatter = "yq", -- yq|jq|none
}
local config = defaultConfig

---@param userConfig? pluginConfig
function M.setup(userConfig) config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {}) end

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"warn"|"error"|"debug"|"trace"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Snippet Manager" })
end

---@param path string
---@return table
local function readAndParseJson(path)
	local name = vim.fs.basename(path)
	local file, _ = io.open(path, "r")
	assert(file, name .. " could not be read")
	local content = file:read("*a")
	file:close()
	local ok, json = pcall(vim.json.decode, content) ---@cast json table
	if not ok then
		notify("Could not parse " .. name, "warn")
		return {}
	end
	return json
end

---@return boolean
local function snippetDirExists()
	local stat = vim.loop.fs_stat(config.snippetDir)
	local exists = stat and stat.type == "directory"
	if not exists then
		notify("Snippet dir does not exist: " .. config.snippetDir, "error")
		return false
	end
	return true
end

---@param pathOfSnippetFile string
---@return string|false filetype
---@nodiscard
local function guessFileType(pathOfSnippetFile)
	-- primary: read package.json
	local relPathOfSnipFile = pathOfSnippetFile:sub(#config.snippetDir + 2)
	local packageJson = readAndParseJson(config.snippetDir .. "/package.json")
	local snipFilesInfo = packageJson.contributes.snippets
	local infoOfFile = vim.tbl_filter(
		function(info) return info.path:gsub("^%.?/", "") == relPathOfSnipFile end,
		snipFilesInfo
	)
	if infoOfFile[1] then
		local lang = vim.infoOfFile[1].language
		if type(lang) == "string" then lang = { lang } end
		lang = vim.tbl_filter(function (l) return l ~= "global" end, lang)
		vim.notify("🪚 lang: " .. vim.inspect(lang))
		return lang[1]
	end

	-- fallback #1: filename is filetype
	local filename = vim.fs.basename(pathOfSnippetFile):gsub("%.json$", "")
	local allKnownFts = vim.fn.getcompletion("", "filetype")
	if vim.tbl_contains(allKnownFts, filename) then return filename end

	-- fallback #2: filename is file extension
	local matchedFt = vim.filetype.match { filename = "dummy." .. filename }
	if matchedFt then return matchedFt end

	return false
end

---@param filepath string
---@param snippetsInFile snippetObj[]
---@return boolean success
---@nodiscard
local function writeAndFormatSnippetFile(filepath, snippetsInFile)
	local ok, jsonStr = pcall(vim.json.encode, snippetsInFile)
	assert(ok and jsonStr, "Could not encode JSON.")

	-- INFO formatting via `yq` or `jq` is necessary, since `vim.json.encode`
	-- does not ensure a stable order of keys in the written JSON.
	if config.jsonFormatter ~= "none" then
		local cmds = {
			-- DOCS https://mikefarah.gitbook.io/yq/operators/sort-keys
			yq = { "yq", "--prettyPrint", "--output-format=json", "--no-colors", "sort_keys(..)" },
			-- DOCS https://jqlang.github.io/jq/manual/#invoking-jq
			jq = { "jq", "--sort-keys", "--monochrome-output" },
		}
		jsonStr = vim.fn.system(cmds[config.jsonFormatter], jsonStr)
		assert(vim.v.shell_error == 0, "JSON formatting exited with " .. vim.v.shell_error)
	end

	local file, _ = io.open(filepath, "w")
	assert(file, "Could not write to " .. filepath)
	file:write(jsonStr)
	file:close()
	return true
end

---@param snip snippetObj snippet to update/create
---@param editedLines string[]
local function updateSnippetFile(snip, editedLines)
	local snippetsInFile = readAndParseJson(snip.fullPath)
	local filepath = snip.fullPath

	-- determine prefix & body
	local numOfPrefixes = type(snip.prefix) == "string" and 1 or #snip.prefix
	local prefix = vim.list_slice(editedLines, 1, numOfPrefixes)
	local body = vim.list_slice(editedLines, numOfPrefixes + 1, #editedLines)

	-- LINT/VALIDATE PREFIX & BODY
	-- trim (only trailing for body, since leading there is indentation)
	prefix = vim.tbl_map(function(line) return vim.trim(line) end, prefix)
	body = vim.tbl_map(function(line) return line:gsub("%s+$", "") end, body)
	-- remove deleted prefixes
	prefix = vim.tbl_filter(function(line) return line ~= "" end, prefix)
	if #prefix == 0 then
		notify("Prefix is empty. No changes made.", "warn")
		return
	end
	-- trim trailing empty lines from body
	while body[#body] == "" do
		table.remove(body)
		if #body == 0 then
			notify("Body is empty. No changes made.", "warn")
			return
		end
	end

	-- new snippet: key = prefix
	local isNewSnippet = snip.originalKey == nil
	local key = isNewSnippet and prefix[1] or snip.originalKey
	assert(key, "Snippet key missing")
	-- ensure key is unique
	while isNewSnippet and snippetsInFile[key] ~= nil do
		key = key .. "_1"
	end

	-- update snipObj
	snip.originalKey = nil -- delete key set by this plugin
	snip.fullPath = nil -- delete key set by this plugin
	snip.body = #body == 1 and body[1] or body
	snip.prefix = #prefix == 1 and prefix[1] or prefix
	snippetsInFile[key] = snip

	local success = writeAndFormatSnippetFile(filepath, snippetsInFile)
	if success then notify(isNewSnippet and "Snippet created." or "Snippet updated.") end
end

---@param snip snippetObj
local function deleteSnippet(snip)
	local snippetsInFile = readAndParseJson(snip.fullPath)
	snippetsInFile[snip.originalKey] = nil -- = delete

	local success = writeAndFormatSnippetFile(snip.fullPath, snippetsInFile)
	if success then notify("Snippet deleted.") end
end

---@param snip snippetObj
---@param mode "new"|"update"
local function editInPopup(snip, mode)
	local a = vim.api
	local conf = config.editSnippetPopup

	-- snippet properties
	local body = type(snip.body) == "string" and { snip.body } or snip.body ---@cast body string[]
	local prefix = type(snip.prefix) == "string" and { snip.prefix } or snip.prefix ---@cast prefix string[]
	local numOfPrefixes = #prefix -- needs to be saved as list_extend mutates `prefix`
	local snipLines = vim.list_extend(prefix, body)
	local nameOfSnippetFile = vim.fs.basename(snip.fullPath)

	-- title
	local displayName = mode == "new" and "New Snippet" or snip.originalKey:sub(1, 25)
	local title = mode == "new" and (' New Snippet in "%s" '):format(nameOfSnippetFile)
		or (" %s [%s] "):format(displayName, nameOfSnippetFile)

	-- create buffer and window
	local bufnr = a.nvim_create_buf(false, true)
	a.nvim_buf_set_lines(bufnr, 0, -1, false, snipLines)
	a.nvim_buf_set_name(bufnr, displayName)
	local guessedFt = guessFileType(snip.fullPath)
	if guessedFt then a.nvim_buf_set_option(bufnr, "filetype", guessedFt) end
	a.nvim_buf_set_option(bufnr, "buftype", "nofile")

	local winnr = a.nvim_open_win(bufnr, true, {
		relative = "win",
		title = title,
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

	-- move cursor
	if mode == "new" then
		vim.cmd.startinsert()
	elseif mode == "update" then
		local firstLineOfBody = numOfPrefixes + 1
		a.nvim_win_set_cursor(winnr, { firstLineOfBody, 0 })
	end

	-- highlight cursor positions like `$0` or `${1:foo}`
	vim.fn.matchadd("DiagnosticVirtualTextInfo", [[\$\d]])
	vim.fn.matchadd("DiagnosticVirtualTextInfo", [[\${\d:.\{-}}]])

	-- label "prefix #N"
	local ns = a.nvim_create_namespace("snippet-manager")
	for i = 1, numOfPrefixes do
		local ln = i - 1
		local label = numOfPrefixes == 1 and "Prefix" or "Prefix #" .. i
		a.nvim_buf_set_extmark(bufnr, ns, ln, 0, {
			virt_text = { { label, "DiagnosticVirtualTextHint" } },
			virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "right_align",
		})
	end
	-- separator line
	local winWidth = a.nvim_win_get_width(winnr)
	a.nvim_buf_set_extmark(bufnr, ns, numOfPrefixes - 1, 0, {
		virt_lines = {
			{ { ("═"):rep(winWidth), "FloatBorder" } },
		},
	})

	-- keymaps
	local function close()
		a.nvim_win_close(winnr, true)
		a.nvim_buf_delete(bufnr, { force = true })
	end
	local opts = { buffer = bufnr, nowait = true, silent = true }
	vim.keymap.set("n", conf.keymaps.cancel, close, opts)
	vim.keymap.set("n", conf.keymaps.confirm, function()
		local editedLines = a.nvim_buf_get_lines(bufnr, 0, -1, false)
		updateSnippetFile(snip, editedLines)
		close()
	end, opts)
	vim.keymap.set("n", conf.keymaps.delete, function()
		if mode == "new" then
			notify("Cannot snippet that has not been created yet.", "warn")
			return
		end
		deleteSnippet(snip)
		close()
	end, opts)
	vim.keymap.set("n", conf.keymaps.openInFile, function()
		close()
		local locationInFile = '"' .. snip.originalKey:gsub(" ", [[\ ]]) .. '":'
		vim.cmd(("edit +/%s %s"):format(locationInFile, snip.fullPath))
	end, opts)

	-- FIX/HACK shifting of virtual lines when using `<CR>` on empty buffer
	vim.keymap.set("i", conf.keymaps.confirm, function()
		local row, col = unpack(a.nvim_win_get_cursor(0))
		if row == 0 and col == 0 then return end
		return "<CR>"
	end, { buffer = bufnr, expr = true })
end

--------------------------------------------------------------------------------

---Searches a folder of vs-code-like snippets in json format and opens the selected.
function M.editSnippet()
	if not snippetDirExists() then return end

	-- get all snippets
	local allSnippets = {} ---@type snippetObj[]
	for name, _ in vim.fs.dir(config.snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then
			local filepath = config.snippetDir .. "/" .. name
			local snippetsInFileDict = readAndParseJson(filepath)

			-- convert dictionary to array for `vim.ui.select`
			local snippetsInFileList = {} ---@type snippetObj[]
			for key, snip in pairs(snippetsInFileDict) do
				snip.fullPath = filepath
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
			local filename = vim.fs.basename(item.fullPath):gsub("%.json$", "")
			return ("%s\t\t[%s]"):format(snipname, filename)
		end,
		kind = "snippet-manager.snippetSearch",
	}, function(snip)
		if not snip then return end
		editInPopup(snip, "update")
	end)
end

function M.addNewSnippet()
	if not snippetDirExists() then return end

	-- get all snippets JSON files
	local jsonFiles = {}
	for name, _ in vim.fs.dir(config.snippetDir, { depth = 3 }) do
		if name:find("%.json$") and name ~= "package.json" then table.insert(jsonFiles, name) end
	end

	-- let user select
	vim.ui.select(jsonFiles, {
		prompt = "Select file for new snippet:",
		format_item = function(item) return item:gsub("%.json$", "") end,
		kind = "snippet-manager.fileSelect",
	}, function(file)
		if not file then return end

		---@type snippetObj
		local snip = {
			fullPath = config.snippetDir .. "/" .. file,
			body = "",
			prefix = "",
		}
		editInPopup(snip, "new")
	end)
end

--------------------------------------------------------------------------------
return M

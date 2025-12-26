local M = {}
--------------------------------------------------------------------------------

---Wraps text with markdown links, automatically inserting the URL if in a Markdown link if the `+` register has a URL. In normal mode, can undo.
---@param startWrap string|"mdlink"
---@param endWrap? string defaults to `startWrap`
function M.wrap(startWrap, endWrap)
	if not endWrap then endWrap = startWrap end
	local mode = vim.fn.mode()
	if mode == "V" then
		vim.notify("Visual line mode not supported", vim.log.levels.WARN)
		return
	end
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local useBigWord = startWrap == "`"

	-- determine text
	local text = ""
	if mode == "n" then
		local cursorChar = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
		if not cursorChar:find("%w") and not useBigWord then
			vim.notify("String under cursor is not a word or number.", vim.log.levels.WARN)
			return
		end
		text = startWrap == "`" and vim.fn.expand("<cWORD>") or vim.fn.expand("<cword>")
	elseif mode == "v" then
		vim.cmd.normal { '"zy', bang = true }
		text = vim.fn.getreg("z")
	end

	-- wrap text
	local insert = startWrap .. text .. endWrap
	local clipboardUrl
	if startWrap == "mdlink" then
		local clipb = vim.fn.getreg("+")
		clipboardUrl = clipb:match("^#[%w-]+$") -- heading-link
			or clipb:match([[^%l%l%l+://[^%s)%]}"'`>]+]]) -- url
			or ""
		insert = ("[%s](%s)"):format(text, clipboardUrl)
	end

	-- normal mode: check whether to undo instead
	local prevOpt = vim.opt.iskeyword:get()
	local shouldUndo = false
	if mode == "n" then
		vim.opt.iskeyword:append { startWrap:sub(1, 1), endWrap:sub(1, 1) }
		local cword = useBigWord and vim.fn.expand("<cWORD>") or vim.fn.expand("<cword>")
		shouldUndo = (not useBigWord and cword == insert)
			or (useBigWord and vim.startswith(insert, startWrap:rep(2)))
		if shouldUndo then insert = useBigWord and text:sub(2, -2) or text end
	end

	-- insert
	if mode == "n" then
		local wordArg = startWrap == "`" and "W" or "w"
		vim.cmd.normal { '"_ci' .. wordArg .. insert, bang = true }
		vim.opt.iskeyword = prevOpt
	elseif mode == "v" then
		vim.cmd.normal { "gv", bang = true } -- re-select, since yank put us in normal mode
		vim.cmd.normal { '"_c' .. insert, bang = true }
	elseif mode == "i" then
		local curLine = vim.api.nvim_get_current_line()
		local newLine = curLine:sub(1, col) .. insert .. curLine:sub(col + 1)
		vim.api.nvim_set_current_line(newLine)
	end

	-- cursor movement
	if startWrap == "mdlink" then
		vim.api.nvim_win_set_cursor(0, { row, col + 1 })
		if clipboardUrl == "" and text ~= "" then vim.cmd.normal { "f)", bang = true } end
	else
		local offset = shouldUndo and -#startWrap or #startWrap
		vim.api.nvim_win_set_cursor(0, { row, col + offset })
	end
	if text == "" or clipboardUrl == "" then vim.cmd.startinsert() end
end

---@param key "o"|"O"|"<CR>"
function M.autoBullet(key)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local indent, continued = "", ""
	local ln = row
	repeat
		local line = vim.api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]
		ln = ln - 1
		if ln == 0 then break end
		indent = line:match("^%s*")
		local task = line:match("^%s*([-*+] %[[x ]%] )")
		local list = not task and line:match("^%s*([-*+] )")
		local blockquote = line:match("^%s*(>+ )")
		local num = line:match("^%s*(%d+%. )")
		continued = list or task or num or blockquote or ""
		if num then continued = num:gsub("%d+", function(n) return tostring(tonumber(n) + 1) end) end
	until continued ~= "" or indent == "" -- loop to consider bullets on hard-wrapped lines
	if continued ~= "" then continued = indent .. continued end

	local line = vim.api.nvim_get_current_line()
	local emptyList = ((continued ~= "") and vim.trim(indent .. continued) == vim.trim(line))
		or line:match("^%s*%d+%. $")
	if key == "o" or key == "O" then
		if key == "O" then row = row - 1 end
		vim.api.nvim_buf_set_lines(0, row, row, false, { continued })
		vim.api.nvim_win_set_cursor(0, { row + 1, 1 })
		vim.cmd.startinsert { bang = true } -- bang -> insert at EoL
	elseif key == "<CR>" and emptyList then
		vim.api.nvim_set_current_line("")
	elseif key == "<CR>" and not emptyList then
		local beforeCur, afterCur = line:sub(1, col), line:sub(col + 1)
		if vim.startswith(afterCur, continued) then continued = "" end -- cursor before list markers
		local nextLine = continued .. afterCur
		vim.api.nvim_buf_set_lines(0, row - 1, row, false, { beforeCur, nextLine })
		vim.api.nvim_win_set_cursor(0, { row + 1, #continued })
	end
end

---@param linesToInsert string[]
function M.insertFrontmatter(linesToInsert)
	local hasFrontmatter = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "---"
	if hasFrontmatter then
		vim.notify("Frontmatter already exists.")
		vim.api.nvim_win_set_cursor(0, { 2, 0 })
	else
		table.insert(linesToInsert, 1, "---")
		vim.list_extend(linesToInsert, { "---", "" })
		vim.api.nvim_buf_set_lines(0, 0, 0, false, linesToInsert)
		vim.api.nvim_win_set_cursor(0, { #linesToInsert - 2, 0 })
		vim.cmd.startinsert { bang = true }
	end
end

---@param dir 1|-1
function M.incrementHeading(dir)
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^#* ", function(match)
		if dir == -1 and match ~= "# " then return match:sub(2) end
		if dir == 1 and match ~= "###### " then return "#" .. match end
		return ""
	end)
	if updated == curLine then updated = (dir == 1 and "## " or "###### ") .. curLine end

	vim.api.nvim_set_current_line(updated)
	local diff = #updated - #curLine
	vim.api.nvim_win_set_cursor(0, { lnum, math.max(col + diff, 0) })
end

function M.followMdlinkOrWikilink()
	local mdlinkPattern = "%[.-]%((.-)%)"
	local wikilinkPattern = "%[%[.-]]"
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local url, wikilink
	local ln = row
	local line = vim.api.nvim_get_current_line()

	-- look in current line
	local idx = 0
	col = col + 1
	while true do
		local partialLine = line:sub(idx)
		local _, urlEnd = partialLine:find(mdlinkPattern)
		local _, wikiEnd = partialLine:find(wikilinkPattern)
		if urlEnd and (col <= idx + urlEnd) and (urlEnd < (wikiEnd or math.huge)) then
			url = partialLine:match(mdlinkPattern)
			break
		elseif wikiEnd and (col <= idx + wikiEnd) then
			wikilink = partialLine:match(wikilinkPattern)
			break
		end
		if not urlEnd and not wikiEnd then break end -- no link found in line
		idx = idx + math.min(urlEnd or math.huge, wikiEnd or math.huge) -- look for next link
	end

	-- look forward in upcoming lines
	local maxForward = 10
	local totalLines = vim.api.nvim_buf_line_count(0)
	while not (url or wikilink) do
		ln = ln + 1
		if ln > totalLines or ln > row + maxForward then
			local msg = ("Could not find URL or wikilink within %d lines."):format(maxForward)
			vim.notify(msg, vim.log.levels.WARN)
			return
		end
		line = vim.api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]
		url = line:match(mdlinkPattern)
		wikilink = line:match(wikilinkPattern)
		if url or wikilink then break end
	end

	if url then
		local isFileLink = not vim.startswith(url, "http")
		if isFileLink then return vim.cmd.edit(url) end

		-- move cursor to start of mdlink, or of the url
		local targetCol = line:find(mdlinkPattern)
		vim.api.nvim_win_set_cursor(0, { ln, targetCol - 1 })
		vim.ui.open(url)
	elseif wikilink then
		-- `vim.lsp.buf.definition` requires to be on the link
		local targetCol = line:find(wikilink, nil, true)
		vim.api.nvim_win_set_cursor(0, { ln, targetCol - 1 })
		local hasMarksman = vim.lsp.get_clients({ name = "marksman", bufnr = 0 })[1]
		if not hasMarksman then return vim.notify("Marksman not attached.", vim.log.levels.WARN) end
		vim.lsp.buf.definition()
	end
end

function M.rename()
	local filepath = vim.api.nvim_buf_get_name(0)
	local edit = {
		textDocument = { uri = vim.uri_from_fname(filepath) },
		edits = {
			{
				newText = vim.fn.expand("<cword>"),
				range = {
					start = { line = 1, character = 1 },
					["end"] = { line = 1, character = 2 },
				},
			},
		},
	}
	vim.lsp.util.apply_text_document_edit(edit, nil, vim.o.encoding)
end

function M.addTitleToUrl()
	assert(vim.fn.executable("curl") == 1, "`curl` not found.")
	local line = vim.api.nvim_get_current_line()
	local url = line:match([[<?%l+://%S+>?]])
	if vim.endswith(url, ")") then return vim.notify("Already Markdown link.") end
	local innerUrl = url:gsub(">$", ""):gsub("^<", "") -- bare URL enclosed in `<>` due to MD034

	local out = vim.system({ "curl", "--silent", "--location", innerUrl }):wait()
	if out.code ~= 0 then return vim.notify(out.stderr, vim.log.levels.ERROR) end
	local title = vim.trim(out.stdout:match("<title.->(.-)</title>") or "")
	title = title -- cleanup
		:gsub("[\n\r]+", " ")
		:gsub("^GitHub %- ", "")
		:gsub(" · GitHub", "")

	local urlStart, urlEnd = line:find(url, nil, true) -- `find` has literal search, `gsub` does not
	local updatedLine = line:sub(1, urlStart - 1)
		.. ("[%s](%s)"):format(title, innerUrl)
		.. line:sub(urlEnd + 1)
	vim.api.nvim_set_current_line(updatedLine)
	if title == "" then
		vim.notify("No title found.", vim.log.levels.WARN)
		local row = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_set_cursor(0, { row, urlStart + 1 })
	end
end

function M.cycleList()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local curLine = vim.api.nvim_get_current_line()

	local updated = curLine:gsub("^(%s*)([%d.*+-]+ )", function(indent, list)
		if list:find("[*+-] ") and not list:find("%- %[") then return indent .. "1. " end -- bullet -> number
		return indent -- number -> none
	end)
	-- none -> bullet
	if updated == curLine then updated = curLine:gsub("^(%s*)(.*)", "%1- %2") end

	vim.api.nvim_set_current_line(updated)
	local diff = #updated - #curLine
	vim.api.nvim_win_set_cursor(0, { lnum, math.max(1, col + diff) })
end

---@param css string url or absolute path
function M.previewViaPandoc(css)
	assert(vim.fn.executable("pandoc") == 1, "Pandoc not found.")
	local outputPath = "/tmp/markdown-preview.html"

	vim.cmd("silent! update")
	vim.system({
		"pandoc",
		"--from=gfm+rebase_relative_paths", -- rebasing, so images are available at output location
		vim.api.nvim_buf_get_name(0),
		"--output=" .. outputPath,
		"--standalone",
		"--css=" .. css,
		"--title-prefix=Preview from nvim", -- used only in browser tab title
	}):wait()

	vim.ui.open(outputPath)
end

function M.codeBlockFromClipboard()
	-- dedent clipboard content
	local code = vim.split(vim.fn.getreg("+"), "\n", { trimempty = true })
	local smallestIndent = vim.iter(code):fold(math.huge, function(acc, line)
		if vim.trim(line) == "" then return acc end -- ignore empty lines for indent
		local indent = #line:match("^%s*")
		return math.min(acc, indent)
	end)
	local dedented = vim.tbl_map(function(line)
		if vim.trim(line) == "" then return line end -- ignore empty lines for indent
		return line:sub(smallestIndent + 1)
	end, code)

	-- insert
	local row = vim.api.nvim_win_get_cursor(0)[1]
	table.insert(dedented, 1, "```")
	table.insert(dedented, "```")
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, dedented)
	vim.api.nvim_win_set_cursor(0, { row, 1 })
	vim.cmd.startinsert { bang = true }
end

--------------------------------------------------------------------------------
return M

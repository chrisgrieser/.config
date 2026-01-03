local M = {}
--------------------------------------------------------------------------------

---Wraps text with markdown links, automatically inserting the URL if in a
---Markdown link if the `+` register has a URL. In normal mode, can undo.
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
	local urlPattern = [[%l+://[^%s)%]}"'`>]+]]
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local mdlink, wikilink, url
	local ln = row
	local line = vim.api.nvim_get_current_line()

	-- look in current line
	local idx = 0
	col = col + 1
	while true do
		local partialLine = line:sub(idx)
		local _, mdlinkEnd = partialLine:find(mdlinkPattern)
		local _, wikiEnd = partialLine:find(wikilinkPattern)
		local _, urlEnd = partialLine:find(urlPattern)
		if
			mdlinkEnd
			and (col <= idx + mdlinkEnd)
			and (mdlinkEnd < (wikiEnd or math.huge))
			and (mdlinkEnd < (urlEnd or math.huge))
		then
			mdlink = partialLine:match(mdlinkPattern)
			break
		elseif wikiEnd and (col <= idx + wikiEnd) and (wikiEnd < (urlEnd or math.huge)) then
			wikilink = partialLine:match(wikilinkPattern)
			break
		elseif urlEnd and (col <= idx + urlEnd) then
			url = partialLine:match(urlPattern)
			break
		end
		if not (mdlinkEnd or wikiEnd or urlEnd) then break end -- no link found in line
		idx = idx + math.min(mdlinkEnd or math.huge, wikiEnd or math.huge, urlEnd or math.huge)
	end

	-- look forward in upcoming lines
	local maxForward = 10
	local totalLines = vim.api.nvim_buf_line_count(0)
	while not (mdlink or wikilink or url) do
		ln = ln + 1
		if ln > totalLines or ln > row + maxForward then
			local msg = ("Could not find URL or wikilink within %d lines."):format(maxForward)
			vim.notify(msg, vim.log.levels.WARN)
			return
		end
		line = vim.api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]
		local mdlinkStart = line:find(mdlinkPattern)
		local wikiStart = line:find(wikilinkPattern)
		local urlStart = line:find(urlPattern)
		local closest =
			math.min(mdlinkStart or math.huge, wikiStart or math.huge, urlStart or math.huge)
		if closest == mdlinkStart then mdlink = line:match(mdlinkPattern) end
		if closest == wikiStart then wikilink = line:match(wikilinkPattern) end
		if closest == urlStart then url = line:match(urlPattern) end
	end

	if mdlink or url then
		local isFileLink = not url and not vim.startswith(mdlink, "http")
		if isFileLink then return vim.cmd.edit(vim.uri_decode(mdlink)) end

		-- move cursor to start of mdlink or url
		local targetCol = mdlink and line:find(mdlinkPattern) or line:find(urlPattern)
		vim.api.nvim_win_set_cursor(0, { ln, targetCol - 1 })
		vim.ui.open(mdlink or url)
	elseif wikilink then
		-- `vim.lsp.buf.definition` requires that cursor is on the link
		local targetCol = line:find(wikilink, nil, true)
		vim.api.nvim_win_set_cursor(0, { ln, targetCol - 1 })
		vim.lsp.buf.definition() -- requires marksman, zk, or markdown-oxide
	end
end
--------------------------------------------------------------------------------

---@param filepath? string
---@return string pattern
local function getBacklinkRegex(filepath)
	if not filepath then filepath = vim.api.nvim_buf_get_name(0) end
	local basename = vim.fs.basename(filepath):gsub("%.md$", "")
	local wikilinkPattern = "\\[\\[" .. vim.fn.escape(basename, "\\") .. "([#|].*?)?\\]\\]"
	local cwd = assert(vim.uv.cwd(), "cwd not found")
	local relpathEncoded = vim.uri_encode(filepath:sub(#cwd + 1)):gsub("%%%w%w", string.upper)
	local mdlinkPattern = "\\[.*?\\]\\(" .. "\\.?" .. relpathEncoded .. "\\)"
	return wikilinkPattern .. "|" .. mdlinkPattern
end

function M.backlinks()
	assert(vim.bo.ft == "markdown", "Only for Markdown files.")
	assert(Snacks, "snacks.nvim not found")
	Snacks.picker.grep {
		title = " Backlinks",
		cmd = "rg",
		args = { "--no-config", "--glob=*.md" },
		live = false,
		regex = true,
		search = getBacklinkRegex(),
		format = function(item, _picker) -- just display the file
			local out = {}
			Snacks.picker.highlight.format(item, item.file, out)
			return out
		end,
	}
end

-- PENDING https://github.com/artempyanykh/marksman/issues/405
function M.renameAndUpdateWikilinks()
	assert(vim.bo.ft == "markdown", "Only for Markdown files.")
	assert(vim.fn.executable("rg") == 1, "`ripgrep` not found.")

	local icon = "󰑕"
	local oldPath = vim.api.nvim_buf_get_name(0)
	local oldName = vim.fs.basename(oldPath):gsub("%.md$", "")
	local oldBufnr = vim.api.nvim_get_current_buf()

	vim.ui.input({
		prompt = icon .. " Rename & update backlinks to: ",
		default = oldName,
	}, function(newName)
		if not newName then return end
		local err = function(msg) vim.notify(msg, vim.log.levels.ERROR) end

		-- RENAME FILE ITSELF
		if newName:find("[/:\\]") then return err("Invalid filename.") end
		if newName == oldName then return err("Cannot use the same filename.") end
		if vim.trim(newName) == "" then return err("Cannot use empty filename.") end
		local newPath = vim.fs.joinpath(vim.fs.dirname(oldPath), newName .. ".md")
		if vim.uv.fs_stat(newPath) then return err(("File %q already exists."):format(newName)) end
		vim.cmd("silent! update")
		local success, errmsg = vim.uv.fs_rename(oldPath, newPath)
		if not success then return err(("Failed to rename to %q: %s"):format(newName, errmsg)) end
		vim.cmd.edit(newPath)
		vim.cmd("silent! write")
		vim.api.nvim_buf_delete(oldBufnr, { force = true })

		-- UPDATE BACKLINKS
		local out = vim.system({
			"rg",
			"--no-config",
			"--json", -- prints result as json lines
			"--glob=*.md",
			"--",
			getBacklinkRegex(oldPath),
		}):wait()
		if out.code ~= 0 then
			local d = vim.json.decode(out.stdout)
			-- `rg` exits 1 if no match was found, which is not an error for us though
			local noBacklinksFound = d and d.data and d.data.stats and d.data.stats.matches == 0
			if not noBacklinksFound then return err("rg error: " .. out.stderr) end
		end

		local jsonLines = vim.split(vim.trim(out.stdout or ""), "\n")
		local cwd = assert(vim.uv.cwd(), "No cwd set.")
		local updateCount, filesChanged = 0, {}
		vim.iter(jsonLines):each(function(jsonLine)
			local o = vim.json.decode(jsonLine)
			if o.type ~= "match" then return end -- `start`, `end`, and `summary` jsons
			local relPath = o.data.path.text
			table.insert(filesChanged, "- " .. relPath)

			---@type lsp.TextDocumentEdit
			local textDocumentEdits = {
				textDocument = { uri = vim.uri_from_fname(cwd .. "/" .. relPath) },
				edits = {},
			}
			for _, submatch in ipairs(o.data.submatches) do
				local origText, replacement = submatch.match.text, ""
				if vim.startswith(origText, "[[") then
					replacement = origText:gsub(vim.pesc(oldName), vim.pesc(newName))
				else
					replacement = origText:gsub("%[(.-)%]%((.-)%)", function(label, destination)
						local oldEncoded, newEncoded = vim.uri_encode(oldName), vim.uri_encode(newName)
						destination = destination:gsub(vim.pesc(oldEncoded), vim.pesc(newEncoded))
						label = label:gsub(vim.pesc(oldName), vim.pesc(newName))
						return ("[%s](%s)"):format(label, destination)
					end)
				end
				if replacement == origText then err(("Link %s not be updated."):format(origText)) end
				table.insert(textDocumentEdits.edits, {
					newText = replacement,
					range = {
						start = { line = o.data.line_number - 1, character = submatch.start },
						["end"] = { line = o.data.line_number - 1, character = submatch["end"] },
					},
				})
				updateCount = updateCount + 1
			end
			-- LSP-API is the easiest method for replacing in non-open documents
			vim.lsp.util.apply_text_document_edit(textDocumentEdits, nil, vim.o.encoding)
		end)
		if updateCount > 0 then vim.cmd("silent! wall") end -- save all changes

		-- NOTIFY
		local msg = ("**%q to %q.**"):format(oldName, newName) .. "\n\n"
		if updateCount == 0 then
			msg = msg .. "No backlinks found to be updated."
		else
			local s1 = updateCount > 1 and "s" or ""
			local s2 = #filesChanged > 1 and "s" or ""
			-- stylua: ignore
			msg = msg
				.. ("Updated [%d] backlink%s in [%d] file%s:"):format(updateCount, s1, #filesChanged, s2)
				.. "\n"
				.. table.concat(filesChanged, "\n")
		end
		vim.notify(msg, nil, { title = "Renamed file", icon = icon })
	end)
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

function M.previewViaPandoc()
	assert(vim.bo.ft == "markdown", "Only for Markdown files.")
	assert(vim.fn.executable("pandoc") == 1, "`pandoc` not found")
	local pathOfThisLuaFile = debug.getinfo(1, "S").source:sub(2)
	local css = vim.fs.dirname(pathOfThisLuaFile) .. "/github-markdown.css"
	assert(vim.uv.fs_stat(css), "Missing CSS file: " .. css)
	vim.cmd("silent! update")

	local filepath = vim.api.nvim_buf_get_name(0)
	local filename = vim.fs.basename(filepath):gsub("%.md$", "")
	local out = vim.system({
		"pandoc",
		filepath,
		"--from=gfm+rebase_relative_paths", -- rebasing, so images are available at output location
		"--to=html",
		"--standalone",
		"--css=" .. css,
		"--title-prefix=" .. filename, -- used as browser tab title
	}):wait()
	assert(out.code == 0, vim.trim(out.stderr))

	-- Convert pandoc's output for callouts to the one GitHub uses
	local callouts = { "note", "warning", "tip", "important", "caution" }
	local html = out.stdout
		:gsub('div class="(%a-)"', function(kind)
			if not vim.list_contains(callouts, kind:lower()) then return end
			return ('div class="markdown-alert markdown-alert-%s"'):format(kind)
		end)
		:gsub('<div class="title">%s*<p>(%a-)</p>%s*</div>', function(kind)
			if not vim.list_contains(callouts, kind:lower()) then return end
			return ('<p class="markdown-alert-title">%s</p>'):format(kind)
		end)

	-- write & open in browser
	local location = "/tmp/markdown-previews"
	vim.fn.mkdir(location, "p")
	local outputPath = ("%s/%s.html"):format(location, filename)
	local file, errmsg = io.open(outputPath, "w")
	assert(file, errmsg)
	file:write(html)
	file:close()
	vim.ui.open(outputPath) -- open in browser
end

function M.codeBlockFromClipboard()
	assert(vim.bo.ft == "markdown", "Only for Markdown files.")
	-- dedent clipboard content
	local code = vim.fn.getreg("+"):gsub("%s*$", ""):gsub("^%s*\n", "") -- trim, but not 1st indent
	local dedented = vim.text.indent(0, code)
	local lines = vim.split(dedented, "\n")

	-- insert
	local row = vim.api.nvim_win_get_cursor(0)[1]
	table.insert(lines, 1, "```")
	table.insert(lines, "```")
	vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)
	vim.api.nvim_win_set_cursor(0, { row, 1 })
	vim.cmd.startinsert { bang = true }
end

--------------------------------------------------------------------------------

---@param url string
---@return string?
local function getTitleForUrl(url)
	assert(vim.fn.executable("curl") == 1, "`curl` not found.")
	local out = vim.system({ "curl", "--silent", "--location", url }):wait()
	if out.code ~= 0 then
		vim.notify(out.stderr, vim.log.levels.ERROR)
		return
	end
	local title = vim.trim(out.stdout:match("<title.->(.-)</title>") or "")
	title = title -- cleanup
		:gsub("[\n\r]+", " ")
		:gsub("^GitHub %- ", "")
		:gsub(" · GitHub$", "")
		:gsub("&amp;", "&")
		:gsub("&#x27;", "'")
	return title
end

function M.addTitleToUrl()
	assert(vim.bo.ft == "markdown", "Only for Markdown files.")

	local line = vim.api.nvim_get_current_line()
	local url = line:match([[<?%l+://%S+>?]])
	if vim.endswith(url, ")") then return vim.notify("Already Markdown link.") end
	local innerUrl = url:gsub(">$", ""):gsub("^<", "") -- bare URL enclosed in `<>` due to MD034
	local title = getTitleForUrl(innerUrl)
	if not title then return end

	local urlStart, urlEnd = line:find(url, nil, true) -- `find` has literal search, `gsub` does not
	local updatedLine = line:sub(1, urlStart - 1)
		.. ("[%s](%s)"):format(title, innerUrl)
		.. line:sub(urlEnd + 1)
	vim.api.nvim_set_current_line(updatedLine)
	if title == "" then
		vim.notify("No title found.", vim.log.levels.WARN)
		local row = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_set_cursor(0, { row, urlStart + 1 })
		vim.schedule(vim.cmd.startinsert)
	end
end
---updates any url in the register to a mdlink if in a Markdown buffer
---@param reg '"'|"+"|string
---@return nil
function M.addTitleToUrlIfMarkdown(reg)
	-- GUARD
	if vim.bo.ft ~= "markdown" or vim.bo.buftype ~= "" then return end
	local node = vim.treesitter.get_node()
	if node and node:type() == "code_fence_content" then return end
	if node and node:type() == "html_block" then return end
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
	if charUnderCursor == "(" then return end -- inserting into mdlink

	local clipb = vim.fn.getreg(reg)
	local url = clipb:match("^%l+://%S+$") -- not ending with `)` to not match mdlinks
	if not url then return end

	local title = getTitleForUrl(url)
	if not title then return end
	local mdlink = ("[%s](%s)"):format(title, url)
	vim.fn.setreg(reg, mdlink)

	-- scroll left & move cursor to start of title
	vim.defer_fn(function()
		vim.cmd.normal { "zH", bang = true } -- scroll fully left
		local line = vim.api.nvim_get_current_line()
		local urlStart = line:find(mdlink, nil, true)
		local row = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_set_cursor(0, { row, urlStart })
		if title == "" then vim.schedule(vim.cmd.startinsert) end
	end, 1) -- deferred to act after the paste
end
--------------------------------------------------------------------------------
return M

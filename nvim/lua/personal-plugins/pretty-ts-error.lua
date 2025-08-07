local M = {}
--------------------------------------------------------------------------------

-- requ

function M.prettyTsError()
	local notifyOpts = { icon = "", title = "ts_ls" }
	local diag = vim.diagnostic.get_next()
	if not diag or diag.source ~= "typescript" then
		vim.notify("No diagnostic found.", vim.log.levels.WARN, notifyOpts)
		return
	end

	-- split diagnostic into codeblocks
	-- example: `Type '{ title: number; subtitle: string; mods: { cmd: { arg: string; }; ctrl: { arg: string; }; }; arg: string; variables: { address: string; url: string; coordinates: string; }; }[]' is not assignable to type 'AlfredItem[]'.`
	local msg = diag
		.message
		:gsub("'{", "\n```js\n{") -- codeblock start
		:gsub("(}%[?]?)'", "%1\n```\n") -- codeblock end
		:gsub("'", "`") -- single word
		:gsub("\n +", "\n") -- remove indents
		:gsub("\nType", "\n\nType") -- padding
	local lines = vim.split(msg, "\n")

	-- format codeblocks
	local fmtArgs
	if vim.fn.executable("biome") == 1 then
		fmtArgs = { "biome", "format", "--stdin-file-path=stdin.ts" }
	elseif vim.fn.executable("prettier") == 1 then
		fmtArgs = { "prettier", "--stdin-filepath=stdin.ts" }
	end
	if fmtArgs then
		lines = vim.iter(lines):fold({}, function(acc, line)
			local isCodeBlock = line:find("^{.+[]}]$") ~= nil
			if isCodeBlock then
				line = "type dummy = " .. line
				local out = vim.system(fmtArgs, { stdin = line }):wait()
				assert(out.stdout and out.code == 0, "Formatter failed. " .. out.stderr)
				local formatted = vim.trim(out.stdout:gsub("^type dummy = ", ""))
				vim.list_extend(acc, vim.split(formatted, "\n"))
			else
				table.insert(acc, line)
			end
			return acc
		end)
	end

	-- open LSP float
	local title = ("  %s %s "):format(diag.source, diag.code)
	local _bufnr, winid = vim.lsp.util.open_floating_preview(lines, "markdown", {
		close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "LspDetach" },
		wrap = false,
		title = title,
		height = #lines,
		focus = true,
	})
	-- FIX value above being ignored
	vim.api.nvim_win_set_config(winid, {
		title = title,
		height = #lines,
	})
end

--------------------------------------------------------------------------------
return M

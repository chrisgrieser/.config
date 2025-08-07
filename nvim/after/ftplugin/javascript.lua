local abbr = require("config.utils").bufAbbrev
local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

vim.bo.commentstring = "// %s" -- add space

--------------------------------------------------------------------------------

-- ABBREVIATIONS
abbr("cosnt", "const")
abbr("local", "const")
abbr("elseif", "else if")
abbr("--", "//")
abbr("~=", "!==")
abbr("()", "() =>")

--------------------------------------------------------------------------------

-- open the next regex at https://regex101.com/
bkeymap("n", "g/", function()
	-- GUARD
	local ok, tsSelect = pcall(require, "nvim-treesitter-textobjects.select")
	if not (ok and tsSelect) then
		vim.notify("`nvim-treesitter-textobjects` not installed.", vim.log.levels.WARN)
		return
	end
	tsSelect.select_textobject("@regex.outer", "textobjects")
	local notFound = vim.fn.mode():find("v") -- if a textobj is found, switches to visual mode
	if not notFound then
		vim.notify("No regex found", nil, { title = "Regex101" })
		return
	end

	-- get regex via temp register `z`
	vim.cmd.normal { '"zy', bang = true }
	local regex, flags = vim.fn.getreg("z"):match("/(.*)/(%l*)")
	local line = vim.api.nvim_get_current_line()
	local substitution = line:match("%.replace ?%(/.*/.*, ?'(.-)'")
		or line:match('%.replace ?%(/.*/.*, ?"(.-)"')

	local data = {
		regex = regex,
		flags = flags,
		substitution = substitution,
		delimiter = "/",
		flavor = "javascript",
		testString = "",
	}

	tsSelect.select_textobject("@regex.inner", "textobjects") -- reselect for easier pasting
	require("rip-substitute.open-at-regex101").open(data)
end, { desc = " Open in regex101" })

--------------------------------------------------------------------------------

bkeymap("n", "<leader>D", function()
	local config = {
		formatterArgs = { "biome", "format", "--stdin-file-name", "stdin.ts" },
	}

	local notifyOpts = { icon = "", title = "ts_ls" }
	local diag = vim.diagnostic.get_next()
	if not diag or diag.source ~= "typescript" then
		vim.notify("No diagnostic found.", vim.log.levels.WARN, notifyOpts)
		return
	end

	-- EXAMPLE
	-- Type '{ title: number; subtitle: string; mods: { cmd: { arg: string; }; ctrl: { arg: string; }; }; arg: string; variables: { address: string; url: string; coordinates: string; }; }[]' is not assignable to type 'AlfredItem[]'.
	local msg = diag
		.message
		:gsub("'{", "\n```js\n{") -- codeblock start
		:gsub("(}%[?]?)'", "%1\n```\n") -- codeblock end
		:gsub("'", "`") -- single word
		:gsub("\n +", "\n") -- remove indents
		:gsub("\nType", "\n- Type") -- add bullets
		:gsub("^Type", "\n- Type") -- add bullets

	local lines = vim.iter(vim.split(msg, "\n")):fold({}, function(acc, line)
		local isCodeBlock = line:find("^{.+[]}]$") ~= nil
		if isCodeBlock then
			line = "type dummy = " .. line
			local stdout = vim.system(config.formatterArgs, { stdin = line }):wait().stdout
			assert(stdout, config.formatterArgs[1] .. " failed.")
			local formatted = vim.trim(stdout:gsub("^type dummy = ", ""))
			Chainsaw(formatted) -- 🪚
			vim.list_extend(acc, vim.split(formatted, "\n"))
		else
			table.insert(acc, line)
		end
		return acc
	end)

	local _bufnr, winid = vim.lsp.util.open_floating_preview(lines, "markdown", {
		close_events = { "CursorMoved", "BufHidden", "LspDetach" },
	})
	vim.api.nvim_win_set_config(winid, {
		title = (" %s %s "):format(diag.source, diag.code),
		title_pos = "center",
	})
end, { desc = " Pretty ts_ls diagnostic" })

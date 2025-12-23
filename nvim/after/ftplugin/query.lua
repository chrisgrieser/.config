-- query = treesitter query language
--------------------------------------------------------------------------------

---.SCM FILES-------------------------------------------------------------------
if vim.bo.buftype == "" then
	vim.opt_local.tabstop = 2
	vim.opt_local.expandtab = true
	vim.bo.commentstring = "; %s" -- add space
	vim.bo.iskeyword = vim.go.iskeyword -- inherit global one instead of overwriting it
end

---:INSPECTTREE BUFFERS---------------------------------------------------------
if vim.bo.buftype == "nofile" then
	vim.opt_local.listchars:append { lead = "│" }

	vim.keymap.set("n", "?", function()
		local msg = [[- `a` toggle anonymized nodes
- `I` toggle nodes source langs
- `o` query editor
- `<CR>` jump to node
- `q` close]]
		vim.notify(msg, nil, { title = ":InspectTree keymaps", icon = "" })
	end, { buffer = true, desc = "Keymap help" })

	-- FIX missing `nowait` for `q`
	-- PENDING https://github.com/neovim/neovim/pull/36804
	-- 1. needs scheduled due to race with nvim's mapping
	-- 2. needs extra check since commenting with `gc` creates temporary buffer
	-- triggering this as well (sic)
	local bufnr = vim.api.nvim_get_current_buf()
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then return end
		vim.keymap.set("n", "q", vim.cmd.close, { buffer = bufnr, nowait = true })
	end)
end

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

	Bufmap {
		"?",
		function()
			local msg = [[- `a` toggle anonymized nodes
- `I` toggle nodes source langs
- `o` query editor
- `<CR>` jump to node
- `q` close]]
			vim.notify(msg, nil, { title = ":InspectTree keymaps", icon = "" })
		end,
		desc = "Keymap help",
	}
end

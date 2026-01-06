-- DOCS https://oxide.md/index
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	-- leave out `.git` to not attach to non-note repos due to https://github.com/Feel-ix-343/markdown-oxide/issues/323
	root_markers = {},
	workspace_required = true,

	on_attach = function(_client, bufnr)
		-- rename file via `vim.lsp.buf.rename` to also update references
		-- Caveat: breaks URIs in mdlinks https://github.com/Feel-ix-343/markdown-oxide/issues/331
		vim.keymap.set("n", "<leader>fr", function()
			-- PENDING https://github.com/Feel-ix-343/markdown-oxide/issues/288
			local node = vim.treesitter.get_node()
			local parent = node and node:parent()
			if parent and vim.endswith(parent:type(), "heading") then
				vim.notify("On heading, would rename heading, not file.", vim.log.levels.WARN)
				return
			end

			local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0)):gsub("%.md$", "")
			vim.lsp.buf.rename(nil, { name = "markdown_oxide" })

			-- workaround to prefill the current file name
			vim.schedule(function()
				if not package.loaded["snacks.input"] then return end
				vim.api.nvim_set_current_line(filename)
				vim.cmd.startinsert { bang = true }
			end)
		end, { desc = "󰑕 Rename & update refs", buffer = bufnr })
	end,
}

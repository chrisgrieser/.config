-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		-- disable in favor of `lua_ls`, since `emmylua` folds too much for comments
		client.server_capabilities.foldingRangeProvider = false
		client.server_capabilities.documentHighlightProvider = false
	end,
	-- WARN setting any settings makes emmylua break half the time
	-- https://github.com/EmmyLuaLs/emmylua-analyzer-rust/issues/678
	-- settings = {
	-- 	Lua = {
	-- 		diagnostics = {
	-- 			disable = { "unnecessary-if" }, -- buggy rule
	-- 		},
	-- 		completion = {
	-- 			callSnippet = true,
	-- 		},
	-- 		signature = {
	-- 			detailSignatureHelper = true,
	-- 		},
	-- 		strict = {
	-- 			requirePath = true,
	-- 			typeCall = true,
	-- 		},
	-- 	},
	-- },
}

--------------------------------------------------------------------------------
-- reproduction for https://github.com/EmmyLuaLs/emmylua-analyzer-rust/issues/678
-- return {
-- 	cmd = { "emmylua_ls" },
-- 	filetypes = { "lua" },
-- 	root_markers = {
-- 		".luarc.json",
-- 		".emmyrc.json",
-- 		".luacheckrc",
-- 		".git",
-- 	},
-- 	workspace_required = false,
--
-- 	settings = {
-- 		Lua = {
-- 			completion = { postfix = "." },
-- 		},
-- 	},
-- }

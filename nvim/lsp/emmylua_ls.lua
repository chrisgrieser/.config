-- DOCS https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md
--------------------------------------------------------------------------------

return {
	-- on_attach = function(client)
	-- 	-- disable formatting in favor of `stylua`
	-- 	client.server_capabilities.documentFormattingProvider = false
	-- 	client.server_capabilities.documentRangeFormattingProvider = false
	-- end,
	-- WARN setting any settings makes emmylua break half the time
	-- settings = {
	-- https://github.com/EmmyLuaLs/emmylua-analyzer-rust/issues/678
	-- Lua = {
	-- 	hint = {
	-- 		enable = false,
	-- 	},
	-- 	completion = {
	-- 		callSnippet = true,
	-- 		postfix = ".",
	-- 	},
	-- 	signature = {
	-- 		detailSignatureHelper = true,
	-- 	},
	-- 	strict = {
	-- 		requirePath = true,
	-- 		typeCall = true,
	-- 	},
	-- },
}

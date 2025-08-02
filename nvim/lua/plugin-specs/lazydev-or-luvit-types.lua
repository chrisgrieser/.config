-- WHEN USING LUA-LSP
-- return {
-- 	"folke/lazydev.nvim",
-- 	ft = "lua",
-- 	opts = {
-- 		library = {
-- 			-- Load luvit types when the "word" `vim.uv` is found
-- 			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
--
-- 			-- global debugging function `Chainsaw`
-- 			{ path = "nvim-chainsaw/lua/chainsaw/nvim-debug.lua", words = { "Chainsaw" } },
-- 		},
-- 	},
-- }

--------------------------------------------------------------------------------
-- WHEN USING EMMYLUA-LS

return {
	"Bilal2453/luvit-meta",
	lazy = false, -- only need it locally for emmylua to have vim.uv typing
}

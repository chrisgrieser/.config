-- DOCS https://github.com/echasnovski/mini.pairs/blob/main/doc/mini-pairs.txt
--------------------------------------------------------------------------------

-- to disable in a buffer:
-- vim.b.minipairs_disable = true

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"echasnovski/mini.pairs",
	event = { "InsertEnter", "CmdlineEnter" },
	opts = {
		modes = { command = true },
		mappings = {
			["<"] = 
		}
	},
	keys = {
		-- Open new scope (`remap` to trigger auto-pairing)
		{ "<D-o>", "a{<CR>", desc = " Open new scope", remap = true },
		{ "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
	},
}

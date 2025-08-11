-- DOCS https://github.com/echasnovski/mini.pairs/blob/main/doc/mini-pairs.txt
--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"echasnovski/mini.pairs",
	event = { "InsertEnter", "CmdlineEnter" },
	opts = {
		modes = { command = true },
		mappings = {
			-- autopair `<>` in quotes or start of the line, useful for keybindings
			["<"] = {
				action = "open",
				pair = "<>",
				-- SIC `neigh_pattern` must match for pairing to work
				neigh_pattern = "[\r\"'].", -- start of line or after quote
				register = { cr = false },
			},
			[">"] = { action = "close", pair = "<>", register = { cr = false } },
		},
	},
	keys = {
		-- `remap` to trigger auto-pairing of this plugin
		{ "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
	},

	config = function(_, opts)
		local pairs = require("mini.pairs")
		pairs.setup(opts)

		-- INFO to disable in a buffer: vim.b.minipairs_disable = true

		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: mini.pairs for markdown",
			pattern = "markdown",
			callback = function(ctx)
				pairs.map_buf(ctx.buf, "i", "*", { action = "closeopen", pair = "**" })
			end,
		})
	end,
}

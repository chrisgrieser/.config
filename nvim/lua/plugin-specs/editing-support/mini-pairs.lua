-- DOCS https://github.com/echasnovski/mini.pairs/blob/main/doc/mini-pairs.txt
--------------------------------------------------------------------------------

-- INFO to disable in a buffer:
-- vim.b.minipairs_disable = true

--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"echasnovski/mini.pairs",
	event = { "InsertEnter", "CmdlineEnter" },
	opts = {
		modes = { command = true },
	},
	keys = {
		-- `remap` to trigger auto-pairing of this plugin
		{ "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
	},

	config = function(_, opts)
		local pairs = require("mini.pairs")
		pairs.setup(opts)

		pairs.map("i", "<", {
			action = "open",
			pair = "<>",
			neigh_pattern = "[\r].",
			register = { cr = false },
		})
		pairs.map("i", ">", {
			action = "close",
			pair = "<>",
			register = { cr = false },
		})

		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: mini.pairs for markdown",
			pattern = "markdown",
			callback = function(ctx)
				pairs.map_buf(ctx.buf, "i", "*", { action = "closeopen", pair = "**" })
			end,
		})
	end,
}

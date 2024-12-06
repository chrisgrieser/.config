---Set up plugin-specific groups cleanly with the plugin config.
---@param spec wk.Spec
vim.g.whichkeyAddGroup = function(spec)
	spec.mode = { "n", "x" }
	-- Deferred to ensure spec is loaded after whichkey itself
	vim.defer_fn(function() require("which-key").add(spec) end, 1500)
end

--------------------------------------------------------------------------------

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		-- remove these nvim-builtin bindings so they do not clutter which-key
		vim.keymap.del("n", "gcc")
		vim.keymap.del("o", "gc")
	end,
	keys = {
		{
			"<leader>?",
			-- alternative: `:Telescope keymaps` with `only_buf = true`
			function() require("which-key").show { global = false } end,
			desc = "⌨️ Buffer keymaps",
		},
	},
	opts = {
		delay = 666,

		-- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/presets.lua
		preset = "helix",
		win = {
			border = vim.g.borderStyle,
			wo = { winblend = 0 },
			height = { min = 0, max = 0.99 },
		},

		spec = {
			{ -- leader subgroups
				mode = { "n", "x" },
				{ "<leader>", group = "Leader", icon = "󰓎" },
				{ "<leader>c", group = "Code action", icon = "" },
				{ "<leader>e", group = "Execute", icon = "󰓗" },
				{ "<leader>f", group = "Refactor", icon = "󱗘" },
				{ "<leader>g", group = "Git", icon = "󰊢" },
				{ "<leader>i", group = "Inspect", icon = "󱈄" },
				{ "<leader>m", group = "Merge conflicts", icon = "" },
				{ "<leader>o", group = "Option toggle", icon = "󰒓" },
				{ "<leader>p", group = "Packages", icon = "󰏗" },
				{ "<leader>q", group = "Quickfix", icon = "" },
				{ "<leader>u", group = "Undo", icon = "󰕌" },
				{ "<leader>y", group = "Yanking", icon = "󰅍" },
			},
			{ -- not using `text_objects` preset, since it's too crowded
				mode = { "o", "x" },
				{ "r", group = "rest of" },
				{ "i", group = "inner" },
				{ "a", group = "outer" },
				{ "g", group = "misc" },
				{ "ip", desc = "paragraph", icon = "¶" },
				{ "ap", desc = "paragraph", icon = "¶" },
				{ "ib", desc = "bracket", icon = "󰅲" },
				{ "ab", desc = "bracket", icon = "󰅲" },
				{ "it", desc = "tag", icon = "" },
				{ "at", desc = "tag", icon = "" },
				{ "is", desc = "sentence", icon = "󰰢" },
				{ "as", desc = "sentence", icon = "󰰢" },
				{ "iw", desc = "word", icon = "󰬞" },
				{ "aw", desc = "word", icon = "󰬞" },
				{ "gn", desc = "search result", icon = "" },
			},
		},
		plugins = {
			marks = false,
			spelling = false,
			presets = { motions = false, g = false, text_objects = false, z = false },
		},
		filter = function(map) return map.desc and map.desc ~= "" end,
		replace = {
			desc = { -- redundant info for when displayed in which-key
				{ " outer ", " " },
				{ " inner ", " " },
				{ " rest of ", " " },
			},
		},
		icons = {
			group = "", -- different color for groups already distinguishable enough
			separator = "│",
			-- mappings = false, -- disable icons for keymaps
		},
		keys = {
			scroll_down = "<PageDown>",
			scroll_up = "<PageUp>",
		},
		show_help = false,
	},
}

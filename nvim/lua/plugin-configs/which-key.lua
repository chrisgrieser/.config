---Set up plugin-specific groups cleanly with the plugin config.
---@param key string
---@param label string
vim.g.whichkeyAddGroup = function(key, label)
	-- Deferred to ensure whichkey spec is loaded & does not conflict with
	-- whichkey itself being lazy-loading
	vim.defer_fn(function()
		local ok, whichkey = pcall(require, "which-key")
		if not ok then return end
		whichkey.add { { key, group = label, mode = { "n", "x" } } }
	end, 1500)
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
		delay = 400,
		spec = {
			{
				mode = { "n", "x" },
				{ "<leader>", group = "󰓎 Leader" },
				{ "<leader>c", group = " Code action" },
				{ "<leader>e", group = "󰓗 Execute" },
				{ "<leader>g", group = "󰊢 Git" },
				{ "<leader>i", group = "󱈄 Inspect" },
				{ "<leader>o", group = "󰒓 Option toggle" },
				{ "<leader>p", group = "󰏗 Packages" },
				{ "<leader>q", group = " Quickfix" },
				{ "<leader>f", group = "󱗘 Refactor" },
				{ "<leader>u", group = "󰕌 Undo" },
				{ "<leader>y", group = "󰅍 Yanking" },
			},
			{ -- not using `text_objects` preset, since it's too crowded
				mode = { "o", "x" },
				{ "r", group = "rest of" },
				{ "i", group = "inner" },
				{ "a", group = "outer" },
				{ "g", group = "misc" },
				{ "ip", desc = "¶ paragraph" },
				{ "ap", desc = "¶ paragraph" },
				{ "ib", desc = "󰅲 bracket" },
				{ "ab", desc = "󰅲 bracket" },
				{ "it", desc = " tag" },
				{ "at", desc = " tag" },
				{ "is", desc = "󰰢 sentence" },
				{ "as", desc = "󰰢 sentence" },
				{ "iw", desc = "󰬞 word" },
				{ "aw", desc = "󰬞 word" },
			},
		},
		plugins = {
			marks = false,
			spelling = false,
			presets = { motions = false, g = false, text_objects = false, z = false },
		},
		filter = function(map) return map.desc and map.desc ~= "" end,
		replace = {
			-- redundant for hints (frontier-pattern to keep "outer any…" mappings)
			desc = {
				{ " outer %f[^a ]", " " },
				{ " inner %f[^a ]", " " },
				{ " rest of ", " " },
			},
		},
		-- https://github.com/folke/which-key.nvim/blob/main/lua/which-key/presets.lua
		preset = "helix",
		win = {
			border = vim.g.borderStyle,
		},
		keys = { scroll_down = "<PageDown>", scroll_up = "<PageUp>" },
		icons = {
			group = "", -- different color for groups already distinguishable enough
			separator = "│",
			mappings = false, -- disable icons for keymaps
		},
		show_help = false,
	},
}

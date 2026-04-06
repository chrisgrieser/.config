vim.pack.add { "https://github.com/folke/which-key.nvim" }
--------------------------------------------------------------------------------

-- INFO needs to be loaded before other plugins to provider this helper function
---Set up plugin-specific groups with the respective plugin's config
---@param spec { [1]: string, mode?: string[], group: string }
vim.g.whichkeyAddSpec = function(spec) ---@diagnostic disable-line: duplicate-set-field for the empty functions in `lazy.nvim` setup
	if not spec.mode then spec.mode = { "n", "x" } end
	require("which-key").add(spec)
end

--------------------------------------------------------------------------------

require("which-key").setup {
	delay = 400,
	preset = "helix",
	win = {
		border = vim.o.winborder,
		height = { min = 1, max = 0.99 },
	},

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
			{ "<leader>r", group = "󱗘 Refactor" },
			{ "<leader>u", group = "󰕌 Undo" },

			{ "g", group = "Goto" },
			{ "z", group = " Folds & Spelling" },
		},
		{ -- using my list instead of `text_objects` preset to reduce noise
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
			{ "gn", desc = " search result" },
		},
	},
	plugins = {
		marks = false,
		registers = false,
		spelling = { enabled = false },
		-- stylua: ignore
		presets = { g = false, z = false, motions = false, text_objects = false, nav = false, operator = false },
	},
	filter = function(map)
		-- need to remove mappings here, since they are nvim-builtins
		-- that do still show up with disabled whichkey-preset
		-- stylua: ignore
		local nvimBultins = { "<C-W><C-D>", "<C-W>d", "gc", "gcc", "gra", "gri", "grn", "grr", "grt", "g~", "gO" }
		if vim.tbl_contains(nvimBultins, map.lhs) then return false end

		return map.desc ~= nil -- only include mappings that have a description
	end,
	replace = {
		desc = { -- remove redundant info when displayed in which-key
			{ " outer ", " " },
			{ " inner ", " " },
			{ " rest of ", " " },
		},
	},
	icons = {
		group = "", -- different color for groups already distinguishable enough
		separator = "│",
		keys = { PageDown = "󰇚", PageUp = "󰸇" },

		-- NOTE we cannot get icons from the keymap descriptions, so we just
		-- use the icons from there and disable whickey's icon features
		mappings = false, -- disable icons for keymaps
	},
	keys = {
		scroll_down = "<PageDown>",
		scroll_up = "<PageUp>",
	},
	show_help = false,
}

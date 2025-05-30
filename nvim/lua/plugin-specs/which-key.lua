---Set up plugin-specific groups cleanly with the plugin config
---(Accessed via `vim.g`, as this file's exports are used by `lazy.nvim`.)
---@param spec { [1]: string, mode?: string[], group: string }
vim.g.whichkeyAddSpec = function(spec)
	if not spec.mode then spec.mode = { "n", "x" } end
	-- Deferred to ensure spec is loaded after whichkey itself
	vim.defer_fn(function() require("which-key").add(spec) end, 1000)
end

--------------------------------------------------------------------------------

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 400,
		preset = "helix",
		win = {
			border = vim.o.winborder,
			height = { min = 1, max = 0.99 },
		},

		spec = {
			{ -- leader subgroups
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
			},
			{ -- using my list instead of `text_objects` preset, since it's too crowded
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
			{ -- base groups
				mode = { "n", "x" },
				{ "g", group = "Goto" },
				{ "z", group = "Folds & spelling" },
			},
		},
		plugins = {
			marks = false,
			registers = false,
			spelling = { enabled = false },
			presets = {
				motions = false,
				g = false,
				text_objects = false,
				z = false,
				nav = false,
				operator = false,
			},
		},
		filter = function(map)
			-- need to remove comment mapping shere, since they are nvim-builtins
			-- that do still show up with disabled whichkey-preset
			-- stylua: ignore
			local nvimBultins = { "<C-W><C-D>", "<C-W>d", "gc", "gcc", "gra", "gri", "grn", "grr", "g~", "gO" }
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
			mappings = false, -- disable icons for keymaps.
			-- NOTE we cannot get icons from the keymap descriptions, so we just
			-- use the icons from there and disable whickey's icon features
		},
		keys = {
			scroll_down = "<PageDown>",
			scroll_up = "<PageUp>",
		},
		show_help = false,
	},
}

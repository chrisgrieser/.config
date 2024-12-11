return {
	"chrisgrieser/nvim-chainsaw",
	ft = "lua", -- in lua, load directly for `Chainsaw` global
	init = function()
		vim.g.whichkeyAddSpec { "<leader>l", group = "󰐪 Log", mode = { "n", "x" } }
	end,
	opts = {
		preCommitHook = {
			enabled = true,
			dontInstallInDirs = { "**/nvim-chainsaw" }, -- plugin dir has marker
		},
		logStatements = {
			variableLog = {
				nvim_lua = "Chainsaw({{var}}) -- {{marker}}",
				lua = 'print("{{marker}} {{var}}: " .. hs.inspect({{var}}))',
			},

			-- not using any marker
			assertLog = { lua = 'assert({{var}}, "")' },

			-- re-purposing `objectLog` for alternative log statements for these
			objectLog = {
				-- Obsidian Notice
				typescript = "new Notice(`{{marker}} {{var}}: ${{{var}}}`, 0)",
				-- AppleScript notification
				zsh = [[osascript -e "display notification \"{{marker}}} ${{var}}\" with title \"{{var}}\""]],
			},

			-- Hammerspoon
			clearLog = { lua = "hs.console.clearConsole() -- {{marker}}" },
			sound = {
				lua = 'hs.sound.getByName("Sosumi"):play() ---@diagnostic disable-line: undefined-field -- {{marker}}',
			},
		},
	},
	config = function(_, opts)
		require("chainsaw").setup(opts)

		vim.g.lualineAdd("sections", "lualine_x", {
			require("chainsaw.visuals.statusline").countInBuffer,
			color = "lualine_x_diagnostics_info_normal", -- only lualine item has also correct bg-color
			padding = { left = 0, right = 1 },
		})
	end,
	keys = {
		-- stylua: ignore start
		{ "<leader>ll", function() require("chainsaw").variableLog() end, mode = { "n", "x" }, desc = "󰀫 variable" },
		{ "<leader>lo", function() require("chainsaw").objectLog() end, mode = { "n", "x" }, desc = "⬟ object" },
		{ "<leader>la", function() require("chainsaw").assertLog() end, mode = { "n", "x" }, desc = "󱈸 assert" },
		{ "<leader>lt", function() require("chainsaw").typeLog() end, mode = { "n", "x" }, desc = "󰜀 type" },
		{ "<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰍩 message" },
		{ "<leader>le", function() require("chainsaw").emojiLog() end, desc = "󰞅 emoji" },
		{ "<leader>ls", function() require("chainsaw").sound() end, desc = "󰂚 sound" },
		{ "<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
		{ "<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
		{ "<leader>lS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
		{ "<leader>lc", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" },
		{ "<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰅗 remove logs" },
		-- stylua: ignore end
	},
}

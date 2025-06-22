return {
	"chrisgrieser/nvim-chainsaw",
	opts = {
		visuals = { icon = "󰹈" },
		preCommitHook = {
			enabled = true,
			dontInstallInDirs = { "**/nvim-chainsaw" }, -- plugin dir itself, when developing it
		},
		logStatements = {
			variableLog = {
				nvim_lua = "Chainsaw({{var}}) -- {{marker}}", -- nvim lua debug
				lua = 'print("{{marker}} {{var}}: " .. hs.inspect({{var}}))', -- Hammerspoon
				swift = 'fputs("{{marker}} {{var}}: \\({{var}})", stderr)', -- to STDERR, requires `import Foundation`
			},
			assertLog = {
				lua = 'assert({{var}}, "{{insert}}")', -- no marker, since intended to be permanent
			},
			objectLog = { -- re-purposing `objectLog` for alternative log statements for these
				typescript = "new Notice(`{{marker}} {{var}}: ${{{var}}}`, 0)", -- Obsidian Notice
				zsh = 'osascript -e "display notification \\"{{marker}} ${{var}}\\" with title \\"{{var}}\\""',
				nvim_lua = "print({{var}}) -- {{marker}}", -- print statement for snacks scratch buffer
				lua = 'hs.alert.show("{{marker}} {{var}}: " .. hs.inspect({{var}}))', -- Hammerspoon alert
			},
			clearLog = { -- Hammerspoon
				lua = "hs.console.clearConsole() -- {{marker}}",
			},
			sound = { -- Hammerspoon
				lua = 'hs.sound.getByName("Sosumi"):play() ---@diagnostic disable-line: undefined-field -- {{marker}}',
			},
		},
	},
	config = function(_, opts)
		require("chainsaw").setup(opts)

		vim.g.lualineAdd("sections", "lualine_x", {
			require("chainsaw.visuals.statusline").countInBuffer,
			color = "lualine_x_diagnostics_info_normal", -- only lualine hlgroups have correct bg
			padding = { left = 0, right = 1 },
		})
	end,
	init = function(spec)
		-- lazyload `nvim-chainsaw` only when `Chainsaw` function is called
		_G.Chainsaw = function(name) ---@diagnostic disable-line: duplicate-set-field
			require("chainsaw") -- loading nvim-chainsaw will override `_G.Chainsaw`
			Chainsaw(name) -- call original function
		end

		local icon = spec.opts.visuals.icon
		vim.g.whichkeyAddSpec { "<leader>l", group = icon .. " Log" }
	end,
	keys = {
		-- stylua: ignore start
		{ "<leader>lr", function() require("chainsaw").removeLogs() end, mode = {"n","x"}, desc = "󰅗 remove logs" },

		{ "<leader>ll", function() require("chainsaw").variableLog() end, mode = {"n","x"}, desc = "󰀫 variable" },
		{ "<leader>lo", function() require("chainsaw").objectLog() end, mode = {"n","x"}, desc = "⬟ object" },
		{ "<leader>la", function() require("chainsaw").assertLog() end, mode = {"n","x"}, desc = "󱈸 assert" },
		{ "<leader>lt", function() require("chainsaw").typeLog() end, mode = {"n","x"}, desc = "󰜀 type" },
		-- stylua: ignore end
		{ "<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰍩 message" },
		{ "<leader>le", function() require("chainsaw").emojiLog() end, desc = " emoji" },
		{ "<leader>ls", function() require("chainsaw").sound() end, desc = "󱄠 sound" },
		{ "<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
		{ "<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
		{ "<leader>lS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
		{ "<leader>lc", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" },

		{
			"<leader>lg",
			function()
				local marker = require("chainsaw.config.config").config.marker
				require("snacks").picker.grep_word {
					title = marker .. " log statements",
					cmd = "rg",
					args = { "--trim" },
					search = marker,
					regex = false,
					live = false,
					format = function(item, _picker) -- only display the grepped line
						local out = {}
						Snacks.picker.highlight.format(item, item.line, out)
						return out
					end,
				}
			end,
			desc = "󰉹 grep log statements",
		},
	},
}

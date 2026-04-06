vim.pack.add { "https://github.com/chrisgrieser/nvim-chainsaw" }
--------------------------------------------------------------------------------

vim.g.whichkeyAddSpec { "<leader>l", group = "󰹈 Log" }

-- stylua: ignore start
Keymap { "<leader>ll", function() require("chainsaw").variableLog() end, mode = { "n", "x" }, desc = "󰀫 variable" }
Keymap { "<leader>lo", function() require("chainsaw").objectLog() end, mode = { "n", "x" }, desc = "⬟ object" }
Keymap { "<leader>la", function() require("chainsaw").assertLog() end, mode = { "n", "x" }, desc = "󱈸 assert" }
Keymap { "<leader>lt", function() require("chainsaw").typeLog() end, mode = { "n", "x" }, desc = "󰜀 type" }
-- stylua: ignore end
Keymap { "<leader>lm", function() require("chainsaw").messageLog() end, desc = "󰍩 message" }
Keymap { "<leader>le", function() require("chainsaw").emojiLog() end, desc = " emoji" }
Keymap { "<leader>ls", function() require("chainsaw").sound() end, desc = "󱄠 sound" }
Keymap { "<leader>lp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" }
Keymap { "<leader>ld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" }
Keymap { "<leader>lS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" }
Keymap { "<leader>lc", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" }
Keymap { "<leader>lr", function() require("chainsaw").removeLogs() end, desc = "󰅗 remove logs" }
Keymap {
	"<leader>lg",
	function()
		local marker = require("chainsaw.config.config").config.marker
		Snacks.picker.grep_word {
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
}

--------------------------------------------------------------------------------

require("chainsaw").setup {
	visuals = {
		icon = "󰹈",
	},
	preCommitHook = {
		enabled = true,
		dontInstallInDirs = { "**/nvim-chainsaw" }, -- plugin dir itself, when developing it
	},
	logStatements = {
		variableLog = {
			nvim_lua = "Chainsaw({{var}}) -- {{marker}}", -- nvim-lua debug
			lua = 'print("{{marker}} {{var}}: " .. hs.inspect({{var}}))', -- Hammerspoon
			swift = 'fputs("{{marker}} {{var}}: \\({{var}})\\n", stderr)', -- to STDERR, requires `import Foundation`
		},
		emojiLog = {
			swift = 'fputs("{{marker}} {{emoji}}\\n", stderr)',
		},
		assertLog = {
			lua = 'assert({{var}}, "{{insert}}")', -- no marker, since intended to be permanent
		},
		objectLog = { -- re-purposing `objectLog` for alternative log statements for these
			typescript = "new Notice(`{{marker}} {{var}}: ${{var}}`, 0)", -- Obsidian Notice
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
}
--------------------------------------------------------------------------------

-- disable LSP diagnostic for `Chainsaw`
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.root_dir and client.root_dir:find("nvim") then
			local globals = client.config.settings.Lua.diagnostics.globals or {}
			table.insert(globals, "Chainsaw")
		end
	end,
})

-- lualine-counter
vim.g.lualineAdd("sections", "lualine_x", {
	require("chainsaw.visuals.statusline").countInBuffer,
	color = "lualine_x_diagnostics_info_normal", -- only lualine hlgroups have correct bg
	padding = { left = 0, right = 1 },
})

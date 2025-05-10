-- DOCS https://github.com/altermo/ultimate-autopair.nvim/blob/v0.6/doc/ultimate-autopair.txt
--------------------------------------------------------------------------------

return {
	"altermo/ultimate-autopair.nvim",
	branch = "v0.6", -- recommended as each new version will have breaking changes
	event = { "InsertEnter", "CmdlineEnter" },
	keys = {
		-- Open new scope (`remap` to trigger auto-pairing)
		{ "<D-o>", "a{<CR>", desc = " Open new scope", remap = true },
		{ "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
		{
			"<leader>o2",
			function()
				require("ultimate-autopair").toggle()
				local mode = require("ultimate-autopair").isenabled() and "enabled" or "disabled"
				vim.notify(mode, nil, { title = "Auto-pairing", icon = "" })
			end,
			desc = " autopairing",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("RecordingEnter", {
			callback = function() require("ultimate-autopair").disable() end,
		})
		vim.api.nvim_create_autocmd("RecordingLeave", {
			callback = function() require("ultimate-autopair").enable() end,
		})
	end,
	opts = {
		bs = {
			space = "balance",
			cmap = false, -- keep my `<BS>` mapping for the cmdline
		},
		fastwarp = {
			map = "<D-f>",
			rmap = "<D-F>", -- backwards
			hopout = true,
			nocursormove = false,
			multiline = false,
		},
		cr = { autoclose = true },
		tabout = { enable = false, map = "<Nop>" },

		extensions = { -- disable in these filetypes
			filetype = { nft = { "TelescopePrompt", "snacks_picker_input" } },
		},

		config_internal_pairs = {
			{ "'", "'", nft = { "markdown", "gitcommit" } }, -- used as apostrophe
			{ '"', '"', nft = { "vim" } }, -- uses as comments in vimscript

			{ -- disable codeblocks, see https://github.com/Saghen/blink.cmp/issues/1692
				"`",
				"`",
				cond = function(_fn)
					local mdCodeblock = vim.bo.ft == "markdown"
						and vim.api.nvim_get_current_line():find("^[%s`]*$")
					return not mdCodeblock
				end,
			},
			{ "```", "```", nft = { "markdown" } },
		},
		--------------------------------------------------------------------------
		-- INFO custom pairs need to be "appended" to the opts as a list
		{ "**", "**", ft = { "markdown" } }, -- bold
		{ [[\"]], [[\"]], ft = { "zsh", "json", "applescript" } }, -- escaped quote

		{ -- commit scope (= only first word) for commit messages
			"(",
			"): ",
			ft = { "gitcommit" },
			cond = function(_fn) return not vim.api.nvim_get_current_line():find(" ") end,
		},

		-- for keymaps like `<C-a>`
		{ "<", ">", ft = { "vim" } },
		{
			"<",
			">",
			ft = { "lua" },
			cond = function(fn)
				-- FIX https://github.com/altermo/ultimate-autopair.nvim/issues/88
				local inLuaLua = vim.endswith(vim.api.nvim_buf_get_name(0), "/ftplugin/lua.lua")
				return not inLuaLua and fn.in_string()
			end,
		},
	},
}

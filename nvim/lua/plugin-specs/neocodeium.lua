-- DOCS https://github.com/monkoose/neocodeium#️-setup
--------------------------------------------------------------------------------
-- ALTERNATIVES
-- BYOK: https://github.com/milanglacier/minuet-ai.nvim
-- Copilot plugin (subscription): https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
-- Copilot LSP (subscription), requires nvim 0.12 https://github.com/github/copilot-language-server-release
-- Specific key: https://github.com/4tyone/snek-nvim
--------------------------------------------------------------------------------

return {
	"monkoose/neocodeium",
	event = "InsertEnter",
	cmd = "NeoCodeium",
	opts = {
		silent = true,
		show_label = false, -- signcolumn label for number of suggestions
		filetypes = {
			bib = false,
			text = false, -- filetype when editing in `pass` (1. extra safeguard)
		},
		-- `filter` should return `false` to disable AI on buffer
		filter = require("config.utils").allowBuffer,
	},
	config = function(_, opts)
		require("neocodeium").setup(opts)

		vim.g.lualineAdd("sections", "lualine_x", function()
			if vim.fn.reg_recording() ~= "" then return "" end -- not needed since disabled when recording

			-- number meanings: https://github.com/monkoose/neocodeium#-statusline
			local status, server = require("neocodeium").get_status()
			if status == 0 and server == 0 then return "" end -- working correctly = no component
			if server == 1 then return "󱙺 connecting…" end
			if server == 2 then return "󱚟 server" end
			if status == 1 then return "󱚧 global" end
			if status == 2 or status == 3 or status == 4 then return "󱚧 buffer" end
			if status == 6 then return "󱚧 buftype" end
			if status == 5 then return "󱚧 encoding" end
			return "󱚟 Unknown error"
		end, "before")
	end,
	keys = {
		{ "<leader>oa", function() vim.cmd.NeoCodeium("toggle") end, desc = "󰚩 NeoCodeium" },
		-- stylua: ignore start
		{ "<D-s>", function() require("neocodeium").accept() end, mode = "i", desc = "󰚩 Accept full suggestion" },
		{ "<D-S>", function() require("neocodeium").accept_word() end, mode = "i", desc = "󰚩 Accept word" },
		{ "<D-a>", function() require("neocodeium").cycle_or_complete(1) end, mode = "i", desc = "󰚩 Next suggestion" },
		{ "<D-A>", function() require("neocodeium").cycle_or_complete(-1) end, mode = "i", desc = "󰚩 Prev suggestion" },
		-- stylua: ignore end
		{
			"<leader>an",
			function()
				vim.cmd.NeoCodeium("restart")
				vim.notify("Restarting…", nil, { title = "NeoCodeium", icon = "󰚩" })
			end,
			desc = "󰚩 NeoCodeium restart",
		},
	},
}

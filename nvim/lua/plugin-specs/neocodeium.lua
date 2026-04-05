--------------------------------------------------------------------------------
vim.pack.add { "https://github.com/monkoose/neocodeium" }
--------------------------------------------------------------------------------
-- ALTERNATIVES
-- BYOK: https://github.com/milanglacier/minuet-ai.nvim
-- Copilot plugin (subscription): https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
-- Copilot LSP (subscription), requires nvim 0.12 https://github.com/github/copilot-language-server-release
-- Cerebras: https://github.com/4tyone/snek-nvim
-- Cerebras: https://github.com/jim-at-jibba/nvim-stride
--------------------------------------------------------------------------------

require("neocodeium").setup {
	silent = true,
	show_label = false, -- signcolumn label for number of suggestions
	filetypes = {
		bib = false,
		text = false, -- filetype when editing in `pass` (1. extra safeguard)
	},
	filter = function (bufnr)
		-- INFO plugins are disabled when using `pass`, for safety
		-- adding redundant safeguards to disable AI for those buffers nonetheless
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		local ft, filename = vim.bo[bufnr].filetype, vim.fs.basename(filepath)
		if vim.fn.reg_recording() ~= "" then return false end -- disable when recording
		if vim.bo[bufnr].buftype ~= "" then return false end
		if ft == "text" then return false end -- disable, since `txt` used by `pass` and others
		if ft == "bib" then return false end -- too large and not useful
		if ft == "csv" then return false end -- too large / sensitive data
		if filename == "config.local" then return false end -- sensitive data
		if not filename:find("%.") then return false end -- extensionless file

		local pathsToIgnore = {
			"security",
			"leetcode/", -- should do leetcode problems on my own
			"/private/var/", -- path when editing in `pass` (extra safeguard)
			"api-key",
			".env",
			"recovery", -- e.g., password recovery files
		}
		local ignorePath = vim.iter(pathsToIgnore):any(
			function(ignored) return filepath:lower():find(ignored, 1, true) ~= nil end
		)

		if ignorePath then
			vim.notify_once("Disabled AI on this buffer.")
			return false --> return `false` to disable
		else
			return true
		end
	end
}

--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {
	{ "<leader>oa", function() vim.cmd.NeoCodeium("toggle") end, desc = "󰚩 NeoCodeium" },
	-- stylua: ignore start
	{ "<D-s>", function() require("neocodeium").accept() end, mode = "i", desc = "󰚩 Accept full suggestion" },
	{ "<D-S>", function() require("neocodeium").accept_word() end, mode = "i", desc = "󰚩 Accept word" },
	{ "<D-a>", function() require("neocodeium").cycle_or_complete(1) end, mode = "i", desc = "󰚩 Next suggestion" },
	{ "<D-A>", function() require("neocodeium").cycle_or_complete(-1) end, mode = "i", desc = "󰚩 Prev suggestion" },
	-- stylua: ignore end
}

--------------------------------------------------------------------------------
vim.g.lualineAdd("sections", "lualine_x", function()
	-- number meanings: https://github.com/monkoose/neocodeium#-statusline
	local status, server = require("neocodeium").get_status()
	if status == 0 and server == 0 then return "" end -- working correctly = no component
	if server == 1 then return "󱙺 connecting…" end
	if server == 2 then return "󱚟 server" end
	if status == 1 then return "󱚧 global" end
	if status == 2 or status == 3 or status == 4 then return "󱚧 buffer" end
	if status == 5 then return "󱚧 encoding" end
	if status == 6 then return "󱚧 buftype" end
	return "󱚟 Unknown error"
end, "before")

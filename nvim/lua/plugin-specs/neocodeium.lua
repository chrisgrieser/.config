-- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/windsurf.vim
--------------------------------------------------------------------------------

---@module "lazy.core.specs"
---@type LazyPluginSpec
return {
	"monkoose/neocodeium",
	event = "InsertEnter",
	cmd = "NeoCodeium",
	opts = {
		silent = true,
		show_label = false, -- signcolumn label for number of suggestions
		filetypes = {
			bib = false,
			text = false, -- `pass` passwords editing ft (extra safeguard)
		},
		filter = function(bufnr)
			-- not when recording
			if vim.fn.reg_recording() ~= "" then return false end

			local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
			local name = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
			local ignoreBuffer = parent:find("private dotfiles")
				or name:lower():find("recovery")
				or name == ".env"
			return not ignoreBuffer -- `false` -> disable in that buffer
		end,
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
		{
			"<D-s>",
			function() require("neocodeium").accept() end,
			mode = "i",
			desc = "󰚩 Accept full suggestion",
		},
		{
			"<D-d>",
			function() require("neocodeium").cycle_or_complete(1) end,
			mode = "i",
			desc = "󰚩 Show/next suggestion",
		},
		{ "<leader>oa", function() vim.cmd.NeoCodeium("toggle") end, desc = "󰚩 NeoCodeium" },
		{ "<leader>aw", function() vim.cmd.NeoCodeium("chat") end, desc = "󰚩 Windsurf chat" },
	},
}

-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

-- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/codeium.vim
return {
	"monkoose/neocodeium",
	event = "InsertEnter",
	cmd = "NeoCodeium",
	opts = {
		silent = true,
		show_label = true, -- signcolumn label for number of suggestions

		filetypes = {
			bib = false,
			text = false, -- `pass` passwords editing ft (extra safeguard)
		},
		filter = function(bufnr)
			local specialBuf = vim.bo[bufnr].buftype ~= ""
			local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
			local name = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
			local ignoreBuffer = parent:find("private dotfiles")
				or name:lower():find("recovery")
				or name == ".env"
			return not specialBuf and not ignoreBuffer -- `false` -> disable in that buffer
		end,
	},
	config = function(_, opts)
		require("neocodeium").setup(opts)

		-- disable while recording
		vim.api.nvim_create_autocmd("RecordingEnter", { command = "NeoCodeium disable" })
		vim.api.nvim_create_autocmd("RecordingLeave", { command = "NeoCodeium enable" })

		-- lualine indicator
		vim.g.lualineAdd("sections", "lualine_x", function()
			-- don't need info that it's disabled during a recording
			if vim.fn.reg_recording() ~= "" then return "" end

			-- number meanings: https://github.com/monkoose/neocodeium?tab=readme-ov-file#-statusline
			local status, server = require("neocodeium").get_status()
			if status == 0 and server == 0 then return "" end -- working correctly = no component
			if server == 1 then return "󱙺 connecting…" end
			if status == 1 then return "󱚧 global" end
			if server == 2 then return "󱚧 server" end
			if status < 5 then return "󱚧 buffer" end
			return "󱚟 Error"
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
			"<D-S>", -- since accepting autocomplete in Obsidian is done via cmd-shift-s
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
		{
			"<leader>oa",
			function() vim.cmd.NeoCodeium("toggle") end,
			desc = "󰚩 NeoCodeium",
		},
	},
}

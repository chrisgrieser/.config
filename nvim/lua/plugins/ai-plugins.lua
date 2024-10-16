-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/SilasMarvin/lsp-ai
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

return {
	{ -- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/codeium.vim
		"monkoose/neocodeium",
		event = "InsertEnter",
		cmd = "NeoCodeium",
		opts = {
			silent = true,
			show_label = false, -- signcolumn label for number of suggestions

			filetypes = {
				DressingInput = false,
				TelescopePrompt = false,
				noice = false, -- sometimes triggered in error-buffers

				-- extra safeguard: `pass` passwords editing filetype is plaintext,
				-- also this is the filetype of critical files
				text = false,
			},
			filter = function(bufnr)
				local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
				local name = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
				local ignoreBuffer = parent:find("private dotfiles") or name:lower():find("recovery")
				return not ignoreBuffer -- `false` -> disable in that buffer
			end,
		},
		config = function(_, opts)
			require("neocodeium").setup(opts)

			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "NeoCodeium disable" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "NeoCodeium enable" })

			-- lualine indicator
			vim.g.lualine_add("sections", "lualine_x", function()
				-- number meanings: https://github.com/monkoose/neocodeium?tab=readme-ov-file#-statusline
				if vim.bo.buftype ~= "" then return "" end
				local status, server = require("neocodeium").get_status()
				if status == 0 and server == 0 then return "" end -- working correctly = no component
				if server == 1 then return "󱙺 connecting…" end
				if status == 1 then return "󱚧 global" end
				if server == 2 then return "󱚧 server" end
				if status < 5 then return "󱚧 buffer" end
				return "󱚟 Error"
			end)
		end,
		keys = {
			{
				"<D-s>",
				function() require("neocodeium").accept() end,
				mode = "i",
				desc = "󰚩 Accept full suggestion",
			},
			{
				"<D-S>",
				function() require("neocodeium").accept_line() end,
				mode = "i",
				desc = "󰚩 Accept line",
			},
			{
				"<D-d>",
				function() require("neocodeium").cycle(1) end,
				mode = "i",
				desc = "󰚩 Next suggestion",
			},
			{
				"<D-D>",
				function() require("neocodeium").cycle(-1) end,
				mode = "i",
				desc = "󰚩 Previous suggestion",
			},
			{
				"<leader>oa",
				function() vim.cmd.NeoCodeium("toggle") end,
				desc = "󰚩 NeoCodeium Suggestions",
			},
		},
	},
}

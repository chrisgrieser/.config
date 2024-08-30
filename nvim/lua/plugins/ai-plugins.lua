-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/SilasMarvin/lsp-ai
-- https://github.com/sourcegraph/sg.nvim
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
			filetypes = {
				DressingInput = false,
				TelescopePrompt = false,
				noice = false, -- sometimes triggered in error-buffers
				["rip-substitute"] = false,

				-- extra safeguard: `pass` passwords editing filetype is plaintext,
				-- also this is the filetype of critical files
				text = false,
			},
			silent = true,
			show_label = true, -- signcolumn label for number of suggestions
		},
		config = function(_, opts)
			require("neocodeium").setup(opts)

			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "NeoCodeium disable" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "NeoCodeium enable" })

			-- extra safeguard: disable in various private folder
			local function disableInPrivatBuffer(ctx)
				local parent = vim.fs.dirname(ctx.file)
				local name = vim.fs.basename(ctx.file)
				if parent:find("private dotfiles") or name:lower():find("recovery") then
					require("config.utils").notify("NeoCodeium", "Disabled for this buffer.")
					vim.cmd.NeoCodeium("disable_buffer")
				end
			end
			disableInPrivatBuffer()
			vim.api.nvim_create_autocmd({ "BufEnter" }, { callback = disableInPrivatBuffer })
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
				function()
					vim.cmd.NeoCodeium("toggle")
					local on = require("neocodeium.options").options.enabled
					require("config.utils").notify("NeoCodeium", on and "enabled" or "disabled", "info")
				end,
				desc = "󰚩 NeoCodeium Suggestions",
			},
		},
	},
}

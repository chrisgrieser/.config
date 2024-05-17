-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/sourcegraph/sg.nvim
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
--------------------------------------------------------------------------------

return {
	{ -- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/codeium.vim
		"monkoose/neocodeium",
		event = "InsertEnter",
		cmd = "NeoCodeium",
		opts = {
			filetypes = {
				DressingInput = false,
				["grug-far"] = false,
				text = false, -- `pass` passwords are plaintext
			},
			silent = true,
		},
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
			{ "<leader>oa", "<cmd>NeoCodeium toggle<CR>", desc = "󰚩 Codium Suggestions" },
		},
		-- symlink the codium config to enable syncing of API key
		build = function()
			local symLinkFrom = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json"
			local symLinkTo = os.getenv("HOME") .. "/.codeium/config.json"
			local fileExists = vim.uv.fs_stat(symLinkTo) ~= nil
			if not fileExists then
				pcall(vim.fn.mkdir, vim.fs.dirname(symLinkTo))
				vim.uv.fs_symlink(symLinkFrom, symLinkTo)
			end
		end,
	},
}

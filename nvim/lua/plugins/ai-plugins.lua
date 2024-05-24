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
				noice = false, -- sometimes triggered in error-buffers
				text = false, -- `pass` passwords are plaintext
			},
			silent = true,
		},
		keys = {
			-- stylua: ignore start
			{ "<D-s>", function() require("neocodeium").accept() end, mode = "i", desc = "󰚩 Accept full suggestion" },
			{ "<D-d>", function() require("neocodeium").cycle(1) end, mode = "i", desc = "󰚩 Next suggestion" },
			{ "<D-D>", function() require("neocodeium").cycle(-1) end, mode = "i", desc = "󰚩 Prev suggestion" },
			-- stylua: ignore end
			{ "<leader>oa", "<cmd>NeoCodeium toggle<CR>", desc = "󰚩 Codium Suggestions" },
		},
		-- symlink the codium config to enable syncing of API key
		build = function()
			local u = require("config.utils")
			local symLinkFrom = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json"
			local symLinkTo = os.getenv("HOME") .. "/.codeium/config.json"
			if not u.fileExists(symLinkFrom) then
				pcall(vim.fn.mkdir, vim.fs.dirname(symLinkTo))
				vim.uv.fs_symlink(symLinkFrom, symLinkTo)
			end
		end,
	},
}

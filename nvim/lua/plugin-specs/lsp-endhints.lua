vim.pack.add { "https://github.com/chrisgrieser/nvim-lsp-endhints" }
--------------------------------------------------------------------------------

Keymap { "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" }

require("lsp-endhints").setup { -- `setup` required
	codeLens = {
		enabled = true,
	},
}

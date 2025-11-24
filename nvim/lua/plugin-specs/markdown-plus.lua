return {
	"yousefhadder/markdown-plus.nvim",
	keys = {
		-- stylua: ignore start
		{ "<D-b>", "<Plug>(MarkdownPlusBold)", ft = "markdown", mode = { "n", "x" }, desc = " Bold" },
		{ "<D-i>", "<Plug>(MarkdownPlusItalic)", ft = "markdown", mode = { "n", "x" }, desc = " Italic" },
		{ "<D-e>", "<Plug>(MarkdownPlusCode)", ft = "markdown", mode = { "n", "x" }, desc = " Inline Code" },
		{ "<C-j>", "<Plug>(MarkdownPlusNextHeader)", ft = "markdown", desc = " Next Header" },
		{ "<C-k>", "<Plug>(MarkdownPlusPrevHeader)", ft = "markdown", desc = " Prev Header" },
		{ "<D-h>", "<Plug>(MarkdownPlusPromoteHeader)", ft = "markdown", desc = " Increase Header" },
		-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
		{ "<D-5>", "<Plug>(MarkdownPlusDemoteHeader)", ft = "markdown", desc = " Decrease Header" },

		{ "o", "<Plug>(MarkdownPlusNewListItemBelow)", ft = "markdown", desc = " o" },
		{ "O", "<Plug>(MarkdownPlusNewListItemAbove)", ft = "markdown", desc = " O" },
		{ "<CR>", "<Plug>(MarkdownPlusListEnter)", ft = "markdown", mode = "i", desc = " <CR>" },
		{ "<Tab>", "<Plug>(MarkdownPlusListIndent)", ft = "markdown", mode = "i", desc = " <Tab>" },
		{ "<S-Tab>", "<Plug>(MarkdownPlusListOutdent)", ft = "markdown", mode = "i", desc = " <Tab>" },
		-- stylua: ignore end
	},
	opts = {
		keymaps = { enabled = false },
	},
}

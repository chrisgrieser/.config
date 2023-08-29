return {
	{
		"piersolenski/wtf.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		opts = {
			popup_type = "popup", -- | "horizontal" | "vertical",
			openai_model_id = "gpt-3.5-turbo",
			search_engine = "google", -- | "duck_duck_go" | "stack_overflow" | "github",
			-- additional_instructions = "Start the reply with 'OH HAI THERE'",
		},
		keys = {
			-- stylua: ignore
			{ "<leader>d", function() require("wtf").search() end, desc = " Search diagnostic with Google" },
			-- stylua: ignore
			{ "<leader>D", function() require("wtf").ai() end, desc = " Debug diagnostic with AI" },
		},
	},
	{ -- code search
		-- requires access tokens: https://github.com/sourcegraph/sg.nvim#setup
		-- which in my case are set in .zshenv (private dotfiles)
		"sourcegraph/sg.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"<leader>qq",
				function() require("sg.extensions.telescope").fuzzy_search_results() end,
				desc = "󰓁 SourceGraph Search",
			},
			{ "<leader>qu", "<cmd>SourcegraphLink<CR>", desc = "󰓁 Copy SourceGraph URL" },
			{ "<leader>qa", "<cmd>CodyAsk<CR>", desc = "󰓁 CodyAsk" },
			{ "<leader>qd", "<cmd>CodyDo<CR>", desc = "󰓁 CodyDo" },
		},
		opts = {
			on_attach = function()
				-- stylua: ignore
				vim.keymap.set("n", "gd", function() vim.cmd.Telescope("lsp_definitions") end, { desc = "󰒕 Definitions" })
				-- stylua: ignore
				vim.keymap.set("n", "gf", function() vim.cmd.Telescope("lsp_references") end, { desc = "󰒕 References" })
			end,
		},
		init = function()
			local ok, whichKey = pcall(require, "which-key")
			if ok then whichKey.register { ["<leader>q"] = { name = " 󰓁 SourceGraph" } } end
		end,
	},
	{ -- AI Ghost Text Suggestions
		"Exafunction/codeium.vim",
		event = "InsertEnter",
		build = function()
			-- symlink to enable syncing of API key
			local symLinkFrom = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json"
			local symLinkTo = os.getenv("HOME") .. "/.codeium/config.json"
			local fileExists = vim.loop.fs_stat(symLinkTo) ~= nil
			if not fileExists then
				pcall(vim.fn.mkdir, vim.fs.dirname(symLinkTo))
				vim.loop.fs_symlink(symLinkFrom, symLinkTo)
			end
		end,
		config = function()
			vim.g.codeium_filetypes = { TelescopePrompt = false }

			-- INFO if cmp visible, will use cmp selection instead.
			vim.g.codeium_disable_bindings = 1
			-- stylua: ignore start
			vim.keymap.set("i", "<Tab>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "󰚩 Accept Suggestion", silent = true })
			vim.keymap.set("i", "<D-s>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "󰚩 Accept Suggestion", silent = true })
			vim.keymap.set("i", "<D-g>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, desc = "󰚩 Accept Suggestion", silent = true })
			-- stylua: ignore end
		end,
	},
}

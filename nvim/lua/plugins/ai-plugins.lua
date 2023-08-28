return {
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
			on_attach = function ()
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
			vim.g.codeium_idle_delay = 75 -- minimum 75
			vim.g.codeium_filetypes = { TelescopePrompt = false, DressingInput = false }

			-- INFO if cmp visible, will use cmp selection instead.
			vim.g.codeium_disable_bindings = 1
			-- stylua: ignore start
			vim.keymap.set("i", "<Tab>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "󰚩 Accept Suggestion", silent = true })
			vim.keymap.set("i", "<D-s>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "󰚩 Accept Suggestion", silent = true })
			-- stylua: ignore end
		end,
	},
	{ -- AI completions via cmp
		"jcdickinson/codeium.nvim",
		commit = "3368831",
		appply,
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		opts = {
			config_path = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json",
			bin_path = vim.fn.stdpath("data") .. "/codeium",
		},
		-- FIX https://github.com/jcdickinson/codeium.nvim/issues/58
		-- build = function()
		-- 	local bin_path = vim.fn.stdpath("data") .. "/codeium"
		-- 	local oldBinaries = vim.fs.find(
		-- 		function() return true end,
		-- 		{ type = "file", limit = math.huge, path = bin_path }
		-- 	)
		-- 	table.remove(oldBinaries) -- remove last item (= most up to date binary) from list
		-- 	for _, binaryPath in pairs(oldBinaries) do
		-- 		os.remove(binaryPath)
		-- 		os.remove(vim.fs.dirname(binaryPath))
		-- 	end
		-- end,
	},
}

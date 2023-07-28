return {
	{ -- AI Ghost Text Suggestions
		"Exafunction/codeium.vim",
		event = "InsertEnter",
		build = function()
			-- HACK enable	syncing of API key
			local symLinkFrom = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json"
			local symLinkTo = vim.env.HOME .. "/.codeium/config.json"
			pcall(vim.fn.mkdir, vim.fs.dirname(symLinkTo))
			os.remove(symLinkTo)
			vim.loop.fs_symlink(symLinkFrom, symLinkTo)
		end,
		config = function()
			-- when cmp completion is loaded, clear the virtual text from codium
			require("cmp").event:on("menu_opened", function() vim.fn["codeium#Clear"]() end)

			-- ignore filetypes
			vim.g.codeium_filetypes = {
				TelescopePrompt = false,
				DressingInput = false,
				DressingSelect = false,
				Mason = false,
				["ccc-ui"] = false,
			}
			vim.g.codeium_disable_bindings = 1
			vim.keymap.set(
				"i",
				"<D-s>",
				function() return vim.fn["codeium#Accept"]() end,
				{ expr = true, desc = "󰚩 Accept Suggestion", silent = true }
			)
		end,
	},
	{ -- AI completions via cmp
		"jcdickinson/codeium.nvim",
		lazy = true, -- loaded by cmp
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		opts = {
			config_path = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json",
			bin_path = vim.fn.stdpath("data") .. "/codeium",
		},
		-- FIX https://github.com/jcdickinson/codeium.nvim/issues/58
		build = function()
			local bin_path = vim.fn.stdpath("data") .. "/codeium"
			local oldBinaries = vim.fs.find(
				function() return true end,
				{ type = "file", limit = math.huge, path = bin_path }
			)
			table.remove(oldBinaries) -- remove last item (= most up to date binary) from list
			for _, binaryPath in pairs(oldBinaries) do
				os.remove(binaryPath)
				os.remove(vim.fs.dirname(binaryPath))
			end
		end,
	},
}

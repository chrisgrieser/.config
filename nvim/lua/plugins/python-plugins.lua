local function venvLualine()
	local topSeparators = { left = "", right = "" }

	-- INFO inserting to not override the existing lualine segments
	local section = require("lualine").get_config().tabline.lualine_a or {}
	table.insert(section, {
		function()
			if vim.bo.ft ~= "python" then return "" end
			local venv = require("venv-selector").get_active_venv()
			if venv == "" then return "" end
			venv = vim.fs.basename(venv)
			-- only add venv name, if non-default
			venv = venv:find("^%.?venv$") and "" or " " .. venv
			return "󱥒" .. venv
		end,
		section_separators = topSeparators,
	})

	require("lualine").setup { tabline = { lualine_a = section } }
end

--------------------------------------------------------------------------------

return {
	{
		"linux-cultist/venv-selector.nvim",
		enabled = true,
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		cmd = { "VenvSelect", "VenvSelectCached" },
		config = function()
			require("venv-selector").setup {
				name = { ".venv" },
				auto_refresh = true,
				notify_user_on_activate = true,
			}
			venvLualine()
		end,
		-- auto-select venv on entering python buffer -- https://github.com/linux-cultist/venv-selector.nvim#-automate
		-- init = function()
		-- 	vim.api.nvim_create_autocmd("BufReadPost", {
		-- 		callback = function()
		-- 			if vim.bo.ft ~= "python" then return end
		-- 			vim.defer_fn(function()
		-- 				local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
		-- 				if venv ~= "" then require("venv-selector").retrieve_from_cache() end
		-- 			end, 200)
		-- 		end,
		-- 	})
		-- end,
	},
	{ -- fix indentation issues in python https://www.reddit.com/r/neovim/comments/wyx4e4/q_auto_indentation_for_python_files/
		"Vimjas/vim-python-pep8-indent",
		ft = "python",
	},
}

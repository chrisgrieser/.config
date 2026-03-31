vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add { "https://github.com/nvim-treesitter/nvim-treesitter" }
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {}

--------------------------------------------------------------------------------

require("nvim-treesitter").setup {}

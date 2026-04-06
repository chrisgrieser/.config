-- DOCS https://github.com/altermo/ultimate-autopair.nvim/blob/v0.6/doc/ultimate-autopair.txt
-- Compared to other autopair plugins, has nicer behavior of adjusting spacing
-- when typing space after a bracket.
--------------------------------------------------------------------------------
vim.pack.add({
	{
		src = "https://github.com/altermo/ultimate-autopair.nvim",
		version = "v0.6",
	},
}, { load = function() end }) -- lazy-loading via `:packadd` later
--------------------------------------------------------------------------------

Keymap { "<D-o>", "{<CR>", mode = "i", desc = " Open new scope", remap = true }

--------------------------------------------------------------------------------

local opts = {
	bs = {
		space = "balance",
		cmap = false, -- keep my `<BS>` mapping for the cmdline
	},
	cr = { autoclose = true },
	tabout = { enable = false, map = "<Nop>" },
	fastwarp = {
		map = "<D-f>",
		rmap = "<D-F>", -- backwards
		hopout = true,
		nocursormove = false,
		multiline = false,
	},

	extensions = { -- disable in these filetypes
		filetype = { nft = { "TelescopePrompt", "snacks_picker_input", "rip-substitute" } },
	},

	config_internal_pairs = {
		{ "'", "'", nft = { "markdown", "gitcommit" } }, -- used as apostrophe
		{ '"', '"', nft = { "vim" } }, -- uses as comments in vimscript

		{ -- disable codeblocks, see https://github.com/Saghen/blink.cmp/issues/1692
			"`",
			"`",
			cond = function(_fn)
				local mdCodeblock = vim.bo.ft == "markdown"
					and vim.api.nvim_get_current_line():find("^[%s`]*$")
				return not mdCodeblock
			end,
		},
		{ "```", "```", nft = { "markdown" } },
	},
	--------------------------------------------------------------------------
	-- INFO custom pairs need to be "appended" to the opts as a list
	{ "**", "**", ft = { "markdown" } }, -- bold
	{ [[\"]], [[\"]], ft = { "zsh", "json", "applescript", "swift" } }, -- escaped quote

	-- for keymaps like `<C-a>`
	{ "<", ">", ft = { "vim" } },
	{
		"<",
		">",
		ft = { "lua" },
		cond = function(fn)
			-- PENDING https://github.com/altermo/ultimate-autopair.nvim/issues/88
			local inLuaLua = vim.endswith(vim.api.nvim_buf_get_name(0), "/ftplugin/lua.lua")
			return not inLuaLua and fn.in_string()
		end,
	},
}
--------------------------------------------------------------------------------

-- lazy-load, since it eagerly loads all modules
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
	desc = "User: lazy-load ultimate-autopair",
	once = true,
	callback = function()
		vim.cmd.packadd("ultimate-autopair.nvim")
		require("ultimate-autopair").setup(opts)
	end,
})

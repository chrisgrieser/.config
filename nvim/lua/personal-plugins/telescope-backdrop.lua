-- PENDING https://github.com/nvim-telescope/telescope.nvim/issues/3020

-- CONFIG
local blend = 40
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Add backdrop to Telescope",
	pattern = "TelescopePrompt",
	callback = function(ctx)
		local backdropName = "TelescopeBackdrop"
		local telescopeBufnr = ctx.buf

		-- `Telescope` does not set a zindex, so it uses the default value
		-- of `nvim_open_win`, which is 50: https://neovim.io/doc/user/api.html#nvim_open_win()
		local telescopeZindex = 50

		local backdropBufnr = vim.api.nvim_create_buf(false, true)
		local winnr = vim.api.nvim_open_win(backdropBufnr, false, {
			relative = "editor",
			row = 0,
			col = 0,
			width = vim.o.columns,
			height = vim.o.lines,
			focusable = false,
			style = "minimal",
			border = "none", -- needs to be explicitly set due to `vim.o.winborder`
			zindex = telescopeZindex - 1, -- ensure it's below the reference window
		})

		vim.api.nvim_set_hl(0, backdropName, { bg = "#000000", default = true })
		vim.wo[winnr].winhighlight = "Normal:" .. backdropName
		vim.wo[winnr].winblend = blend
		vim.bo[backdropBufnr].buftype = "nofile"

		-- close backdrop when the reference buffer is closed
		vim.api.nvim_create_autocmd({ "WinClosed", "BufLeave" }, {
			desc = "User(once): Close backdrop when reference buffer is closed",
			once = true,
			buffer = telescopeBufnr,
			callback = function()
				if vim.api.nvim_win_is_valid(winnr) then vim.api.nvim_win_close(winnr, true) end
				if vim.api.nvim_buf_is_valid(backdropBufnr) then
					vim.api.nvim_buf_delete(backdropBufnr, { force = true })
				end
			end,
		})
	end,
})

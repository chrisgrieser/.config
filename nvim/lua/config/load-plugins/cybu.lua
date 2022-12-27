return {
	{
		"ghillb/cybu.nvim", -- Cycle Buffers
		keys = "<BS>",
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		config = function()
			require("cybu").setup {
				display_time = 1000,
				position = {
					anchor = "bottomcenter",
					max_win_height = 12,
					vertical_offset = 3,
				},
				style = {
					border = borderStyle,
					padding = 7,
					path = "tail",
					hide_buffer_id = true,
					highlights = {
						current_buffer = "CursorLine",
						adjacent_buffers = "Normal",
					},
				},
				behavior = {
					mode = {
						default = {
							switch = "immediate",
							view = "paging",
						},
					},
				},
			}
		end,
	},
}

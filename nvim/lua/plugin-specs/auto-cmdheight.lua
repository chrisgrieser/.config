return {
	"jake-stewart/auto-cmdheight.nvim",
	lazy = false,
	-- enabled = false,
	opts = {
		max_lines = 5, -- max cmdheight before displaying hit enter prompt.
		duration = 2, -- number of seconds until the cmdheight can restore.
		remove_on_key = true, -- whether key press is required to restore cmdheight.

		-- always clear the cmdline after duration and key press.
		-- by default it will only happen when cmdheight changed.
		clear_always = false,
	},
}

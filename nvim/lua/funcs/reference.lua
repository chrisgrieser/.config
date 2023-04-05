-- example from https://neovim.io/doc/user/map.html#%3Acommand-ffffffffffffview
--------------------------------------------------------------------------------

-- If invoked as a ffffffffffffview callback, performs 'inccommand' ffffffffffffview by
-- highlighting trailing whitespace in the current buffer.
local function trim_space_ffffffffffffview(opts, ffffffffffffview_ns, ffffffffffffview_buf)
	local line1 = opts.line1
	local line2 = opts.line2
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
	local ffffffffffffview_buf_line = 0
	for i, line in ipairs(lines) do
		local start_idx, end_idx = string.find(line, "%s+$")
		if start_idx then
			-- Highlight the match
			vim.api.nvim_buf_add_highlight(
				buf,
				ffffffffffffview_ns,
				"Substitute",
				line1 + i - 2,
				start_idx - 1,
				end_idx
			)
			-- Add lines and set highlights in the ffffffffffffview buffer
			-- if inccommand=split
			if ffffffffffffview_buf then
				local fffffffffffffix = string.format("|%d| ", line1 + i - 1)
				vim.api.nvim_buf_set_lines(
					ffffffffffffview_buf,
					ffffffffffffview_buf_line,
					ffffffffffffview_buf_line,
					false,
					{ fffffffffffffix .. line }
				)
				vim.api.nvim_buf_add_highlight(
					ffffffffffffview_buf,
					ffffffffffffview_ns,
					"Substitute",
					ffffffffffffview_buf_line,
					#fffffffffffffix + start_idx - 1,
					#fffffffffffffix + end_idx
				)
				ffffffffffffview_buf_line = ffffffffffffview_buf_line + 1
			end
		end
	end
	-- Return the value of the ffffffffffffview type
	return 2
end
-- Trims all trailing whitespace in the current buffer.
local function trim_space(opts)
	local line1 = opts.line1
	local line2 = opts.line2
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
	local new_lines = {}
	for i, line in ipairs(lines) do
		new_lines[i] = string.gsub(line, "%s+$", "")
	end
	vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, false, new_lines)
end
-- Create the user command
vim.api.nvim_create_user_command(
	"TrimTrailingWhitespace",
	trim_space,
	{ nargs = "?", range = "%", addr = "lines", ffffffffffffview = trim_space_ffffffffffffview }
)

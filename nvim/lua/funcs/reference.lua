-- example from https://neovim.io/doc/user/map.html#%3Acommand-preview
--------------------------------------------------------------------------------

-- If invoked as a preview callback, performs 'inccommand' preview by
-- highlighting trailing whitespace in the current buffer.
local function trim_space_preview(opts, preview_ns, preview_buf)
	local line1 = opts.line1
	local line2 = opts.line2
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
	local preview_buf_line = 0
	for i, line in ipairs(lines) do
		local start_idx, end_idx = string.find(line, "%s+$")
		if start_idx then
			-- Highlight the match
			vim.api.nvim_buf_add_highlight(
				buf,
				preview_ns,
				"Substitute",
				line1 + i - 2,
				start_idx - 1,
				end_idx
			)
			-- Add lines and set highlights in the preview buffer
			-- if inccommand=split
			if preview_buf then
				local prefix = string.format("|%d| ", line1 + i - 1)
				vim.api.nvim_buf_set_lines(
					preview_buf,
					preview_buf_line,
					preview_buf_line,
					false,
					{ prefix .. line }
				)
				vim.api.nvim_buf_add_highlight(
					preview_buf,
					preview_ns,
					"Substitute",
					preview_buf_line,
					#prefix + start_idx - 1,
					#prefix + end_idx
				)
				preview_buf_line = preview_buf_line + 1
			end
		end
	end
	-- Return the value of the preview type
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
	{ nargs = "?", range = "%", addr = "lines", preview = trim_space_preview }
)

local M = {}
--------------------------------------------------------------------------------

---Sets the global BorderStyle variable and the matching BorderChars Variable.
---See also https://neovim.io/doc/user/api.html#nvim_open_win()
---(BorderChars is needed for Harpoon and Telescope, both of which do not accept
---a Borderstyle string.)
---@param str string none|single|double|rounded|shadow|solid
function M.set(str)
	BorderStyle = str

	if str == "single" then
		BorderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
	elseif str == "double" then
		BorderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
	elseif str == "rounded" then
		BorderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	elseif str == "none" then
		BorderChars = { "", "", "", "", "", "", "", "" }
	end
	-- default: rounded
	if not BorderChars then BorderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" } end
end

--------------------------------------------------------------------------------
return M

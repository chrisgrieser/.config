local u = require("config.utils")
local fn = vim.fn
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")

--------------------------------------------------------------------------------

-- DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
local function sendToWezTerm()
	fn.system([[
		open -a 'WezTerm' 
		i=0
		while ! pgrep -xq wezterm-gui; do 
			sleep 0.1
			i=$((i+1))
			test $i -gt 30 && return
		done
		sleep 0.2
	]])

	local text
	if fn.mode() == "n" then
		text = vim.api.nvim_get_current_line() .. "\n"
		fn.system { "wezterm", "cli", "send-text", "--no-paste", text }
	elseif fn.mode():find("[Vv]") then
		u.normal('"zy')
		text = fn.getreg("z"):gsub("\n$", "")
		fn.system { "wezterm", "cli", "send-text", text }
	end
end

vim.keymap.set(
	{ "n", "x" },
	"<localleader><localleader>",
	sendToWezTerm,
	{ desc = " Send to WezTerm", buffer = true }
)

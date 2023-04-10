local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
--------------------------------------------------------------------------------

-- hover -> man page
keymap(
	"n",
	"<leader>h",
	function() return "<cmd>tab Man " .. expand("<cword>") .. "<CR>" end,
	{ desc = "Man page in new tab", buffer = true, expr = true }
)

--------------------------------------------------------------------------------

-- pipe textobj

--stylua: ignore
keymap({ "o", "x" }, "iP", function() require("various-textobjs").shellPipe(true) end, { desc = "inner shellPipe textobj", buffer = true })
--stylua: ignore
keymap({ "o", "x" }, "aP", function() require("various-textobjs").shellPipe(false) end, { desc = "outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------
-- Reload Sketchybar
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")

	if parentFolder:find("sketchybar") then
		fn.system([[brew services restart sketchybar]])

		-- dismiss notification, HACK for https://github.com/FelixKratz/SketchyBar/issues/322
		--stylua: ignore
		---@diagnostic disable: param-type-mismatch
		vim.defer_fn(function() fn.system([[osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"]]) end, 3000)
	else
		local output = fn.system(('zsh "%s"'):format(expand("%:p")))
		local logLevel = vim.v.shell_error > 0 and u.logError or u.logTrance
		vim.notify(output, logLevel)
	end
end, { buffer = true, desc = " Run Shell Script" })

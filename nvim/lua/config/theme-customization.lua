local M = {}
--------------------------------------------------------------------------------

local lightTheme = require("plugin-configs.themes")[1].colorscheme
local darkTheme = require("plugin-configs.themes")[2].colorscheme
local lightOpacity = require("plugin-configs.themes")[1].opacity
local darkOpacity = require("plugin-configs.themes")[2].opacity
--------------------------------------------------------------------------------

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHl(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
---@param changes vim.api.keyset.highlight
local function setHl(hlgroup, changes) vim.api.nvim_set_hl(0, hlgroup, changes) end

-- FIX For plugins using backdrop-like effects, there is some winblend bug,
-- which causes the underlines to be displayed in ugly red. We fix this by
-- temporarily disabling the underline effects set.
local function toggleUnderlines()
	local change = vim.bo.buftype == "" and "underline" or "none"
	updateHl("@markup.link.url", "gui=" .. change)
	updateHl("@markup.link.url.markdown_inline", "gui=" .. change)
	updateHl("@string.special.url.comment", "gui=" .. change)
	updateHl("@string.special.url.html", "gui=" .. change)
	updateHl("Underlined", "gui=" .. change)
	-- setHl("LspReferenceWrite", { underdashed = vim.bo.buftype == "" })
	-- setHl("LspReferenceRead", { underdotted = vim.bo.buftype == "" })
end
vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
	desc = "User: FIX underlines for backdrop",
	callback = function(ctx)
		-- WinEnter needs a delay so buftype changes set by plugins are picked up
		-- Dressing.nvim needs to be detected separately, as it uses `noautocmd`
		if ctx.event == "WinEnter" or (ctx.event == "FileType" and ctx.match == "DressingInput") then
			vim.defer_fn(toggleUnderlines, 1)
		end
	end,
})

--------------------------------------------------------------------------------

-- For triggering via hammerspoon, as triggering via `OptionSet` autocmd does
-- not work reliabely.
function M.updateColorscheme()
	-- resets colors, so a theme is not affected by a previous themes colors
	vim.cmd.highlight("clear")

	vim.cmd.colorscheme(vim.o.background == "dark" and darkTheme or lightTheme)
	vim.g.neovide_transparency = vim.o.background == "dark" and darkOpacity or lightOpacity
end

-- initialize theme on startup
-- (darkmode not detected via `vim.o.background`, as Neovide does not set it in time)
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
vim.o.background = macOSMode.stdout:find("Dark") and "dark" or "light"
M.updateColorscheme() -- initialize

--------------------------------------------------------------------------------
return M

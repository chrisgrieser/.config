local M = {}
--------------------------------------------------------------------------------

local lightTheme = require("plugin-configs.themes")[1].colorschemeName
local darkTheme = require("plugin-configs.themes")[2].colorschemeName
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

---@param hlName string|nil name of highlight group
---@param key "fg"|"bg"|"bold"|nil nil gets whole value
---@nodiscard
---@return string|vim.api.keyset.hl_info|nil -- the value, or nil if hlgroup or key is not available
local function getHlValue(hlName, key)
	if not key then return vim.api.nvim_get_hl(0, { name = hlName }) end
	local hl
	repeat
		-- follow linked highlights
		hl = vim.api.nvim_get_hl(0, { name = hlName })
		hlName = hl.link
	until not hl.link
	local value = hl[key]
	if not value then return nil end
	return ("#%06x"):format(value)
end

local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
--------------------------------------------------------------------------------

local function customHighlights()
	-- Comments: keep color and add underlines
	local commentFg = getHlValue("Comment", "fg")
	if commentFg then setHl("@string.special.url.comment", { fg = commentFg, underline = true }) end

	-- Diagnostics: underlines instead of undercurls
	for _, type in pairs { "Error", "Warn", "Info", "Hint" } do
		updateHl("DiagnosticUnderline" .. type, "gui=underline cterm=underline")
	end

	-- Spelling: underdotted instead of undercurls (used only for commit messages though)
	for _, type in pairs { "Bad", "Cap", "Rare", "Local" } do
		updateHl("Spell" .. type, "gui=underdotted cterm=underline")
	end

	-- LSP cursorword
	setHl("LspReferenceWrite", { underdashed = true }) -- definition
	setHl("LspReferenceRead", { underdotted = true }) -- reference
	setHl("LspReferenceText", {}) -- too much noise, as it underlines e.g. strings
end

function M.themeModifications()
	local theme = vim.o.background == "light" and lightTheme or darkTheme

	local function revertedTodoComments()
		local types = { todo = "Hint", error = "Error", warning = "Warn", note = "Info" }
		local textColor = vim.o.background == "dark" and "#000000" or "#ffffff"
		for type, altType in pairs(types) do
			local fg = getHlValue("@comment." .. type, "fg")
				or getHlValue("Diagnostic" .. altType, "fg")
			if fg and fg ~= textColor then setHl("@comment." .. type, { bg = fg, fg = textColor }) end
		end
	end

	-----------------------------------------------------------------------------

	if theme == "dawnfox" then
		setHl("ColorColumn", { bg = "#e9dfd2" })
		setHl("WinSeparator", { fg = "#cfc1b3" })
		setHl("Operator", { fg = "#846a52" })
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHl("lualine_y_diff_modified_" .. v, "guifg=#828208")
				updateHl("lualine_y_diff_added_" .. v, "guifg=#477860")
			end
		end, 100)
		vim.defer_fn(function() setHl("@ibl.indent.char.1", { fg = "#e0cfbd" }) end, 1)

		-- FIX python highlighting issues
		setHl("@type.builtin.python", { link = "Typedef" })
		setHl("@string.documentation.python", { link = "Typedef" })
		setHl("@keyword.operator.python", { link = "Operator" })
	end
end

--------------------------------------------------------------------------------

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
	setHl("LspReferenceWrite", { underdashed = vim.bo.buftype == "" })
	setHl("LspReferenceRead", { underdotted = vim.bo.buftype == "" })
end
vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
	desc = "User: FIX underlines when backdrop",
	group = vim.api.nvim_create_augroup("underlinesInBackdrop", {}),
	callback = function(ctx)
		-- WinEnter needs a delay so buftype changes set by plugins are picked up
		-- Dressing.nvim needs to be detected separately, as it uses `noautocmd`
		if ctx.event == "WinEnter" or (ctx.event == "FileType" and ctx.match == "DressingInput") then
			vim.defer_fn(toggleUnderlines, 1)
		end
	end,
})

--------------------------------------------------------------------------------

-- for triggering via hammerspoon, as triggering via `OptionSet` autocmd does
-- not work reliabely due to some colorschemes setting the background themselves
-- with different timings?
function M.updateColorscheme()
	vim.cmd.highlight("clear") -- fixes some issues when switching colorschemes

	vim.cmd.colorscheme(vim.o.background == "dark" and darkTheme or lightTheme)
	vim.g.neovide_transparency = vim.o.background == "dark" and darkOpacity or lightOpacity

	M.themeModifications()
	vim.defer_fn(customHighlights, 1) -- after modifications, so the dependent colors work
end

-- initialize theme on startup
-- (darkmode not detected via `vim.o.background`, as Neovide does not set it in time)
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
vim.o.background = macOSMode.stdout:find("Dark") and "dark" or "light"
M.updateColorscheme() -- initialize

--------------------------------------------------------------------------------
return M

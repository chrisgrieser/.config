local M = {}
local u = require("config.utils")

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHl(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
---@param changes vim.api.keyset.highlight
local function setHl(hlgroup, changes) vim.api.nvim_set_hl(0, hlgroup, changes) end

local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
--------------------------------------------------------------------------------

local function customHighlights()
	-- Comments: keep color and add underlines
	setHl("@string.special.url.comment", { fg = u.getHlValue("Comment", "fg"), underline = true })

	-- Diagnostics: underlines instead of undercurls
	for _, type in pairs { "Error", "Warn", "Info", "Hint" } do
		updateHl("DiagnosticUnderline" .. type, "gui=underline cterm=underline")
	end

	-- Spelling: underdotted instead of undercurls (used only for commit messages though)
	for _, type in pairs { "Bad", "Cap", "Rare", "Local" } do
		updateHl("Spell" .. type, "gui=underdotted cterm=underline")
	end

	-- Lualine A: bold
	vim.defer_fn(function()
		for _, v in pairs(vimModes) do
			updateHl("lualine_a_" .. v, "gui=bold")
		end
	end, 100)

	-- emphasized `return`
	updateHl("@keyword.return", "gui=bold")
end

function M.themeModifications()
	local mode = vim.o.background
	local theme = mode == "light" and vim.g.lightTheme or vim.g.darkTheme


	local function revertedTodoComments()
		local types = { todo = "Hint", error = "Error", warning = "Warn", note = "Info" }
		local textColor = mode == "dark" and "#000000" or "#ffffff"
		for type, altType in pairs(types) do
			local fg = u.getHlValue("@comment." .. type, "fg")
				or u.getHlValue("Diagnostic" .. altType, "fg")
			if fg and fg ~= textColor then setHl("@comment." .. type, { bg = fg, fg = textColor }) end
		end
	end

	-----------------------------------------------------------------------------

	if theme == "tokyonight" then
		local yellow = mode == "dark" and "#b8b042" or "#e8e05e"
		for _, vimMode in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. vimMode, "guifg=" .. yellow)
			updateHl("lualine_y_diff_added_" .. vimMode, "guifg=#369a96")
		end
		updateHl("GitSignsChange", "guifg=#acaa62")
		updateHl("diffChanged", "guifg=" .. yellow)
		updateHl("GitSignsAdd", "guifg=#369a96")

		setHl("@keyword.return", { fg = "#ff45ff", bold = true })
		revertedTodoComments()
		-- sometimes not set when switching themes
		vim.defer_fn(function() setHl("@ibl.indent.char.1", { fg = "#3b4261" }) end, 1)

		-- FIX
		-- bold and italic having white color, notably the lazy.nvim window
		setHl("Bold", { bold = true })
		setHl("Italic", { italic = true })
		-- broken when switching themes
		setHl("TelescopeSelection", { link = "Visual" })
	elseif theme == "bluloco" then
		setHl("@keyword.return", { fg = "#d42781", bold = true })
		revertedTodoComments()
		setHl("@lsp.typemod.variable.global.lua", { link = "@namespace" }) -- `vim` and `hs`
		setHl("@lsp.typemod.variable.defaultLibrary.lua", { link = "@module.builtin" })
	elseif theme == "dawnfox" then
		setHl("Whitespace", { link = "NonText" }) -- more visible
		setHl("@namespace.builtin.lua", { link = "@variable.builtin" }) -- `vim` and `hs`
		setHl("@keyword.return", { fg = "#9f2e69", bold = true })
		setHl("@markup.italic", { italic = true }) -- FIX
		setHl("@character.printf", { link = "SpecialChar" })
		updateHl("@markup.raw", "gui=none") -- no italics

		setHl("ColorColumn", { bg = "#e9dfd2" })
		setHl("VertSplit", { fg = "#b29b84" })
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
	elseif theme == "kanagawa" then
		-- transparent sign column
		setHl("SignColumn", {})
		updateHl("GitSignsAdd", "guibg=none")
		updateHl("GitSignsChange", "guibg=none")
		updateHl("GitSignsDelete", "guibg=none")
		updateHl("DiagnosticSignHint", "guibg=none")
		updateHl("DiagnosticSignInfo", "guibg=none")
		updateHl("DiagnosticSignWarn", "guibg=none")
		updateHl("DiagnosticSignError", "guibg=none")
	end
end

--------------------------------------------------------------------------------

-- FIX: For plugins using backdrop-like effects, there is some winblend bug,
-- which causes the underlines to be displayed in ugly red. We fix this by
-- temporarily disabling the underline effects set.
local function toggleUnderlines()
	local change = vim.bo.buftype == "" and "underline" or "none"
	updateHl("@string.special.url.comment", "gui=" .. change)
	updateHl("@string.special.url.html", "gui=" .. change)
	updateHl("@markup.link.url.markdown_inline", "gui=" .. change)
end
vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
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
	vim.cmd.colorscheme(vim.o.background == "dark" and vim.g.darkTheme or vim.g.lightTheme)
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

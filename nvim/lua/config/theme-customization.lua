local M = {}
local u = require("config.utils")

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHl(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
---@param changes vim.api.keyset.highlight
local function setHl(hlgroup, changes) vim.api.nvim_set_hl(0, hlgroup, changes) end

--------------------------------------------------------------------------------

local function customHighlights()
	setHl("@lsp.type.comment", {}) -- FIX https://github.com/stsewd/tree-sitter-comment/issues/22
	setHl("MatchParen", { reverse = true }) -- stand out more

	setHl("Whitespace", { link = "NonText" }) -- trailing spaces more visible
	setHl("SnippetTabstop", { bg = u.getHlValue("Folded", "bg") })
	setHl("@character.printf", { link = "SpecialChar" }) -- missing in many themes

	-- Diagnostics: underlines instead of undercurls
	for _, type in pairs { "Error", "Warn", "Info", "Hint" } do
		updateHl("DiagnosticUnderline" .. type, "gui=underline cterm=underline")
	end

	-- Spelling: underdotted instead of undercurls (used only for commit messages though)
	for _, type in pairs { "Bad", "Cap", "Rare", "Local" } do
		updateHl("Spell" .. type, "gui=underdotted cterm=underline")
	end

	-- Comments: color in grey and add underlines
	local commentFg = u.getHlValue("Comment", "fg")
	setHl("@string.special.url.comment", { fg = commentFg, underline = true })
end

function M.themeModifications()
	local mode = vim.o.background
	local theme = mode == "light" and vim.g.lightTheme or vim.g.darkTheme

	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }

	local function boldLualineA()
		for _, v in pairs(vimModes) do
			updateHl("lualine_a_" .. v, "gui=bold")
		end
	end
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

		-- FIX bold and italic having white color, notably the lazy.nvim window
		setHl("Bold", { bold = true })
		setHl("Italic", { italic = true })

		setHl("@keyword.return", { fg = "#ff45ff", bold = true })
		if mode == "dark" then revertedTodoComments() end
		-- sometimes not set when switching themes
		vim.defer_fn(function() setHl("@ibl.indent.char.1", { fg = "#3b4261" }) end, 1)
	elseif theme == "dawnfox" then
		setHl("@namespace.builtin.lua", { link = "@variable.builtin" }) -- `vim` and `hs`
		setHl("@keyword.return", { fg = "#9f2e69", bold = true })
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
	elseif theme == "dracula" then
		vim.defer_fn(boldLualineA, 1)
		revertedTodoComments()

		setHl("@number", { fg = "#7ca2ff" })
		setHl("@number.comment", { link = "@number" })

		updateHl("LspInlayHint", "guibg=#323543")

		setHl("Constant", {})
		setHl("@string.regexp", { fg = "#e37171" }) -- less saturated
		setHl("Boolean", { link = "Special" })
		setHl("Number", { link = "@field" })
		setHl("@keyword.return", { fg = "#5e9fff", bold = true })
	elseif theme == "everforest" then
		setHl("@keyword.return", { fg = "#fd4283", bold = true })
		updateHl("ErrorMsg", "gui=none") -- remove underline
		setHl("Red", { fg = "#cf7e7d" })
		setHl("IblIndent", { fg = "#d2cdad" })
		setHl("NonText", { fg = "#c8b789" })
		local commentColor = u.getHlValue("Comment", "fg")
		setHl("DiagnosticUnnecessary", { fg = commentColor, underdashed = true })
		setHl("TSParameter", { fg = "#6f92b3" })
	elseif theme == "monet" then
		setHl("NonText", { fg = "#717ca7" }) -- more distinguishable from comments
		setHl("Folded", { bg = "#313548" })
		updateHl("String", "gui=none") -- no italics
		setHl("Visual", { bg = "#2a454e" }) -- no bold
		updateHl("TelescopeSelection", "gui=none") -- no bold
		setHl("@keyword.return", { fg = "#1c79d6", bold = true }) -- darker
		for _, v in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. v, "guifg=#cfc53a")
		end
		updateHl("GitSignsChange", "guifg=#acaa62")
	elseif theme == "neomodern" then
		revertedTodoComments()
		setHl("@lsp.type.parameter", { link = "Changed" })
		setHl("@keyword.return", { fg = "#de8c56", bold = true })
		setHl("NonText", { fg = "#57534f" })
		setHl("IblIndent", { fg = "#393734" })
	elseif theme == "gruvbox-material" or theme == "sonokai" then
		local commentColor = u.getHlValue("Comment", "fg")
		updateHl("DiagnosticUnnecessary", "gui=underdouble cterm=underline guifg=" .. commentColor)
		setHl("TSParameter", { fg = "#6f92b3" })
		setHl("@keyword.return", { fg = "#b577c8", bold = true })
	elseif theme == "material" and mode == "light" then
		boldLualineA()
		revertedTodoComments()
		updateHl("@property", "guifg=#6c9798")
		updateHl("Comment", "guifg=#9cb4b5")
		updateHl("@variable.member", "guifg=#6c9798")
		setHl("TelescopeMatching", { fg = "#de8c56" })
	elseif theme == "kanagawa" then
		boldLualineA()

		-- transparent sign column
		setHl("SignColumn", {})
		updateHl("GitSignsAdd", "guibg=none")
		updateHl("GitSignsChange", "guibg=none")
		updateHl("GitSignsDelete", "guibg=none")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticSign" .. type, "guibg=none")
		end
	elseif theme == "bluloco" then
		updateHl("ColorColumn", "guibg=#2e3742")
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

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		M.themeModifications()
		vim.defer_fn(customHighlights, 1) -- after modifications, so the dependent colors work
	end,
})

-- for triggering via hammerspoon, as triggering via `OptionSet` autocmd does
-- not work reliabely due to some colorschemes setting the background themselves
-- with different timings
function M.updateColorscheme()
	vim.cmd.highlight("clear") -- fixes some issues when switching colorschemes
	local targetTheme = vim.o.background == "dark" and vim.g.darkTheme or vim.g.lightTheme
	vim.cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
-- (darkmode not detected via `vim.o.background`, as Neovide does not set it in time)
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
local targetTheme = macOSMode.stdout:find("Dark") and vim.g.darkTheme or vim.g.lightTheme
vim.cmd.colorscheme(targetTheme)

--------------------------------------------------------------------------------
return M

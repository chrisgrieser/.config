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
	setHl("@comment.warning.gitcommit", { link = "WarningMsg" }) -- de-emphasize 50-72 chars
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
			if fg and fg ~= textColor then
				setHl("@comment." .. type, { bg = fg, fg = textColor })
			end
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
		updateHl("GitSignsAdd", "guifg=#369a96")

		-- FIX bold and italic having white color, notably the lazy.nvim window
		setHl("Bold", { bold = true })
		setHl("Italic", { italic = true })

		setHl("@keyword.return", { fg = "#ff45ff", bold = true })
		if mode == "dark" then revertedTodoComments() end
		setHl("TelescopeSelection", { link = "Visual" }) -- sometimes not set when switching themes
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
	elseif theme == "rose-pine" and mode == "light" then
		revertedTodoComments()
		setHl("IblIndent", { fg = "#dbc7b3" })
		setHl("diffAdded", { fg = "#78a991" })
		setHl("diffRemoved", { fg = "#d28884" })
		setHl("Comment", { fg = "#9492aa" })
		updateHl("LspInlayHint", "blend=none")
		setHl("Conceal", { link = "NonText" })
		setHl("NonText", { fg = "#8a87b5" })
		setHl("Bold", { bold = true })
	elseif theme == "neomodern" then
		revertedTodoComments()
		setHl("@lsp.type.parameter", { link = "Changed" })
		if mode == "light" then
			setHl("@keyword.return", { fg = "#fd4283", bold = true })
			setHl("NonText", { fg = "#b5b5bb" })
			setHl("IblIndent", { fg = "#d8d8db" })
			for _, v in pairs(vimModes) do
				updateHl("lualine_a_" .. v, "guifg=#ffffff")
			end

			-- higher contrast
			setHl("@lsp.mod.readonly", { fg = "#ec9403" })
			setHl("@keyword", { fg = "#9255e6" })
			setHl("@keyword.conditional", { fg = "#9255e6" })
		else
			setHl("@keyword.return", { fg = "#de8c56", bold = true })
			setHl("NonText", { fg = "#57534f" })
			setHl("IblIndent", { fg = "#393734" })
		end
	elseif theme == "dracula" then
		vim.defer_fn(boldLualineA, 1)
		revertedTodoComments()
		setHl("Constant", {})
		setHl("Boolean", { link = "Special" })
		setHl("Number", { link = "@field" })
		setHl("@keyword.return", { fg = "#5e9fff", bold = true })
	elseif theme == "dawnfox" then
		setHl("@markup.italic.markdown_inline", { italic = true })
		setHl("@namespace.builtin.lua", { fg = "#b96691" }) -- `vim` and `hs`

		setHl("@ibl.indent.char.1", { fg = "#e0cfbd" })
		setHl("ColorColumn", { bg = "#e9dfd2" })
		setHl("VertSplit", { fg = "#b29b84" })
		setHl("Operator", { fg = "#846a52" })
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHl("lualine_y_diff_modified_" .. v, "guifg=#828208")
				updateHl("lualine_y_diff_added_" .. v, "guifg=#477860")
			end
		end, 100)
		updateHl("@keyword.return", "gui=bold")

		-- FIX python highlighting issues
		setHl("@type.builtin.python", { link = "Typedef" })
		setHl("@string.documentation.python", { link = "Typedef" })
		setHl("@keyword.operator.python", { link = "Operator" })
	elseif theme == "gruvbox-material" or theme == "sonokai" then
		local commentColor = u.getHlValue("Comment", "fg")
		updateHl("DiagnosticUnnecessary", "gui=underdouble cterm=underline guifg=" .. commentColor)
		setHl("TSParameter", { fg = "#6f92b3" })
		setHl("@keyword.return", { fg = "#b577c8", bold = true })
	elseif theme == "material" and mode == "light" then
		updateHl("@property", "guifg=#6c9798")
		updateHl("@field", "guifg=#6c9798")
		updateHl("Comment", "guifg=#9cb4b5")
		updateHl("NonText", "guifg=#9cb4b5")
		updateHl("NotifyINFOTitle", "guifg=#4eb400")
		updateHl("NotifyINFOIcon", "guifg=#4eb400")

		-- fix cursor being partially overwritten by the theme
		vim.opt.guicursor:append("r-cr-o-v:hor10")
		vim.opt.guicursor:append("a:blinkwait200-blinkoff500-blinkon700")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
		end
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
		vim.opt.guicursor:append("i-ci-c:ver25")
		vim.opt.guicursor:append("o-v:hor10")
		if mode == "dark" then updateHl("ColorColumn", "guibg=#2e3742") end
	end
end

--------------------------------------------------------------------------------

-- FIX: For plugins using backdrop-like effects, there is some winblend bug,
-- which causes the underlines to be displayed in ugly red. We fix this by
-- temporarily disabling the underline effects set by this plugin.
local function toggleUnderlines()
	local change = vim.bo.buftype == "" and "underline" or "none"
	updateHl("@string.special.url.comment", "gui=" .. change)
end
vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
	group = vim.api.nvim_create_augroup("underlinesInBackdrop", {}),
	callback = function(ctx)
		-- WinEnter needs a delay so buftype changes set by plugins are picked up
		-- Dressing.nvim needs to be detected separately, as it uses `noautocmd`
		if ctx.event == "WinEnter" then
			vim.defer_fn(toggleUnderlines, 1)
		elseif ctx.event == "FileType" and ctx.match == "DressingInput" then
			toggleUnderlines()
		end
	end,
})

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		M.themeModifications()
		customHighlights() -- after modifications, so the dependent colors work
	end,
})

-- for triggering via hammerspoon, as triggering via `OptionSet` autocmd does
-- not work reliabely due to some colorschemes setting the background themselves
-- with different timings
function M.updateColorscheme()
	local targetTheme = vim.o.background == "dark" and vim.g.darkTheme or vim.g.lightTheme
	vim.cmd.highlight("clear") -- fixes some issues when switching colorschemes
	vim.cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
-- (darkmode not detected via `vim.o.background`, as Neovide does not set it in time)
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
local targetTheme = macOSMode.stdout:find("Dark") and vim.g.darkTheme or vim.g.lightTheme
vim.cmd.colorscheme(targetTheme)

--------------------------------------------------------------------------------
return M

local M = {}
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

	-- emphasized `return`
	updateHl("@keyword.return", "gui=bold")

	-- LSP cursorword
	setHl("LspReferenceWrite", { underdashed = true }) -- definition
	setHl("LspReferenceRead", { underdotted = true }) -- reference
	setHl("LspReferenceText", {}) -- too much noise, as it underlines e.g. strings
end

function M.themeModifications()
	local theme = vim.o.background == "light" and vim.g.lightTheme or vim.g.darkTheme

	local function revertedTodoComments()
		local types = { todo = "Hint", error = "Error", warning = "Warn", note = "Info" }
		local textColor = vim.o.background == "dark" and "#000000" or "#ffffff"
		for type, altType in pairs(types) do
			local fg = getHlValue("@comment." .. type, "fg")
				or getHlValue("Diagnostic" .. altType, "fg")
			if fg and fg ~= textColor then setHl("@comment." .. type, { bg = fg, fg = textColor }) end
		end
	end

	local function lualineBold()
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHl("lualine_a_" .. v, "gui=bold")
			end
		end, 100)
	end

	-----------------------------------------------------------------------------

	if theme == "tokyonight" then
		local yellow = vim.o.background == "dark" and "#b8b042" or "#e8e05e"
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
		-- FIX for blink cmp highlight
		setHl("BlinkCmpKind", { link = "Special" })
	elseif theme == "bluloco" then
		setHl("@keyword.return", { fg = "#d42781", bold = true })
		revertedTodoComments()
		lualineBold()
		setHl("@lsp.typemod.variable.global.lua", { link = "@namespace" }) -- `vim` and `hs`
		setHl("@lsp.typemod.variable.defaultLibrary.lua", { link = "@module.builtin" })
		setHl("Title", { fg = "#7c84da", bold = true })
		setHl("Conceal", { link = "NonText" })
	elseif theme == "dawnfox" then
		setHl("Whitespace", { link = "NonText" }) -- more visible
		setHl("@namespace.builtin.lua", { link = "@variable.builtin" }) -- `vim` and `hs`
		setHl("@keyword.return", { fg = "#9f2e69", bold = true })
		setHl("@markup.italic", { italic = true }) -- FIX
		setHl("@character.printf", { link = "SpecialChar" })
		updateHl("@markup.raw", "gui=none") -- no italics

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
	elseif theme == "dracula" then
		revertedTodoComments()

		setHl("@number", { fg = "#7ca2ff" })
		setHl("@number.comment", { link = "@number" })

		updateHl("LspInlayHint", "guibg=#323543")

		setHl("Constant", {})
		setHl("@string.regexp", { fg = "#e37171" }) -- less saturated
		setHl("Boolean", { link = "Special" })
		setHl("Number", { link = "@field" })
		setHl("@keyword.return", { fg = "#5e9fff", bold = true })
	end
end

--------------------------------------------------------------------------------

-- FIX: For plugins using backdrop-like effects, there is some winblend bug,
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

	local isDark = vim.o.background == "dark"
	local targetTheme = isDark and vim.g.darkTheme or vim.g.lightTheme
	if targetTheme then vim.cmd.colorscheme(targetTheme) end
	vim.g.neovide_transparency = (isDark and vim.g.darkOpacity or vim.g.lightOpacity)

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

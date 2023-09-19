local api = vim.api
local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = "⌨️  Search Keymaps" })

keymap("n", "<D-,>", function()
	local thisFilePath = debug.getinfo(1).source:sub(2)
	cmd.edit(thisFilePath)
end, { desc = "⌨️ Edit keybindings.lua" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- visual instead of logical lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- - HJKL behaves like hjkl, but bigger distance and also on visual lines
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- `0` ensures fully scrolling to the left on long unwrapped lines
keymap({ "n", "x" }, "L", "$") -- not using "o", since used for link textobj
keymap({ "n", "x" }, "J", "6gj") -- - work on visual lines instead of logical ones for when wrapping is one
keymap({ "n", "x" }, "K", "6gk")

-- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "J", "2j")
keymap("o", "K", "2k")

-- indent-wise movement
keymap({ "n", "x" }, "gj", function() require("funcs.quality-of-life").gotoNextIndentChange("down") end)
keymap({ "n", "x" }, "gk", function() require("funcs.quality-of-life").gotoNextIndentChange("up") end)

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward", unique = false }) -- overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings

-- Simplified Marks
-- INFO a custom lualine component shows what is currently marked
keymap("n", "ä", "'M", { desc = " Goto Mark" })

keymap("n", "Ä", function()
	u.normal("mM")
	u.notify("", " Mark set.", "trace")
end, { desc = " Set Mark" })

keymap("n", "dä", function()
	api.nvim_del_mark("M")
	u.notify("", " Mark deleted.", "trace")
end, { desc = " Delete Mark" })

-- Hunks and Changes
keymap("n", "gh", "<cmd>Gitsigns next_hunk<CR>zv", { desc = "󰊢 Next Hunk" })
keymap("n", "gH", "<cmd>Gitsigns prev_hunk<CR>zv", { desc = "󰊢 Previous Hunk" })
keymap("n", "gc", "g;", { desc = "Goto older change" })
keymap("n", "gC", "g,", { desc = "Goto newer change" })

--------------------------------------------------------------------------------

-- SEARCH
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })

-- auto-nohl -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local key = fn.keytrans(char)
	local isCmdlineSearch = fn.getcmdtype():find("[/?]") ~= nil
	local searchMvKeys = { "n", "N", "*", "#" } -- works for RHS, therefore no need to consider remaps

	local searchStarted = (key == "/" or key == "?") and fn.mode() == "n"
	local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
	local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
	if not (searchStarted or searchConfirmed or searchCancelled or fn.mode() == "n") then return end
	local searchMovement = vim.tbl_contains(searchMvKeys, key)
	local hlSearchOn = vim.opt.hlsearch:get()

	if (searchMovement or searchConfirmed or searchStarted) and not hlSearchOn then
		vim.opt.hlsearch = true
	elseif (searchCancelled or not searchMovement) and hlSearchOn and not searchConfirmed then
		vim.opt.hlsearch = false
	end

	-- nvim-hlslens plugin
	if searchConfirmed or searchMovement then
		local ok, hlslens = pcall(require, "hlslens")
		if ok then hlslens.start() end
	end
end, api.nvim_create_namespace("auto_nohl"))

--------------------------------------------------------------------------------
-- EDITING

-- Delete trailing stuff
-- (wrapping in normal avoids temporarily scrolling to the side)
keymap("n", "X", "<cmd>normal!mz$x`z<CR>", { desc = "󱎘 Delete char at EoL" })

-- QUICKFIX
require("funcs.quickfix").setup()
keymap("n", "gq", require("funcs.quickfix").next, { desc = " Next Quickfix" })
keymap("n", "gQ", require("funcs.quickfix").previous, { desc = " Prev Quickfix" })
keymap("n", "dQ", require("funcs.quickfix").deleteList, { desc = " Empty Quickfix List" })

-- COMMENTS
-- stylua: ignore
keymap("n", "qw", function () require("funcs.quality-of-life").commentHr() end, { desc = " Horizontal Divider" })
keymap("n", "wq", '"zyy"zpkqqj', { desc = " Duplicate Line as Comment", remap = true })

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent line" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent line" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent selection" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent selection" })
keymap("n", "[", "<", { desc = "outdent" })
keymap("n", "]", ">", { desc = "indent" })

keymap("n", "~", function() require("funcs.quality-of-life").toggleCase() end, { desc = "better ~" })

-- WORD FLIPPER
keymap(
	"n",
	"Ö",
	function() require("funcs.flipper").flipWord() end,
	{ desc = "󱀽 flip words / toggle casing" }
)

-- [O]pen new scope / brace
keymap(
	{ "n", "i" },
	"<D-o>",
	function() require("funcs.quality-of-life").openNewScope() end,
	{ desc = " Open new scope" }
)

-- SPELLING
keymap("n", "zl", function() vim.cmd.Telescope("spell_suggest") end, { desc = "󰓆 Spell Suggest" })
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", function()
	if api.nvim_win_get_cursor(0)[1] == fn.line("$") then return end
	return [[<cmd>. move +1<CR>==]]
end, { desc = "󰜮 Move Line Down", expr = true })
keymap("n", "<Up>", function()
	if api.nvim_win_get_cursor(0)[1] == 1 then return end
	return [[<cmd>. move -2<CR>==]]
end, { desc = "󰜷 Move Line Up", expr = true })
keymap("n", "<Right>", function()
	if fn.col(".") >= fn.col("$") - 1 then return end
	return [["zx"zp]]
end, { desc = "Move Char Right", expr = true })
keymap("n", "<Left>", function()
	if fn.col(".") == 1 then return end
	return [["zdh"zph]]
end, { desc = "Move Char Left", expr = true })

-- stylua: ignore start
keymap("x", "<Down>", [[:move '>+1<CR><cmd>normal! gv=gv<CR>]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR><cmd>normal! gv=gv<CR>]], { desc = "󰜷 Move selection up", silent = true })
-- stylua: ignore end

keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<Left>", [["zdh"zPgvhoho]], { desc = "➡️ Move selection left" })

-- Merging
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 Merge line up" })

-- URL Opening (forward-seeking `gx`)
keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = fn.mode():find("v") -- various textobjs only switches to visual if obj found
	if foundURL then
		u.normal('"zy')
		local url = fn.getreg("z")
		vim.fn.system { "open", url }
	end
end, { desc = "󰌹 Smart URL Opener" })

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-a>", "<Esc>I") -- BoL
-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "better i" })

-- COMMAND MODE
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear full line
keymap("c", "<C-w>", "<C-r><C-w>") -- add word under cursor
keymap("c", "<BS>", function()
	local cmdLine = vim.fn.getcmdline()
	local cmdlineEmpty = cmdLine:find("^$")
	local isIncRename = cmdLine:find("^IncRename $")
	local isSubstitute = cmdLine:find("^%%? ?s ?/$")
	if cmdlineEmpty or isIncRename or isSubstitute then return end
	return "<BS>"
end, { desc = "Restricted <BS>", expr = true })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` from Normal starts Visual Block" })

-- TERMINAL MODE
-- also relevant for iron.nvim
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (Terminal Mode)" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = " Esc Terminal Mode" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

keymap("n", "<CR>", function()
	if vim.bo.buftype == "terminal" then
		u.normal("a") -- enter terminal mode
	else
		require("funcs.alt-alt").altBuffer()
	end
end, { desc = "󰽙 Alt Buffer" })
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next Window" })

-- stylua: ignore
keymap({"n", "x", "i"}, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "󰽙 close buffer/window" })
keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " 󰽙 Buffers" })

keymap("n", "<C-w>h", "<cmd>split<CR>", { desc = " horizontal split" })
keymap("n", "<C-w>v", "<cmd>vertical split<CR>", { desc = " vertical split" })
keymap("n", "<C-w><C-h>", "<cmd>split<CR>", { desc = " horizontal split" })
keymap("n", "<D-t>", "<cmd>tabedit %<CR>", { desc = "󰓩 New Tab" })

keymap("n", "<C-Right>", "<cmd>vertical resize +3<CR>", { desc = " vertical resize (+)" })
keymap("n", "<C-Left>", "<cmd>vertical resize -3<CR>", { desc = " vertical resize (-)" })
keymap("n", "<C-Up>", "<cmd>resize +3<CR>", { desc = " horizontal resize (+)" })
keymap("n", "<C-Down>", "<cmd>resize -3<CR>", { desc = " horizontal resize (-)" })

--------------------------------------------------------------------------------
-- CLIPBOARD

--- macOS bindings (needed for compatibility with automation apps)
keymap({ "n", "x" }, "<D-c>", "y", { desc = "copy" })
keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" })
keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })

-- keep the register clean
keymap("n", "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = " Paste w/o switching register" })

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	local isBlankLine = api.nvim_get_current_line():find("^%s*$")
	if isBlankLine then return '"_dd' end
	return "dd"
end, { expr = true })

-- always paste characterwise when in insert mode
keymap("i", "<D-v>", function()
	local regContent = fn.getreg("+"):gsub("^%s*", ""):gsub("%s*$", "")
	fn.setreg("+", regContent, "v") ---@diagnostic disable-line: param-type-mismatch
	return "<C-g>u<C-r><C-o>+" -- "<C-g>u" adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

------------------------------------------------------------------------------
-- CMD-KEYBINDINGS

keymap(
	{ "n", "x" },
	"<D-l>",
	function() fn.system { "open", "-R", expand("%:p") } end,
	{ desc = "󰀶 Reveal in Finder" }
)
keymap({ "n", "x" }, "<D-5>", function()
	local parentFolder = expand("%:p:h")
	if not parentFolder:find("Alfred%.alfredpreferences") then
		u.notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	fn.system { "open", "alfredpreferences://navigateto/workflows>workflow>" .. workflowId }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	fn.system { "open", "-a", "Alfred Preferences" }
end, { desc = "󰮤 Reveal Workflow in Alfred" })

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

--------------------------------------------------------------------------------
-- FILES

---using this to show the actual directory where I am telescoping
---@nodiscard
---@return string name of the current project
local function projectName()
	local pwd = vim.loop.cwd()
	return vim.fs.basename(pwd)
end

keymap("n", "go", function()
	local project = projectName()
	if project == "" then
		u.notify("", "No pwd available.", "error")
		return
	end
	require("telescope.builtin").find_files { prompt_title = project }
end, { desc = " Browse in Project" })

-- stylua: ignore
keymap( "n", "gO", function()
	local parentFolder = expand("%:p:h")
	require("telescope.builtin").find_files {
		prompt_title = vim.fs.basename(parentFolder),
		cwd = parentFolder,
	}
end, { desc = " Browse in current Folder" })

keymap("n", "gl", function()
	local project = projectName()
	if project == "" then
		u.notify("", "No pwd available.", "error")
		return
	end
	require("telescope.builtin").live_grep { prompt_title = "Live Grep: " .. projectName() }
end, { desc = " Live Grep in Project" })

-- stylua: ignore
keymap({ "n", "x" }, "gL", function() cmd.Telescope("grep_string") end, { desc = " Grep cword in Project" })
-- stylua: ignore
keymap("n", "gr", "<cmd>lua require('telescope').extensions.recent_files.pick()<CR>", { desc = " Recent Files" })

keymap("n", "g.", function() cmd.Telescope("resume") end, { desc = " Continue" })
keymap("n", "ga", "gf", { desc = "Goto File under Cursor" }) -- needed, since remapped

--------------------------------------------------------------------------------
-- FOLDING

-- toggle all top-level folds
keymap("n", "zz", function() cmd("%foldclose") end, { desc = "󰘖 Close toplevel folds" })

------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- INFO some LSP bindings done globally, so they can be used by null-ls as well
-- stylua: ignore start
keymap("n", "ge", function() vim.diagnostic.goto_next { float = true } end, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", function() vim.diagnostic.goto_prev { float = true } end, { desc = "󰒕 Previous Diagnostic" })
-- stylua: ignore end

-- uses "v" instead of "x", so signature can be shown during snippet completion
keymap({ "n", "i", "v" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "󰒕 Signature" })

keymap("n", "gd", function() cmd.Telescope("lsp_definitions") end, { desc = "󰒕 Definitions" })
keymap("n", "gf", function() cmd.Telescope("lsp_references") end, { desc = "󰒕 References" })

keymap("n", "<leader>v", ":IncRename ", { desc = "󰒕 IncRename" })
keymap("n", "<leader>V", ":IncRename <C-r><C-w>", { desc = "󰒕 IncRename (cword)" })
keymap(
	"n",
	"gs",
	function() cmd.Telescope("lsp_document_symbols") end,
	{ desc = "󰒕 Symbols", unique = false }
)
keymap(
	"n",
	"gw",
	function() cmd.Telescope("lsp_workspace_symbols") end,
	{ desc = "󰒕 Workspace Symbols" }
)

--------------------------------------------------------------------------------
-- stylua: ignore
keymap("n", "<PageDown>", function() require("funcs.quality-of-life").scrollHoverWin("down") end, { desc = "󰮷 Scroll hover down" })
-- stylua: ignore
keymap("n", "<PageUp>", function() require("funcs.quality-of-life").scrollHoverWin("up") end, { desc = "󰮽 Scroll hover up" })

--------------------------------------------------------------------------------
-- Q / ESC TO CLOSE SPECIAL WINDOWS

autocmd("FileType", {
	pattern = {
		"help",
		"lspinfo",
		"qf", -- quickfix
		"lazy",
		"noice",
		"httpResult", -- rest.nvim
		"DressingSelect", -- done here and not as dressing keybinding to be able to set `nowait`
		"DressingInput",
		"man",
	},
	callback = function()
		local opts = { buffer = true, nowait = true, desc = "󱎘 Close", unique = false }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

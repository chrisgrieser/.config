require("config.utils")
local qol = require("funcs.quality-of-life")
--------------------------------------------------------------------------------
-- META

-- search keymaps
Keymap("n", "?", function() Cmd.Telescope("keymaps") end, { desc = " Keymaps" })
-- stylua: ignore

-- Theme Picker
Keymap("n", "<leader>T", function() Cmd.Telescope("colorscheme") end, { desc = " Colorschemes" })

-- Highlights
Keymap("n", "<leader>H", function() Cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- Update [P]lugins
Keymap("n", "<leader>p", require("lazy").sync, { desc = ":Lazy sync" })
Keymap("n", "<leader>P", require("lazy").home, { desc = ":Lazy home" })
Keymap("n", "<leader>M", Cmd.Mason, { desc = ":Mason" })

-- copy [l]ast ex[c]ommand
Keymap("n", "<leader>lc", function()
	local lastCommand = Fn.getreg(":"):gsub("^I ", "") -- remove `I ` from my inspect command
	Fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "גּ Copy last command" })

-- [l]ast command [a]gain
-- as opposed to `@:`, this works across restarts of neovim
Keymap("n", "<leader>la", ":<Up><CR>", { desc = "גּ Run last command again" })

-- copy [l]ast [n] notification
Keymap("n", "<leader>ln", function()
	local history = require("notify").history()
	local lastNotify = history[#history]
	local msg = table.concat(lastNotify.message, "\n")
	Fn.setreg("+", msg)
	vim.notify("Last Notification copied.", LogTrace)
end, { desc = "גּ Copy Last Notification" })

-- Dismiss notifications
Keymap("n", "<Esc>", function()
	if not vim.g.neovide then return end -- notify.nvim not loaded for Terminal
	local clearPending = require("notify").pending() > 10
	require("notify").dismiss { pending = clearPending }
end, { desc = "Clear Notifications" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
Keymap({ "o", "x" }, "H", "^")
Keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
Keymap({ "n", "x", "o" }, "L", "$")

Keymap({ "n", "x" }, "J", "6j")
Keymap({ "n", "x" }, "K", "6k")

Keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines
Keymap("o", "K", "2k")

-- JUMP HISTORY
Keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
Keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- SEARCH
Keymap({ "n", "o" }, "-", "/", { desc = "Search" })
Keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })
Keymap("n", "+", "*", { desc = "Search word under cursor" })
Keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "Visual star" })

-- automatically do `:nohl` when done with search https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	if Fn.mode() == "n" then
		local originalSearchRelatedKeys = { "<CR>", "n", "N", "*", "#", "?", "/" }
		local new_hlsearch = vim.tbl_contains(originalSearchRelatedKeys, Fn.keytrans(char))
		if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
	end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

-- MARKS
-- stylua: ignore
Keymap("n", "ä", function() require("funcs.mark-cycler").gotoMark() end, { desc = "Goto Next Mark" })
Keymap("n", "Ä", function() require("funcs.mark-cycler").setMark() end, { desc = "Set Next Mark" })

-- reset marks on startup (needs to be on VimEnter so it's not called too early)
Autocmd("VimEnter", {
	callback = function() require("funcs.mark-cycler").clearMarks() end,
})

-- HUNKS AND CHANGES
Keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
Keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })
Keymap("n", "gc", "g;", { desc = "goto next change" })
Keymap("n", "gC", "g,", { desc = "goto previous change" })

-- [M]atching Bracket
-- remap needed, if using the builtin matchit plugin (currently disabled)
Keymap("n", "m", "%", { desc = "Goto Matching Bracket" })

--------------------------------------------------------------------------------

-- FOLDING
-- with count: close {n} fold levels
-- without toggle current fold
Keymap("n", "^", function()
	if vim.v.count == 0 then
		Normal("za")
	else
		require("ufo").closeFoldsWith(vim.v.count - 1) -- -1 as topmost is foldlevel 0
	end
end, { desc = "ﬕ Toggle fold / Close {n} foldlvls" })
Keymap("n", "zR", function() require("ufo").openAllFolds() end, { desc = "  Open all folds" })
Keymap("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "  Close all folds" })
Keymap("n", "zz", function()
	Cmd("%foldclose") -- close toplevel folds
	Cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "ﬕ Close toplevel folds" })

--------------------------------------------------------------------------------
-- EDITING

-- NUMBERS
Keymap("n", "<M-a>", "10<C-a>", { desc = "+ 10" })
Keymap("n", "<M-x>", "10<C-x>", { desc = "- 10" })

-- QUICKFIX
Keymap("n", "gq", require("funcs.quickfix").next, { desc = " Next Quickfix" })
Keymap("n", "gQ", require("funcs.quickfix").previous, { desc = " Previous Quickfix" })
Keymap("n", "dQ", require("funcs.quickfix").deleteList, { desc = " Delete Quickfix List" })
-- stylua: ignore
Keymap("n", "<leader>q", function() require("replacer").run { rename_files = false } end, { desc = " Replacer.nvim" })

-- COMMENTS & ANNOTATIONS
Keymap("n", "qw", qol.commentHr, { desc = "Horizontal Divider" })
Keymap("n", "qd", "Rkqqj", { desc = "Duplicate Line as Comment", remap = true })
-- stylua: ignore
Keymap("n", "qf", function() require("neogen").generate() end, { desc = "Neogen: Comment Function" })

-- WHITESPACE CONTROL
Keymap("n", "=", "mzO<Esc>`z", { desc = " add blank above" })
Keymap("n", "_", "mzo<Esc>`z", { desc = " add blank below" })
Keymap("n", "<Tab>", ">>", { desc = " indent" })
Keymap("n", "<S-Tab>", "<<", { desc = " outdent" })
Keymap("x", "<Tab>", ">gv", { desc = " indent" })
Keymap("x", "<S-Tab>", "<gv", { desc = " outdent" })

-- Word Switcher (fallback: switch casing)
-- stylua: ignore
Keymap( "n", "<BS>", function() require("funcs.wave").switch() end, { desc = "switch common words" })

-- Append to / delete from EoL
local trailingKeys = { ",", ";", '"', "'", ")", "}", "]", "\\" }
for _, v in pairs(trailingKeys) do
	Keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = v .. " to EoL" })
end
Keymap("n", "X", "mz$x`z", { desc = "delete last character" })

--------------------------------------------------------------------------------

-- SPELLING

-- [z]pelling [l]ist
Keymap("n", "zl", function() Cmd.Telescope("spell_suggest") end, { desc = "暈suggest" })
Keymap("n", "za", "1z=", { desc = "暈autofix" }) -- [a]utofix word under cursor

---add word under cursor to vale dictionary
---@param mode string accept|reject
local function valeWord(mode)
	local word = Expand("<cword>")
	local success = AppendToFile(word, LinterConfig .. "/vale/styles/Vocab/Docs/" .. mode .. ".txt")
	if not success then return end -- error message already by AppendToFile
	Cmd.mkview(2)
	Cmd.update()
	Cmd.edit() -- reload file for diagnostics to take effect
	Cmd.loadview(2)
	vim.notify("暈Now " .. mode .. "ing:\n" .. word)
end
Keymap("n", "zg", function() valeWord("accept") end, { desc = "暈Add to accepted words (vale)" })
Keymap("n", "zw", function() valeWord("reject") end, { desc = "暈Add to rejected words (vale)" })

--------------------------------------------------------------------------------

-- [S]ubstitute Operator (substitute.nvim)
Keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
Keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
Keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
-- stylua: ignore
Keymap( "n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange operator" })
Keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

-- Node S[w]apping
-- stylua: ignore start
Keymap("n", "ü", function () require('sibling-swap').swap_with_right() end, { desc = "壟 Move Node Right" })
Keymap("n", "Ü", function () require('sibling-swap').swap_with_left() end, { desc = "鹿 Move Node Left" })

Autocmd("FileType", {
	pattern = {"markdown", "text", "gitcommit"},
	callback = function()
		Keymap("n", "ü", '"zdawel"zph', { desc = "壟 Move Word Right", buffer = true })
		Keymap("n", "Ü", '"zdawbh"zph', { desc = "鹿 Move Word Left", buffer = true })
	end,
})
-- stylua: ignore end

--------------------------------------------------------------------------------

-- search & replace
Keymap(
	"n",
	"<leader>f",
	[[:%s/<C-r>=expand("<cword>")<CR>//g<Left><Left>]],
	{ desc = "弄 :substitute" }
)
Keymap("x", "<leader>f", ":s///g<Left><Left><Left>", { desc = "弄 :substitute" })
Keymap(
	{ "n", "x" },
	"<leader>F",
	function() require("ssr").open() end,
	{ desc = "弄 Structural search & replace" }
)
Keymap("n", "<leader>n", ":%normal ", { desc = "弄 :normal" })
Keymap("x", "<leader>n", ":normal ", { desc = "弄 :normal" })

-- Refactor
-- stylua: ignore start
Keymap({ "n", "x" }, "<leader>i", function() require("refactoring").refactor("弄 Inline Variable") end, { desc = "弄 Inline Variable" })
Keymap({ "n", "x" }, "<leader>e", function() require("refactoring").refactor("弄 Extract Variable") end, { desc = "弄 Extract Variable" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Undo
Keymap({ "n", "x" }, "U", "<C-r>", { desc = "碑 redo" }) -- redo
Keymap("n", "<C-u>", qol.undoDuration, { desc = "碑 undo specific durations" })
Keymap("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "碑 Undotree" })

-- Logging & Debugging
-- stylua: ignore start
Keymap({ "n", "x" }, "<leader>ll", function() require("funcs.quick-log").log() end, { desc = " log" })
Keymap({ "n", "x" }, "<leader>lo", function() require("funcs.quick-log").objectlog() end, { desc = " object log" })
Keymap("n", "<leader>lb", function() require("funcs.quick-log").beeplog() end, { desc = " beep log" })
Keymap("n", "<leader>lt", function() require("funcs.quick-log").timelog() end, { desc = " time log" })
Keymap("n", "<leader>lr", function() require("funcs.quick-log").removelogs() end, { desc = "  remove log" })
Keymap("n", "<leader>ld", function() require("funcs.quick-log").debuglog() end, { desc = " debugger" })
-- stylua: ignore end

-- Sort & highlight duplicate lines
-- stylua: ignore
Keymap( { "n", "x" }, "<leader>S", ":sort<CR>", { desc = "弄 Sort" })

-- Replace Mode
-- needed, since `R` mapped to duplicate line
Keymap("n", "cR", "R", { desc = "Replace Mode" })

-- URL Opening (forward-seeking `gx`)
Keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = Fn.mode():find("v") -- will only switch to visual mode if URL found
	if foundURL then
		Normal('"zy')
		local url = Fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = " Smart URL Opener" })

--------------------------------------------------------------------------------

-- Line & Character Movement
Keymap("n", "<Down>", qol.moveLineDown)
Keymap("n", "<Up>", qol.moveLineUp)
Keymap("x", "<Down>", qol.moveSelectionDown)
Keymap("x", "<Up>", qol.moveSelectionUp)
Keymap("n", "<Right>", qol.moveCharRight)
Keymap("n", "<Left>", qol.moveCharLeft)
Keymap("x", "<Right>", qol.moveSelectionRight)
Keymap("x", "<Left>", qol.moveSelectionLeft)

-- Merging / Splitting Lines
Keymap({ "n", "x" }, "M", "J", { desc = "merge line up" })
Keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "merge line down" })
Keymap("n", "<leader>s", Cmd.TSJToggle, { desc = "split/join" })

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
Keymap("i", "<C-e>", "<Esc>A") -- EoL
Keymap("i", "<C-k>", "<Esc>lDi") -- kill line
Keymap("i", "<C-a>", "<Esc>I") -- BoL
Keymap("c", "<C-a>", "<Home>")
Keymap("c", "<C-e>", "<End>")
Keymap("c", "<C-u>", "<C-e><C-u>") -- clear

--------------------------------------------------------------------------------
-- VISUAL MODE
Keymap("x", "V", "j", { desc = "repeated V selects more lines" })
Keymap("x", "v", "<C-v>", { desc = "vv from Normal Mode starts Visual Block Mode" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

-- for consistency with terminal buffers also <S-CR>
-- stylua: ignore start
Keymap("n", "<S-CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })
Keymap("n", "<CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })

Keymap({ "n", "x", "i" }, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "close buffer/window" })
Keymap({ "n", "x", "i" }, "<D-S-t>", function() require("funcs.alt-alt").reopenBuffer() end, { desc = "reopen last buffer" })

Keymap("n", "gb", function() Cmd.Telescope("buffers") end, { desc = " Open Buffers" })
-- stylua: ignore end

Keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize (+)" }) -- resizing on one key for sanity
Keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize (-)" })
Keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize (+)" })
Keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize (-)" })

-- Harpoon
Keymap("n", "<D-CR>", function() require("harpoon.ui").nav_next() end, { desc = "ﯠ Next" })
-- stylua: ignore start
-- consistent with adding/removing bookmarks in the Browser/Obsidian
Keymap("n", "<D-d>", function()
	require("harpoon.mark").add_file()
	vim.b.harpoonMark = "ﯠ"
end, { desc = "ﯠ Add File" })
Keymap("n", "<D-S-d>", function()
	require("harpoon.ui").toggle_quick_menu()
	UpdateHarpoonIndicator()
end, { desc = "ﯠ Menu" })
-- stylua: ignore end

------------------------------------------------------------------------------

-- CMD-KEYBINDINGS
Keymap({ "n", "x", "i" }, "<D-s>", Cmd.update, { desc = "save" }) -- cmd+s, will be overridden on lsp attach

-- stylua: ignore
Keymap({ "n", "x" }, "<D-l>", function() Fn.system("open -R '" .. Expand("%:p") .. "'") end, { desc = " Reveal in Finder" })

Keymap("n", "<D-0>", ":10messages<CR>", { desc = ":messages (last 10)" }) -- as cmd.function these wouldn't require confirmation
Keymap("n", "<D-9>", ":Notifications<CR>", { desc = ":Notifications" })

-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
-- are overridden inside snippet for snipeptjumping
vim.g.VM_maps = {
	["Find Under"] = "<D-j>", -- select word under cursor & enter visual-multi (normal) / add next occurrence (visual-multi)
	["Visual Add"] = "<D-j>", -- enter visual-multi (visual)
	["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi)
}

--- copy & paste
Keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
Keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
Keymap("i", "<D-v>", "<C-g>u<C-r><C-o>+", { desc = "paste" }) -- "<C-g>u" adds undopoint before the paste
Keymap("x", "<D-c>", "y", { desc = "copy" }) -- needed for compatibility with automation apps

-- cmd+e: inline code
Keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
Keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
Keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

-- cmd+t: template string
Keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String" }) -- no selection = word under cursor
Keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String" })
Keymap("i", "<D-t>", "${}<Left>", { desc = "Template String" })

--------------------------------------------------------------------------------

-- COLOR PICKER
Keymap("n", "#", ":CccPick<CR>", { desc = " Color Picker" })
Keymap("n", "'", ":CccConvert<CR>", { desc = " Convert Color" }) -- shift-# on German keyboard

--------------------------------------------------------------------------------
-- FILES

-- number of harpoon files in the current project
---@return number|nil
local function harpoonFileNumber()
	local pwd = vim.loop.cwd() or ""
	local jsonPath = Fn.stdpath("data") .. "/harpoon.json"
	local json = ReadFile(jsonPath)
	if not json then return end

	local data = vim.json.decode(json)
	local project = data.projects[pwd]
	if not project then return end
	local fileNumber = #project.mark.marks
	return fileNumber
end

-- find files
-- add project name + number of harpoon files to prompt title
Keymap("n", "go", function()
	local pwd = vim.loop.cwd() or ""
	local projectName = pwd:gsub(".*/", "")
	local harpoonNumber = harpoonFileNumber() or 0
	local title = tostring(harpoonNumber) .. "ﯠ " .. projectName
	require("telescope").extensions.file_browser.file_browser { prompt_title = title }
end, { desc = " Browse in Project" })

Keymap("n", "gO", function()
	local thisFolder = Expand("%:p:h")
	require("telescope").extensions.file_browser.file_browser { path = thisFolder }
end, { desc = " Browse in Folder" })
Keymap("n", "gF", function() Cmd.Telescope("live_grep") end, { desc = " ripgrep folder" })
Keymap("n", "gr", function() Cmd.Telescope("oldfiles") end, { desc = " Recent Files" })

-- File Operations
-- stylua: ignore start
Keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = " Copy filepath" })
Keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = " Copy filename" })
Keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = " chmod +x" })
Keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = " Rename file" })
Keymap("n", "<D-S-m>", function() require("genghis").moveAndRenameFile() end, { desc = " Move-rename file" })
Keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = " Duplicate file" })
Keymap("n", "<D-BS>", function() require("genghis").trashFile() end, { desc = " Move file to trash" })
Keymap("n", "<D-n>", function() require("genghis").createNewFile() end, { desc = " Create new file" })
Keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = " Selection to new file" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- stylua: ignore start
Keymap("n", "ge", function() vim.diagnostic.goto_next { wrap = true, float = true } end, { desc = "璉Next Diagnostic" })
Keymap("n", "gE", function() vim.diagnostic.goto_prev { wrap = true, float = true } end, { desc = "璉Previous Diagnostic" })
-- stylua: ignore end

Keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "璉Show Diagnostic" })
-- fallback for languages without an action LSP
Keymap("n", "gs", function() Cmd.Telescope("treesitter") end, { desc = " Document Symbol" })

-- actions defined globally so null-ls can use them without LSP
Keymap({ "n", "x" }, "<leader>c", vim.lsp.buf.code_action, { desc = "璉Code Action" })

-- copy breadcrumbs (nvim navic)
Keymap("n", "<D-b>", function()
	if not require("nvim-navic").is_available() then
		vim.notify("No Breadcrumbs available.", LogWarn)
		return
	end
	local rawdata = require("nvim-navic").get_data()
	local breadcrumbs = ""
	for _, v in pairs(rawdata) do
		breadcrumbs = breadcrumbs .. v.name .. "."
	end
	breadcrumbs = breadcrumbs:sub(1, -2)
	Fn.setreg("+", breadcrumbs)
	vim.notify("COPIED\n" .. breadcrumbs)
end, { desc = "璉Copy Breadcrumbs" })

Autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities
		-- stylua: ignore start

		-- overrides treesitter-refactor's rename
		if capabilities.renameProvider then
			-- cannot run `cmd.IncRename` since the plugin *has* to use the
			-- command line; needs defer to not be overwritten by treesitter-
			-- refactor's smart-rename
			---@diagnostic disable-next-line: param-type-mismatch
			vim.defer_fn(function() Keymap("n", "<leader>v", ":IncRename ", { desc = "璉IncRename Variable", buffer = true}) end, 1)
		end

		-- conditional to not overwrite treesitter goto-symbol
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			Keymap("n", "gs", function() Cmd.Telescope("lsp_document_symbols") end, { desc = "璉Document Symbols", buffer = true }) -- overrides treesitter symbols browsing
			Keymap("n", "gS", function() Cmd.Telescope("lsp_workspace_symbols") end, { desc = "璉Workspace Symbols", buffer = true })
		end

		Keymap("n", "gd", function() Cmd.Telescope("lsp_definitions") end, { desc = "璉Goto Definition", buffer = true })
		Keymap("n", "gf", function() Cmd.Telescope("lsp_references") end, { desc = "璉Goto Reference", buffer = true })
		Keymap("n", "gy", function() Cmd.Telescope("lsp_type_definitions") end, { desc = "璉Goto Type Definition", buffer = true })
		Keymap({ "n", "i", "x" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "璉Signature", buffer = true })
		Keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "璉Hover", buffer = true })
		-- stylua: ignore end

		-- Save & Format
		Keymap({ "n", "i", "x" }, "<D-s>", function()
			Cmd.update()
			vim.lsp.buf.format()
		end, { buffer = true, desc = "璉Save & Format" })
	end,
})

-- copy breadcrumbs (nvim navic)
Keymap("n", "<D-b>", function()
	if require("nvim-navic").is_available() then
		local rawdata = require("nvim-navic").get_data()
		local breadcrumbs = ""
		for _, v in pairs(rawdata) do
			breadcrumbs = breadcrumbs .. v.name .. "."
		end
		breadcrumbs = breadcrumbs:sub(1, -2)
		Fn.setreg("+", breadcrumbs)
		vim.notify("COPIED\n" .. breadcrumbs)
	else
		vim.notify("No Breadcrumbs available.", LogWarn)
	end
end, { desc = "璉Copy Breadcrumbs" })

--------------------------------------------------------------------------------
-- GIT

-- Neogit
Keymap("n", "<leader>gn", Cmd.Neogit, { desc = " Neogit" })
Keymap("n", "<leader>gc", ":Neogit commit<CR>", { desc = " Commit (Neogit)" })

-- Gitsigns
Keymap("n", "<leader>ga", ":Gitsigns stage_hunk<CR>", { desc = " Add Hunk" })
Keymap("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = " Preview Hunk" })
Keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = " Reset Hunk" })
Keymap("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = " Blame Line" })

-- Telescope
-- stylua: ignore
Keymap("n", "<leader>gs", function() Cmd.Telescope("git_status") end, { desc = " Status (Telescope)" })
Keymap("n", "<leader>gl", function() Cmd.Telescope("git_commits") end, { desc = " Log (Telescope)" })

-- My utils
-- stylua: ignore start
Keymap({ "n", "x" }, "<leader>gh", function () require("funcs.git-utils").githubLink() end, { desc = " GitHub Link" })
Keymap("n", "<leader>gg", function () require("funcs.git-utils").addCommitPush() end, { desc = " Add-Commit-Push" })
Keymap("n", "<leader>gi", function () require("funcs.git-utils").issueSearch() end, { desc = " Issues" })
Keymap("n", "<leader>gm", function () require("funcs.git-utils").amendNoEditPushForce() end, { desc = " Amend-No-Edit & Force Push" })
Keymap("n", "<leader>gM", function () require("funcs.git-utils").amendAndPushForce() end, { desc = " Amend & Force Push" })
-- stylua: ignore end

-- Diffview
Keymap("n", "<leader>gd", function()
	vim.ui.input({ prompt = "Git Pickaxe (empty = full history)" }, function(query)
		if not query then return end
		if query ~= "" then query = string.format(" -G'%s'", query) end
		Cmd("DiffviewFileHistory %" .. query)
		Cmd.wincmd("w") -- go directly to file window
		Cmd.wincmd("|") -- maximize
	end)
end, { desc = " File History (Diffview)" })

--------------------------------------------------------------------------------

-- Option Toggling
Keymap("n", "<leader>or", ":set relativenumber!<CR>", { desc = " Toggle Relative Line Numbers" })
Keymap("n", "<leader>on", ":set number!<CR>", { desc = " Toggle Line Numbers" })
Keymap("n", "<leader>ow", qol.toggleWrap, { desc = " Toggle Wrap" })
Keymap("n", "<leader>ol", Cmd.LspRestart, { desc = " 璉LSP Restart" })
Keymap("n", "<leader>od", function()
	if vim.g.diagnosticOn == nil then vim.g.diagnosticOn = true end
	if vim.g.diagnosticOn then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	vim.g.diagnosticOn = not vim.g.diagnosticOn
end, { desc = " 璉 Toggle Diagnostics" })

--------------------------------------------------------------------------------

-- TERMINAL & CODE RUNNER
Keymap("t", "<S-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
Keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste in Terminal Mode" })

Keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = " ToggleTerm" })
-- stylua: ignore
Keymap( "x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = "  Run Selection in ToggleTerm" })

Keymap("n", "7", function()
	local isCodiBuffer = Bo.buftype ~= ""
	if isCodiBuffer then
		Cmd.CodiExpand() -- multiline output for the current line
	else
		Cmd.CodiNew()
		vim.api.nvim_buf_set_name(0, "Codi: " .. Bo.filetype)
	end
end, { desc = " Codi" })

--------------------------------------------------------------------------------

-- q / Esc to close special windows
Autocmd("FileType", {
	pattern = {
		"help",
		"lspinfo",
		"tsplayground",
		"qf",
		"lazy",
		"notify",
		"AppleScriptRunOutput",
		"DressingSelect", -- done here and not as dressing keybinding to be able to set `nowait`
		"DressingInput",
		"man",
	},
	callback = function()
		local opts = { buffer = true, nowait = true, desc = "close" }
		Keymap("n", "<Esc>", Cmd.close, opts)
		Keymap("n", "q", Cmd.close, opts)
	end,
})

-- remove the waiting time from the q, due to conflict with `qq` for comments
Autocmd("FileType", {
	pattern = { "ssr", "TelescopePrompt", "harpoon" },
	callback = function()
		local opts = { buffer = true, nowait = true, remap = true, desc = "close" }
		if Bo.filetype == "ssr" then
			Keymap("n", "q", "Q", opts)
		elseif Bo.filetype == "harpoon" then
			-- HACK 1ms delay ensures it comes later in the autocmd stack and takes effect
			---@diagnostic disable-next-line: param-type-mismatch
			vim.defer_fn(function() Keymap("n", "q", "<Esc>", opts) end, 1)
		elseif Bo.filetype == "TelescopePrompt" then
			Keymap("n", "q", "<Esc>", opts)
		end
	end,
})

--------------------------------------------------------------------------------

-- spider moves
Keymap({ "o", "x" }, "w", function() require("spider").motion("w") end, { desc = "Spider-w" })
Keymap({ "o", "x" }, "e", function() require("spider").motion("e") end, { desc = "Spider-e" })
Keymap({ "o", "x" }, "b", function() require("spider").motion("b") end, { desc = "Spider-b" })
Keymap({ "n", "o", "x" }, "ge", function() require("spider").motion("ge") end, { desc = "Spider-ge" })

-- Simple version of the delaytrain.nvim
for _, key in ipairs { "x", "h", "l", "e", "b", "w" } do
	local timeout = 3000
	local maxUsage = 8

	local count = 0
	Keymap("n", key, function()
		if key == "x" then
			Normal([["_x]])
		elseif key == "e" or key == "b" or key == "w" then
			require("spider").motion(key)
			return
		end

		-- abort when recording, since this only leads to bugs then
		if Fn.reg_recording() ~= "" or Fn.reg_executing() ~= "" then return end

		if count <= maxUsage then
			count = count + 1
			vim.defer_fn(function() count = count - 1 end, timeout) ---@diagnostic disable-line: param-type-mismatch
			Normal(key)
		end
	end, { desc = key .. " (delaytrain)" })
end

--------------------------------------------------------------------------------


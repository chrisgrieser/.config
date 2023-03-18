require("config.utils")
local qol = require("funcs.quality-of-life")
--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = " Keymaps" })
-- stylua: ignore
keymap( "n", "g?", function()
	require("telescope.builtin").keymaps { prompt_title = " Buffer Keymaps", only_buf = true }
end, { desc = " Buffer Keymaps" })

-- Theme Picker
keymap("n", "<leader>T", function() cmd.Telescope("colorscheme") end, { desc = " Colorschemes" })

-- Highlights
keymap("n", "<leader>H", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- Update [P]lugins
keymap("n", "<leader>p", require("lazy").sync, { desc = ":Lazy sync" })
keymap("n", "<leader>P", require("lazy").home, { desc = ":Lazy home" })
keymap("n", "<leader>M", cmd.Mason, { desc = ":Mason" })

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":"):gsub("^I ", "") -- remove `I ` from my inspect command
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "גּ Copy last command" })

-- [l]ast command [a]gain
-- as opposed to `@:`, this works across restarts of neovim
keymap("n", "<leader>la", ":<Up><CR>", { desc = "גּ Run last command again" })

-- copy [l]ast [n] notification
keymap("n", "<leader>ln", function()
	local history = require("notify").history()
	local lastNotify = history[#history]
	local msg = table.concat(lastNotify.message, "\n")
	fn.setreg("+", msg)
	vim.notify("Last Notification copied.", logTrace)
end, { desc = "גּ Copy Last Notification" })

-- Dismiss notifications
keymap("n", "<Esc>", function()
	if not vim.g.neovide then return end -- notify.nvim not loaded for Terminal
	local clearPending = require("notify").pending() > 10
	require("notify").dismiss { pending = clearPending }
end, { desc = "Clear Notifications" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap({ "n", "x", "o" }, "L", "$")

keymap({ "n", "x" }, "J", "6j")
keymap({ "n", "x" }, "K", "6k")

keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "K", "2k")

-- JUMP HISTORY
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- SEARCH
keymap({ "n", "o" }, "-", "/", { desc = "Search" })
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })
keymap("n", "+", "*", { desc = "Search word under cursor" })
keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "Visual star" })

-- automatically do `:nohl` when done with search https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	if fn.mode() == "n" then
		local originalSearchRelatedKeys = { "<CR>", "n", "N", "*", "#", "?", "/" }
		local new_hlsearch = vim.tbl_contains(originalSearchRelatedKeys, fn.keytrans(char))
		if opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
	end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

-- MARKS
-- stylua: ignore
keymap("n", "ä", function() require("funcs.mark-cycler").gotoMark() end, { desc = "Goto Next Mark" })
keymap("n", "Ä", function() require("funcs.mark-cycler").setMark() end, { desc = "Set Next Mark" })

-- reset marks on startup (needs to be on VimEnter so it's not called too early)
autocmd("VimEnter", {
	callback = function() require("funcs.mark-cycler").clearMarks() end,
})

-- HUNKS AND CHANGES
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })
keymap("n", "gc", "g;", { desc = "goto next change" })
keymap("n", "gC", "g,", { desc = "goto previous change" })

-- [M]atchIt
-- remap needed, since using the builtin matchit plugin
keymap("n", "m", "%", { remap = true, desc = "MatchIt" })

--------------------------------------------------------------------------------

-- FOLDING
-- with count: close {n} fold levels
-- without toggle current fold
keymap("n", "^", function()
	if vim.v.count == 0 then
		normal("za")
	else
		require("ufo").closeFoldsWith(vim.v.count - 1) -- -1 as topmost is foldlevel 0
	end
end, { desc = "ﬕ Toggle fold / Close {n} foldlevels" })
keymap("n", "zR", function() require("ufo").openAllFolds() end, { desc = "  Open all folds" })
keymap("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "  Close all folds" })
keymap("n", "zz", ":%foldclose<CR>zo", { desc = "ﬕ Close toplevel folds" })

--------------------------------------------------------------------------------
-- EDITING

-- NUMBERS
keymap("n", "<M-a>", "10<C-a>", { desc = "+ 10" })
keymap("n", "<M-x>", "10<C-x>", { desc = "- 10" })

-- QUICKFIX
keymap("n", "gq", require("funcs.quickfix").next, { desc = " Next Quickfix" })
keymap("n", "gQ", require("funcs.quickfix").previous, { desc = " Previous Quickfix" })
keymap("n", "dQ", require("funcs.quickfix").deleteList, { desc = " Delete Quickfix List" })
-- stylua: ignore
keymap("n", "<leader>q", function() require("replacer").run { rename_files = false } end, { desc = " Replacer.nvim" })

-- COMMENTS & ANNOTATIONS
keymap("n", "qw", qol.commentHr, { desc = "Horizontal Divider" })
keymap("n", "qd", "Rkqqj", { desc = "Duplicate Line as Comment", remap = true })
-- stylua: ignore
keymap("n", "qf", function() require("neogen").generate() end, { desc = "Neogen: Comment Function" })

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "add blank line above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "add blank line below" })
keymap("n", "<Tab>", ">>", { desc = " indent" })
keymap("n", "<S-Tab>", "<<", { desc = " outdent" })
keymap("x", "<Tab>", ">gv", { desc = " indent" })
keymap("x", "<S-Tab>", "<gv", { desc = " outdent" })

-- Word Switcher
keymap(
	"n",
	"<BS>",
	function() require("funcs.word-switcher").switch() end,
	{ desc = "switch common words" }
)

-- Append to / delete from EoL
local trailingKeys = { ",", ";", '"', "'", ")", "}", "]", "\\" }
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = v .. " to EoL" })
end
keymap("n", "X", "mz$x`z", { desc = "delete last character" })

--------------------------------------------------------------------------------

-- SPELLING

-- [z]pelling [l]ist
keymap("n", "zl", function() cmd.Telescope("spell_suggest") end, { desc = "暈suggest" })
keymap("n", "za", "mz]s1z=`z", { desc = "暈autofix" }) -- [a]utofix word under cursor

---add word under cursor to vale dictionary
---@param mode string accept|reject
local function valeWord(mode)
	local word = expand("<cword>")
	local success = AppendToFile(word, LinterConfig .. "/vale/styles/Vocab/Docs/" .. mode .. ".txt")
	if not success then return end -- error message already by AppendToFile
	cmd.edit() -- reload file for diagnostics to take effect
	vim.notify("暈Now " .. mode .. "ing:\n" .. word)
end
keymap("n", "zg", function() valeWord("accept") end, { desc = "暈Add to accepted words (vale)" })
keymap("n", "zw", function() valeWord("reject") end, { desc = "暈Add to rejected words (vale)" })

--------------------------------------------------------------------------------

-- [S]ubstitute Operator (substitute.nvim)
keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
-- stylua: ignore
keymap( "n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange operator" })
keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

-- Node S[w]apping
-- stylua: ignore start
keymap("n", "ü", function () require('sibling-swap').swap_with_right() end, { desc = "壟 Move Node Right" })
keymap("n", "Ü", function () require('sibling-swap').swap_with_left() end, { desc = "鹿 Move Node Left" })

autocmd("FileType", {
	pattern = {"markdown", "text", "gitcommit"},
	callback = function()
		keymap("n", "ü", '"zdawel"zph', { desc = "壟 Move Word Right", buffer = true })
		keymap("n", "Ü", '"zdawbh"zph', { desc = "鹿 Move Word Left", buffer = true })
	end,
})
-- stylua: ignore end

--------------------------------------------------------------------------------

-- search & replace
keymap(
	"n",
	"<leader>f",
	[[:%s/<C-r>=expand("<cword>")<CR>//gI<Left><Left><Left>]],
	{ desc = "弄 :substitute" }
)
keymap("x", "<leader>f", ":s///gI<Left><Left><Left><Left>", { desc = "substitute" })
keymap(
	{ "n", "x" },
	"<leader>F",
	function() require("ssr").open() end,
	{ desc = "弄 Structural search & replace" }
)
keymap("n", "<leader>n", ":%normal ", { desc = "弄 :normal" })
keymap("x", "<leader>n", ":normal ", { desc = "弄 :normal" })

-- Refactor
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>i", function() require("refactoring").refactor("Inline Variable") end, { desc = "弄 Inline Variable" })
keymap({ "n", "x" }, "<leader>e", function() require("refactoring").refactor("Extract Variable") end, { desc = "弄 Extract Variable" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "碑 redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "碑 undo specific durations" })
keymap("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "碑 Undotree" })

-- Logging & Debugging
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.quick-log").log() end, { desc = " log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.quick-log").objectlog() end, { desc = " object log" })
keymap("n", "<leader>lb", function() require("funcs.quick-log").beeplog() end, { desc = " beep log" })
keymap("n", "<leader>lt", function() require("funcs.quick-log").timelog() end, { desc = " time log" })
keymap("n", "<leader>lr", function() require("funcs.quick-log").removelogs() end, { desc = "  remove log" })
keymap("n", "<leader>ld", function() require("funcs.quick-log").debuglog() end, { desc = " debugger" })
-- stylua: ignore end

-- Sort & highlight duplicate lines
-- stylua: ignore
keymap( { "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "弄 Sort (+ highlight duplicates)" })

-- Replace Mode
-- needed, since `R` mapped to duplicate line
keymap("n", "cR", "R", { desc = "Replace Mode" })

-- URL Opening (forward-seeking `gx`)
keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = fn.mode():find("v") -- will only switch to visual mode if URL found
	if foundURL then
		normal([["zy]])
		local url = fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = " Smart URL Opener" })

--------------------------------------------------------------------------------

-- Line & Character Movement
keymap("n", "<Down>", qol.moveLineDown)
keymap("n", "<Up>", qol.moveLineUp)
keymap("x", "<Down>", qol.moveSelectionDown)
keymap("x", "<Up>", qol.moveSelectionUp)
keymap("n", "<Right>", qol.moveCharRight)
keymap("n", "<Left>", qol.moveCharLeft)
keymap("x", "<Right>", qol.moveSelectionRight)
keymap("x", "<Left>", qol.moveSelectionLeft)

-- Merging / Splitting Lines
keymap({ "n", "x" }, "M", "J", { desc = "merge line up" })
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "merge line down" })
keymap("n", "<leader>s", cmd.TSJToggle, { desc = "split/join" })

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-k>", "<Esc>lDi") -- kill line
keymap("i", "<C-a>", "<Esc>I") -- BoL
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "vv from Normal Mode starts Visual Block Mode" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

-- for consistency with terminal buffers also <S-CR>
-- stylua: ignore start
keymap("n", "<S-CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })
keymap("n", "<CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })

keymap({ "n", "x", "i" }, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "close buffer/window" })
keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " Open Buffers" })
-- stylua: ignore end

keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize (+)" }) -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize (-)" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize (+)" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize (-)" })

-- Harpoon
keymap("n", "<D-CR>", function() require("harpoon.ui").nav_next() end, { desc = "ﯠ Next" })
-- stylua: ignore start
-- consistent with adding/removing bookmarks in the Browser/Obsidian
keymap("n", "<D-d>", function() require("harpoon.mark").add_file() end, { desc = "ﯠ Add File" })
keymap("n", "<D-S-d>", function() require("harpoon.ui").toggle_quick_menu() end, { desc = "ﯠ Menu" })
-- stylua: ignore end

------------------------------------------------------------------------------

-- CMD-KEYBINDINGS
keymap({ "n", "x", "i" }, "<D-s>", cmd.update, { desc = "save" }) -- cmd+s, will be overridden on lsp attach

-- stylua: ignore
keymap({ "n", "x" }, "<D-l>", function() fn.system("open -R '" .. expand("%:p") .. "'") end, { desc = " Reveal in Finder" })

keymap("n", "<D-0>", ":10messages<CR>", { desc = ":messages (last 10)" }) -- as cmd.function these wouldn't require confirmation
keymap("n", "<D-9>", ":Notifications<CR>", { desc = ":Notifications" })

-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
g.VM_maps = {
	["Find Under"] = "<D-j>", -- select word under cursor & enter visual-multi (normal) / add next occurrence (visual-multi)
	["Visual Add"] = "<D-j>", -- enter visual-multi (visual)
	["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi)
}

--- copy & paste
keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
keymap("i", "<D-v>", "<C-g>u<C-r><C-o>+", { desc = "paste" }) -- "<C-g>u" adds undopoint before the paste
keymap("x", "<D-c>", "y", { desc = "copy" }) -- needed for compatibility with automation apps

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

-- cmd+t: template string
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String" }) -- no selection = word under cursor
keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String" })
keymap("i", "<D-t>", "${}<Left>", { desc = "Template String" })

--------------------------------------------------------------------------------

-- COLOR PICKER
keymap("n", "#", ":CccPick<CR>", { desc = " Color Picker" })
keymap("n", "'", ":CccConvert<CR>", { desc = " Convert Color" }) -- shift-# on German keyboard

--------------------------------------------------------------------------------
-- FILES

-- number of harpoon files in the current project
---@return number|nil
local function harpoonFileNumber()
	local pwd = vim.loop.cwd()
	local jsonPath = fn.stdpath("data") .. "/harpoon.json"
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
keymap("n", "go", function()
	local pwd = vim.loop.cwd() or ""
	local projectName = pwd:gsub(".*/", "")
	local harpoonNumber = harpoonFileNumber() or 0
	local title = tostring(harpoonNumber) .. "ﯠ " .. projectName
	require("telescope").extensions.file_browser.file_browser { prompt_title = title }
end, { desc = " Browse in Project" })

keymap("n", "gO", function()
	local thisFolder = expand("%:p:h")
	require("telescope").extensions.file_browser.file_browser { path = thisFolder }
end, { desc = " Browse in Folder" })
keymap("n", "gF", function() cmd.Telescope("live_grep") end, { desc = " ripgrep folder" })
keymap("n", "gr", function() cmd.Telescope("oldfiles") end, { desc = " Recent Files" })

-- File Operations
-- stylua: ignore start
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = " Copy filepath" })
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = " Copy filename" })
keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = " chmod +x" })
keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = " Rename file" })
keymap("n", "<D-S-m>", function() require("genghis").moveAndRenameFile() end, { desc = " Move-rename file" })
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = " Duplicate file" })
keymap("n", "<D-BS>", function() require("genghis").trashFile() end, { desc = " Move file to trash" })
keymap("n", "<D-n>", function() require("genghis").createNewFile() end, { desc = " Create new file" })
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = " Selection to new file" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- stylua: ignore start
keymap("n", "ge", function() vim.diagnostic.goto_next { wrap = true, float = true } end, { desc = "璉Next Diagnostic" })
keymap("n", "gE", function() vim.diagnostic.goto_prev { wrap = true, float = true } end, { desc = "璉Previous Diagnostic" })
-- stylua: ignore end

keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "璉Show Diagnostic" })
-- fallback for languages without an action LSP
keymap("n", "gs", function() cmd.Telescope("treesitter") end, { desc = " Document Symbol" })

-- actions defined globally so null-ls can use them without LSP
keymap({ "n", "x" }, "<leader>c", vim.lsp.buf.code_action, { desc = "璉Code Action" })

-- copy breadcrumbs (nvim navic)
keymap("n", "<D-b>", function()
	if not require("nvim-navic").is_available() then
		vim.notify("No Breadcrumbs available.", logWarn)
		return
	end

	local rawdata = require("nvim-navic").get_data()
	local breadcrumbs = ""
	for _, v in pairs(rawdata) do
		breadcrumbs = breadcrumbs .. v.name .. "."
	end
	breadcrumbs = breadcrumbs:sub(1, -2)
	fn.setreg("+", breadcrumbs)
	vim.notify("COPIED\n" .. breadcrumbs)
end, { desc = "璉Copy Breadcrumbs" })

autocmd("LspAttach", {
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
			vim.defer_fn(function() keymap("n", "<leader>v", ":IncRename ", { desc = "璉IncRename Variable", buffer = true}) end, 1)
		end

		-- conditional to not overwrite treesitter goto-symbol
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			keymap("n", "gs", function() cmd.Telescope("lsp_document_symbols") end, { desc = "璉Document Symbols", buffer = true }) -- overrides treesitter symbols browsing
			keymap("n", "gS", function() cmd.Telescope("lsp_workspace_symbols") end, { desc = "璉Workspace Symbols", buffer = true })
		end

		keymap("n", "gd", function() cmd.Telescope("lsp_definitions") end, { desc = "璉Goto Definition", buffer = true })
		keymap("n", "gf", function() cmd.Telescope("lsp_references") end, { desc = "璉Goto Reference", buffer = true })
		keymap("n", "gy", function() cmd.Telescope("lsp_type_definitions") end, { desc = "璉Goto Type Definition", buffer = true })
		keymap({ "n", "i", "x" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "璉Signature", buffer = true })
		keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "璉Hover", buffer = true })
		-- stylua: ignore end

		-- Save & Format
		keymap({ "n", "i", "x" }, "<D-s>", function()
			cmd.update()
			vim.lsp.buf.format { async = true }
		end, { buffer = true, desc = "璉Save & Format" })
	end,
})

-- copy breadcrumbs (nvim navic)
keymap("n", "<D-b>", function()
	if require("nvim-navic").is_available() then
		local rawdata = require("nvim-navic").get_data()
		local breadcrumbs = ""
		for _, v in pairs(rawdata) do
			breadcrumbs = breadcrumbs .. v.name .. "."
		end
		breadcrumbs = breadcrumbs:sub(1, -2)
		fn.setreg("+", breadcrumbs)
		vim.notify("COPIED\n" .. breadcrumbs)
	else
		vim.notify("No Breadcrumbs available.", logWarn)
	end
end, { desc = "璉Copy Breadcrumbs" })

--------------------------------------------------------------------------------
-- GIT

keymap("n", "<leader>gn", cmd.Neogit, { desc = " Commit (Neogit)" })
keymap("n", "<leader>gc", ":Neogit commit<CR>", { desc = " Commit (Neogit)" })
keymap("n", "<leader>ga", ":Gitsigns stage_hunk<CR>", { desc = " Add Hunk" })
keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = " Reset Hunk" })
keymap("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = " Blame Line" })

keymap(
	"n",
	"<leader>gs",
	function() cmd.Telescope("git_status") end,
	{ desc = " Status (Telescope)" }
)
keymap("n", "<leader>gl", function() cmd.Telescope("git_commit") end, { desc = " Log (Telescope)" })

-- stylua: ignore start
keymap({ "n", "x" }, "<leader>gl", function () require("funcs.git-utils").gitLink() end, { desc = " Link" })
keymap("n", "<leader>gg", function () require("funcs.git-utils").addCommitPush() end, { desc = " Add-Commit-Push" })
keymap("n", "<leader>gi", function () require("funcs.git-utils").issueSearch() end, { desc = " Issues" })
keymap("n", "<leader>gm", function () require("funcs.git-utils").amendAndPushForce("no-edit") end, { desc = " Amend-No-Edit & Force Push" })
keymap("n", "<leader>gM", function () require("funcs.git-utils").amendAndPushForce("edit") end, { desc = " Amend & Force Push" })
-- stylua: ignore end

-- Diffview
keymap("n", "<leader>gd", function()
	vim.ui.input({ prompt = "Git Pickaxe (empty = full history)" }, function(query)
		if not query then return end
		if query ~= "" then query = string.format(" -G'%s'", query) end
		cmd("DiffviewFileHistory %" .. query)
		cmd.wincmd("w") -- go directly to file window
		cmd.wincmd("|") -- maximize
	end)
end, { desc = " File History (Diffview)" })

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>or", ":set relativenumber!<CR>", { desc = " Toggle Relative Line Numbers" })
keymap("n", "<leader>on", ":set number!<CR>", { desc = " Toggle Line Numbers" })
keymap("n", "<leader>ow", qol.toggleWrap, { desc = " Toggle Wrap" })
keymap("n", "<leader>ol", cmd.LspRestart, { desc = " 璉LSP Restart" })
keymap("n", "<leader>od", function()
	if g.diagnosticOn == nil then g.diagnosticOn = true end
	if g.diagnosticOn then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	g.diagnosticOn = not g.diagnosticOn
end, { desc = " 璉 Toggle Diagnostics" })

--------------------------------------------------------------------------------

-- TERMINAL & CODE RUNNER
keymap("t", "<S-CR>", [[<C-\><C-n><C-w>w]], { desc = " go to next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste in Terminal Mode" })

keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = " ToggleTerm" })
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = " Selection to ToggleTerm" })

-- stylua: ignore start
keymap({"n", "x"}, "5", function() require("iron.core").repl_for(bo.filetype) end, { desc = " Toggle REPL (Iron)" })
keymap("n", "4", function() require("iron.core").send_line() end, { desc = " Send Line to REPL (Iron)" })
keymap("x", "4", function() require("iron.core").visual_send() end, { desc = " Send Selection to REPL (Iron)" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- q / Esc to close special windows
augroup("quickClose", {})
autocmd("FileType", {
	group = "quickClose",
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
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

-- remove the waiting time from the q, due to conflict with `qq` for comments
autocmd("FileType", {
	group = "quickClose",
	pattern = { "ssr", "TelescopePrompt", "harpoon" },
	callback = function()
		local opts = { buffer = true, nowait = true, remap = true, desc = "close" }
		if bo.filetype == "ssr" then
			keymap("n", "q", "Q", opts)
		elseif bo.filetype == "harpoon" then
			-- HACK 1ms delay ensures it comes later in the autocmd stack and takes effect
			---@diagnostic disable-next-line: param-type-mismatch
			vim.defer_fn(function() keymap("n", "q", "<Esc>", opts) end, 1)
		elseif bo.filetype == "TelescopePrompt" then
			keymap("n", "q", "<Esc>", opts)
		end
	end,
})

--------------------------------------------------------------------------------

-- Simple version of the delaytrain.nvim
-- CamelCaseMotion for e, w, and b
for _, key in ipairs { "x", "h", "l", "e", "w", "b" } do
	local timeout = 3000
	local maxUsage = 10

	local count = 0
	keymap("n", key, function()
		if key == "x" then
			key = [["_x]]
		elseif key == "e" or key == "w" or key == "b" then
			key = "<Plug>CamelCaseMotion_" .. key
		end

		-- abort when recording, since this only leads to bugs then
		local isRecording = fn.reg_recording() ~= ""
		local isPlaying = fn.reg_executing() ~= ""
		if isRecording or isPlaying then return end

		if count <= maxUsage then
			count = count + 1
			vim.defer_fn(function() count = count - 1 end, timeout) ---@diagnostic disable-line: param-type-mismatch
			return key
		end
	end, { expr = true, desc = key .. " (delaytrain)" })
end

--------------------------------------------------------------------------------

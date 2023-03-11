require("config.utils")
local qol = require("funcs.quality-of-life")
--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = " Keymaps" })

-- Theme Picker
keymap("n", "<leader>T", function() cmd.Telescope("colorscheme") end, { desc = " Colorschemes" })

-- Highlights
-- stylua: ignore
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
keymap("n", "<leader>la", "@:", { desc = "גּ Run last command again" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap({ "n", "x", "o" }, "L", "$")

keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap("x", "J", "6j")
keymap({ "n", "x" }, "K", "6k")

keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "K", "2k")

-- add overscroll
keymap("n", "j", function() qol.overscroll("j") end, { desc = "j (with overscroll)" })
keymap({ "n", "x" }, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- Search
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

-- Marks
-- stylua: ignore
keymap("n", "ä", function() require("funcs.mark-cycler").gotoMark() end, { desc = "Goto Next Mark" })
keymap("n", "Ä", function() require("funcs.mark-cycler").setMark () end, { desc = "Set Next Mark" })

-- reset marks on startup (needs to be on VimEnter so it's not called too early)
augroup("marks", {})
autocmd("VimEnter", {
	group = "marks",
	callback = function() require("funcs.mark-cycler").clearMarks() end,
})

--------------------------------------------------------------------------------

-- Dismiss notifications
keymap("n", "<Esc>", function()
	if not vim.g.neovide then return end -- notify.nvim not loaded for Terminal
	local clearPending = require("notify").pending() > 10
	require("notify").dismiss { pending = clearPending }
end, { desc = "Clear Notifications" })

-- FOLDING
keymap("n", "^", "za", { desc = "ﬕ toggle fold" })

-- [M]atchIt
-- remap needed, since using the builtin matchit plugin
keymap("n", "m", "%", { remap = true, desc = "MatchIt" }) 

-- HUNKS AND CHANGES
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })
keymap("n", "gc", "g;", { desc = "goto next change" })
keymap("n", "gC", "g,", { desc = "goto previous change" })

-- QUICKFIX
-- make cnext loop back https://vi.stackexchange.com/a/8535
-- stylua: ignore
keymap( "n", "gq", [[:silent try | cnext | catch | cfirst | catch | endtry<CR><CR>]], { desc = "Next Quickfix" })
keymap("n", "gQ", function() cmd.Telescope("quickfix") end, { desc = " Quickfix list" })
keymap("n", "dQ", function () cmd.cexpr("[]") end, { desc = "Clear Quickfix List" })

--------------------------------------------------------------------------------
-- EDITING

-- Comments & Annotations
keymap("n", "qw", qol.commentHr, { desc = "Horizontal Divider" })
keymap("n", "qd", "Rkqqj", { desc = "Duplicate Line as Comment", remap = true })
-- stylua: ignore
keymap("n", "qf", function() require("neogen").generate() end, { desc = "Neogen: Comment Function" })

-- Whitespace Control
keymap("n", "=", "mzO<Esc>`z", { desc = "add blank line above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "add blank line below" })
keymap("n", "<Tab>", ">>", { desc = " indent" })
keymap("n", "<S-Tab>", "<<", { desc = " outdent" })
keymap("x", "<Tab>", ">gv", { desc = " indent" })
keymap("x", "<S-Tab>", "<gv", { desc = " outdent" })

-- Casing
keymap("n", "ü", "mzlb~`z", { desc = "toggle capital/lowercase of word" })
keymap("n", "Ü", "gUiw", { desc = "uppercase word" })
keymap("n", "~", "~h")
keymap("n", "<BS>", qol.wordSwitch, { desc = "switch common words" })

-- Append to / delete from EoL
local trailingKeys = { ",", ";", '"', "'", ")", "}", "]", "\\" }
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = v .. " to EoL" })
end
keymap("n", "X", "mz$x`z", { desc = "delete last character" })

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", function() cmd.Telescope("spell_suggest") end, { desc = "暈suggest" })
keymap("n", "gl", "]s", { desc = "暈next misspelling" })
keymap("n", "gL", "]s", { desc = "暈prev misspelling" })
keymap("n", "za", "mz]s1z=`z", { desc = "暈autofix" }) -- [a]utofix word under cursor

-- [S]ubstitute Operator (substitute.nvim)
keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
-- stylua: ignore
keymap( "n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange operator" })
keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

-- IS[w]ap
keymap("n", "<leader>w", cmd.ISwapWith, { desc = "弄 swap nodes" })

-- search & replace
-- stylua: ignore start
keymap("n", "<leader>f", [[:%s/<C-r>=expand("<cword>")<CR>//gI<Left><Left><Left>]], { desc = "弄 :substitute" })
keymap("x", "<leader>f", ":s///gI<Left><Left><Left><Left>", { desc = "substitute" })
keymap({ "n", "x" }, "<leader>F", function() require("ssr").open() end, { desc = "弄 Structural search & replace" })
-- stylua: ignore end
keymap("n", "<leader>n", ":%normal ", { desc = "弄 :normal" })
keymap("x", "<leader>n", ":normal ", { desc = "弄 :normal" })

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "碑 redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "碑 undo specific durations" })
keymap("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "碑 Undotree" })

-- Refactor
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>i", function() require("refactoring").refactor("Inline Variable") end, { desc = "弄 Inline Variable" })
keymap({ "n", "x" }, "<leader>e", function() require("refactoring").refactor("Extract Variable") end, { desc = "弄 Extract Variable" })
-- stylua: ignore end

-- Logging & Debugging
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.log").objectlog() end, { desc = " log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.quick-log").objectlog() end, { desc = " object log" })
keymap("n", "<leader>lb", function() require("funcs.quick-log").beeplog() end, { desc = " beep log" })
keymap("n", "<leader>lt", function() require("funcs.quick-log").timelog() end, { desc = " time log" })
keymap("n", "<leader>lr", function() require("funcs.quick-log").removelogs() end, { desc = "  remove log" })
keymap("n", "<leader>ld", function() require("funcs.quick-log").debuglog() end, { desc = " debugger" })
-- stylua: ignore end

-- Sort & highlight duplicate lines
-- stylua: ignore
keymap( { "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "弄 Sort (+ highlight duplicates)" })

-- URL Opening (forward-seeking `gx`)
keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = fn.mode():find("v")
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

keymap("n", "<S-CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })
keymap("n", "<CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "switch to alt buffer/window" })

keymap({ "n", "x", "i" }, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "close buffer/window/tab" })
keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " Open Buffers" })

keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize (+)" }) -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize (-)" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize (+)" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize (-)" })

-- Harpoon
keymap("n", "<D-CR>", function() require("harpoon.ui").nav_next() end, { desc = "ﯠ Next" })
-- stylua: ignore start
keymap("n", "g<CR>", function() require("harpoon.ui").toggle_quick_menu() end, { desc = "ﯠ Menu" })
keymap("n", "<leader><CR>", function() require("harpoon.mark").add_file() end, { desc = "ﯠ Add File" })
-- stylua: ignore end

------------------------------------------------------------------------------

-- CMD-Keybindings
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

-- Color Picker
keymap("n", "#", ":CccPick<CR>", {desc = " Color Picker"})
keymap("n", "'", ":CccConvert<CR>", {desc = " Convert Color"}) -- shift-# on German keyboard

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
	require("telescope.builtin").find_files { prompt_title = title }
end, { desc = " Open File in Project" })

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
-- GIT

-- Neo[G]it
keymap("n", "<leader>gs", ":Neogit<CR>", { desc = " Neogit" })
keymap("n", "<leader>gc", ":Neogit commit<CR>", { desc = " Commit" })
keymap("n", "<leader>ga", ":Gitsigns stage_hunk<CR>", { desc = " Add Hunk" })
keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = " Reset Hunk" })
keymap("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = " Blame Line" })

-- my custom functions
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>gl", function () require("funcs.git-utils").gitLink() end, { desc = " GitHub Link" })
keymap("n", "<leader>gg", function () require("funcs.git-utils").addCommitPush() end, { desc = " Add-Commit-Push" })
keymap("n", "<leader>gi", function () require("funcs.git-utils").issueSearch() end, { desc = " GitHub Issues" })
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
keymap("n", "<leader>os", ":set spell!<CR>", { desc = " Toggle Spelling" })
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

-- TERMINAL AND CODI
keymap("t", "<S-CR>", [[<C-\><C-n><C-w>w]], { desc = " go to next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste in Terminal Mode" })

keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = " ToggleTerm" })
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = " Selection to ToggleTerm" })

keymap("n", "5", function()
	cmd.CodiNew()
	cmd.file("Codi: " .. bo.filetype) -- HACK to set buffername, since Codi does not provide a filename for its buffer
end, { desc = ":CodiNew" })

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
	local timeout = 4000
	local maxUsage = 8

	local count = 0
	keymap("n", key, function()
		if key == "x" then
			key = [["_x]]
		elseif key == "e" or key == "w" or key == "b" then
			key = "<Plug>CamelCaseMotion_" .. key
		end

		if fn.reg_executing() ~= "" then return key end

		if count <= maxUsage then
			count = count + 1
			vim.defer_fn(function() count = count - 1 end, timeout) ---@diagnostic disable-line: param-type-mismatch
			return key
		end
	end, { expr = true, desc = key .. " (delaytrain)" })
end

--------------------------------------------------------------------------------

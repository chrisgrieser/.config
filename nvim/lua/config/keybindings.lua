local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = "⌨️  Search Keymaps" })

keymap("n", "<D-,>", function()
	local thisFilePath = debug.getinfo(1).source:sub(2)
	vim.cmd.edit(thisFilePath)
end, { desc = "⌨️ Edit keybindings.lua" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- - HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- `0` ensures fully scrolling to the left on long indented lines
keymap({ "n", "x" }, "L", "$") -- not using "o", since used for link textobj
keymap({ "n", "x" }, "J", "6gj") -- - work on visual lines instead of logical ones for when wrapping is one
keymap({ "n", "x" }, "K", "6gk")

-- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "J", "2j")
keymap("o", "K", "2k")

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- visual instead of logcial lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- Simplified Marks
-- INFO a custom lualine component shows what is currently marked
keymap("n", "ä", "'M", { desc = " Goto Mark" })

keymap("n", "Ä", function()
	u.normal("mM")
	vim.notify(" Mark set.", u.trace)
end, { desc = " Set Mark" })

keymap("n", "dä", function()
	vim.api.nvim_del_mark("M")
	vim.notify(" Mark deleted.", u.trace)
end, { desc = " Delete Mark" })

-- Hunks and Changes
keymap("n", "gh", "<cmd>Gitsigns next_hunk<CR>zv", { desc = "󰊢 Next Hunk" })
keymap("n", "gH", "<cmd>Gitsigns prev_hunk<CR>zv", { desc = "󰊢 Previous Hunk" })
keymap("n", "gc", "g;", { desc = "Goto last change" })

-- Goto brackets
keymap("n", "m", "<Plug>(MatchitNormalForward)", { desc = "Goto Matching Bracket" })

-- pattern-matching, so not super reliable when it comes to unmatched stuff
-- DOCS https://github.com/chrisbra/matchit/blob/master/doc/matchit.txt#L38
keymap("n", "^", "<Plug>(MatchitNormalMultiForward)", { desc = "Goto Unmatched Bracket" })

--------------------------------------------------------------------------------

-- SEARCH
keymap("n", "-", "/", { desc = "Search word under cursor" })
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })
keymap("n", "+", "*", { desc = "Search word under cursor" })
keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "* Visual Star" })

-- auto-nohl -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	if vim.g.scrollview_refreshing then return end -- FIX: https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161
	local searchKeys = { "n", "N", "*", "#" }
	local searchConfirmed = (fn.keytrans(char) == "<CR>" and fn.getcmdtype():find("[/?]") ~= nil)
	if searchConfirmed or (fn.mode() == "n") then
		local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
		if searchKeyUsed or searchConfirmed then require("hlslens").start() end
		---@diagnostic disable-next-line: param-type-mismatch
		if vim.opt.hlsearch:get() ~= searchKeyUsed then vim.opt.hlsearch = searchKeyUsed end
	end
end, vim.api.nvim_create_namespace("auto_nohl"))

autocmd("CmdlineEnter", {
	callback = function()
		if fn.getcmdtype():find("[/?]") then vim.opt.hlsearch = true end
	end,
})

--------------------------------------------------------------------------------
-- EDITING

-- QUICKFIX
keymap("n", "gq", require("funcs.quickfix").next, { desc = " Next Quickfix" })
keymap("n", "gQ", require("funcs.quickfix").previous, { desc = " Previous Quickfix" })
keymap("n", "dQ", require("funcs.quickfix").deleteList, { desc = " Empty Quickfix List" })

-- COMMENTS & ANNOTATIONS
keymap("n", "qw", require("funcs.comment-divider").commentHr, { desc = " Horizontal Divider" })
keymap("n", "wq", '"zyy"zpkqqj', { desc = " Duplicate Line as Comment", remap = true })

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })

keymap("n", "X", "mz$x`z", { desc = "Delete char at EoL" })

keymap("n", "~", "~h", { desc = "Toggle Case (w/o moving)" })

-- Word Flipper
-- stylua: ignore
keymap( "n", "ö", function() require("funcs.flipper").flipWord() end, { desc = "flip words / toggle casing" })

-- [O]pen new Scope
keymap({ "n", "i" }, "<D-o>", function()
	local line = vim.api.nvim_get_current_line()
	line = line:gsub(" $", "") .. " {" -- only appends space if there is none already
	vim.api.nvim_set_current_line(line)
	local ln = u.getCursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" })
	u.setCursor(0, { ln + 1, 1 }) -- go line down
	cmd.startinsert { bang = true }
end, { desc = " Open new scope" })

--------------------------------------------------------------------------------
-- SPELLING

-- [z]pelling [l]ist
keymap("n", "zl", function() cmd.Telescope("spell_suggest") end, { desc = "󰓆 Spell Suggest" })
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

---add word under cursor to vale/languagetool dictionary
keymap({ "n", "x" }, "zg", function()
	local word
	if fn.mode() == "n" then
		local iskeywBefore = vim.opt_local.iskeyword:get() -- remove word-delimiters for <cword>
		vim.opt_local.iskeyword:remove { "_", "-", "." }
		word = expand("<cword>")
		vim.opt_local.iskeyword = iskeywBefore
	else
		u.normal('"zy')
		word = fn.getreg("z")
	end
	local filepath = u.linterConfigFolder .. "/dictionary-for-vale-and-languagetool.txt"
	local success = u.appendToFile(filepath, word)
	if not success then return end -- error message already by AppendToFile
	vim.notify(('󰓆 Now accepting:\n"%s"'):format(word))
end, { desc = "󰓆 Accept Word" })

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move Line Down", silent = true })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move Line Up", silent = true })
keymap("n", "<Right>", function()
	if vim.fn.col(".") >= vim.fn.col("$") - 1 then return end
	return [["zx"zp]]
end, { desc = "Move Char Right", expr = true })
keymap("n", "<Left>", function()
	if vim.fn.col(".") == 1 then return end
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
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 Merge line down" })
keymap("x", "<leader>s", [[<Esc>`>a<CR><Esc>`<i<CR><Esc>]], { desc = "󰗈 split around selection" })

-- URL Opening (forward-seeking `gx`)
keymap("n", "gx", function()
	require("various-textobjs").url()
	-- various textobjs only switch to visual if obj found
	local foundURL = fn.mode():find("v")
	if foundURL then
		u.normal('"zy')
		local url = fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = "󰌹 Smart URL Opener" })

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-a>", "<Esc>I") -- BoL
-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "better i" })

-- COMMAND MODE
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear full line
keymap("c", "<C-w>", "<C-r><C-w>") -- add word under cursor

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "vv from Normal starts Visual Block" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

-- stylua: ignore start
keymap("n", "<CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "󰽙 Alt Buffer" })
keymap("n", "<C-CR>", "<C-w>w", { desc = " Next Window" })

keymap({ "n", "x", "i" }, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "󰽙 close buffer/window" })
keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " 󰽙 Buffers" })

-- stylua: ignore end
keymap("n", "<C-w>h", "<cmd>split<CR>", { desc = " horizontal split" })
keymap("n", "<C-w>v", "<cmd>vertical split<CR>", { desc = " vertical split" })

keymap("n", "<C-Right>", "<cmd>vertical resize +3<CR>", { desc = " vertical resize (+)" })
keymap("n", "<C-Left>", "<cmd>vertical resize -3<CR>", { desc = " vertical resize (-)" })
keymap("n", "<C-Up>", "<cmd>resize +3<CR>", { desc = " horizontal resize (+)" })
keymap("n", "<C-Down>", "<cmd>resize -3<CR>", { desc = " horizontal resize (-)" })

------------------------------------------------------------------------------
-- CMD-KEYBINDINGS

-- stylua: ignore
keymap({"n", "x"}, "<D-l>", function() fn.system("open -R '" .. expand("%:p") .. "'") end, { desc = "󰀶 Reveal in Finder" })
keymap({ "n", "x" }, "<D-5>", function()
	local parentFolder = expand("%:p:h")
	if not parentFolder:find("Alfred%.alfredpreferences") then
		vim.notify("Not in an Alfred directory.", u.warn)
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	local shellCmd = ("open 'alfredpreferences://navigateto/workflows>workflow>%s'"):format(workflowId)
	fn.system(shellCmd)

	-- in case the right workflow is already open, Alfred is not focussed.
	-- Therefore manually focussing in addition to that here as well.
	fn.system("open -a 'Alfred Preferences'")
end, { desc = "󰮤 Reveal Workflow in Alfred" })

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

-- cmd+t: template string
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String" }) -- no selection = word under cursor
keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String" })
keymap("i", "<D-t>", "${}<Left>", { desc = "Template String" })

--------------------------------------------------------------------------------
-- FILES

---using this to show the actual directory where I am telescoping
---@nodiscard
---@return string name of the current project
local function projectName()
	local pwd = vim.loop.cwd() or ""
	local name = pwd:gsub(".*/", "")
	return name
end

keymap("n", "go", function()
	local project = projectName()
	if project == "" then
		vim.notify("No pwd available", u.error)
		return
	end
	require("telescope").extensions.file_browser.file_browser { prompt_title = "󰝰 " .. project }
end, { desc = " Browse in Project" })

-- stylua: ignore
keymap( "n", "gO", function()
	require("telescope").extensions.file_browser.file_browser {
		path = expand("%:p:h"),
		prompt_title = "󰝰 " .. expand("%:p:h:t"),
	}
end, { desc = " Browse in Current Folder" })

keymap("n", "gl", function()
	local project = projectName()
	if project == "" then
		vim.notify("No pwd available", u.error)
		return
	end
	require("telescope.builtin").live_grep { prompt_title = "Live Grep: " .. projectName() }
end, { desc = " Live Grep in Project" })

-- stylua: ignore
keymap({ "n", "x" }, "gL", function() cmd.Telescope("grep_string") end, { desc = " Grep cword in Project" })
-- stylua: ignore
keymap("n", "gr", [[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]], { desc = " Recent Files" })

keymap("n", "g.", function() cmd.Telescope("resume") end, { desc = "  Continue" })
keymap("n", "ga", "gf", { desc = "Goto File under Cursor" }) -- needed, since `gf` remapped

--------------------------------------------------------------------------------
-- FOLDING

-- toggle all toplevel folds
keymap("n", "zz", function() cmd("%foldclose") end, { desc = "󰘖 Close toplevel folds" })

-- stylua: ignore
keymap("n", "zr", function() require("ufo").openFoldsExceptKinds { "comments" } end, { desc = "󰘖 󱃄 Open All Folds except comments" })
keymap("n", "zm", function() require("ufo").closeAllFolds() end, { desc = "󰘖 󱃄 Close All Folds" })

-- set foldlevel via z{n}
for _, lvl in pairs { 1, 2, 3, 4, 5 } do
	local desc = lvl < 4 and "󰘖 Set Fold Level" or "which_key_ignore"
	keymap("n", "z" .. tostring(lvl), function() require("ufo").closeFoldsWith(lvl) end, { desc = desc })
end

------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- INFO some LSP bindings done globally, so they can be used by null-ls as well
-- stylua: ignore start
keymap("n", "ge", function() vim.diagnostic.goto_next { float = true } end, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", function() vim.diagnostic.goto_prev { float = true } end, { desc = "󰒕 Previous Diagnostic" })
-- stylua: ignore end

keymap("n", "gs", function() cmd.Telescope("treesitter") end, { desc = " Document Symbols" })

-- Save & Format
keymap({ "n", "x", "i" }, "<D-s>", function()
	vim.lsp.buf.format()
	cmd.update()
end, { desc = "󰒕  Save & Format" })

-- uses "v" instead of "x", so signature can be shown during snippet completion
keymap({ "n", "i", "v" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "󰒕 Signature" })

keymap("n", "gd", function() cmd.Telescope("lsp_definitions") end, { desc = "󰒕 Definitions" })
keymap("n", "gf", function() cmd.Telescope("lsp_references") end, { desc = "󰒕 References" })

autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- overrides treesitter-refactor's rename
		if capabilities.renameProvider then
			-- cannot run `cmd.IncRename` since the plugin *has* to use the
			-- command line; needs defer to not be overwritten by treesitter-
			-- refactor's smart-rename
			-- stylua: ignore
			vim.defer_fn( function() keymap("n", "<leader>v", ":IncRename ", { desc = "󰒕 IncRename", buffer = true }) end, 1)
			-- stylua: ignore
			keymap("n", "<leader>V", function() return ":IncRename " .. expand("<cword>") end, { desc = "󰒕 IncRename (cword)", buffer = true, expr = true })
		end
		if capabilities.documentSymbolProvider then
			-- overwrites treesitter goto-symbol
			-- stylua: ignore start
			keymap("n", "gs", function() cmd.Telescope("lsp_document_symbols") end, { desc = "󰒕 Symbols", buffer = true })
			keymap("n", "gw", function() cmd.Telescope("lsp_workspace_symbols") end, { desc = "󰒕 Workspace Symbols", buffer = true })
			-- stylua: ignore end
		end
	end,
})

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
		local opts = { buffer = true, nowait = true, desc = " Close" }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

--------------------------------------------------------------------------------

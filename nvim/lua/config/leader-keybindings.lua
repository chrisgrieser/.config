local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-;>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

keymap("n", "<leader>pd", function()
	local packagesDir = vim.fn.stdpath("data") ---@cast packagesDir string
	vim.ui.open(packagesDir)
end, { desc = "󰝰 Open Packages Directory" })

--------------------------------------------------------------------------------
-- CMDLINE

-- better than `:lua`, since using `vim.notify`
vim.api.nvim_create_user_command("Eval", function(ctx)
	local output = vim.fn.luaeval(ctx.args)
	vim.notify(vim.inspect(output), nil, { title = "Cmdline" })
end, { desc = "Eval cmdline", nargs = "+" })
keymap("n", "<leader>xe", ":Eval ", { desc = "󰓗 Eval" })

-- Copy Last Command
keymap("n", "<leader>xc", function()
	local lastCommand = vim.fn.getreg(":"):gsub("^Eval ", "")
	vim.fn.setreg("+", lastCommand)
	vim.notify(lastCommand, vim.log.levels.INFO, { title = "Copied" })
end, { desc = "󰓗 Copy last e[x]ecuted [c]ommand" })

--------------------------------------------------------------------------------
-- RUN
keymap("n", "<leader>xr", function()
	vim.cmd.update()
	local hasShebang = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("^#!")

	if vim.bo.filetype == "lua" then
		vim.cmd.source()
	elseif hasShebang then
		vim.cmd("! chmod +x %")
		vim.cmd("! %")
	else
		vim.notify("File has no shebang", vim.log.levels.WARN)
	end
end, { desc = "󰜎 [r]un file" })

--------------------------------------------------------------------------------
-- INSPECT
keymap("n", "<leader>ih", vim.cmd.Inspect, { desc = " Highlights under cursor" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " :InspectTree" })
keymap("n", "<leader>il", vim.cmd.LspInfo, { desc = "󰒕 :LspInfo" })

keymap("n", "<leader>ib", function()
	local out = {
		"filetype: " .. vim.bo.filetype,
		"buftype: " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		"cwd: " .. (vim.uv.cwd() or "n/a"):gsub("/Users/%w+", "~"),
		("indent: %s (%s)"):format(vim.bo.expandtab and "spaces" or "tabs", vim.bo.tabstop),
	}
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then table.insert(out, "node: " .. node:type()) end
	vim.notify(table.concat(out, "\n"), vim.log.levels.TRACE, { title = "Buffer Info" })
end, { desc = "󰽙 Buffer Info" })

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 LSP Var Rename" })
keymap("n", "<leader>fd", ":global //d<Left><Left>", { desc = " delete matching lines" })

---@param use "spaces"|"tabs"
local function retabber(use)
	vim.bo.expandtab = use == "spaces"
	vim.bo.shiftwidth = 2
	vim.bo.tabstop = 3
	vim.cmd.retab { bang = true }
	vim.notify("Now using " .. use)
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use Tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces" })

keymap("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

--------------------------------------------------------------------------------
-- YANK STUFF

keymap("n", "<leader>yl", function()
	-- cannot use `:g // y` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		vim.notify(("Copied %d lines"):format(#matchLines))
	end)
end, { desc = "󰗈 matching lines" })

vim.fn.setreg("a", "")
keymap("n", "<leader>yy", [["Ay]], { desc = "󰅍 yank-append to [a]" })
keymap("n", "<leader>yd", [["Ad]], { desc = " delete-append to [a]" })
keymap("n", "<leader>yp", [["ap]], { desc = " paste from [a]" })
keymap("n", "<leader>yr", function() vim.fn.setreg("a", "") end, { desc = " reset [a]" })

keymap("n", "<leader>yc", function()
	local codeContext = require("nvim-treesitter").statusline {
		indicator_size = math.huge, -- disable shortening
		type_patterns = { "class", "function", "method", "field", "pair" }, -- `pair` for yaml/json
	}
	if codeContext and codeContext ~= "" then
		vim.fn.setreg("+", codeContext)
		vim.notify(codeContext, nil, { title = "Copied" })
	else
		vim.notify("No code context.", vim.log.levels.WARN)
	end
end, { desc = " Yank code context" })

--------------------------------------------------------------------------------
-- UNDO

keymap(
	"n",
	"<leader>ur",
	function() vim.cmd.later(vim.opt.undolevels:get()) end,
	{ desc = "󰛒 Redo All" }
)

keymap("n", "<leader>uu", ":earlier ", { desc = "󰜊 Undo to earlier" })

--------------------------------------------------------------------------------
-- LSP
keymap({ "n", "x" }, "<leader>cc", vim.lsp.buf.code_action, { desc = "󰒕 Code Action" })
keymap({ "n", "x" }, "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })

--------------------------------------------------------------------------------

-- Append to EoL
local trailChars = { ",", "\\", "{", ")", ";", "." }
for _, key in pairs(trailChars) do
	local pad = key == "\\" and " " or ""
	keymap("n", "<leader>" .. key, ("mzA%s%s<Esc>`z"):format(pad, key))
end

-- JUST
keymap(
	"n",
	"<leader>j",
	function() require("funcs.nano-plugins").justRecipe("first") end,
	{ desc = " 1st Just recipe" }
)
keymap(
	"n",
	"<leader>J",
	function() require("funcs.nano-plugins").justRecipe() end,
	{ desc = " Just recipes" }
)

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })

keymap("n", "<leader>ol", function()
	vim.notify("Restarting…", nil, { title = "LSP" })
	vim.cmd.LspRestart()
end, { desc = "󰒕 :LspRestart" })

keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = " Diagnostics" })

keymap(
	"n",
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 3 or 0 end,
	{ desc = "󰈉 Conceal" }
)

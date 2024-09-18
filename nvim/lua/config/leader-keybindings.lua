local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")
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
	u.notify("Cmdline", vim.inspect(output), "trace")
end, { desc = "Eval cmdline", nargs = "+" })
keymap("n", "<leader>xe", ":Eval ", { desc = "󰓗 Eval" })

-- Copy Last Command
keymap("n", "<leader>xc", function()
	local lastCommand = vim.fn.getreg(":"):gsub("^Eval ", "")
	u.copyAndNotify(lastCommand)
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
		u.notify("run file", "File has no shebang.", "warn")
	end
end, { desc = "󰜎 e[x]ecute/[r]un file" })

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
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
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
	u.notify("Indent", "Now using " .. use)
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use Tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces" })

keymap("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub(
		"[\"']",
		function(quote) return (quote == [["]] and [[']] or [["]]) end
	)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

--------------------------------------------------------------------------------
-- YANK
keymap("n", "<leader>yl", function()
	-- cannot use `:g // y` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		u.notify("Copied", tostring(#matchLines) .. " lines")
	end)
end, { desc = "󰗈 matching lines" })

vim.fn.setreg("a", "")
keymap("n", "<leader>yy", [["Ay]], { desc = "󰅍 yank-append to [a]" })
keymap("n", "<leader>yd", [["Ad]], { desc = " delete-append to [a]" })
keymap("n", "<leader>yp", [["ap<cmd>let @a=''<CR>]], { desc = " paste from [a]" })

--------------------------------------------------------------------------------
-- UNDO

keymap(
	"n",
	"<leader>ur",
	function() vim.cmd.later(vim.opt.undolevels:get()) end,
	{ desc = "󰛒 Redo All" }
)

keymap("n", "<leader>u1", function() vim.cmd.earlier("1h") end, { desc = "󰜊 Undo 1h" })
keymap("n", "<leader>u8", function() vim.cmd.earlier("8h") end, { desc = "󰜊 Undo 8h" })

-- save open time for each buffer
autocmd("BufReadPost", { callback = function() vim.b.timeOpened = os.time() end })

keymap("n", "<leader>uo", function()
	local now = os.time()
	local secsPassed = now - vim.b.timeOpened
	vim.cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open" })

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
	u.notify("LSP", "Restarting…", "trace")
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

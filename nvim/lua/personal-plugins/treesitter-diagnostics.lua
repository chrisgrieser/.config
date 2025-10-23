-- SOURCE https://pastebin.com/kUSSXzNQ
-- https://www.reddit.com/r/neovim/comments/1ocpmpu/re_treesitter_diagnostics/
--------------------------------------------------------------------------------

local ignore = {
	parsers = { "comment", "luadoc" }, -- many false positives in these embedded languages
	filetypes = { "markdown" }, -- injected languages often false positives
}

--------------------------------------------------------------------------------

--- language-independent query for syntax errors and missing elements
local errorQuery = vim.treesitter.query.parse("query", "[(ERROR)(MISSING)] @a")
local ns = vim.api.nvim_create_namespace("treesitter.diagnostics")

--- @param args vim.api.keyset.create_autocmd.callback_args
local function diagnose(args)
	-- GUARD
	if not vim.api.nvim_buf_is_valid(args.buf) then return end
	if not vim.diagnostic.is_enabled { bufnr = args.buf } then return end
	if vim.bo[args.buf].buftype ~= "" then return end
	if vim.list_contains(ignore.filetypes, vim.bo[args.buf].filetype) then return end

	local diagnostics = {}
	local parser = vim.treesitter.get_parser(args.buf, nil, { error = false })
	if not parser then return end

	parser:parse(false, function(_, trees)
		if not trees then return end

		parser:for_each_tree(function(tree, ltree)
			if vim.list_contains(ignore.parsers, ltree:lang()) or not tree:root():has_error() then
				return
			end

			for _, node in errorQuery:iter_captures(tree:root(), args.buf) do
				local lnum, col, endLnum, endCol = node:range()

				-- collapse nested syntax errors that occur at the exact same position
				local parent = node:parent()
				if parent and parent:type() == "ERROR" and parent:range() == node:range() then
					-- clamp large syntax error ranges to just the line to reduce noise
					if endLnum > lnum then
						endLnum = lnum + 1
						endCol = 0
					end

					--- @type vim.Diagnostic
					local diag = {
						source = "treesitter",
						lnum = lnum,
						end_lnum = endLnum,
						col = col,
						end_col = endCol,
						message = "",
						code = ltree:lang() .. "-syntax",
						bufnr = args.buf,
						namespace = ns,
						severity = vim.diagnostic.severity.ERROR,
					}
					diag.message = node:missing() and ("syntax error: " .. node:type()) or "error"

					-- add context to the error using sibling and parent nodes
					local previous = node:prev_sibling()
					if previous and previous:type() ~= "ERROR" then
						local previousType = previous:named() and previous:type()
							or ("`%s`").format(previous:type())
						diag.message = diag.message .. " after " .. previousType
					end

					if
						parent
						and parent:type() ~= "ERROR"
						and (previous == nil or previous:type() ~= parent:type())
					then
						diag.message = diag.message .. " in " .. parent:type()
					end

					table.insert(diagnostics, diag)
				end
			end
		end)
	end)
	vim.diagnostic.set(ns, args.buf, diagnostics)
end

vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave" }, {
	desc = "user: treesitter diagnostics",
	group = vim.api.nvim_create_augroup("user-treesitter-diagnostics", { clear = true }),
	callback = vim.schedule_wrap(diagnose),
})

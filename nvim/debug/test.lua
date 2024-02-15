local M = {}

local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local utils = require("telescope.utils")

local symbols_sorter = function(symbols)
	if vim.tbl_isempty(symbols) then return symbols end

	local current_buf = vim.api.nvim_get_current_buf()

	-- sort adequately for workspace symbols
	local filename_to_bufnr = {}
	for _, symbol in ipairs(symbols) do
		if filename_to_bufnr[symbol.filename] == nil then
			filename_to_bufnr[symbol.filename] = vim.uri_to_bufnr(vim.uri_from_fname(symbol.filename))
		end
		symbol.bufnr = filename_to_bufnr[symbol.filename]
	end

	table.sort(symbols, function(a, b)
		if a.bufnr == b.bufnr then return a.lnum < b.lnum end
		if a.bufnr == current_buf then return true end
		if b.bufnr == current_buf then return false end
		return a.bufnr < b.bufnr
	end)

	return symbols
end

--------------------------------------------------------------------------------

M.workspace_symbols = function(opts)
	local params = { query = opts.query or "" }
	vim.lsp.buf_request(opts.bufnr, "workspace/symbol", params, function(err, server_result, _, _)
		if err then
			vim.api.nvim_err_writeln("Error when finding workspace symbols: " .. err.message)
			return
		end

		local locations = vim.lsp.util.symbols_to_items(server_result or {}, opts.bufnr) or {}
		local ignore_folders = opts.ignore_folders or {}

		locations = utils.filter_symbols(locations, opts, symbols_sorter)
		if locations == nil then
			-- error message already printed in `utils.filter_symbols`
			return
		end

		if vim.tbl_isempty(locations) then
			utils.notify("builtin.lsp_workspace_symbols", {
				msg = "No results from workspace/symbol. Maybe try a different query: "
					.. "'Telescope lsp_workspace_symbols query=example'",
				level = "INFO",
			})
			return
		end

		opts.ignore_filename = vim.F.if_nil(opts.ignore_filename, false)

		pickers
			.new(opts, {
				prompt_title = "LSP Workspace Symbols",
				finder = finders.new_table {
					results = locations,
					entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
				},
				previewer = conf.qflist_previewer(opts),
				sorter = conf.prefilter_sorter {
					tag = "symbol_type",
					sorter = conf.generic_sorter(opts),
				},
			})
			:find()
	end)
end

--------------------------------------------------------------------------------
M.workspace_symbols { ignore_folders = { "node_modules", ".local" } }

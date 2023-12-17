local M = {}
local api = vim.api
local util = require("vim.lsp.util")
--------------------------------------------------------------------------------

-- https://github.com/smjonas/inc-rename.nvim/blob/main/lua/inc_rename/init.lua#L313-L356
local function rename_notify(err, result, _, _)
	if err or not result then return end

	local changed_instances = 0
	local changed_files = 0

	local with_edits = result.documentChanges ~= nil
	for _, change in pairs(result.documentChanges or result.changes) do
		changed_instances = changed_instances + (with_edits and #change.edits or #change)
		changed_files = changed_files + 1
	end

	local message = string.format(
		"[LSP] Renamed %s instance%s in %s file%s.",
		changed_instances,
		changed_instances == 1 and "" or "s",
		changed_files,
		changed_files == 1 and "" or "s"
	)
	vim.notify(message)
end

function M.lsp_rename(new_name, options)
	options = options or {}
	local bufnr = options.bufnr or api.nvim_get_current_buf()
	local clients = vim.lsp.get_active_clients {
		bufnr = bufnr,
		name = options.name,
	}
	if options.filter then clients = vim.tbl_filter(options.filter, clients) end

	-- Clients must at least support rename, prepareRename is optional
	clients = vim.tbl_filter(
		function(client) return client.supports_method("textDocument/rename") end,
		clients
	)

	if #clients == 0 then
		vim.notify("[LSP] Rename, no matching language servers with rename capability.")
	end

	local win = api.nvim_get_current_win()

	-- Compute early to account for cursor movements after going async
	local cword = vim.fn.expand("<cword>")

	---@private
	local function get_text_at_range(range, offset_encoding)
		return api.nvim_buf_get_text(
			bufnr,
			range.start.line,
			util._get_line_byte_from_position(bufnr, range.start, offset_encoding),
			range["end"].line,
			util._get_line_byte_from_position(bufnr, range["end"], offset_encoding),
			{}
		)[1]
	end

	local try_use_client
	try_use_client = function(idx, client)
		if not client then return end

		---@private
		local function rename(name)
			local params = util.make_position_params(win, client.offset_encoding)
			params.newName = name
			local handler = client.handlers["textDocument/rename"]
				or vim.lsp.handlers["textDocument/rename"]
			client.request("textDocument/rename", params, function(...)
				handler(...)
				rename_notify(...)
				try_use_client(next(clients, idx))
			end, bufnr)
		end

		if client.supports_method("textDocument/prepareRename") then
			local params = util.make_position_params(win, client.offset_encoding)
			client.request("textDocument/prepareRename", params, function(err, result)
				if err or result == nil then
					if next(clients, idx) then
						try_use_client(next(clients, idx))
					else
						local msg = err and ("Error on prepareRename: " .. (err.message or ""))
							or "Nothing to rename"
						vim.notify(msg, vim.log.levels.INFO)
					end
					return
				end

				if new_name then
					rename(new_name)
					return
				end

				local prompt_opts = {
					prompt = "New Name: ",
				}
				-- result: Range | { range: Range, placeholder: string }
				if result.placeholder then
					prompt_opts.default = result.placeholder
				elseif result.start then
					prompt_opts.default = get_text_at_range(result, client.offset_encoding)
				elseif result.range then
					prompt_opts.default = get_text_at_range(result.range, client.offset_encoding)
				else
					prompt_opts.default = cword
				end
				vim.ui.input(prompt_opts, function(input)
					if not input or #input == 0 then return end
					rename(input)
				end)
			end, bufnr)
		else
			assert(
				client.supports_method("textDocument/rename"),
				"Client must support textDocument/rename"
			)
			if new_name then
				rename(new_name)
				return
			end

			local prompt_opts = {
				prompt = "New Name: ",
				default = cword,
			}
			vim.ui.input(prompt_opts, function(input)
				if not input or #input == 0 then return end
				rename(input)
			end)
		end
	end

	try_use_client(next(clients))
end

--------------------------------------------------------------------------------
return M

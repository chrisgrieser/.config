local M = {}
--------------------------------------------------------------------------------

---sets `buffer`, `silent` and `nowait` to true
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?:boolean, nowait?: boolean}
function M.bufKeymap(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { buffer = true, silent = true, nowait = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

---@param text string
---@param replace string
function M.bufAbbrev(text, replace) vim.keymap.set("ia", text, replace, { buffer = true }) end

---Helper function for LSPs that do not support ignore files (such as `ltex`)
---@param bufnr integer
function M.isObsidianOrNotesOrIcloud(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local obsiDir = #vim.fs.find(".obsidian", { path = path, upward = true, type = "directory" }) > 0
	local iCloudDocs = vim.startswith(path, os.getenv("HOME") .. "/Library/Mobile Documents/")
	local notesDir = vim.startswith(path, vim.g.notesDir)
	return obsiDir or notesDir or iCloudDocs
end

function M.loadGhToken()
	if vim.env.GITHUB_TOKEN then return end
	local tokenPath = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/github-token.txt"
	local file = io.open(tokenPath, "r")
	if not file then
		vim.notify("Could not find file for `GITHUB_TOKEN`.", vim.log.levels.ERROR)
		return
	end
	vim.env.GITHUB_TOKEN = file:read("*l") -- read first line
	file:close()
end

--------------------------------------------------------------------------------
return M

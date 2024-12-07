-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
--------------------------------------------------------------------------------

local config = {
	sign = "",
	hlgroups = {
		borders = "FloatBorder",
		upstream = "DiagnosticVirtualTextHint",
		base = "DiagnosticVirtualTextInfo",
		stashed = "DiagnosticVirtualTextWarn",
	},
	keys = {
		leader = "<leader>m",
		upstream = "u",
		base = "b",
		stashed = "s",
	},
	notifyOpts = { title = "Merge conflicts", icon = "" },
}

--------------------------------------------------------------------------------

---@param out vim.SystemCompleted
---@param bufnr number
local function setupConflictMarkers(out, bufnr)
	local ns = vim.api.nvim_create_namespace("conflictMarkers")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- make it idempotent

	-- GUARD
	local noConflicts = out.code == 0
	local notGitRepo = vim.startswith(out.stdout, "warning: Not a git repository")
	if noConflicts or notGitRepo then return end

	-- get conflict line numbers
	local conflictLnums = {}
	for conflictLnum in out.stdout:gmatch("(%d+): leftover conflict marker") do
		table.insert(conflictLnums, tonumber(conflictLnum))
	end
	if #conflictLnums == 0 then return end
	if #conflictLnums % 4 ~= 0 then
		local msg = "Conflicts found but conflict style is not `diff3`. Aborting."
		vim.notify(msg, vim.log.levels.WARN, config.notifyOpts)
		return
	end

	-- signs & highlights
	for i = 1, #conflictLnums do
		local type = ({ "upstream", "base", "stashed" })[i % 4]
		local lnum = conflictLnums[i] - 1
		local nextLnum = type and conflictLnums[i + 1] - 1

		-- borders
		vim.api.nvim_buf_add_highlight(bufnr, ns, config.hlgroups.borders, lnum, 0, 8)
		local typeHl = config.hlgroups[type] or config.hlgroups.stashed -- stashed on 4th border
		vim.api.nvim_buf_add_highlight(bufnr, ns, typeHl, lnum, 8, -1)

		-- signs
		if type then
			vim.api.nvim_buf_set_extmark(0, ns, lnum + 1, 0, {
				sign_hl_group = typeHl,
				sign_text = config.sign .. config.keys[type],
			})
			vim.api.nvim_buf_set_extmark(0, ns, lnum + 2, 0, {
				end_row = nextLnum - 1,
				sign_hl_group = typeHl,
				sign_text = config.sign,
			})
		end
	end

	-- move to conflict & disable diagnostics
	vim.api.nvim_win_set_cursor(0, { conflictLnums[1], 0 })
	vim.diagnostic.enable(false, { bufnr = bufnr })

	-- mappings
	local mapInfo = {}
	local function map(lhs, rhs, desc)
		lhs = (config.keys.leader .. lhs):gsub("<leader>", vim.g.mapleader)
		vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
		table.insert(mapInfo, ("[%s] %s"):format(lhs, desc))
	end
	-- SOURCE https://www.reddit.com/r/neovim/comments/1h7f0bz/comment/m0ldka9/
	map("<leader>mm", "/<<<<CR>", "Goto [m]erge [m]arker")
	map("<leader>mu", "dd/|||<CR>0v/>>><CR>$x", "[m]erge [u]pstream (top)")
	map("<leader>mb", "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "[m]erge [b]ase (middle)")
	map("<leader>ms", "0v/====<CR>$x/>>><CR>dd", "[m]erge [s]tashed (bottom)")

	-- notify
	local pluralS = #conflictLnums > 1 and "s" or ""
	local header = ("%d conflict%s found."):format(#conflictLnums / 4, pluralS)
	local mapInfoStr = table.concat(mapInfo, "\n")
	vim.notify(header .. "\n" .. mapInfoStr, nil, config.notifyOpts)
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "User: Git conflict markers",
	callback = function(ctx)
		local bufnr = ctx.buf
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out) setupConflictMarkers(out, bufnr) end)
		)
	end,
})

require("config.utils")
--------------------------------------------------------------------------------

-- simple alternative to fidget.nvim, via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
local function lsp_progress()
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end
	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word
	return client .. progress .. "%% " .. task
end

local function mixedIndentation()
	local ignoredFts = { "css", "markdown", "sh", "lazy", "grapple", "" }
	if vim.tbl_contains(ignoredFts, bo.filetype) or fn.mode() == "i" or bo.buftype == "terminal" then
		return ""
	end

	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	local mixed = fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		return " mixed"
	elseif hasSpaces and not bo.expandtab then
		return " noet"
	elseif hasTabs and bo.expandtab then
		return " et"
	end
	return ""
end

-- show branch info only when *not* on main/master
augroup("branchChange", {})
autocmd({ "BufEnter", "FocusGained", "WinEnter", "TabEnter" }, {
	group = "branchChange",
	callback = function()
		g.cur_branch = fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

-- NAVIC
local navic = require("nvim-navic")
navic.setup {
	icons = { Object = "ﴯ " },
	separator = "  ",
	depth_limit = 7,
	depth_limit_indicator = "…",
}

local function showBreadcrumbs() return navic.is_available() and not (bo.filetype == "css") end

local function selectionCount()
	local isVisualMode = fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = fn.line("v")
	local ends = fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return " " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "C"
end

local function searchCounter()
	if fn.mode() ~= "n" or vim.v.hlsearch == 0 then return "" end
	local total = fn.searchcount().total
	local current = fn.searchcount().current
	local searchTerm = fn.getreg("/")
	local isStarSearch = searchTerm:find([[^\<.*\>$]])
	if isStarSearch then searchTerm = "*" .. searchTerm:sub(3, -3) end
	if total == 0 then return " 0 " .. searchTerm end
	return " " .. current .. "/" .. total .. " " .. searchTerm
end

-- clock, but only when full screen (as it covers the sketchybar then)
local function clock()
	if fn.winwidth(0) < 110 then return "" end
	local time = os.date():sub(12, 16)

	-- blinking `:`, requires statusline-refresh interval of 1000
	if os.time() % 2 == 1 then time = time:gsub(":", " ") end

	return " " .. time
end

---returns a harpoon icon if the current file is marked in Harpoon. Does not
---`require` itself, so won't load Harpoon (for when lazyloading Harpoon)
---@return string empty string when not marked
local function harpoonIndicator()
	local harpoonJsonPath = fn.stdpath("data") .. "/harpoon.json"
	local harpoonJson = ReadFile(harpoonJsonPath)
	if not harpoonJson then
		vim.notify("harpoon.json not valid", logWarn)
		return ""
	end
	local harpoonData = vim.json.decode(harpoonJson)
	local pwd = vim.loop.cwd()
	local currentProject = harpoonData.projects[pwd]
	local markedFiles = currentProject.mark.marks
	local currentFile = expand("%")

	for _, file in pairs(markedFiles) do
		if file.filename == currentFile then return "ﯠ" end
	end
	return ""
end

---Counts number of LSP references of item under the cursor
---@param count? number
local function lspReferencesCount(count)
	local params = vim.lsp.util.make_position_params(0) ---@diagnostic disable-line: missing-parameter
	params.context.includeDeclaration = false
	vim.pretty_print("params:", params)

	print("count:", count)
	if count > 0 then
		return "璉 "..tostring(count)
	elseif count == 0 then
		return ""
	else
		vim.lsp.buf_request(0, "textDocument/references", params, function(err, references, _, _)
			if err then
				vim.notify("Error when finding references: " .. err.message, logError)
				return
			end
			lspReferencesCount(#references)
		end)
		return ""
	end
end

keymap("n", "<D-f>", lspReferencesCount)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- nerdfont: 'nf-ple'
local bottomSeparators = IsGui() and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = IsGui() and { left = "", right = "" } or { left = "", right = "" }

require("lualine").setup {
	sections = {
		lualine_a = {
			{ harpoonIndicator, padding = { left = 1, right = 0 } },
			{
				"filetype",
				colored = false,
				padding = { left = 1, right = 0 },
				icon_only = true,
			},
			{
				"filename",
				file_status = false,
				fmt = function(str) return str:gsub("zsh;#toggleterm# %d", "Toggleterm") end,
			},
		},
		lualine_b = { { require("funcs.alt-alt").altFileStatusline } },
		lualine_c = {
			{ searchCounter },
		},
		lualine_x = {
			{ lsp_progress },
			{
				"diagnostics",
				symbols = { error = " ", warn = " ", info = " ", hint = "ﬤ " },
			},
			{ mixedIndentation },
		},
		lualine_y = {
			"diff",
			{ "branch", cond = isStandardBranch },
		},
		lualine_z = {
			"location",
			{ selectionCount, padding = { left = 0, right = 1 } },
		},
	},
	winbar = {
		lualine_a = {
			{ clock },
			{ lspReferencesCount },
		},
		lualine_b = {
			{
				navic.get_location,
				cond = showBreadcrumbs,
				section_separators = topSeparators,
			},
		},
		lualine_c = {
			{
				function() return " " end, -- dummy to avoid bar appearing and disappearing
				cond = showBreadcrumbs,
			},
		},
		lualine_x = {
			{
				require("lazy.status").updates,
				cond = function()
					if not require("lazy.status").has_updates() then return false end
					local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
					return numberOfUpdates >= UpdateCounterThreshhold
				end,
				color = "NonText",
			},
		},
		-- INFO dap and recording status defined in the respective plugin configs
		-- for lualine_y and lualine_z
	},
	options = {
		refresh = { statusline = 1000 },
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"DressingSelect",
			"Mason",
			"harpoon",
			"ccc-ui",
			"",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
		disabled_filetypes = {
			statusline = {},
			winbar = {
				"toggleterm",
				"gitcommit",
			},
		},
	},
}

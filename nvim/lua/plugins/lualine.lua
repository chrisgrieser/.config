local function indentation()
	local out = ""
	local usesSpaces = vim.bo.expandtab
	local usesTabs = not vim.bo.expandtab
	local ft = vim.bo.filetype
	local tabwidth = vim.bo.tabstop
	local spaceFiletypes = { "python", "yaml" }
	local ignoredFiletypes = { "css", "markdown" }
	if vim.tbl_contains(ignoredFiletypes, ft) or vim.fn.mode() ~= "n" or vim.bo.buftype ~= "" then
		return ""
	end

	-- non-default indentation (e.g. changed via indent-o-matic)
	if usesSpaces and not vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. tostring(tabwidth) .. "␣"
	elseif usesTabs and vim.tbl_contains(spaceFiletypes, ft) then
		out = out .. "↹ (" .. tostring(tabwidth) .. ")"
	elseif usesTabs and vim.opt_global.tabstop:get() ~= tabwidth then
		out = out .. " ↹ " .. tostring(tabwidth)
	end

	-- mixed indentation
	local hasTabs = vim.fn.search("^\t", "nw") > 0
	local hasSpaces = vim.fn.search("^ ", "nw") > 0
	local mixed = vim.fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		out = out .. " mixed"
	elseif usesTabs and hasSpaces then
		out = out .. " ␣"
	elseif usesSpaces and hasTabs then
		out = out .. " ↹ "
	end
	if out ~= "" then out = " " .. out end
	return out
end

--------------------------------------------------------------------------------

-- show branch info only when *not* on main/master
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "WinEnter", "TabEnter" }, {
	callback = function()
		vim.g.cur_branch = vim.fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local notMainBranch = vim.g.cur_branch ~= "main" and vim.g.cur_branch ~= "master"
	local validFiletype = vim.bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

--------------------------------------------------------------------------------

local function selectionCount()
	local isVisualMode = vim.fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = vim.fn.line("v")
	local ends = vim.fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return " " .. tostring(lines) .. "L " .. tostring(vim.fn.wordcount().visual_chars) .. "C"
end

local function searchCounter()
	if vim.fn.mode() ~= "n" or vim.v.hlsearch == 0 then return "" end
	local total = vim.fn.searchcount().total
	local current = vim.fn.searchcount().current
	local searchTerm = vim.fn.getreg("/")
	local isStarSearch = searchTerm:find([[^\<.*\>$]])
	if isStarSearch then searchTerm = "*" .. searchTerm:sub(3, -3) end
	if total == 0 then return " 0 " .. searchTerm end
	return (" %s/%s %s"):format(current, total, searchTerm)
end

local function clock()
	if vim.opt.columns:get() < 120 then return "" end -- only show the clock when it covers the menubar clock
	local time = tostring(os.date()):sub(12, 16)
	if os.time() % 2 == 1 then time = time:gsub(":", " ") end -- make the `:` blink
	return time
end

---returns a harpoon icon if the current file is marked in Harpoon. Does not
---`require` itself, so won't load Harpoon (for when lazyloading Harpoon)
---@return string empty string when not marked
local function harpoonIndicator()
	local harpoonJsonPath = vim.fn.stdpath("data") .. "/harpoon.json"
	local harpoonJson = ReadFile(harpoonJsonPath)
	if not harpoonJson then return "" end

	local harpoonData = vim.json.decode(harpoonJson)
	local pwd = vim.loop.cwd()
	local currentProject = harpoonData.projects[pwd]
	local markedFiles = currentProject.mark.marks
	local currentFile = Expand("%")

	for _, file in pairs(markedFiles) do
		if file.filename == currentFile then return "ﯠ" end
	end
	return ""
end

--------------------------------------------------------------------------------

-- simple alternative to fidget.nvim
-- via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
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

--------------------------------------------------------------------------------

-- nerdfont: icons with prefix 'ple-'
-- stylua: ignore start
local bottomSeparators = vim.g.neovide and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = vim.g.neovide and { left = " ", right = " " } or { left = "", right = "" }
-- stylua: ignore end

local lualineConfig = {
	sections = {
		lualine_a = {
			{
				harpoonIndicator,
				padding = { left = 1, right = 0 },
				cond = function() return vim.fn.filereadable(vim.fn.stdpath("data") .. "/harpoon.json") end,
			},
			{
				"filetype",
				colored = false,
				padding = { left = 1, right = 0 },
				icon_only = true,
			},
			{
				"filename",
				file_status = false,
				fmt = function(str) return str:gsub("%w+;#toggleterm#.*", "Toggleterm") end,
			},
		},
		lualine_b = { { require("funcs.alt-alt").altFileStatusline } },
		lualine_c = {
			{ require("funcs.quickfix").counter },
			{ searchCounter },
			{
				require("funcs.lsp-count").statusline,
				color = { fg = "grey" },
				cond = function() return vim.v.hlsearch == 0 end, -- don't show when searching
			},
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = " ", warn = " ", info = " ", hint = "ﬤ " },
			},
			{ indentation },
			{ lsp_progress },
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
			{ clock, section_separators = topSeparators },
		},
		lualine_b = {
			{
				require("nvim-navic").get_location,
				cond = require("nvim-navic").is_available,
				section_separators = topSeparators,
			},
		},
		lualine_c = {
			{ function() return " " end, cond = require("nvim-navic").is_available }, -- dummy to avoid bar flickering
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

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "VimEnter",
	config = function() require("lualine").setup(lualineConfig) end,
}

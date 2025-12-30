local M = {}
--------------------------------------------------------------------------------

local config = {
	provider = {
		endpoint = "https://api.openai.com/v1/responses", -- only supports OpenAI-compatible
		model = "gpt-5-mini", -- https://platform.openai.com/docs/models/gpt-5-mini
		reasoningEffort = "minimal",
		costPerMilTokens = { input = 0.25, output = 2 }, -- just for cost notification
		apiKey = vim.env.OPENAI_API_KEY,
		-- stylua: ignore
		-- fallback, if `apiKey` is not set
		apiKeyCmd = { "cat", vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt" },
		timeoutSecs = 30,
	},
	appearance = {
		icon = "󰚩",
		signText = "║",
		signHlgroup = "DiagnosticSignInfo",
	},
	prompt = {
		system = [[
			You are an export {{filetype}} developer.
			I will give you an instruction as well as some code.
			Follow the instruction and rewrite the code.

			Explain in short bullet points what you did, followed by the
			rewritten code in a Markdown code block.
		]],
		tasks = {
			simplify = "Simplify the code without diminishing its readability.",
			fix = "Fix any mistake in the code.",
		},
	},
	postSuccess = {
		showCostIfHigherThan = 0.001,
		sound = true, -- currently macOS only
		wordDiffViaGitsigns = true, -- requires `gitsigns.nvim`
	},
}

--------------------------------------------------------------------------------

---@param msg string
---@param level "info"|"warn"|"error"|"trace"
---@param opts? table
local function notify(msg, level, opts)
	if not opts then opts = {} end
	opts.title = "AI rewrite"
	opts.icon = config.appearance.icon
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

---@param task? string one to the keys of `opts.prompt.tasks`
---@param customPrompt? string
---@return nil
local function rewrite(task, customPrompt)
	local ctx = {
		bufnr = vim.api.nvim_get_current_buf(),
		winid = vim.api.nvim_get_current_win(),
		usesSpaces = vim.bo.expandtab,
	}

	-- API KEY
	local openaiApiKey = config.provider.apiKey
	if not openaiApiKey then
		local out = vim.system(config.provider.apiKeyCmd):wait()
		assert(out.code == 0, "Could not get OpenAI API key: " .. out.stderr)
		openaiApiKey = vim.trim(out.stdout)
	end

	-- SELECTION
	local mode = vim.fn.mode()
	assert(mode:find("[nV]"), "Only normal and visual line mode are supported.")
	local prevCursor = vim.api.nvim_win_get_cursor(0)
	if mode == "n" then vim.cmd.normal { "Vip", bang = true } end
	vim.cmd.normal { "V", bang = true } -- leave visual line mode
	if mode == "n" then vim.api.nvim_win_set_cursor(ctx.winid, prevCursor) end

	local startRow = vim.api.nvim_buf_get_mark(ctx.bufnr, "<")[1]
	local endRow = vim.api.nvim_buf_get_mark(ctx.bufnr, ">")[1]
	local selectionLines = vim.api.nvim_buf_get_lines(ctx.bufnr, startRow - 1, endRow, false)
	local selection = table.concat(selectionLines, "\n")
	if startRow > endRow then -- selection was reversed
		startRow, endRow = endRow, startRow
	end
	local _, oldIndent = vim.text.indent(0, selection)

	-- PROMPTS
	local systemPrompt = config.prompt.system:gsub("{{filetype}}", vim.bo.ft)
	local userPrompt = ("The code is:\n```%s\n%s\n```"):format(vim.bo.ft, selection)
	local taskPrompt = customPrompt or config.prompt.tasks[task]
	if not taskPrompt then
		local msg = ("Unknown task: %s"):format(task)
			.. "\n\nMust be one to the keys of `opts.prompt.tasks`."
		notify(msg, "warn")
		return
	end
	taskPrompt = vim.trim("The task is: " .. taskPrompt)

	-- PREPARE REQUEST
	-- DOCS Responses API https://platform.openai.com/docs/api-reference/responses/get
	local model = config.provider.model
	local data = {
		model = model,
		reasoning = { effort = config.provider.reasoningEffort },
		input = {
			{ role = "system", content = systemPrompt },
			{ role = "system", content = taskPrompt },
			{ role = "user", content = userPrompt },
		},
	}
	if vim.fn.executable("curl") == 0 then return notify("`curl` not found.", "error") end
	-- stylua: ignore
	local curlArgs = {
		"curl", "--silent", config.provider.endpoint,
		"--header", "Content-Type: application/json",
		"--header", "Authorization: Bearer " .. openaiApiKey,
		"--data", vim.json.encode(data),
	}

	-- START NOTIFICATION / SPINNER
	local timer
	local progressMsg = ("[%s] %s"):format(task, model)
	if package.loaded["snacks"] then
		local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local updateIntervalMs = 250
		timer = assert(vim.uv.new_timer())
		timer:start(
			0,
			updateIntervalMs,
			vim.schedule_wrap(function()
				local spinner = spinners[math.floor(vim.uv.now() / updateIntervalMs) % #spinners + 1]
				-- `id` to replace existing notification when using snacks.notifier
				notify(progressMsg .. " " .. spinner, "trace", { id = "ai-rewrite" })
			end)
		)
	else
		notify(progressMsg .. "…", "trace")
	end

	-- SIGNS
	if vim.api.nvim_strwidth(config.appearance.signText .. config.appearance.icon) > 2 then
		notify("Sign text + icon must be 1 char each.", "warn")
		return
	end
	local ns = vim.api.nvim_create_namespace("ai-rewrite")
	vim.api.nvim_buf_set_extmark(ctx.bufnr, ns, startRow - 1, 0, {
		sign_text = config.appearance.signText .. config.appearance.icon, -- first line also gets icon
		sign_hl_group = config.appearance.signHlgroup,
	})
	vim.api.nvim_buf_set_extmark(ctx.bufnr, ns, startRow, 0, {
		sign_text = config.appearance.signText,
		sign_hl_group = config.appearance.signHlgroup,
		end_row = endRow - 1,
	})

	-- SEND REQUEST
	vim.system(
		curlArgs,
		{ timeout = 1000 * config.provider.timeoutSecs },
		vim.schedule_wrap(function(out)
			-- STOP SPINNER & SIGNS
			if timer then
				timer:stop()
				timer:close()
			end
			vim.api.nvim_buf_clear_namespace(ctx.bufnr, ns, 0, -1) -- clear signs

			-- GUARD
			if out.code == 124 then return notify("OpenAI request timed out.", "warn") end
			if out.code ~= 0 then return notify("OpenAI request failed: " .. out.stderr, "warn") end
			local resp = vim.json.decode(out.stdout, { luanil = { object = true } })
			if resp.error then return notify(resp.error.message, "error") end

			-- PROCESS RESPONSE
			local code = resp.output[2].content[1].text
			local explanation, rewritten = code:match("^(.+)\n+```%w*\n(.+)\n```")
			assert(explanation and rewritten, "Could not parse answer: " .. rewritten)
			explanation = vim.trim(explanation:gsub("Changes made:%s*", ""))

			-- NOTIFY WITH EXPLANATION
			local msg = ("# %s (%s)\n%s"):format(task, model, explanation)
			local cost = (resp.usage.input_tokens / 1000 / 1000)
					* config.provider.costPerMilTokens.input
				+ (resp.usage.output_tokens / 1000 / 1000) * config.provider.costPerMilTokens.output
			if cost > config.postSuccess.showCostIfHigherThan then
				msg = msg .. ("\n\n*cost: %s$*"):format(cost)
			end
			notify(msg, "info", { id = "ai-rewrite", timeout = false })

			-- UPDATE BUFFER
			-- fix indentation ourselves, since LLMs often do this wrong, even when
			-- explicitly prompted to respect original indentation
			local rewrittenLines = vim.split(rewritten, "\n")
			local indentedLines = vim.tbl_map(function(line)
				-- `vim.text.indent` only indents w/ spaces, so we need to indent manually
				if line == "" then return "" end
				local indentChar = ctx.usesSpaces and " " or "\t"
				return indentChar:rep(oldIndent) .. line
			end, rewrittenLines)
			vim.api.nvim_buf_set_lines(ctx.bufnr, startRow - 1, endRow, false, indentedLines)
			vim.api.nvim_win_set_cursor(ctx.winid, { startRow, 0 })

			-- POST SUCCESS
			if config.postSuccess.sound then
				if jit.os == "OSX" then -- using macOS' `afplay`
					local sound =
						"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
					vim.system { "afplay", "--volume", "0.4", sound }
				end
			end
			if config.postSuccess.wordDiffViaGitsigns then
				local ok, gitsigns = pcall(require, "gitsigns.config")
				if not ok then return end
				gitsigns.config.linehl = true
				gitsigns.config.word_diff = true
				gitsigns.config.show_deleted = true
			end

			-- LSP RANGE FORMATTING
			local formatDelay = 100 -- FIX needed to ensure buffer was updated, scheduling not enough
			local formattingLsps =
				vim.lsp.get_clients { bufnr = ctx.bufnr, method = "textDocument/rangeFormatting" }
			if #formattingLsps > 0 then
				local newEndRow = startRow + #rewrittenLines - 1
				local range = { start = { startRow - 1, 0 }, ["end"] = { newEndRow, -1 } }
				vim.defer_fn(function()
					vim.cmd.undojoin() -- = next undo reverts change & formatting
					vim.lsp.buf.format { bufnr = ctx.bufnr, range = range }
				end, formatDelay)
			end

			-- CURSORMOVED/BUFLEAVE: DISABLE WORD-DIFF AND REMOVE NOTIFICATION
			local delay = config.postSuccess.lspRangeFormat and formatDelay + 100 or 0
			vim.defer_fn(function()
				vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
					buffer = ctx.bufnr,
					once = true,
					callback = function()
						if package.loaded["snacks"] then Snacks.notifier.hide() end
						local ok, gitsigns = pcall(require, "gitsigns.config")
						if not (ok and config.postSuccess.wordDiffViaGitsigns) then return end
						gitsigns.config.linehl = false
						gitsigns.config.word_diff = false
						gitsigns.config.show_deleted = false
					end,
				})
			end, delay)
		end)
	)
end

---@param task string? one to the keys of `opts.prompt.tasks`; if not specified prompt user
function M.task(task)
	if task then
		rewrite(task, nil)
	else
		local label = vim.trim(config.appearance.icon .. " Prompt:") .. " "
		vim.ui.input({ prompt = label }, function(customPrompt)
			if not customPrompt then return end
			rewrite("custom prompt", customPrompt)
		end)
	end
end

--------------------------------------------------------------------------------
return M

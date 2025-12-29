local M = {}
--------------------------------------------------------------------------------

local config = {
	openai = {
		endpoint = "https://api.openai.com/v1/responses", -- only supports OpenAI-compatible
		model = "gpt-5-mini", -- https://platform.openai.com/docs/models/gpt-5-mini
		reasoningEffort = "minimal",
		costPerMilTokens = { input = 0.25, output = 2 },
		apiKey = vim.env.OPENAI_API_KEY,
		-- stylua: ignore
		-- fallback, if `apiKey` is not set
		apiKeyCmd = { "cat", vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt" },
	},
	timeoutSecs = 30,
	appearance = {
		icon = "󰚩",
		signHlgroup = "DiagnosticSignInfo",
	},
	prompt = {
		system = [[
			You are an export {{filetype}} developer.
			I will give you a task as well as some code.
			Follow the task and rewrite the code.
			- Output nothing but the code, if not stated otherwise.
			- Do not add Markdown code fences.
			- Restpect the indentation used in the original code.
		]],
		tasks = {
			simplify = [[Simplify the code without diminishing its readability.]],
			fix = [[
				Fix any mistake in the following code.
				Add a leading comment with a bullet list of what has been changed.
			]],
		},
	},
	postSuccess = {
		showCostIfHigherThan = 0.001,
		lspRangeFormat = true, -- if LSP server supports `textDocument/rangeFormatting`
		sound = true, -- currently macOS only
		hook = function()
			local ok, gitsigns = pcall(require, "gitsigns")
			if not ok then return end
			vim.cmd.normal { "k", bang = true } -- in case cursor is already at hunk start
			gitsigns.nav_hunk("next")
			vim.defer_fn(gitsigns.preview_hunk_inline, 100) -- `nav_hunk` is async without callback
		end,
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

---@param task string one of the keys of `opts.prompt.tasks`
---@return nil
function M.rewrite(task)
	local ctx = {
		bufnr = vim.api.nvim_get_current_buf(),
		winid = vim.api.nvim_get_current_win(),
	}

	-- API KEY
	local openaiApiKey = config.openai.apiKey
	if not openaiApiKey then
		local out = vim.system(config.openai.apiKeyCmd):wait()
		assert(out.code == 0, "Could not get OpenAI API key: " .. out.stderr)
		openaiApiKey = vim.trim(out.stdout)
	end

	-- SELECTION
	local mode = vim.fn.mode()
	assert(mode:find("[nV]"), "Only normal and visual line mode are supported.")
	local prevCursor = vim.api.nvim_win_get_cursor(0)
	if mode == "n" then vim.cmd.normal { "Vip", bang = true } end
	local startPos, endPos = vim.fn.getpos("."), vim.fn.getpos("v")
	local startRow, endRow = startPos[2], endPos[2]
	local selectionLines = vim.fn.getregion(startPos, endPos)
	local selection = table.concat(selectionLines, "\n")
	vim.cmd.normal { "V", bang = true } -- leave visual line mode
	if mode == "n" then vim.api.nvim_win_set_cursor(ctx.winid, prevCursor) end
	if startRow > endRow then -- selection was reversed
		startRow, endRow = endRow, startRow
	end

	-- PROMPTS
	local systemPrompt = config.prompt.system:gsub("{{filetype}}", vim.bo.ft)
	local userPrompt = ("The code is:\n```%s\n%s\n```"):format(vim.bo.ft, selection)
	if not task then
		notify("Task not specified.\n\nMust be one to the keys of `opts.prompt.tasks`.", "warn")
		return
	end
	local taskPrompt = config.prompt.tasks[task]
	if not taskPrompt then
		local msg = "Unknown task: " .. task .. "\n\nMust be one to the keys of `opts.prompt.tasks`."
		notify(msg, "warn")
		return
	end
	taskPrompt = "The task is: " .. vim.trim(taskPrompt)

	-- PREPARE REQUEST
	-- DOCS Responses API https://platform.openai.com/docs/api-reference/responses/get
	local model = config.openai.model
	local data = {
		model = model,
		reasoning = { effort = config.openai.reasoningEffort },
		input = {
			{ role = "system", content = systemPrompt },
			{ role = "system", content = taskPrompt },
			{ role = "user", content = userPrompt },
		},
	}
	if vim.fn.executable("curl") == 0 then return notify("`curl` not found.", "error") end
	-- stylua: ignore
	local curlArgs = {
		"curl", "--silent", config.openai.endpoint,
		"--header", "Content-Type: application/json",
		"--header", "Authorization: Bearer " .. openaiApiKey,
		"--data", vim.json.encode(data),
	}

	-- START NOTIFICATION / SPINNER
	local timer
	local staticMsg = ("[%s] %s"):format(task, model)
	if package.loaded["snacks"] then
		local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local updateIntervalMs = 250
		timer = assert(vim.uv.new_timer())
		timer:start(
			0,
			updateIntervalMs,
			vim.schedule_wrap(function()
				local spinner = spinners[math.floor(vim.uv.now() / updateIntervalMs) % #spinners + 1]
				-- id to replace existing notification when using snacks.notifier
				notify(staticMsg .. " " .. spinner, "trace", { id = "ai-rewrite" })
			end)
		)
	else
		notify(staticMsg .. "…", "trace")
	end

	-- SIGNS
	local ns = vim.api.nvim_create_namespace("ai-rewrite")
	vim.api.nvim_buf_set_extmark(ctx.bufnr, ns, startRow - 1, 0, {
		sign_text = "┃" .. config.appearance.icon, -- first line also gets icon
		sign_hl_group = config.appearance.signHlgroup,
	})
	vim.api.nvim_buf_set_extmark(ctx.bufnr, ns, startRow, 0, {
		sign_text = "┃",
		sign_hl_group = config.appearance.signHlgroup,
		end_row = endRow - 1,
	})

	-- SEND REQUEST
	vim.system(
		curlArgs,
		{ timeout = 1000 * config.timeoutSecs },
		vim.schedule_wrap(function(out)
			-- GUARD
			if out.code == 124 then return notify("OpenAI request timed out.", "warn") end
			if out.code ~= 0 then return notify("OpenAI request failed: " .. out.stderr, "warn") end
			local resp = vim.json.decode(out.stdout, { luanil = { object = true } })
			if resp.error then return notify(resp.error.message, "error") end

			-- NOTIFY
			local msg = "✅ " .. staticMsg
			local cost = (resp.usage.input_tokens / 1000 / 1000) * config.openai.costPerMilTokens.input
				+ (resp.usage.output_tokens / 1000 / 1000) * config.openai.costPerMilTokens.output
			if cost > config.postSuccess.showCostIfHigherThan then
				msg = msg .. ("\n\n(cost: %s$)"):format(cost)
			end
			notify(msg, "info", { id = "ai-rewrite" })

			-- STOP SPINNER & SIGNS
			if timer then
				timer:stop()
				timer:close()
			end
			vim.api.nvim_buf_clear_namespace(ctx.bufnr, ns, 0, -1) -- clear signs

			-- UPDATE BUFFER
			local answer = resp.output[2].content[1].text
			local answerLines = vim.split(answer, "\n")
			vim.api.nvim_buf_set_lines(ctx.bufnr, startRow - 1, endRow, false, answerLines)
			vim.api.nvim_win_set_cursor(ctx.winid, { startRow, 0 })

			-- POST SUCCESS
			if config.postSuccess.lspRangeFormat then
				local formattingLsps =
					vim.lsp.get_clients { bufnr = ctx.bufnr, method = "textDocument/rangeFormatting" }
				if #formattingLsps > 0 then
					local newEndRow = startRow + #answerLines - 1
					local range = { start = { startRow - 1, 0 }, ["end"] = { newEndRow, -1 } }
					vim.defer_fn(
						function() vim.lsp.buf.format { bufnr = ctx.bufnr, range = range } end,
						100 -- delay needed to ensure buffer was updated, scheduling not enough
					)
				end
			end
			if config.postSuccess.sound then
				if jit.os == "OSX" then -- using macOS' `afplay`
					local sound =
						"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
					vim.system { "afplay", "--volume", "0.4", sound }
				end
			end
			config.postSuccess.hook()
		end)
	)
end

--------------------------------------------------------------------------------
return M

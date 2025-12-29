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
	prompt = {
		system = [[
			You are an export developer {{filetype}} developer.
			I will give you a task as well as some code.
			Follow the task and rewrite the code.
			Output nothing but the simplified code, without comment or markdown fences.
		]],
		tasks = {
			simplify = "Simplify the code without diminishing its readability.",
			fix = "Fix any mistask in the following code.",
		},
	},
	postSuccess = {
		lspRangeFormat = true,
		sound = true, -- currently macOS only
	},
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"warn"|"error"|"trace"
---@param opts? table
local function notify(msg, level, opts)
	if not level then level = "info" end
	if not opts then opts = {} end
	opts.title = "AI rewrite"
	opts.icon = "󰚩"
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

function M.rewrite(task)
	-- CONTEXT
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()

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
	if mode == "n" then vim.cmd.normal { "Vip", bang = true } end
	local startPos, endPos = vim.fn.getpos("."), vim.fn.getpos("v")
	local startRow, endRow = startPos[2], endPos[2]
	local selectionLines = vim.fn.getregion(startPos, endPos)
	local selection = table.concat(selectionLines, "\n")
	vim.cmd.normal { "V", bang = true } -- leave visual line mode
	if startRow > endRow then -- selection was reversed
		startRow, endRow = endRow, startRow
	end

	-- PROMPTS
	local systemPrompt = vim.trim(config.prompt.system):gsub("{{filetype}}", vim.bo.ft)
	local taskPrompt = vim.trim(config.prompt.tasks[task])
	local userPrompt = ([[```{{filetype}}\n{{selection}}\n```]])
		:gsub("{{filetype}}", vim.bo.ft)
		:gsub("{{selection}}", vim.pesc(selection))
	if not taskPrompt then
		local msg = "Unknown task: "
			.. task
			.. "\n\nThe task must be one to the keys of `opts.prompt.tasks`"
		notify(msg)
		return
	end

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

	-- SPINNER
	local timer
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
				notify(model .. " " .. spinner, "trace", { id = "ai-rewrite" })
			end)
		)
	else
		notify(model .. " started", "trace")
	end

	-- SIGNS
	local ns = vim.api.nvim_create_namespace("ai-rewrite")
	vim.api.nvim_buf_set_extmark(bufnr, ns, startRow - 1, 0, {
		sign_text = "󰚩", -- different text in first row
		sign_hl_group = "DiagnosticSignHint",
	})
	vim.api.nvim_buf_set_extmark(bufnr, ns, startRow, 0, {
		sign_text = "AI",
		sign_hl_group = "DiagnosticSignHint",
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
			local cost = (resp.usage.input_tokens / 1000 / 1000) * config.openai.costPerMilTokens.input
				+ (resp.usage.output_tokens / 1000 / 1000) * config.openai.costPerMilTokens.output
			local msg = ("%s finished ✅\n\n(cost: %s$)"):format(model, cost)
			notify(msg, "trace", { id = "ai-rewrite" })

			-- STOP SPINNER & SIGNS
			if timer then
				timer:stop()
				timer:close()
			end
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- clear signs

			-- UPDATE BUFFER
			local answer = resp.output[2].content[1].text
			local answerLines = vim.split(answer, "\n")
			vim.api.nvim_buf_set_lines(bufnr, startRow - 1, endRow, false, answerLines)
			vim.api.nvim_win_set_cursor(winid, { startRow, 0 })

			-- POST SUCCESS
			if config.postSuccess.lspRangeFormat then
				local formattingLsps =
					vim.lsp.get_clients { bufnr = bufnr, method = "textDocument/rangeFormatting" }
				if #formattingLsps > 0 then
					local newEndRow = startRow + #answerLines - 1
					local range = { start = { startRow - 1, 0 }, ["end"] = { newEndRow, -1 } }
					-- delay needed to ensure buffer was updated
					vim.defer_fn(function() vim.lsp.buf.format { bufnr = bufnr, range = range } end, 100)
				end
			end
			if config.postSuccess.sound then
				if jit.os == "OSX" then -- using macOS' `afplay`
					local sound =
						"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
					vim.system { "afplay", "--volume", "0.3", sound }
				end
			end
		end)
	)
end

--------------------------------------------------------------------------------
return M

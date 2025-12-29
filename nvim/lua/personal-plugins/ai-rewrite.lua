local M = {}
--------------------------------------------------------------------------------

local config = {
	openai = {
		model = "gpt-5-mini", -- https://platform.openai.com/docs/models/gpt-5-mini
		reasoningEffort = "minimal",
		costPerMilTokens = { input = 0.25, output = 2 },
		apiKeyFile = "~/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt",
	},
	systemPrompt = [[
		You are an export developer {{filetype}} developer.

		I will send you some code, and I want you to simplify the code while not
		diminishing its readability.

		Output nothing but the simplified code.
	]],
	postSuccessHook = function(bufnr)
		if jit.os == "OSX" then -- using macOS' `afplay`
			local sound =
				"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
			vim.system { "afplay", "--volume", "0.3", sound }
		end

		local ok, conform = pcall(require, "conform")
		if not ok then vim.lsp.buf.format { bufnr = bufnr } end
		if ok then conform.format { bufnr = bufnr } end

		local ok2, gitsigns = pcall(require, "gitsigns")
		if ok2 then gitsigns.preview_hunk_inline() end
	end,
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"warn"|"error"|"trace"
---@param opts? table
local function notify(msg, level, opts)
	if not level then level = "info" end
	if not opts then opts = {} end
	opts.title = "AI Rewrite"
	opts.icon = "󰚩"
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

function M.rewrite()
	-- API KEY
	local file, errmsg = io.open(vim.fs.normalize(config.openai.apiKeyFile), "r")
	assert(file, errmsg)
	local openaiApiKey = file:read("*a")
	file:close()

	-- SELECTION
	local mode = vim.fn.mode()
	assert(mode:find("[nV]"), "Only normal and visual line mode are supported.")
	if mode == "n" then vim.cmd.normal { "Vip", bang = true } end
	local startPos, endPos = vim.fn.getpos("."), vim.fn.getpos("v")
	local startRow, en = startPos[2]
	local selectionLines = vim.fn.getregion(startPos, endPos)
	local selection = table.concat(selectionLines, "\n")
	vim.cmd.normal { "V", bang = true } -- leave visual line mode

	-- PROMPTS
	local systemPrompt = vim.trim(config.systemPrompt):gsub("{{filetype}}", vim.bo.ft)
	local userPrompt = ([[```{{filetype}}\n{{selection}}\n```]])
		:gsub("{{filetype}}", vim.bo.ft)
		:gsub("{{selection}}", vim.pesc(selection))

	-- PREPARE REQUEST
	local url = "https://api.openai.com/v1/responses" -- https://platform.openai.com/docs/api-reference/responses/get
	local timeoutSecs = 20
	local data = {
		model = config.openai.model,
		reasoning = { effort = config.openai.reasoningEffort },
		input = {
			{ role = "system", content = systemPrompt },
			{ role = "user", content = userPrompt },
		},
	}
	local curlArgs = { -- stylua: ignore
		"curl",
		"--silent",
		url,
		"--header",
		"Content-Type: application/json",
		"--header",
		"Authorization: Bearer " .. openaiApiKey,
		"--data",
		vim.json.encode(data),
	}
	local model = config.openai.model

	-- SPINNER
	if package.loaded["snacks"] then
		local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local updateIntervalMs = 250
		local timer = assert(vim.uv.new_timer())
		timer:start(
			0,
			updateIntervalMs,
			vim.schedule_wrap(function()
				local spinner = spinners[math.floor(vim.uv.now() / updateIntervalMs) % #spinners + 1]
				-- id to replace existing notification when using snacks.notifier
				notify(model .. " " .. spinner, "trace", {
					id = "ongoing-ai-rewrite-request",
				})
			end)
		)
	else
		notify(model .. " started", "trace")
	end

	-- SEND REQUEST
	vim.system(
		curlArgs,
		{ timeout = 1000 * timeoutSecs },
		vim.schedule_wrap(function(out)
			-- GUARD
			if out.code == 124 then return notify("OpenAI request timed out.", "warn") end
			if out.code ~= 0 then return notify("OpenAI request failed: " .. out.stderr, "warn") end
			local resp = vim.json.decode(out.stdout, { luanil = { object = true } })
			if resp.error then return notify(resp.error.message, "error") end

			-- NOTIFY
			local cost = (resp.usage.input_tokens / 1000 / 1000) * config.openai.costPerMilTokens.input
				+ (resp.usage.output_tokens / 1000 / 1000) * config.openai.costPerMilTokens.output
			local msg = {
				model .. " finished ✅",
				"",
				("(cost: %s$)"):format(cost),
			}
			notify(table.concat(msg, "\n"), "trace", { id = "ongoing-ai-rewrite-request" })

			-- UPDATE BUFFER
			local answer = resp.output[2].content[1].text
			vim.api.nvim_buf_set_lines(0, startRow - 1, endRow, false, vim.split(answer, "\n"))
		end)
	)
end

--------------------------------------------------------------------------------
return M

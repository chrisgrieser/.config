local M = {}
--------------------------------------------------------------------------------

local config = {
	openai = {
		model = "gpt-5-mini",
		reasoningEffort = "minimal",
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

function M.rewrite()
	-- API KEY
	local file, errmsg = io.open(vim.fs.normalize(config.openai.apiKeyFile), "r")
	assert(file, errmsg)
	local openaiApiKey = file:read("*a")
	file:close()

	-- SELECTION
	local mode = vim.fn.mode()
	assert(mode:find("[nvV]"), "Only normal and visual modes are supported.")
	if mode == "n" then vim.cmd.normal { "vip", bang = true } end
	local selectionLines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
	local selection = table.concat(selectionLines, "\n")
	vim.cmd.normal { vim.fn.mode(), bang = true } -- leave visual mode

	-- PROMPTS
	local systemPrompt = vim.trim(config.systemPrompt):gsub("{{filetype}}", vim.bo.ft)
	local userPrompt = ([[```{{filetype}}\n{{selection}}\n```]])
		:gsub("{{filetype}}", vim.bo.ft)
		:gsub("{{selection}}", vim.pesc(selection))

	-- SEND REQUEST
	-- DOCS https://platform.openai.com/docs/api-reference/responses/get
	local url = "https://api.openai.com/v1/responses"
	local timeoutSecs = 15
	local data = {
		model = config.openai.model,
		reasoning = { effort = config.openai.reasoningEffort },
		input = {
			{ role = "system", content = systemPrompt },
			{ role = "user", content = userPrompt },
		},
	}
	-- stylua: ignore
	local curlArgs = {
		"curl", "--silent", "--max-time", tostring(timeoutSecs), url,
		"--header", "Content-Type: application/json",
		"--header", "Authorization: Bearer " .. openaiApiKey,
		"--data", vim.json.encode(data),
	}

	local out = vim.system(curlArgs):wait()
	assert(out.code == 0, "OpenAI request failed: " .. out.stderr)
	local response = vim.json.decode(out.stdout, { luanil = { object = true } })
	if response.error then
		vim.notify(response.error.message, vim.log.levels.ERROR)
		return
	end
	local answer = response.output[2].content[1].text
	Chainsaw(answer) -- 🪚
	local cost = response.usage.total_tokens * costPerToken
	Chainsaw(cost) -- 🪚
end

--------------------------------------------------------------------------------
return M

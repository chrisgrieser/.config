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
	Chainsaw(openaiApiKey) -- 🪚
	file:close()

	-- SELECTION
	local selectionLines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
	local selection = table.concat(selectionLines, "\n")
	local mode = vim.fn.mode()
	if mode:find("[Vv]") then vim.cmd.normal { mode, bang = true } end -- leave visual mode

	-- PROMPTS
	local systemPrompt = config.systemPrompt:gsub("{{filetype}}", vim.bo.filetype)
	local userPrompt = ([[```{{filetype}}\n{{selection}}\n```]])
		:gsub("{{filetype}}", vim.bo.filetype)
		:gsub("{{selection}}", vim.pesc(selection))

	-- SEND REQUEST
	-- DOCS https://platform.openai.com/docs/api-reference/responses/get
	local url = "https://api.openai.com/v1/responses"
	local timeoutSecs = 30
	local data = {
		model = config.openai.model,
		reasoning = { effort = config.openai.reasoningEffort },
		input = {
			{ role = "system", content = systemPrompt },
			{ role = "user", content = userPrompt },
		},
	}
	local dataEnc = vim.json.encode(data)

	-- stylua: ignore
	local out = vim.system ({
		"curl", "--silent", "--max-time", tostring(timeoutSecs), url,
		"--header", "Content-Type: application/json",
		"--header", "Authorization: Bearer " .. openaiApiKey,
		"--data", "-@", -- `-@` -> read from stdin
	}, { stdin = dataEnc }):wait()
	assert(out.code == 0, "OpenAI request failed: " .. out.stderr)
	local response = vim.json.decode(out.stdout)
	if response.error then error(response.error.message) end
	Chainsaw(response) -- 🪚
end

--------------------------------------------------------------------------------
return M

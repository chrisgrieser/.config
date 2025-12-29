local M = {}
--------------------------------------------------------------------------------

local config = {
	provider = {
		name = "openai",
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
	-- API Key
	local file, errmsg = io.open(vim.fs.normalize(config.provider.apiKeyFile), "r")
	assert(file, errmsg)
	local openaiApiKey = file:read("*a")
	file:close()

	-- selection
	local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
	local mode = vim.fn.mode()
	if mode:find("[Vv]") then vim.cmd.normal { mode, bang = true } end -- leave visual mode

	-- send request
	local url = "https://api.openai.com/v1/chat/completions"
	local headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. openaiApiKey }
	local data = {
		model = config.provider.model,
		messages = {
			{ role = "system", content = config.systemPrompt },
			{ role = "user", content = string.format(config.systemPrompt, { filetype = vim.bo.filetype }) },
		}
	}
end

--------------------------------------------------------------------------------
return M

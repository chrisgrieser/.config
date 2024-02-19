local u = require("config.utils")
--------------------------------------------------------------------------------
-- INFO potential alternatives:
-- https://github.com/huggingface/llm-ls
-- https://docs.sourcegraph.com/cody/overview/install-neovim
--------------------------------------------------------------------------------

return {
	-- AI Ghost-Text Suggestions
	"Exafunction/codeium.vim",
	event = "InsertEnter",
	build = function()
		-- symlink to enable syncing of API key
		local symLinkFrom = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json"
		local symLinkTo = os.getenv("HOME") .. "/.codeium/config.json"
		local fileExists = vim.loop.fs_stat(symLinkTo) ~= nil
		if not fileExists then
			pcall(vim.fn.mkdir, vim.fs.dirname(symLinkTo))
			vim.loop.fs_symlink(symLinkFrom, symLinkTo)
		end

		-- FIX accumulated leftover binaries https://github.com/Exafunction/codeium.vim/issues/200
		local bin_path = os.getenv("HOME") .. "/.codeium/bin"
		local oldBinaries =
			vim.fs.find("language_server_macos_arm", { limit = math.huge, path = bin_path })
		table.remove(oldBinaries) -- remove last item (= current binary) from list to keep it
		for _, binaryPath in pairs(oldBinaries) do
			os.remove(binaryPath)
			os.remove(vim.fs.dirname(binaryPath))
		end
	end,
	keys = {
		{
			"<D-s>",
			function() return vim.fn["codeium#Accept"]() end,
			mode = "i",
			expr = true,
			silent = true,
			desc = "󰚩 Accept Suggestion",
		},
		{
			"<leader>oa",
			function()
				vim.g.codeium_enabled = vim.g.codeium_enabled == false
				local newState = vim.g.codeium_enabled and "enabled" or "disabled"
				u.notify("Codium", "󰚩 Suggestions " .. newState .. ".")
			end,
			desc = "󰚩 Codium Suggestions",
		},
	},
	config = function()
		u.addToLuaLine("sections", "lualine_x", function()
			-- only display activity
			local status = vim.fn["codeium#GetStatusString"]()
			if not status:find("%*") then return "" end
			return "󰚩 …"
		end)

		vim.g.codeium_filetypes = {
			TelescopePrompt = false,
			DressingInput = false,
			text = false, -- `pass` passwords are plaintext and should not be sent
		}
		vim.g.codeium_disable_bindings = 1
	end,
}

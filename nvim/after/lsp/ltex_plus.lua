-- DOCS https://ltex-plus.github.io/ltex-plus/settings.html
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" },
	root_dir = function(bufnr, on_dir)
		-- do not load in specific repos (there is no `ltexignore` to do this)
		local pathsToIgnore = {
			vim.env.HOME .. "/phd-data-analysis/",
			vim.g.notesDir,
		}
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		local ignoredPath = vim.iter(pathsToIgnore)
			:any(function(p) return vim.startswith(filepath, p) end)
		if ignoredPath then return end

		-- do not load on large files due to lags
		local maxKb = 20
		local largeFile = vim.uv.fs_stat(filepath).size > maxKb * 1024
		if largeFile then
			local msg = ("Disabled since file larger than %d kb."):format(maxKb)
			vim.notify(msg, nil, { title = "ltex_plus" })
			return
		end

		-- set root markers
		local rootMarkers = { ".git" }
		on_dir(vim.fs.root(bufnr, rootMarkers))
	end,
	---@type lspconfig.settings.ltex
	settings = {
		ltex = {
			language = "auto", -- also per-file via yaml header: `lang: de-DE` https://ltex-plus.github.io/ltex-plus/advanced-usage.html#set-language-in-markdown-with-yaml-front-matter
			diagnosticSeverity = { default = "warning" },
			disabledRules = {
				["en-US"] = {
					"MORFOLOGIK_RULE_EN_US", -- spellcheck done via Harper instead
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"UPPERCASE_SENTENCE_START", -- done via Harper
					"CONSECUTIVE_SPACES", -- done by Harper & rumdl
				},
				["de"] = {
					"ABKUERZUNG_LEERZEICHEN", -- not needed
					"TYPOGRAFISCHE_ANFUEHRUNGSZEICHEN", -- don't expect smart quotes
				},
			},
			additionalRules = {
				enablePickyRules = true,
				mothersTongue = "de-DE",
			},
			markdown = {
				nodes = { Link = "dummy" }, -- don't check link text
			},
		},
	},
}

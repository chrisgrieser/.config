local M = {}
--------------------------------------------------------------------------------
-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---mappings from https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
---@type table<string, string>
local lspToMasonMap = {
	basedpyright = "basedpyright", -- python lsp (fork of pyright)
	bashls = "bash-language-server", -- also used for zsh
	biome = "biome", -- ts/js/json/css linter/formatter
	css_variables = "css-variables-language-server",
	cssls = "css-lsp",
	efm = "efm", -- linter integration (only used for shellcheck & just)
	emmet_language_server = "emmet-language-server", -- css/html snippets
	jsonls = "json-lsp",
	ltex = "ltex-ls", -- languagetool (natural language linter)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	ruff = "ruff", -- python linter & formatter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	ts_ls = "typescript-language-server",
	typos_lsp = "typos-lsp", -- spellchecker for code
	yamlls = "yaml-language-server",
}

--- copypasted from https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs.lua
--- @class serverConfig : vim.lsp.ClientConfig
--- @field enabled? boolean
--- @field single_file_support? boolean
--- @field filetypes? string[]
--- @field filetype? string
--- @field on_new_config? function
--- @field autostart? boolean
--- @field package _on_attach? fun(client: vim.lsp.Client, bufnr: integer)
--- @field root_dir? string|fun(filename: string, bufnr: number)

---@type table<string, serverConfig>
M.serverConfigs = {}
for lspName, _ in pairs(lspToMasonMap) do
	M.serverConfigs[lspName] = {}
end

local extraDependencies = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"stylua", -- efm
	"markdown-toc", -- efm
	"markdownlint", -- efm
}

-- INFO To have the mason-module access this, we cannot return this table, since
-- `lazy.nvim` uses the return values for the plugin spec. Thus we save it in a
-- global variable, so the mason-module can access it.
M.masonDependencies = vim.list_extend(extraDependencies, vim.tbl_values(lspToMasonMap))

--------------------------------------------------------------------------------
-- BASH / ZSH

-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
M.serverConfigs.bashls = {
	filetypes = { "sh", "zsh", "bash" }, -- work in zsh as well
	settings = {
		bashIde = {
			shellcheckPath = "", -- disable while using efm
			shellcheckArguments = "--shell=bash", -- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
			shfmt = { spaceRedirects = true },
		},
	},
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
local efmConfig = {
	lua = {
		{
			formatCommand = "stylua -",
			formatStdin = true,
			rootMarkers = { "stylua.toml", ".stylua.toml" },
		},
	},
	markdown = {
		-- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
		{
			formatCommand = "markdown-toc --indent=4 -i '${INPUT}' && cat '${INPUT}'",
			formatStdin = false,
		},
		{
			formatCommand = "markdownlint --fix '${INPUT}' && cat '${INPUT}'",
			rootMarkers = { ".markdownlint.yaml" },
			formatStdin = false,
		},
	},
	zsh = {
		-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
		-- since doing so with bash-lsp does not work
		-- PENDING https://github.com/bash-lsp/bash-language-server/pull/1133
		{
			lintSource = "shellcheck",
			lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
			lintStdin = true,
			lintFormats = {
				"-:%l:%c: %trror: %m [SC%n]",
				"-:%l:%c: %tarning: %m [SC%n]",
				"-:%l:%c: %tote: %m [SC%n]",
			},
		},
	},
	just = {
		{
			formatCommand = 'just --fmt --unstable --justfile="${INPUT}" ; cat "${INPUT}"',
			formatStdin = false,
			rootMarkers = { "Justfile", ".justfile" },
		},
	},
}

M.serverConfigs.efm = {
	-- cleanup useless empty folder efm creates on startup
	on_attach = function() os.remove(vim.fs.normalize("~/.config/efm-langserver")) end,

	filetypes = vim.tbl_keys(efmConfig),
	settings = { languages = efmConfig },
	init_options = { documentFormatting = true },
}

--------------------------------------------------------------------------------
-- LUA

-- DOCS https://luals.github.io/wiki/settings/
M.serverConfigs.lua_ls = {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				showWord = "Disable", -- don't suggest common words as fallback
				workspaceWord = false, -- already done by cmp-buffer
				postfix = "..", -- useful for `table.insert` and the like
			},
			diagnostics = {
				disable = { "trailing-space" }, -- formatter already handles that
			},
			hint = { -- inlay hints
				enable = true,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable", -- mostly wrong on invalid code
			},
			format = {
				enable = false, -- using `stylua` instead
			},
			-- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			workspace = { checkThirdParty = "Disable" },
		},
	},
}

--------------------------------------------------------------------------------
-- PYTHON

-- DOCS https://docs.astral.sh/ruff/editors/settings/
M.serverConfigs.ruff = {
	init_options = {
		settings = {
			organizeImports = false, -- if "I" ruleset is added, already included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
	-- disable in favor of pyright's hover info
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}

--------------------------------------------------------------------------------
-- CSS

-- DOCS
-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
M.serverConfigs.cssls = {
	-- using `biome` instead (this key overrides `settings.format.enable = true`)
	init_options = { provideFormatter = false },

	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore", -- needed for scrollbars
				duplicateProperties = "warning",
				zeroUnits = "warning",
			},
		},
	},
}

M.serverConfigs.css_variables = {
	root_dir = function()
		-- Add custom root markers for Obsidian snippet folders.
		local markers = { ".project-root", ".git" }
		return vim.fs.root(0, markers)
	end,
}

-- DOCS https://github.com/bmatcuk/stylelint-lsp#settings
M.serverConfigs.stylelint_lsp = {
	settings = {
		stylelintplus = { autoFixOnFormat = true },
	},
}

-- DOCS https://github.com/olrtg/emmet-language-server#neovim
M.serverConfigs.emmet_language_server = {
	filetypes = { "html", "css", "scss" },
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

--------------------------------------------------------------------------------
-- JS/TS

-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
M.serverConfigs.ts_ls = {
	settings = {
		-- "Cannot redeclare block-scoped variable" -> not useful for single-file-JXA
		-- (biome works only on single-file and so already check for unintended re-declarations.)
		diagnostics = { ignoredCodes = { 2451 } },

		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			},
			-- even formatting disabled still relevant for `organizeImports` code action
			format = { convertTabsToSpaces = false },
		},

		-- enable checking javascript without a `jsconfig.json`
		-- DOCS https://www.typescriptlang.org/tsconfig
		implicitProjectConfiguration = { checkJs = true, target = "ES2022" },
	},
	on_attach = function(client)
		-- disable formatting in favor of biome
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
M.serverConfigs.ts_ls.settings.javascript = M.serverConfigs.ts_ls.settings.typescript

--------------------------------------------------------------------------------

-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
M.serverConfigs.jsonls = {
	-- Disable formatting in favor of biome
	init_options = {
		provideFormatter = false,
		documentRangeFormattingProvider = false,
	},
}

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
M.serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = {
				enable = true,
				printWidth = 100,
				proseWrap = "always",
			},
		},
	},
}

--------------------------------------------------------------------------------
-- LTEX (LanguageTool LSP)

---Helper function, as ltex etc lack ignore files
---@param client vim.lsp.Client
---@param bufnr number
local function detachIfObsidianOrIcloud(client, bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local obsiDir = #vim.fs.find(".obsidian", { path = path, upward = true, type = "directory" }) > 0
	local iCloudDocs = vim.startswith(path, os.getenv("HOME") .. "/Documents/")
	if obsiDir or iCloudDocs then
		-- delay, so it's ensured the client is attached
		vim.defer_fn(function() vim.lsp.buf_detach_client(bufnr, client.id) end, 500)
		vim.diagnostic.enable(false, { bufnr = 0 })
	end
end

-- DOCS https://valentjn.github.io/ltex/settings.html
M.serverConfigs.ltex = {
	filetypes = { "markdown" }, -- not in .txt files, as those are used by `pass`
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			dictionary = {
				-- HACK since reading external file with the method described in ltex-docs[^1] does not work
				-- [^1]: https://valentjn.github.io/ltex/vscode-ltex/setting-scopes-files.html#external-setting-files
				["en-US"] = (function()
					if not vim.uv.fs_stat(vim.o.spellfile) then
						vim.notify("[ltex] Spellfile not found: " .. vim.o.spellfile, vim.log.levels.WARN)
						return {}
					end
					local words = {}
					for word in io.lines(vim.o.spellfile) do
						table.insert(words, word)
					end
					return words
				end)(),
			},
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
				},
			},
			diagnosticSeverity = {
				default = "info",
				MORFOLOGIK_RULE_EN_US = "hint",
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
	on_attach = function(ltex, bufnr)
		detachIfObsidianOrIcloud(ltex, bufnr)

		-- have `zg` update ltex' dictionary file as well as vim's spellfile
		vim.keymap.set({ "n", "x" }, "zg", function()
			local word
			if vim.fn.mode() == "n" then
				word = vim.fn.expand("<cword>")
				vim.cmd.normal { "zg", bang = true }
			else
				vim.cmd.normal { 'zggv"zy', bang = true }
				word = vim.fn.getreg("z")
			end
			local ltexSettings = ltex.config.settings or {}
			table.insert(ltexSettings.ltex.dictionary["en-US"], word)
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = ltexSettings })
		end, { desc = "󰓆 Add Word", buffer = bufnr })
	end,
}

-- TYPOS
-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
M.serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "Information" }, -- Information|Warning|Hint|Error
}

--------------------------------------------------------------------------------
return M

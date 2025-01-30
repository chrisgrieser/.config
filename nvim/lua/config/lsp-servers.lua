local M = {}
--------------------------------------------------------------------------------
-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---mappings from https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
---@type table<string, string>
local lspToMasonMap = {
	basedpyright = "basedpyright", -- python lsp (fork of pyright)
	bashls = "bash-language-server", -- also used for zsh
	biome = "biome", -- ts/js/json/css linter/formatter
	css_variables = "css-variables-language-server", -- support css variables across multiple files
	cssls = "css-lsp",
	efm = "efm", -- linter/formatter integration
	emmet_language_server = "emmet-language-server", -- css/html snippets
	gh_actions_ls = "gh-actions-language-server",
	harper_ls = "harper-ls", -- natural language linter
	html = "html-lsp",
	jsonls = "json-lsp",
	ltex_plus = "ltex-ls-plus", -- ltex-fork, languagetool (natural language linter)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	ruff = "ruff", -- python linter & formatter
	stylelint_lsp = "stylelint-lsp", -- css linter
	stylua3p_ls = "lua-3p-language-servers", -- stylua wrapper
	taplo = "taplo", -- toml lsp
	ts_ls = "typescript-language-server", -- also used for javascript
	ts_query_ls = "ts_query_ls", -- tree-sitter queries
	typos_lsp = "typos-lsp", -- spellchecker for code
	yamlls = "yaml-language-server",
}

---@module "lspconfig"
---@class myLspConfig : lspconfig.Config
---@field cmd? string -- make this optional

---@type table<string, myLspConfig>
M.serverConfigs = {}
for lspName, _ in pairs(lspToMasonMap) do
	M.serverConfigs[lspName] = {}
end

--------------------------------------------------------------------------------

local extraDependencies = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"stylua", -- used lua-3p-ls
	"markdown-toc", -- efm
	"markdownlint", -- efm
}

-- for auto-installation via `mason-tool-installer`
M.masonDependencies = vim.list_extend(extraDependencies, vim.tbl_values(lspToMasonMap))

--------------------------------------------------------------------------------
-- BASH / ZSH

-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
M.serverConfigs.bashls = {
	filetypes = { "bash", "sh", "zsh" }, -- force it to work in zsh as well
	settings = {
		bashIde = {
			shfmt = { spaceRedirects = true },
			includeAllWorkspaceSymbols = true,
			globPattern = "**/*@(.sh|.bash|.zsh)",
			shellcheckArguments = "--shell=bash",
		},
	},
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
local efmConfig = {
	markdown = {
		{ -- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
			formatCommand = "markdown-toc --indent=$'\t' -i '${INPUT}' && cat '${INPUT}'",
			formatStdin = false,
		},
		{ -- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
			formatCommand = "markdownlint --fix '${INPUT}' && cat '${INPUT}'",
			rootMarkers = { ".markdownlint.yaml" },
			formatStdin = false,
		},
		{
			lintSource = "markdownlint",
			lintCommand = "markdownlint --stdin",
			lintIgnoreExitCode = true,
			lintStdin = true,
			lintSeverity = 3, -- 3: info, 2: warning
			lintFormats = { "%f:%l:%c %m", "%f:%l %m", "%f: %l: %m" },
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
	filetypes = vim.tbl_keys(efmConfig),
	settings = { languages = efmConfig },
	init_options = { documentFormatting = true },

	-- use root marker from efm config
	root_dir = function()
		local allRootMarkers = vim.iter(vim.tbl_values(efmConfig))
			:flatten()
			:map(function(config) return config.rootMarkers end)
			:flatten()
			:totable()
		return vim.fs.root(0, allRootMarkers)
	end,

	-- cleanup useless empty folder `efm` creates on startup
	on_attach = function() os.remove(vim.fs.normalize("~/.config/efm-langserver")) end,
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
				showWord = "Disable", -- already done by completion plugin
				workspaceWord = false, -- already done by completion plugin
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				disable = {
					-- formatter already handles that
					"trailing-space",
					-- don't dim content of unused functions
					-- (no loss of diagnostic, used `unused-local` will still inform
					-- us about these functions)
					"unused-function",
				},
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
	-- disable in favor of basedpyright's hover info
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
	-- Add `biome.jsonc` as root marker for Obsidian snippet folders
	root_dir = function() return vim.fs.root(0, { "biome.jsonc", ".git" }) end,
}

-- DOCS https://github.com/bmatcuk/stylelint-lsp#settings
M.serverConfigs.stylelint_lsp = {
	settings = {
		stylelintplus = { autoFixOnFormat = true },
	},
}

-- DOCS https://github.com/olrtg/emmet-language-server#neovim
M.serverConfigs.emmet_language_server = {
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

--------------------------------------------------------------------------------
-- JS/TS

-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
M.serverConfigs.ts_ls = {
	settings = {
		-- "Cannot re-declare block-scoped variable" -> not useful for single-file-JXA
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
			-- even with formatting disabled still relevant for `organizeImports` code-action
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
-- JSON & YAML
-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
M.serverConfigs.jsonls = {
	-- Disable formatting in favor of biome
	init_options = { provideFormatter = false, documentRangeFormattingProvider = false },
}

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
M.serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = { enable = true, printWidth = 100, proseWrap = "always" },
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
		vim.diagnostic.enable(false, { bufnr = 0 })
		-- defer to ensure client is already attached
		vim.defer_fn(function() vim.lsp.buf_detach_client(bufnr, client.id) end, 500)
	end
end

-- DOCS https://github.com/elijah-potter/harper/blob/master/harper-ls/README.md#configuration
M.serverConfigs.harper_ls = {
	filetypes = { "markdown" }, -- not using in all filetypes, since too many false positives
	settings = {
		["harper-ls"] = {
			userDictPath = vim.o.spellfile,
			diagnosticSeverity = "hint",
			linters = {
				spell_check = true,
				sentence_capitalization = false, -- PENDING https://github.com/elijah-potter/harper/issues/228
			},
		},
	},
	on_attach = function(harper, bufnr)
		detachIfObsidianOrIcloud(harper, bufnr)
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.title:find("^Add .* to the global dictionary%.") ~= nil end,
				apply = true,
			}
		end, { desc = "󰓆 Add Word to spellfile", buffer = bufnr })
	end,
}

-- DOCS of the original https://valentjn.github.io/ltex/settings.html
-- DOCS of the fork https://ltex-plus.github.io/ltex-plus/settings.html
M.serverConfigs.ltex_plus = {
	filetypes = { "markdown" },
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			diagnosticSeverity = { default = "info" },
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"MORFOLOGIK_RULE_EN_US" -- spellcheck done via Harper instead
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
	on_attach = detachIfObsidianOrIcloud,
}

-- TYPOS
-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
M.serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "Hint" },
}

--------------------------------------------------------------------------------
return M

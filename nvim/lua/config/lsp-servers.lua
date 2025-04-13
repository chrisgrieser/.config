-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lsp
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---@type table<string, string>
local lspToMasonMap = {
	basedpyright = "basedpyright", -- python lsp (pyright fork)
	bashls = "bash-language-server", -- also used for zsh
	biome = "biome", -- ts/js/json/css linter/formatter
	css_variables = "css-variables-language-server", -- support css variables across multiple files
	cssls = "css-lsp",
	efm = "efm", -- integration of external linter/formatter
	emmet_language_server = "emmet-language-server", -- css/html snippets
	gh_actions_ls = "gh-actions-language-server",
	harper_ls = "harper-ls", -- natural language linter
	html = "html-lsp",
	jsonls = "json-lsp",
	just = "just-lsp",
	ltex_plus = "ltex-ls-plus", -- languagetool: natural language linter (ltex fork)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	ruff = "ruff", -- python linter & formatter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	ts_ls = "typescript-language-server",
	ts_query_ls = "ts_query_ls", -- Treesitter query files
	typos_lsp = "typos-lsp", -- spellchecker for code
	yamlls = "yaml-language-server",
}

---@type table<string, vim.lsp.Config>
local serverConfigs = {}
for lspName, _ in pairs(lspToMasonMap) do
	serverConfigs[lspName] = {}
end

--------------------------------------------------------------------------------
-- MASON
local extraDependencies = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"stylua", -- efm
	"markdown-toc", -- efm
	"markdownlint", -- efm
}

-- for auto-installation via `mason-tool-installer`
local masonDependencies = vim.list_extend(extraDependencies, vim.tbl_values(lspToMasonMap))

--------------------------------------------------------------------------------
-- BASH / ZSH

-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
serverConfigs.bashls = {
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
	lua = {
		{
			formatCommand = "stylua --search-parent-directories --stdin-filepath='${INPUT}' --respect-ignores -",
			formatStdin = true,
			rootMarkers = { "stylua.toml", ".stylua.toml" },
		},
	},
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
			lintStdin = true, -- caveat: linting from stdin does not support `.markdownlintignore`
			lintIgnoreExitCode = true,
			lintSeverity = vim.diagnostic.severity.INFO,
			lintFormats = { "%f:%l:%c MD%n/%m", "%f:%l MD%n/%m" },
		},
	},
	zsh = {
		-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
		-- since doing so with bash-lsp does not work
		-- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
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
}

serverConfigs.efm = {
	cmd = { "efm-langserver" }, -- PENDING efm being added https://github.com/neovim/nvim-lspconfig/tree/master/lsp
	filetypes = vim.tbl_keys(efmConfig),
	settings = { languages = efmConfig },
	init_options = { documentFormatting = true },

	root_markers = vim.iter(vim.tbl_values(efmConfig))
		:flatten()
		:map(function(tool) return tool.rootMarkers end)
		:flatten()
		:totable(),

	-- cleanup useless empty folder `efm` creates on startup
	on_attach = function() os.remove(vim.fs.normalize("~/.config/efm-langserver")) end,
}

--------------------------------------------------------------------------------
-- LUA

-- DOCS https://luals.github.io/wiki/settings/
serverConfigs.lua_ls = {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Disable", -- signature help more useful here
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
					-- (no loss of diagnostic, `unused-local` still informs about these functions)
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
serverConfigs.ruff = {
	init_options = {
		settings = {
			organizeImports = false, -- if "I" ruleset is added, already included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
	-- disable in favor of basedpyright's hover info
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}

vim.lsp.config("ruff", {})

--------------------------------------------------------------------------------
-- CSS

-- DOCS
-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
serverConfigs.cssls = {
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

serverConfigs.css_variables = {
	-- Add `biome.jsonc` as root marker for Obsidian snippet folders
	root_markers = { "biome.jsonc", ".git" },
}

-- DOCS https://github.com/bmatcuk/stylelint-lsp#settings
serverConfigs.stylelint_lsp = {
	settings = {
		stylelintplus = { autoFixOnFormat = true },
	},
}

-- DOCS https://github.com/olrtg/emmet-language-server#neovim
serverConfigs.emmet_language_server = {
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

--------------------------------------------------------------------------------
-- JS/TS

-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
serverConfigs.ts_ls = {
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
serverConfigs.ts_ls.settings.javascript = serverConfigs.ts_ls.settings.typescript

--------------------------------------------------------------------------------
-- JSON & YAML
-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
serverConfigs.jsonls = {
	-- Disable formatting in favor of biome
	init_options = { provideFormatter = false, documentRangeFormattingProvider = false },
}

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = { enable = true, printWidth = 100, proseWrap = "always" },
		},
	},
}

--------------------------------------------------------------------------------
-- LTEX-PLUS, HARPER & TYPOS

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
		vim.defer_fn(function() vim.lsp.buf_detach_client(bufnr, client.id) end, 1000)
	end
end

-- DOCS
-- https://writewithharper.com/docs/integrations/neovim
-- https://writewithharper.com/docs/integrations/language-server#Configuration
serverConfigs.harper_ls = {
	filetypes = { "markdown" }, -- PENDING https://github.com/elijah-potter/harper/issues/228
	settings = {
		["harper-ls"] = {
			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile,
			markdown = { IgnoreLinkTitle = true },
			linters = {
				SentenceCapitalization = false, -- false positives: https://github.com/Automattic/harper/issues/1056
			},
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
		},
	},
	on_attach = function(harper, bufnr)
		detachIfObsidianOrIcloud(harper, bufnr)
		-- Using `harper` to write to the spellfile affectively does the same as
		-- the builtin `zg`, but has the advantage that `harper` is hot-reloaded.
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.title:find("^Add .* to the global dictionary%.") ~= nil end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to spellfile", buffer = bufnr })
	end,
}

-- DOCS https://ltex-plus.github.io/ltex-plus/settings.html
serverConfigs.ltex_plus = {
	filetypes = { "markdown" },
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			diagnosticSeverity = { default = "warning" },
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"MORFOLOGIK_RULE_EN_US", -- spellcheck; done via Harper instead
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
serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "Hint" },
}

--------------------------------------------------------------------------------
-- SOURCEKIT & CLANG
-- Not installed via `mason`, but already available via Xcode Command Line
-- Tools (which are usually installed on macOS-dev devices for `homebrew`).
if jit.os == "OSX" then
	serverConfigs.sourcekit = {
		root_markers = {
			".git",
			"info.plist", -- Alfred dirs
			vim.fs.basename(vim.g.icloudSync), -- snacks scratch buffers
		},
	}
	serverConfigs.clangd = {}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- for when loaded from `init.lua`, enable LSPs
for server, config in pairs(serverConfigs) do
	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end

-- for when loaded from `mason` config, return list of mason packages
return masonDependencies

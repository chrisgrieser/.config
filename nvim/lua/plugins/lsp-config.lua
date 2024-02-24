local u = require("config.utils")
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---mappings from https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
---@type table<string, string>
local lspToMasonMap = {
	autotools_ls = "autotools-language-server", -- Makefile lsp
	bashls = "bash-language-server",
	biome = "biome", -- ts/js/json linter/formatter
	cssls = "css-lsp",
	efm = "efm", -- linter integration, only used for shellcheck in zsh files
	emmet_language_server = "emmet-language-server", -- css/html completions
	html = "html-lsp",
	jsonls = "json-lsp",
	ltex = "ltex-ls", -- languagetool (natural language linter)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	pyright = "pyright", -- python lsp
	ruff_lsp = "ruff-lsp", -- python linter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	typos_lsp = "typos-lsp", -- spellchecker for code
	vale_ls = "vale-ls", -- natural language linter
	yamlls = "yaml-language-server",
}

--------------------------------------------------------------------------------

---@class (exact) lspConfiguration see https://github.com/neovim/nvim-lspconfig/blob/master/doc/lspconfig.txt#L46
---@field autostart? boolean
---@field capabilities? table <string, string|table|boolean|function>
---@field cmd? string[]
---@field filetypes? string[]
---@field handlers? table <string, function>
---@field init_options? table <string, string|table|boolean>
---@field on_attach? function(client, bufnr)
---@field on_new_config? function(new_config, root_dir)
---@field root_dir? function(filename, bufnr)
---@field settings? table <string, table>
---@field single_file_support? boolean

---@type table<string, lspConfiguration>
local serverConfigs = {}
for lspName, _ in pairs(lspToMasonMap) do
	serverConfigs[lspName] = {}
end

--------------------------------------------------------------------------------
-- BASH / ZSH

-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts

-- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
-- disable shellcheck via LSP to avoid double-diagnostics
serverConfigs.bashls = {
	settings = {
		bashIde = { shellcheckPath = "" },
	},
}

-- HACK use efm to use shellcheck with zsh files
-- EFM: Markdown & Shell
serverConfigs.efm = {
	cmd = { "efm-langserver", "-c", vim.g.linterConfigs .. "/efm.yaml" },
	filetypes = { "sh", "markdown" }, -- limit to filestypes needed
}

local efmDependencies = {
	"shellcheck", -- PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"markdownlint",
}

--------------------------------------------------------------------------------
-- LUA

-- DOCS https://luals.github.io/wiki/settings/
serverConfigs.lua_ls = {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				showWord = "Disable", -- don't suggest common words as fallback
				workspaceWord = false, -- already done by cmp-buffer
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				globals = { "vim" }, -- when contributing to nvim plugins missing a `.luarc.json`
				disable = { "trailing-space" }, -- formatter already does that
			},
			hint = { -- inlay hints
				enable = true,
				setType = true,
				arrayIndex = "Disable",
			},
			-- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			workspace = { checkThirdParty = "Disable" },
		},
	},
}

--------------------------------------------------------------------------------
-- PYTHON

-- DOCS https://github.com/astral-sh/ruff-lsp#settings
serverConfigs.ruff_lsp = {
	init_options = {
		settings = {
			organizeImports = false, -- when "I" ruleset is added, then included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}

--------------------------------------------------------------------------------
-- CSS

-- DOCS https://github.com/olrtg/emmet-language-server#neovim
serverConfigs.emmet_language_server = {
	filetypes = { "html", "css", "scss" },
	init_options = {
		showSuggestionsAsSnippets = true, -- so it works with luasnip
	},
}

-- DOCS
-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
serverConfigs.cssls = {
	settings = {
		css = {
			format = {
				enable = true,
				-- BUG this config is being ignored. Leaving in case of css-lsp-update
				-- preserveNewLines = true,
				-- maxPreserveNewLines = 2,
				-- spaceAroundSelectorSeparator = true,
			},
			lint = {
				vendorPrefix = "ignore", -- needed for scrollbars
				duplicateProperties = "warning",
				zeroUnits = "warning",
			},
		},
	},
}

-- DOCS https://github.com/bmatcuk/stylelint-lsp#settings
-- INFO still requires LSP installed via npm (not working with stylelint from mason)
serverConfigs.stylelint_lsp = {
	filetypes = { "css", "scss" }, -- don't enable on js/ts, since I don't need it there
	settings = {
		stylelintplus = { autoFixOnFormat = true },
	},
}

--------------------------------------------------------------------------------
-- JS/TS

-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
local tsserverConfig = {
	settings = {
		-- [typescript-tools.nvim]
		complete_function_calls = true,
		-- [typescript-tools.nvim] relevant even if not formatting, since used by `organizeImports`
		tsserver_format_options = { convertTabsToSpaces = false },

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
		},

		-- enable checking javascript without a `jsconfig.json`
		-- DOCS https://www.typescriptlang.org/tsconfig
		implicitProjectConfiguration = { checkJs = true, target = "ES2022" },
	},
	on_attach = function(client)
		-- Disable formatting in favor of biome
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
tsserverConfig.settings.javascript = tsserverConfig.settings.typescript

-- SIC needs to be enabled, can be removed with nvim 0.10 support for dynamic config
serverConfigs.biome = {
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = true
		client.server_capabilities.documentRangeFormattingProvider = true
	end,
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
-- Disable formatting in favor of biome
serverConfigs.jsonls = {
	init_options = {
		provideFormatter = false,
		documentRangeFormattingProvider = false,
	},
}

--------------------------------------------------------------------------------
-- LTEX (LanguageTool LSP)

-- since reading external file with the method described in docs does not work
local function getDictWords()
	local dictfile = vim.g.linterConfigs .. "/spellfile-vim-ltex.add"
	local fileDoesNotExist = vim.loop.fs_stat(dictfile) == nil
	if fileDoesNotExist then return {} end
	local words = {}
	for word in io.lines(dictfile) do
		table.insert(words, word)
	end
	return words
end

-- DOCS https://valentjn.github.io/ltex/settings.html
serverConfigs.ltex = {
	filetypes = { "markdown" },
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			dictionary = { ["en-US"] = getDictWords() },
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"PUNCTUATION_PARAGRAPH_END", -- too many false positives
				},
			},
			diagnosticSeverity = {
				default = "info",
				MORFOLOGIK_RULE_EN_US = "hint", -- spelling
			},
			additionalRules = {
				enablePickyRules = true,
				mothersTongue = "de-DE",
			},
			markdown = {
				nodes = { Link = "dummy" },
			},
		},
	},
	on_attach = function(_, bufnr)
		-- have `zg` update ltex dictionary file as well as vim's spellfile
		vim.keymap.set({ "n", "x" }, "zg", function()
			local word
			if vim.fn.mode() == "n" then
				word = vim.fn.expand("<cword>")
				u.normal("zg")
			else
				u.normal('zggv"zy')
				word = vim.fn.getreg("z")
			end
			local ltexSettings = vim.lsp.get_active_clients({ name = "ltex" })[1].config.settings
			table.insert(ltexSettings.ltex.dictionary["en-US"], word)
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = ltexSettings })
		end, { desc = "󰓆 Add Word", buffer = bufnr })

		-- Disable ltex in Obsidian vault, as there is no `.ltexignore` https://github.com/valentjn/vscode-ltex/issues/576
		vim.defer_fn(function()
			if vim.loop.cwd() == vim.env.VAULT_PATH then vim.cmd.LspStop("ltex") end
		end, 300)
	end,
}

-- TYPOS
-- DOCS https://github.com/tekumara/typos-lsp#settings
serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "information" },
}

-- VALE
-- DOCS https://vale.sh/docs/integrations/guide/#vale-ls
-- DOCS https://vale.sh/docs/topics/config#search-process
serverConfigs.vale_ls = {
	init_options = {
		configPath = vim.g.linterConfigs .. "/vale/vale.ini",
		installVale = true,
		syncOnStartup = false,
	},

	-- just needs any root directory to work, we are providing the config already
	root_dir = function() return os.getenv("HOME") end,

	-- FIX https://github.com/errata-ai/vale-ls/issues/4
	on_attach = function() vim.env.VALE_CONFIG_PATH = vim.g.linterConfigs .. "/vale/vale.ini" end,
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = {
				enable = true,
				printWidth = 105,
				proseWrap = "always",
			},
		},
	},
	-- SIC needs enabling via setting *and* via capabilities to work.
	-- Probably fixed with nvim 0.10 supporting dynamic config changes
	on_attach = function(client) client.server_capabilities.documentFormattingProvider = true end,
}

--------------------------------------------------------------------------------

return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		mason_dependencies = vim.list_extend(efmDependencies, vim.tbl_values(lspToMasonMap)),
		dependencies = {
			"folke/neodev.nvim", -- loading as dependency ensures it's loaded before lua_ls
			opts = { library = { plugins = false } }, -- too slow with all my plugins
		},
		config = function()
			require("lspconfig.ui.windows").default_options.border = vim.g.borderStyle

			-- Enable snippets-completion (nvim-cmp) and folding (nvim-ufo)
			local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
			lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
			lspCapabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }

			for lsp, serverConfig in pairs(serverConfigs) do
				serverConfig.capabilities = lspCapabilities
				require("lspconfig")[lsp].setup(serverConfig)
			end
		end,
	},
	-- { -- better TS support
	-- 	"pmizio/typescript-tools.nvim",
	-- 	ft = { "typescript", "javascript" },
	-- 	mason_dependencies = "typescript-language-server",
	-- 	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	-- 	config = function()
	-- 		-- typescript-tools does not accept `settings.diagnostics.ignoreCode`
	-- 		-- https://github.com/pmizio/typescript-tools.nvim/issues/233
	-- 		local api = require("typescript-tools.api")
	-- 		tsserverConfig.handlers = {
	-- 			-- "Cannot redeclare block-scoped variable" -> not useful for single-file-JXA
	-- 			-- (Biome works only on single-file and so already check for unintended re-declarations.)
	-- 			["textDocument/publishDiagnostics"] = api.filter_diagnostics { 2451 },
	-- 		}
	-- 		require("typescript-tools").setup(tsserverConfig)
	-- 	end,
	-- },
	{
		"yioneko/nvim-vtsls",
		ft = { "typescript", "javascript" },
		mason_dependencies = "typescript-language-server",
	}
}

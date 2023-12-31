local u = require("config.utils")
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---mappings from https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua
---@type table<string, string>
vim.g.lspToMasonMap = {
	-- buggy, try again later
	autotools_ls = "autotools-language-server", -- Makefiles lsp
	bashls = "bash-language-server",
	biome = "biome", -- ts/js/json linter/formatter
	cssls = "css-lsp",
	efm = "efm", -- linter integration, only used for shellcheck in zsh files
	emmet_language_server = "emmet-language-server", -- css/html completion
	html = "html-lsp",
	jsonls = "json-lsp",
	ltex = "ltex-ls", -- languagetool (natural language linter)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	pyright = "pyright", -- python lsp
	ruff_lsp = "ruff-lsp", -- python linter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	tsserver = "typescript-language-server", -- js/ts lsp
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
---@field init_options? table <string, string|table|boolean>
---@field on_attach? function(client, bufnr)
---@field on_new_config? function(new_config, root_dir)
---@field root_dir? function(filename, bufnr)
---@field settings? table <string, table>
---@field single_file_support? boolean

---@type table<string, lspConfiguration>
local serverConfigs = {}
for lspName, _ in pairs(vim.g.lspToMasonMap) do
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
-- WORKAROUND: use efm to use shellcheck with zsh files

-- EFM: Markdown & Shell
serverConfigs.efm = {
	cmd = { "efm-langserver", "-c", vim.g.linterConfigFolder .. "/efm.yaml" },
	filetypes = { "sh", "markdown" }, -- limit to filestypes needed
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
			workspace = { checkThirdParty = "Disable" }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
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
	-- Disable hover in favor of pyright
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}

-- DOCS
-- https://github.com/microsoft/pyright/blob/main/docs/settings.md
-- https://microsoft.github.io/pyright/#/settings
serverConfigs.pyright = {
	on_attach = function(pyright)
		-- Automatically set python_path virtual env
		if not vim.env.VIRTUAL_ENV then return end
		pyright.config.settings.python.pythonPath = vim.env.VIRTUAL_ENV .. "/bin/python"
		vim.lsp.buf_notify(
			0,
			"workspace/didChangeConfiguration",
			{ settings = pyright.config.settings }
		)
	end,
}

--------------------------------------------------------------------------------
-- CSS

-- don't pollute completions for js/ts with stuff I don't need
serverConfigs.emmet_language_server = {
	filetypes = { "html", "css", "scss" },
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
				preserveNewLines = true,
				maxPreserveNewLines = 2,
				spaceAroundSelectorSeparator = true,
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

local configForBoth = {
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
	-- not entirely clear whats these below do, cannot find documentation
	suggest = {
		completeFunctionCalls = true,
		completeJSDocs = true,
		jsdoc = { generateReturns = true },
	},
	preferGoToSourceDefinition = true,
}

-- DOCS https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
serverConfigs.tsserver = {
	settings = {
		-- enable checking javascript without a `jsconfig.json`
		implicitProjectConfiguration = { -- DOCS https://www.typescriptlang.org/tsconfig
			checkJs = true,
			target = "ES2022", -- JXA is compliant with most of ECMAScript: https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/ES6-Features-in-JXA
		},

		-- INFO "cannot redeclare block-scoped variable" -> not useful for JXA.
		-- (Biome works on single-file-mode and therefore can be used to check for
		-- unintended re-declaring.)
		diagnostics = { ignoredCodes = { 2451 } },
		typescript = configForBoth,
		javascript = configForBoth,
	},
	-- Disable formatting in favor of biome
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}

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
	local dictfile = vim.g.linterConfigFolder .. "/spellfile-vim-ltex.add"
	local fileDoesNotExist = vim.loop.fs_stat(dictfile) == nil
	if fileDoesNotExist then return {} end
	local words = {}
	for word in io.lines(dictfile) do
		table.insert(words, word)
	end
	return words
end

-- FIX, PENDING https://github.com/williamboman/mason.nvim/issues/1531
vim.env.JAVA_HOME = vim.env.HOMEBREW_PREFIX .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

-- DOCS https://valentjn.github.io/ltex/settings.html
serverConfigs.ltex = {
	filetypes = { "gitcommit", "markdown" }, -- disable for bibtex and text files
	settings = {
		ltex = {
			language = "en-US", -- de-DE; default language, can be set per-file via markdown yaml header
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
			additionalRules = { enablePickyRules = true },
			completionEnabled = false, -- already taken care of by cmp-buffer
			markdown = { nodes = { Link = "dummy" } }, -- ignore links https://valentjn.github.io/ltex/settings.html#ltexmarkdownnodes
		},
	},
	on_attach = function()
		-- have `zg` update ltex as well
		vim.keymap.set({ "n", "x" }, "zg", function()
			local word
			if vim.fn.mode() == "n" then
				word = vim.fn.expand("<cword>")
				u.normal("zg") -- regular `zg` to add to spellfile
			else
				u.normal('zggv"zy') -- regular `zg` to add to spellfile, reselect
				word = vim.fn.getreg("z")
			end
			local ltexSettings = vim.lsp.get_active_clients({ name = "ltex" })[1].config.settings
			table.insert(ltexSettings.ltex.dictionary["en-US"], word)
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = ltexSettings })
		end, { desc = "󰓆 Add Word", buffer = true })

		-- Disable in Obsidian
		vim.defer_fn(function()
			if vim.loop.cwd() == vim.env.VAULT_PATH then vim.cmd.LspStop("ltex") end
		end, 500)
	end,
}

-- TYPOS
-- DOCS https://github.com/tekumara/typos-vscode#settings
serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "information" },
}

-- DOCS https://vale.sh/docs/integrations/guide/#vale-ls
-- DOCS https://vale.sh/docs/topics/config#search-process
serverConfigs.vale_ls = {
	init_options = {
		installVale = true, -- needs to be set, since false by default
		syncOnStartup = false,
	},
	-- just needs any root directory to work, we are providing the config already
	root_dir = function() return os.getenv("HOME") end,
}

-- FIX https://github.com/errata-ai/vale-ls/issues/4
vim.env.VALE_CONFIG_PATH = vim.g.linterConfigFolder .. "/vale/vale.ini"

--------------------------------------------------------------------------------

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = {
				enable = true,
				printWidth = 120,
				proseWrap = "always",
			},
		},
	},
	-- SIC needs enabling via setting *and* via capabilities to work
	-- TODO probably due to missing dynamic formatting in nvim?
	on_attach = function(client) client.server_capabilities.documentFormattingProvider = true end,
}

--------------------------------------------------------------------------------

local function setupAllLsps()
	-- Enable snippets-completion (nvim_cmp) and folding (nvim-ufo)
	local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
	lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
	lspCapabilities.textDocument.foldingRange =
		{ dynamicRegistration = false, lineFoldingOnly = true }

	for lsp, serverConfig in pairs(serverConfigs) do
		serverConfig.capabilities = lspCapabilities
		require("lspconfig")[lsp].setup(serverConfig)
	end
end

--------------------------------------------------------------------------------

return {
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = { -- loading as dependency ensures it's loaded before lua_ls
			"folke/neodev.nvim",
			opts = { library = { plugins = false } }, -- too slow with all my plugins
		},
		config = function()
			setupAllLsps()
			require("lspconfig.ui.windows").default_options.border = vim.g.myBorderStyle
		end,
	},
}

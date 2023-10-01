local u = require("config.utils")

--------------------------------------------------------------------------------

vim.g.myLsps = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css/html completion
	"pyright", -- python LSP
	"jedi_language_server", -- python (has refactor code actions & better hovers)
	"ruff_lsp", -- python linter
	"marksman", -- markdown
	"biome", -- ts/js/json linter/formatter
	"tsserver", -- ts/js
	"bashls", -- used for zsh
	"taplo", -- toml
	"html",
	"ltex", -- languagetool (requires `openjdk`)
}

--------------------------------------------------------------------------------

---@class lspConfiguration see :h lspconfig-setup
---@field settings? table <string, table>
---@field root_dir? function(filename, bufnr)
---@field filetypes? string[]
---@field init_options? table <string, string|table|boolean>
---@field on_attach? function(client, bufnr)
---@field capabilities? table <string, string|table|boolean|function>
---@field cmd? string[]
---@field autostart? boolean

---@type table<string, lspConfiguration>
local serverConfigs = {}

for _, lsp in pairs(vim.g.myLsps) do
	serverConfigs[lsp] = {}
end

--------------------------------------------------------------------------------
-- LUA

serverConfigs.lua_ls = {
	-- DOCS https://github.com/LuaLS/lua-language-server/wiki/Settings
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				globals = { "vim" }, -- when contributing to nvim plugins missing a .luarc.json
				disable = { "trailing-space" }, -- formatter already does that
				severity = { ["return-type-mismatch"] = "Error" }, -- https://github.com/LuaLS/lua-language-server/wiki/Settings#diagnosticsseverity
			},
			hint = {
				enable = true, -- enabled inlay hints
				setType = true,
				arrayIndex = "Disable",
			},
			workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			format = { enable = false }, -- using stylua instead
		},
	},

	on_attach = function(client)
		-- enable `willRename` for `nvim-lsp-file-operations`
		client.server_capabilities.workspace.fileOperations.willRename =
			client.server_capabilities.workspace.fileOperations.didRename
	end,
}

--------------------------------------------------------------------------------
-- PYTHON

-- DOCS https://github.com/astral-sh/ruff-lsp#settings
serverConfigs.ruff_lsp = {
	init_options = {
		-- disable, since already included in FixAll when ruff-rules include "I"
		settings = { organizeImports = false },
	},
	on_attach = function(client)
		-- Disable hover in favor of jedi
		client.server_capabilities.hoverProvider = false

		-- add fix-all code actions to formatting
		-- https://github.com/astral-sh/ruff-lsp/issues/119#issuecomment-1595628355
		vim.keymap.set("n", "<D-s>", function()
			vim.lsp.buf.code_action { apply = true, context = { only = { "source.fixAll.ruff" } } }
			require("conform").format()
			vim.cmd.update()
		end, { buffer = true, desc = "󰒕 RuffFixAll & Format & Save" })
	end,
}

-- DOCS https://github.com/microsoft/pyright/blob/main/docs/configuration.md
serverConfigs.pyright = {
	settings = {
		python = {
			analysis = { diagnosticMode = "workspace" },
		},
	},
	-- Disable hover in favor of jedi
	on_attach = function(client) client.server_capabilities.hoverProvider = false end,
}

serverConfigs.jedi_language_server = {
	init_options = {
		diagnostics = { enable = true },
	},
}

--------------------------------------------------------------------------------
-- JS/TS/CSS

-- don't pollute completions for js and ts with stuff I don't need
serverConfigs.emmet_ls = {
	filetypes = { "html", "css" },
}

-- DOCS https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
serverConfigs.cssls = {
	settings = {
		css = {
			colorDecorators = { enable = true }, -- color inlay hints
			lint = {
				compatibleVendorPrefixes = "ignore",
				vendorPrefix = "ignore",
				unknownVendorSpecificProperties = "ignore",
				unknownProperties = "ignore", -- duplicate with stylelint
				duplicateProperties = "warning",
				emptyRules = "warning",
				importStatement = "warning",
				zeroUnits = "warning",
				fontFaceProperties = "warning",
				hexColorLength = "warning",
				argumentsInColorFunction = "warning",
				unknownAtRules = "warning",
				ieHack = "warning",
				propertyIgnoredDueToDisplay = "warning",
			},
		},
	},
}

-- DOCS https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
serverConfigs.tsserver = {
	settings = {
		-- enable checking javascript without a `jsconfig.json`
		implicitProjectConfiguration = {
			checkJs = true,
			-- JXA is compliant with most of ECMAScript: https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/ES6-Features-in-JXA
			-- ES2022: .at(), ES2021: `.replaceAll()`, `new Set`
			target = "ES2022",
		},
		-- "cannot redeclare block-scoped variable" -> not useful for JXA
		diagnostics = { ignoredCodes = { 2451 } },
		completions = { completeFunctionCalls = true },
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
		javascript = {
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
	},
	-- disable formatting, since taken care of by biome
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}

--------------------------------------------------------------------------------
-- JSON/YAML/TOML

-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
-- disable formatting, since taken care of by biome
serverConfigs.jsonls = {
	init_options = {
		provideFormatter = false,
	},
}

-- disable formatting, since taken care of by prettier
serverConfigs.yamlls = {
	settings = {
		yaml = { format = { enable = false } },
	},
}

--------------------------------------------------------------------------------
-- LTEX (LanguageTool LSP)

-- HACK since reading external file with the method described in docs does not work
local function getDictWords()
	local dictfile = u.linterConfigFolder .. "/spellfile-vim-ltex.add"
	local fileDoesNotExist = vim.loop.fs_stat(dictfile) == nil
	if fileDoesNotExist then return {} end
	local words = {}
	for word in io.lines(dictfile) do
		table.insert(words, word)
	end
	return words
end

-- HACK need to set $JAVA_HOME, since `ltex.java.path` does not to work
local brewPrefix = vim.trim(vim.fn.system("brew --prefix"))
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

-- DOCS https://valentjn.github.io/ltex/settings.html
serverConfigs.ltex = {
	filetypes = { "gitcommit", "markdown" }, -- disable for bibtex and text files
	settings = {
		ltex = {
			completionEnabled = false,
			language = "en-US", -- de-DE; default language, can be set per-file via markdown yaml header
			dictionary = { ["en-US"] = getDictWords() },
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"PUNCTUATION_PARAGRAPH_END", -- too many false positives
					"CURRENCY",
				},
			},
			diagnosticSeverity = {
				default = "info",
				MORFOLOGIK_RULE_EN_US = "hint", -- spelling
			},
			additionalRules = { enablePickyRules = true },
			markdown = {
				-- ignore links https://valentjn.github.io/ltex/settings.html#ltexmarkdownnodes
				nodes = { Link = "dummy" },
			},
		},
	},
}

--------------------------------------------------------------------------------

local function setupAllLsps()
	-- Enable snippets-completion (nvim_cmp) and folding (nvim-ufo)
	local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
	lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
	lspCapabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

	for lsp, serverConfig in pairs(serverConfigs) do
		serverConfig.capabilities = lspCapabilities
		require("lspconfig")[lsp].setup(serverConfig)
	end
end

local function lspCurrentTokenHighlight()
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
			if not capabilities.documentHighlightProvider then return end

			vim.api.nvim_create_autocmd("CursorHold", {
				callback = vim.lsp.buf.document_highlight,
				buffer = args.buf,
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				callback = vim.lsp.buf.clear_references,
				buffer = args.buf,
			})
		end,
	})
end

--------------------------------------------------------------------------------

return {
	{ -- nvim-lua-types
		"folke/neodev.nvim",
		opts = {
			library = { plugins = false }, -- too slow with all my plugins
		},
	},
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim", -- ensures it's loaded before lua_ls
		init = function()
			setupAllLsps()
			lspCurrentTokenHighlight()
		end,
		config = function() require("lspconfig.ui.windows").default_options.border = u.borderStyle end,
	},
}

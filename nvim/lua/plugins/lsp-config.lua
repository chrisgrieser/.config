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
	"ltex", -- languagetool
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
	-- DOCS https://luals.github.io/wiki/settings/
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				displayContext = 6,
				showWord = "Disable", -- don't suggest common words as fallback
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				globals = { "vim" }, -- when contributing to nvim plugins missing a .luarc.json
				disable = { "trailing-space" }, -- formatter already does that
			},
			hint = {
				enable = true, -- enabled inlay hints
				setType = true,
				arrayIndex = "Disable",
			},
			workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		},
	},
}

--------------------------------------------------------------------------------
-- PYTHON

-- DOCS https://github.com/astral-sh/ruff-lsp#settings
serverConfigs.ruff_lsp = {
	init_options = {
		-- disabled, since they are done by the ruff_fix formatter
		settings = {
			organizeImports = false, -- when "I" ruleset is added, then included in "fixAll"
			fixAll = false,
			codeAction = { fixViolation = { enable = false } },
		},
	},
	-- Disable hover in favor of jedi
	on_attach = function(client) client.server_capabilities.hoverProvider = false end,
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

-- DOCS https://github.com/pappasam/jedi-language-server#configuration
serverConfigs.jedi_language_server = {
	init_options = {
		diagnostics = { enable = true },
		codeAction = { nameExtractVariable = "extracted_var", nameExtractFunction = "extracted_def" },
	},
}

--------------------------------------------------------------------------------
-- JS/TS/CSS

-- don't pollute completions for js/ts with stuff I don't need
serverConfigs.emmet_ls = {
	filetypes = { "html", "css" },
}

-- DOCS https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
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
		implicitProjectConfiguration = { -- DOCS https://www.typescriptlang.org/tsconfig
			checkJs = true,
			target = "ES2022", -- JXA is compliant with most of ECMAScript: https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/ES6-Features-in-JXA
		},

		-- INFO "cannot redeclare block-scoped variable" -> not useful for JXA.
		-- Biome works on single-file-mode and therefore can be used to check for
		-- unintended re-declaring
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
}

--------------------------------------------------------------------------------
-- LTEX (LanguageTool LSP)

-- since reading external file with the method described in docs does not work
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

-- FIX / PENDING https://github.com/williamboman/mason.nvim/issues/1531
local brewPrefix = vim.trim(vim.fn.system("brew --prefix"))
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

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
					"CURRENCY",
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
	on_attach = function(_)
		-- have `zg` update ltex
		vim.keymap.set("n", "zg", function()
			local ltex = vim.lsp.get_active_clients({ name = "ltex" })[1]
			if not ltex then return end
			local word = vim.fn.expand("<cword>")
			table.insert(ltex.config.settings.ltex.dictionary["en-US"], word)
			vim.lsp.buf_notify(
				0,
				"workspace/didChangeConfiguration",
				{ settings = ltex.config.settings }
			)
			u.normal("zg") -- add to spellfile, which is used as dictionary
		end, { desc = "󰓆 Add Word", buffer = true })

		-- Disable in Obsidian
		vim.defer_fn(function()
			local isInObsidianVault = vim.loop.cwd() == vim.env.VAULT_PATH
			if isInObsidianVault then vim.cmd.LspStop() end
		end, 500)
	end,
}

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = {
				enable = true,
				printWidth = 120,
			},
		},
	},
	-- SIC needs enabling via setting *and* via capabilities to work
	-- TODO probably due to missing dynamic formatting in nvim
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
	vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
		callback = function()
			vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true }) -- definition
			vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true }) -- reference
			vim.api.nvim_set_hl(0, "LspReferenceText", {}) -- too much noise, as is underlines e.g. strings
		end,
	})
end

local function lspSignatureSettings()
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = u.borderStyle,
	})
	-- INFO this needs to be disabled for noice.nvim
	-- vim.lsp.handlers["textDocument/hover"] =
	-- vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })
end

--------------------------------------------------------------------------------
-- PENDING
vim.api.nvim_create_autocmd({ "FileType" }, {
	-- stylua: ignore
	pattern = { "c", "cpp", "rust", "go", "java", "python", "javascript", "typescript", "html", "css", "kotlin", "dart", "lua" },
	callback = function()
		vim.defer_fn(
			function()
				vim.lsp.start {
					name = "ast-grep",
					cmd = { "ast-grep", "lsp" },
					root_dir = vim.fs.dirname(vim.fs.find({ "sgconfig.yml" }, { upward = true })[1]),
				}
			end,
			1
		)
	end,
})

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
			lspSignatureSettings()
		end,
		config = function() require("lspconfig.ui.windows").default_options.border = u.borderStyle end,
	},
}

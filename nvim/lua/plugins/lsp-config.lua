-- DOCS https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- Default configs: https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations

local u = require("config.utils")
local conf = {
	settings = {},
	on_attach = {},
	filetypes = {},
	init_options = {},
}

--------------------------------------------------------------------------------

local lsp_servers = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python LSP
	"jedi_language_server", -- python (has refactor code actions & better hovers)
	"ruff_lsp", -- python
	"marksman", -- markdown
	"biome", -- ts/js/json
	"tsserver", -- ts/js
	"bashls", -- used for zsh
	"taplo", -- toml
	"html",
	"ltex", -- latex/languagetool (requires `openjdk`)
}

--------------------------------------------------------------------------------
-- LUA
-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings

conf.settings.lua_ls = {
	Lua = {
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			postfix = ".", -- useful for `table.insert` and the like
		},
		diagnostics = {
			disable = { "trailing-space" }, -- formatter already does that
			severity = { -- https://github.com/LuaLS/lua-language-server/wiki/Settings#diagnosticsseverity
				["return-type-mismatch"] = "Error",
			},
		},
		hint = {
			enable = true,
			setType = true,
			arrayIndex = "Disable",
		},
		workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		format = { enable = false }, -- using stylua instead
	},
}

--------------------------------------------------------------------------------
-- PYTHON
-- https://github.com/astral-sh/ruff-lsp#settings
-- disable, since already included in FixAll when ruff-rules include "I"
conf.init_options.ruff_lsp = {
	settings = { organizeImports = false },
}

-- add fix-all code actions to formatting
-- https://github.com/astral-sh/ruff-lsp/issues/119#issuecomment-1595628355
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("n", "<D-s>", function()
			vim.cmd.update()
			vim.lsp.buf.format { name = "efm" }
			vim.lsp.buf.code_action { apply = true, context = { only = { "source.fixAll.ruff" } } }
		end, { buffer = true, desc = "󰒕 Format & RuffFixAll & Save" })
	end,
})

-- Disable hover in favor of jedi/pyright
conf.on_attach.ruff_lsp = function(client, _) client.server_capabilities.hoverProvider = false end

-- jedi has far better hover information
conf.on_attach.pyright = function(client, _) client.server_capabilities.hoverProvider = false end

-- the docs say it's "initializationOptions", but it's actually "init_options"
conf.init_options.jedi_language_server = {
	diagnostics = { enable = true },
}

--------------------------------------------------------------------------------
-- EMMET
-- don't pollute completions for js and ts with stuff I don't need
conf.filetypes.emmet_ls = { "css", "html" }

--------------------------------------------------------------------------------
-- CSS
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
conf.settings.cssls = {
	css = {
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
		colorDecorators = { enable = true }, -- not supported yet
	},
}

--------------------------------------------------------------------------------
-- TSSERVER
-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration

conf.settings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- "cannot redeclare block-scoped variable" -> not useful when applied to JXA
		ignoredCodes = { 2451 },
	},
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
}

-- disable formatting, since taken care of by biome https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
conf.on_attach.tsserver = function(client, _)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

--------------------------------------------------------------------------------
-- JSON
-- https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
conf.init_options.jsonls = {
	provideFormatter = false, -- use `biome` instead
}

-- YAML
conf.settings.yamlls = {
	yaml = { format = { enable = false } },
}

--------------------------------------------------------------------------------
-- LTEX
-- https://valentjn.github.io/ltex/settings.html

-- disable for bibtex and text files
conf.filetypes.ltex = { "gitcommit", "markdown" }

-- HACK since reading external file with the method described in the ltex docs
-- does not work
local dictfile = u.linterConfigFolder .. "/spellfile-vim-ltex.add"
local fileExists = vim.loop.fs_stat(dictfile) ~= nil
local words = {}
if fileExists then
	for word in io.lines(dictfile) do
		table.insert(words, word)
	end
end

-- INFO path to java runtime engine (the builtin from ltex does not seem to work)
-- here: using `openjdk`, w/ default M1 mac installation path (`brew install openjdk`)
-- HACK set need to set $JAVA_HOME, since `ltex.java.path` does not seem to work
local brewPrefix = vim.fn.system("brew --prefix"):gsub("\n$", "")
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

conf.settings.ltex = {
	ltex = {
		completionEnabled = false,
		language = "en-US", -- default language, can be set per-file via markdown yaml header
		dictionary = { ["en-US"] = words },
		disabledRules = {
			["en-US"] = {
				"EN_QUOTES", -- don't expect smart quotes
				"WHITESPACE_RULE", -- too many false positives
				"PUNCTUATION_PARAGRAPH_END", -- too many false positives
				"CURRENCY",
			},
		},
		diagnosticSeverity = {
			default = "hint",
			MORFOLOGIK_RULE_EN_US = "warning", -- spelling
		},
		additionalRules = { enablePickyRules = true },
		markdown = {
			-- ignore links https://valentjn.github.io/ltex/settings.html#ltexmarkdownnodes
			nodes = { Link = "dummy" },
		},
	},
}

--------------------------------------------------------------------------------
-- SETUP ALL LSP
-- enable capabilities for plugins
local lspCapabilities = vim.lsp.protocol.make_client_capabilities()

-- Enable snippets-completion (for nvim_cmp)
lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable folding (for nvim-ufo)
lspCapabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local function setupAllLsps()
	-- INFO must be before the lsp-config setup of lua-ls
	-- plugins are helpful e.g. for plenary, but slow down lsp loading
	require("neodev").setup { library = { plugins = false } }

	for _, lsp in pairs(lsp_servers) do
		require("lspconfig")[lsp].setup {
			capabilities = lspCapabilities,
			settings = conf.settings[lsp], -- if no settings, will assign nil and therefore do nothing
			on_attach = conf.on_attach[lsp],
			filetypes = conf.filetypes[lsp],
			init_options = conf.init_options[lsp],
		}
	end
end

--------------------------------------------------------------------------------

local function lspCurrentTokenHighlight()
	u.colorschemeMod("LspReferenceWrite", { underdashed = true }) -- i.e. definition
	u.colorschemeMod("LspReferenceRead", { underdotted = true }) -- i.e. reference
	u.colorschemeMod("LspReferenceText", {}) -- too much noise, as is underlines e.g. strings
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufnr = args.buf
			local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
			if not capabilities.documentHighlightProvider then return end

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				callback = vim.lsp.buf.document_highlight,
				buffer = bufnr,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				callback = vim.lsp.buf.clear_references,
				buffer = bufnr,
			})
		end,
	})
end

--------------------------------------------------------------------------------

return {
	{ -- package manager
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Overview" },
		},
		opts = {
			ui = {
				border = u.borderStyle,
				height = 0.8, -- so it won't cover the statusline
				icons = { package_installed = "✓", package_pending = "󰔟", package_uninstalled = "✗" },
			},
		},
	},
	{ -- auto-install lsp servers
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		opts = { ensure_installed = lsp_servers },
	},
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim", -- lsp for nvim-lua config
		init = function()
			setupAllLsps()
			lspCurrentTokenHighlight()
		end,
		config = function() require("lspconfig.ui.windows").default_options.border = u.borderStyle end,
	},
}

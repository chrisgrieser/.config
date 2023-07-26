local u = require("config.utils")
local lspSettings = {}
local lspOnAttach = {}
local lspFiletypes = {}

--------------------------------------------------------------------------------

local lsp_servers = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python
	"marksman", -- markdown
	"tsserver", -- ts/js
	"bashls", -- also used for zsh
	"taplo", -- toml
	"html",
	"ltex", -- latex/languagetool (requires `openjdk`)
	"rome", -- js/ts/json – formatting capability needs to be provided via null-ls
	-- TODO ast-grep https://ast-grep.github.io/guide/editor-integration.html
}

--------------------------------------------------------------------------------
-- LUA

-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings
lspSettings.lua_ls = {
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
		hint = { -- LSP inlayhints
			enable = true,
			setType = true,
			arrayIndex = "Disable",
		},
		workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
		telemetry = { enable = false },
	},
}

--------------------------------------------------------------------------------
-- Emmet
-- don't use for js/ts
lspFiletypes.emmet_ls = { "css", "html" }

--------------------------------------------------------------------------------
-- CSS

-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
lspSettings.cssls = {
	css = {
		lint = {
			propertyIgnoredDueToDisplay = "error",
			vendorPrefix = "ignore",
			universalSelector = "ignore",
			float = "ignore",
			boxModel = "ignore",
			-- since these would be duplication with stylelint
			duplicateProperties = "ignore",
			emptyRules = "warning",
		},
		colorDecorators = { enable = false }, -- not supported yet
	},
}

--------------------------------------------------------------------------------
-- TSSERVER

-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
lspSettings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- "cannot redeclare block-scoped variable" -> useless when applied to JXA
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

lspOnAttach.tsserver = function(client, _)
	-- disable formatting, since taken care of by rome https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

--------------------------------------------------------------------------------
-- JSON
-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = { format = { enable = false } }, -- taken care of by rome
}

--------------------------------------------------------------------------------
-- BASH / ZSH

-- force bashls (and treesitter) to work in zsh files as well
vim.api.nvim_create_autocmd("FileType", {
	pattern = "zsh",
	callback = function() vim.bo.filetype = "sh" end,
})

--------------------------------------------------------------------------------
-- LTEX
-- https://valentjn.github.io/ltex/settings.html

-- deactivate for bibtex and text files
lspFiletypes.ltex = { "gitcommit", "markdown" }

-- HACK since reading external file with the method described in the ltex docs
-- does not work
local dictfile = u.linterConfigFolder .. "/dictionary-for-vale-and-languagetool.txt"
local words = {}
for word in io.open(dictfile, "r"):lines() do
	table.insert(words, word)
end

-- INFO path to java runtime engine (the builtin from ltex does not seem to work)
-- here: using `openjdk`, w/ default M1 mac installation path (`brew install openjdk`)
-- HACK set need to set $JAVA_HOME, since `ltex.java.path` does not seem to work
local brewPrefix = vim.fn.system("brew --prefix"):gsub("\n", "")
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

lspSettings.ltex = {
	ltex = {
		completionEnabled = false,
		language = "en-US", -- default language, can be set per-file via markdown yaml header
		dictionary = { ["en-US"] = words, ["de-DE"] = words },
		disabledRules = {
			["en-US"] = {
				"EN_QUOTES", -- don't expect smart quotes
				"WHITESPACE_RULE", -- often false positives
				"PUNCTUATION_PARAGRAPH_END", -- often false positives
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
		local config = {
			capabilities = lspCapabilities,
			-- INFO if no settings, will assign nil and therefore do nothing
			settings = lspSettings[lsp],
			on_attach = lspOnAttach[lsp],
			filetypes = lspFiletypes[lsp],
		}

		require("lspconfig")[lsp].setup(config)
	end
end

--------------------------------------------------------------------------------
-- DIAGNOSTICS
local function diagnosticConfig()
	-- Sign Icons
	local diagnosticTypes = { Error = "", Warn = "▲", Info = "", Hint = "" }
	for type, icon in pairs(diagnosticTypes) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	-- Underlines
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			for type, _ in pairs(diagnosticTypes) do
				vim.cmd.highlight("DiagnosticUnderline" .. type .. " gui=underdouble cterm=underline")
			end
		end,
	})

	-- Floats & Virtual Text
	require("lspconfig.ui.windows").default_options.border = u.borderStyle
	vim.lsp.handlers["textDocument/hover"] =
		vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })
	-- needs to be disabled due to noice.nvim
	-- vim.lsp.handlers["textDocument/signatureHelp"] =
	-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })

	local function fmt(diag)
		local source = diag.source and " (" .. diag.source:gsub("%.$", "") .. ")" or ""
		local msg = diag.message
		return msg .. source
	end

	vim.diagnostic.config {
		virtual_text = {
			severity = { min = vim.diagnostic.severity.WARN }, -- not text for hints
			source = false, -- already handled by format function
			format = function(diag) return fmt(diag) end,
			spacing = 1,
		},
		float = {
			format = function(diag) return fmt(diag) end,
			focusable = true,
			border = u.borderStyle,
			max_width = 70,
			header = "", -- remove "Diagnostics:" heading
		},
	}
end
--------------------------------------------------------------------------------

return {
	{ -- package manager
		"williamboman/mason.nvim",
		lazy = true,
		opts = {
			ui = {
				border = u.borderStyle,
				icons = { package_installed = "✓", package_pending = "󰔟", package_uninstalled = "✗" },
			},
		},
	},
	{ -- auto-install lsp servers
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		opts = { ensure_installed = lsp_servers },
	},
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim", -- lsp for nvim-lua config
		init = setupAllLsps,
		config = diagnosticConfig,
	},
}

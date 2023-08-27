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
	"pylsp", -- python LSP
	"ruff_lsp", -- python linter, formatting capability needs to be provided via cli
	"marksman", -- markdown
	"rome", -- js/ts/json – formatting capability needs to be provided via cli
	"tsserver", -- ts/js
	"bashls", -- also used for zsh
	"taplo", -- toml
	"lemminx", -- xml/plist
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
-- PYTHON
-- https://github.com/astral-sh/ruff-lsp#settings
-- disable global code actions, since they are done via the ruff-cli-formatting already
conf.init_options.ruff_lsp = {
	settings = { organizeImports = false, fixAll = false },
}

-- Disable hover in favor of Pylsp
conf.on_attach.ruff_lsp = function(client, _) client.server_capabilities.hoverProvider = false end

conf.on_attach.pyright = function(client, _)
	-- pylsp has better hover, esp. the basic stuff for learning (e.g. "range()")
	client.server_capabilities.hoverProvider = false
	client.server_capabilities.signature_help = false
end

conf.on_attach.pylsp = function(client, _)
	client.server_capabilities.signature_help = false
end

-- pylsp has better hover
conf.settings.pylsp = {
	pylsp = {
		plugins = {
			-- taken care of by ruff
			flake8 = { enabled = false },
			pyflakes = { enabled = false },
			pycodestyle = { enabled = false },
		}
	},
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

-- disable formatting, since taken care of by rome https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
conf.on_attach.tsserver = function(client, _)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

--------------------------------------------------------------------------------
-- JSON
-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
conf.settings.jsonls = {
	json = { format = { enable = false } }, -- taken care of by rome
}

--------------------------------------------------------------------------------
-- XML/PLIST
-- https://github.com/eclipse/lemminx/blob/main/docs/Configuration.md#all-formatting-options
conf.settings.lemminx = {
	xml = {
		-- disabled, since it messes up some formatting of Alfred .plist files
		format = { enabled = false },
	},
}

--------------------------------------------------------------------------------
-- BASH / ZSH

-- HACK make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- so .sh files with zsh-shebang still get sh filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
	},
}

-- CAVEAT: various attempts of setting shellcheck args for bashls do not work,
-- apparently because bash-ls blocks them due to the zsh-shebang, regardless of
-- filetype defined by nvim.
-- Therefore using shellcheck via null-ls, since there enforcing the shell via
-- `--shell=bash` does work.

--------------------------------------------------------------------------------
-- LTEX
-- https://valentjn.github.io/ltex/settings.html

-- disable for bibtex and text files
conf.filetypes.ltex = { "gitcommit", "markdown", "octo" }

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
local brewPrefix = vim.fn.system("brew --prefix"):gsub("\n$", "")
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

conf.settings.ltex = {
	ltex = {
		completionEnabled = false,
		language = "en-US", -- default language, can be set per-file via markdown yaml header
		dictionary = { ["en-US"] = words, ["de-DE"] = words },
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
-- DIAGNOSTICS
local function diagnosticConfig()
	-- Sign Icons
	local diagnosticTypes = { Error = "", Warn = "▲", Info = "", Hint = "" }
	for type, icon in pairs(diagnosticTypes) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	-- Floats & Virtual Text
	require("lspconfig.ui.windows").default_options.border = u.borderStyle
	vim.lsp.handlers["textDocument/hover"] =
		vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })

	-- WARN this needs to be disabled due to noice.nvim
	-- vim.lsp.handlers["textDocument/signatureHelp"] =
	-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })

	vim.diagnostic.config {
		virtual_text = {
			severity = { min = vim.diagnostic.severity.WARN }, -- no text for hints
			source = false, -- already handled by format function
			format = function(diag) return u.diagnosticFmt(diag) end,
			spacing = 1,
		},
		float = {
			format = function(diag) return u.diagnosticFmt(diag) end,
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

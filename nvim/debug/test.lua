local pythonPath = vim.lsp.get_active_clients({ name = "pyright" })[1].config.settings.python.pythonPath

local venv = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(pythonPath)))
vim.notify(venv)

local p = vim.fn.stdpath("config") .. "/snippets"
require("blink.cmp.sources.snippets.scan").load_package_json(p)
vim.notify("🖨️ 🔵")


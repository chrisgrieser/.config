local str1 = "origin  git@github.com:chrisgrieser/nvim-tinygit (fetch)"
local str2 = "origin  https://github.com/chrisgrieser/nvim-tinygit (fetch)"
local firstRemote = str2:match(":(%S+)") or str2:match("/(%S+)")
vim.notify("❗ firstRemote: " .. tostring(firstRemote))

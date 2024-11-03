
local progressIcons = { "󰋙", "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" }

local out=""
for i = 0, 100, 1 do
	out = out .. tostring(i) .. "\n"
end
vim.notify("🖨️ out: " .. tostring(out))

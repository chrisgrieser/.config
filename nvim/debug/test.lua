
local progressIcons = { "󰋙", "󰫃", "󰫄", "󰫅", "󰫆", "󰫇", "󰫈" }

local out=""
for percent = 0, 100, 1 do
	local idx = math.ceil(percent / 100 * #progressIcons)
	local line = ("%d: %s"):format(percent, progressIcons[idx])
	out = out .. line .. "\n"

	
end
vim.notify("🖨️ out: " .. tostring(out))

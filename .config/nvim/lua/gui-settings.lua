require("utils")
require("appearance")
--------------------------------------------------------------------------------

-- BASE CONFIG
local lightTheme = "melange"
-- local lightTheme = "dawnfox"

local darkTheme = "tokyonight-moon"
-- local darkTheme = "melange"
-- local darkTheme = "kanagawa"
-- local darkTheme = "onedark"

-- font size dependent on device
if fn.hostname():find("iMac") then
	g.neovide_scale_factor = 1
elseif fn.hostname():find("mini") then
	g.neovide_scale_factor = 0.95
elseif fn.hostname():find("Mother") then
	g.neovide_scale_factor = 0.95
end

opt.guifont = "JetBrainsMonoNL Nerd Font:h26.9"
opt.guicursor = "n-sm:block," ..
	"i-ci-c-ve:ver25," ..
	"r-cr-o-v:hor10," ..
	"a:blinkwait300-blinkoff500-blinkon700"

--------------------------------------------------------------------------------

---@param mode string light|dark
function themeModifications(mode)
	if g.colors_name == "tokyonight" then
		local modes = {"normal", "visual", "insert", "terminal", "replace", "command", "inactive"}
		for _, v in pairs(modes) do
			cmd("highlight lualine_y_diff_modified_" .. v .. " guifg=#acaa62")
			cmd("highlight lualine_y_diff_added_" .. v .. " guifg=#8cbf8e")
		end
	elseif g.colors_name == "dawnfox" then
		cmd [[highlight IndentBlanklineChar guifg=#deccba]]
		cmd [[highlight VertSplit guifg=#b29b84]]
	elseif g.colors_name == "melange" and mode == "light" then
		cmd [[highlight def link @punctuation @label]]
		cmd [[highlight! def link NotifyINFOIcon @define]]
		cmd [[highlight! def link NotifyINFOTitle @define]]
		cmd [[highlight! def link NotifyINFOBody @define]]
	end
end

-- THEME
local function light()
	api.nvim_set_option("background", "light")
	cmd("colorscheme " .. lightTheme)
	g.neovide_transparency = 0.94
	customHighlights()
	themeModifications("light")
end

--
local function dark()
	api.nvim_set_option("background", "dark")
	cmd("colorscheme " .. darkTheme)
	g.neovide_transparency = 0.97
	customHighlights()
	themeModifications("dark")
end

-- toggle theme with OS
local auto_dark_mode = require("auto-dark-mode")
auto_dark_mode.setup {
	update_interval = 3000,
	set_dark_mode = dark,
	set_light_mode = light,
}
auto_dark_mode.init()

--------------------------------------------------------------------------------
-- CMD-Keybindings
keymap({"n", "v"}, "<D-w>", ":close<CR>") -- cmd+w
keymap("i", "<D-w>", "<Esc>:close<CR>")

keymap({"n", "v", "i"}, "<D-n>", qol.createNewFile)

keymap({"n", "v"}, "<D-z>", "u") -- cmd+z
keymap({"n", "v"}, "<D-Z>", "<C-R>") -- cmd+shift+z
keymap("i", "<D-z>", "<C-o>u")
keymap("i", "<D-Z>", "<C-o><C-r>")
keymap({"n", "v"}, "<D-s>", ":write!<CR>") -- cmd+s
keymap("i", "<D-s>", "<Esc>:write!<CR>a")
keymap("n", "<D-a>", "ggVG") -- cmd+a
keymap("i", "<D-a>", "<Esc>ggVG")
keymap("v", "<D-a>", "ggG")

keymap("", "<D-BS>", qol.trashFile)
keymap({"n", "v"}, "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
keymap({"n", "v", "i"}, "<D-1>", ":Lexplore<CR><CR>") -- file tree (netrw)
keymap({"n", "v", "i"}, "<D-0>", ":messages<CR>")
keymap({"n", "v", "i"}, "<D-9>", ":Notification<CR>")

-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
g.VM_maps = {
	["Find Under"] = "<D-j>", -- cmd+j
	["Visual Add"] = "<D-j>",
	["Select Cursor Up"] = "<M-Up>", -- opt+up
	["Select Cursor Down"] = "<M-Down>",
}

-- cut, copy & paste
keymap("n", "<D-c>", "yy") -- no selection = line
keymap("v", "<D-c>", "y")
keymap("n", "<D-x>", "dd") -- no selection = line
keymap("v", "<D-x>", "d")
keymap({"n", "v"}, "<D-v>", "p")
keymap("c", "<D-v>", "<C-r>+")
keymap("i", "<D-v>", qol.insertModePasteFix)

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>") -- no selection = word under cursor
keymap("v", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>")
keymap("i", "<D-e>", "``<Left>")

-- cmd+t: Template string
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>") -- no selection = word under cursor
keymap("v", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>")
keymap("i", "<D-t>", "${}<Left>")

local delta = 1.1
keymap({"n", "v", "i"}, "<D-+>", function()
	g.neovide_scale_factor = g.neovide_scale_factor * delta
end)
keymap({"n", "v", "i"}, "<D-->", function()
	g.neovide_scale_factor = g.neovide_scale_factor / delta
end)

--------------------------------------------------------------------------------

-- NEOVIDE
-- https://neovide.dev/configuration.html

g.neovide_cursor_animation_length = 0.01
g.neovide_cursor_trail_size = 0.9
g.neovide_scroll_animation_length = 2
g.neovide_floating_blur_amount_x = 5.0
g.neovide_floating_blur_amount_y = 5.0
g.neovide_cursor_unfocused_outline_width = 0.1
g.neovide_underline_automatic_scaling = true -- slightly unstable according to docs

g.neovide_cursor_vfx_mode = "railgun"
g.neovide_cursor_vfx_particle_lifetime = 1
g.neovide_cursor_vfx_particle_density = 20.0
g.neovide_cursor_vfx_particle_speed = 25.0
g.neovide_cursor_vfx_particle_phase = 1.3 -- only railgun
g.neovide_cursor_vfx_particle_curl = 1.3 -- only railgun

g.neovide_confirm_quit = false
g.neovide_input_use_logo = true -- logo = `cmd` (on macOS)
g.neovide_hide_mouse_when_typing = true
g.neovide_remember_window_size = true

g.neovide_input_macos_alt_is_meta = true -- makes `opt` usable on macOS
-- needed when alt is turned into meta key
keymap({"n", "v"}, "<M-l>", "@")
keymap("i", "<M-.>", "…")
keymap("i", "<M-->", "–")

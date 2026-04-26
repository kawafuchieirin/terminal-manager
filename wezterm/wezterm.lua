local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 外観
config.font_size = 14
config.hide_tab_bar_if_only_one_tab = true

-- 挙動
config.window_close_confirmation = "NeverPrompt"

return config

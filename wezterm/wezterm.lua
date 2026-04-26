local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- =========================
-- フォント
-- =========================
-- UDEV Gothic 35LG: BIZ UDGothic + JetBrains Mono (UD系で視認性最重視)+リガチャ
-- Nerd Font アイコンは HackGen Console NF にフォールバック
-- 透過背景でもくっきり読めるよう Bold weight + サイズ大き目
config.font = wezterm.font_with_fallback({
  { family = "UDEV Gothic 35LG", weight = "Bold" },
  { family = "HackGen Console NF", weight = "Bold" },
  { family = "Hiragino Sans" },
})
config.font_size = 15.0
config.line_height = 1.15
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.bold_brightens_ansi_colors = true
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- =========================
-- カラースキーム
-- =========================
config.color_scheme = "Tokyo Night"

-- =========================
-- ウィンドウ
-- =========================
config.window_background_opacity = 1
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.initial_cols = 120
config.initial_rows = 36

-- =========================
-- タブバー
-- =========================
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- =========================
-- ペイン
-- =========================
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

-- =========================
-- 挙動
-- =========================
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 10000
config.use_ime = true

-- =========================
-- パフォーマンス
-- =========================
config.front_end = "WebGpu"
config.max_fps = 120
config.check_for_updates = false

-- =========================
-- キーバインド (macOS)
-- =========================
config.keys = {
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "[", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Prev") },
  { key = "]", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Next") },
  {
    key = "k",
    mods = "CMD",
    action = wezterm.action.Multiple({
      wezterm.action.ClearScrollback("ScrollbackAndViewport"),
      wezterm.action.SendKey({ key = "L", mods = "CTRL" }),
    }),
  },

  -- 透過トグル (設定ファイル値 <-> 1.0)
  {
    key = "o",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        overrides.window_background_opacity = config.window_background_opacity
      else
        overrides.window_background_opacity = 1.0
      end
      window:set_config_overrides(overrides)
      window:toast_notification("WezTerm",
        string.format("Opacity: %.2f", overrides.window_background_opacity), nil, 1500)
    end),
  },
  -- 透明度を上げる (より不透明に)
  {
    key = "=",
    mods = "CMD|SHIFT",
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      local current = overrides.window_background_opacity or config.window_background_opacity
      overrides.window_background_opacity = math.min(1.0, current + 0.05)
      window:set_config_overrides(overrides)
      window:toast_notification("WezTerm",
        string.format("Opacity: %.2f", overrides.window_background_opacity), nil, 1500)
    end),
  },
  -- 透明度を下げる (より透ける)
  {
    key = "-",
    mods = "CMD|SHIFT",
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      local current = overrides.window_background_opacity or config.window_background_opacity
      overrides.window_background_opacity = math.max(0.0, current - 0.05)
      window:set_config_overrides(overrides)
      window:toast_notification("WezTerm",
        string.format("Opacity: %.2f", overrides.window_background_opacity), nil, 1500)
    end),
  },
}

return config

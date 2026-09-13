local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- =========================
-- フォント
-- =========================
-- PlemolJP Console NF: IBM Plex Mono + IBM Plex Sans JP ベースの UD 等幅。
-- 透過背景でも特に視認性が高く、Nerd Font アイコンも内蔵。
-- フォールバックは UDEV Gothic 35LG / HackGen Console NF / Hiragino Sans。
config.font = wezterm.font_with_fallback({
  { family = "PlemolJP Console NF", weight = "Bold" },
  { family = "UDEV Gothic 35LG", weight = "Bold" },
  { family = "HackGen Console NF", weight = "Bold" },
  { family = "Hiragino Sans" },
})
config.font_size = 15.0
config.line_height = 1.15
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.bold_brightens_ansi_colors = true
-- 透過背景での色滲み（フリンジ）を抑えるため LCD サブピクセルではなく
-- グレースケール AA（Normal）でレンダリング。Light hinting で細部のシャープさは維持。
config.freetype_load_target = "Light"
config.freetype_render_target = "Normal"

-- =========================
-- カラースキーム
-- =========================
config.color_scheme = "Tokyo Night"

-- =========================
-- ウィンドウ
-- =========================
-- フォーカス時は読みやすさ重視で不透明寄り、非アクティブ時は透けて背景が見える
local FOCUSED_OPACITY = 0.85
local UNFOCUSED_OPACITY = 0.5
config.window_background_opacity = FOCUSED_OPACITY
config.macos_window_background_blur = 20

wezterm.on("window-focus-changed", function(window, _)
  local overrides = window:get_config_overrides() or {}
  overrides.window_background_opacity = window:is_focused() and FOCUSED_OPACITY or UNFOCUSED_OPACITY
  window:set_config_overrides(overrides)
end)
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
config.colors = { split = "#7aa2f7" }

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
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "[", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Prev") },
  { key = "]", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Next") },
  { key = "LeftArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "LeftArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
  { key = "RightArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
  { key = "UpArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
  { key = "DownArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
  { key = "Enter", mods = "CMD|SHIFT", action = wezterm.action.TogglePaneZoomState },
  { key = "r", mods = "CMD|SHIFT", action = wezterm.action.RotatePanes("Clockwise") },
  { key = "s", mods = "CMD|SHIFT", action = wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
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

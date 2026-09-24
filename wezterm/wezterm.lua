local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

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

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local background = tab.is_active and "#e0af68" or "#3b4261"
  local foreground = tab.is_active and "#1a1b26" or "#c0caf5"
  local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
  }
end)

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
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 } -- kb: Leader：続けて次のキーを入力
config.keys = {
  { key = "w", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }) }, -- kb: ワークスペース一覧
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode }, -- kb: コピーモード
  { key = "d", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- kb: 上下にペイン分割
  { key = "r", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- kb: 左右にペイン分割
  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) }, -- kb: 確認付きでペインを閉じる
  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") }, -- kb: 左のペインへ移動
  { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") }, -- kb: 下のペインへ移動
  { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") }, -- kb: 上のペインへ移動
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") }, -- kb: 右のペインへ移動
  { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState }, -- kb: ペイン最大化 / 解除
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") }, -- kb: 新規タブ
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) }, -- kb: 確認なしで現在のペインを閉じる
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) }, -- kb: 1番目のタブへ移動
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) }, -- kb: 2番目のタブへ移動
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) }, -- kb: 3番目のタブへ移動
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- kb: 左右にペイン分割
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- kb: 上下にペイン分割
  { key = "[", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Prev") }, -- kb: 前のペインへ移動
  { key = "]", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Next") }, -- kb: 次のペインへ移動
  { key = "LeftArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Left") }, -- kb: 左のペインへ移動
  { key = "RightArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Right") }, -- kb: 右のペインへ移動
  { key = "UpArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Up") }, -- kb: 上のペインへ移動
  { key = "DownArrow", mods = "CMD|ALT", action = wezterm.action.ActivatePaneDirection("Down") }, -- kb: 下のペインへ移動
  { key = "LeftArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) }, -- kb: ペイン境界を左へ1セル移動
  { key = "RightArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) }, -- kb: ペイン境界を右へ1セル移動
  { key = "UpArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) }, -- kb: ペイン境界を上へ1セル移動
  { key = "DownArrow", mods = "CMD|CTRL", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) }, -- kb: ペイン境界を下へ1セル移動
  { key = "Enter", mods = "CMD|SHIFT", action = wezterm.action.TogglePaneZoomState }, -- kb: ペイン最大化 / 解除
  { key = "r", mods = "CMD|SHIFT", action = wezterm.action.RotatePanes("Clockwise") }, -- kb: ペイン配置を時計回りに入れ替え
  { key = "s", mods = "CMD|SHIFT", action = wezterm.action.PaneSelect({ mode = "SwapWithActive" }) }, -- kb: 選択したペインと現在のペインを入れ替え
  {
    key = "k", mods = "CMD", -- kb: 画面・スクロールバックをクリア
    action = wezterm.action.Multiple({
      wezterm.action.ClearScrollback("ScrollbackAndViewport"),
      wezterm.action.SendKey({ key = "L", mods = "CTRL" }),
    }),
  },

  -- Ctrl+C: 選択中のテキストがあればコピー、なければ従来どおり SIGINT を送る。
  -- 選択したまま実行中のコマンドを止めたいときは、Esc か左クリックで選択を外してから押す。
  {
    key = "c", mods = "CTRL", -- kb: 選択中ならコピー、選択がなければ中断（SIGINT）
    action = wezterm.action_callback(function(window, pane)
      local selection = window:get_selection_text_for_pane(pane)
      if selection and selection ~= "" then
        window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(wezterm.action.ClearSelection, pane)
      else
        window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
      end
    end),
  },

  -- 透過トグル (設定ファイル値 <-> 1.0)
  {
    key = "o", mods = "CTRL|SHIFT", -- kb: 背景透過のオン / オフ
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
    key = "=", mods = "CMD|SHIFT", -- kb: 不透明度を0.05上げる（最大1.0）
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
    key = "-", mods = "CMD|SHIFT", -- kb: 不透明度を0.05下げる（最小0.0）
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

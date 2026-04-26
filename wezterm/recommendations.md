# WezTerm おすすめ設定

macOS 環境を前提とした WezTerm のおすすめ設定リファレンス。現状の `wezterm.lua` は最小構成のため、必要な項目を取捨選択して取り込む。

## 目次

1. [フォント](#フォント)
2. [外観・カラースキーム](#外観カラースキーム)
3. [ウィンドウ・パディング](#ウィンドウパディング)
4. [タブバー](#タブバー)
5. [キーバインド（macOS）](#キーバインドmacos)
6. [ペイン分割](#ペイン分割)
7. [スクロールバック](#スクロールバック)
8. [日本語入力（IME）](#日本語入力ime)
9. [パフォーマンス](#パフォーマンス)
10. [便利機能](#便利機能)
11. [完成版サンプル](#完成版サンプル)

---

## フォント

プログラミング向けフォント＋日本語フォントのフォールバックを設定する。

```lua
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Regular" },
  { family = "HackGen Console NF" },           -- 日本語含むプログラミング向けフォント
  { family = "Hiragino Sans", weight = "Regular" }, -- macOS標準日本語フォント
})
config.font_size = 14.0
config.line_height = 1.1
config.cell_width = 1.0

-- リガチャ（=>, !=, --> 等の合字）を有効化
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
```

**おすすめフォント（brew install --cask 可）**:

| フォント | 特徴 |
|---------|------|
| `font-jetbrains-mono` | リガチャ対応、視認性高い、デファクトスタンダード |
| `font-hackgen-nerd` | 日本語＋Nerd Fontアイコン同梱、英数2:全角3比率で揃う |
| `font-fira-code` | リガチャ豊富、英数のみ |
| `font-cascadia-code` | Microsoft製、英数のみ |

## 外観・カラースキーム

WezTerm 同梱の人気スキームを使う。

```lua
-- 同梱スキームから選択（公式 https://wezfurlong.org/wezterm/colorschemes/index.html）
config.color_scheme = "Tokyo Night"  -- 他の候補: "Catppuccin Mocha", "Dracula", "Gruvbox Dark"

-- 背景透過とブラー（macOSのみ blur 効果あり）
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20
```

**人気スキーム**:

| スキーム名 | 系統 |
|-----------|------|
| `Tokyo Night` | 暗紫系、人気No.1クラス |
| `Catppuccin Mocha` | パステル暗色、目に優しい |
| `Dracula` | ヴィヴィッド暗色 |
| `Gruvbox Dark` | レトロ暖色 |
| `Solarized Dark` | クラシック |

スキーム一覧は `wezterm ls-fonts --list-system` ではなく公式サイトで確認。

## ウィンドウ・パディング

```lua
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- macOS のタイトルバーを非表示（ペイン領域を最大化）
config.window_decorations = "RESIZE"

-- ウィンドウ初期サイズ
config.initial_cols = 120
config.initial_rows = 36
```

`window_decorations` の選択肢:

| 値 | 効果 |
|----|------|
| `"TITLE \| RESIZE"` | デフォルト（タイトルバー＋リサイズ可） |
| `"RESIZE"` | タイトルバー非表示。macOSではドラッグ用の薄いバーのみ残る |
| `"NONE"` | 完全な枠なし。ドラッグ・リサイズも不可になるため非推奨 |

## タブバー

```lua
config.use_fancy_tab_bar = false        -- シンプルなテキストタブバー
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true          -- タブバーを下に
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32
```

## キーバインド（macOS）

WezTerm のデフォルトは Linux 寄りのため、macOS 慣習に合わせるとよい。

```lua
config.keys = {
  -- Cmd+T: 新規タブ
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Cmd+W: タブを閉じる（確認なし）
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  -- Cmd+1..9: タブ切り替え
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },

  -- Cmd+D: 横分割（縦線で区切る）
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  -- Cmd+Shift+D: 縦分割
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Cmd+[/]: ペイン移動
  { key = "[", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Prev") },
  { key = "]", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Next") },

  -- Cmd+K: 画面クリア＋スクロールバッククリア
  { key = "k", mods = "CMD", action = wezterm.action.Multiple({
      wezterm.action.ClearScrollback("ScrollbackAndViewport"),
      wezterm.action.SendKey({ key = "L", mods = "CTRL" }),
  })},
}
```

## ペイン分割

キーバインドだけでなく、デフォルトの挙動もチューニング。

```lua
-- ペイン境界線の色
config.colors = {
  split = "#444444",
}

-- ペイン非アクティブ時を少し暗く
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.7,
}
```

## スクロールバック

```lua
config.scrollback_lines = 10000
config.enable_scroll_bar = true
config.min_scroll_bar_height = "2cell"
```

## 日本語入力（IME）

macOS のことえり / Google 日本語入力 / かわせみ等を WezTerm 内で快適に使うための設定。

```lua
-- IMEを有効化（macOS では必須に近い）
config.use_ime = true

-- 変換中の見た目調整（オプション）
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"
```

**注意**: `use_ime = false` のままだと「英かな」キーで切り替えても日本語入力できない。

## パフォーマンス

```lua
-- フロントエンドを WebGpu に（macOS では Metal を使う）
config.front_end = "WebGpu"

-- フレームレート上限（リフレッシュレートに合わせる）
config.max_fps = 120

-- 起動時にネットワーク経由で更新確認しない
config.check_for_updates = false
```

`front_end` の選択肢:

| 値 | 特徴 |
|----|------|
| `"WebGpu"` | 推奨。GPU を使い高速 |
| `"OpenGL"` | 互換性重視 |
| `"Software"` | GPUなし（旧Mac等） |

## 便利機能

### Quick Select Mode（URL・パス選択）

`Ctrl+Shift+Space` で URL や Git ハッシュにラベルを表示し、キー入力で選択＋コピー。デフォルトで有効。

```lua
config.disable_default_quick_select_patterns = false
```

### ハイパーリンク自動検出

```lua
-- URL 等を自動でクリック可能リンクに（Cmd+Click で開く）
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- 追加で `file://` パスや GitHub Issue 番号を検出
table.insert(config.hyperlink_rules, {
  regex = [[\b#(\d+)\b]],
  format = "https://github.com/$YOUR_ORG/$YOUR_REPO/issues/$1",
})
```

### 起動時のコマンド

```lua
-- デフォルトシェルを明示
config.default_prog = { "/bin/zsh", "-l" }

-- 起動時の作業ディレクトリ
config.default_cwd = wezterm.home_dir
```

### ウィンドウクローズ確認

現状は `NeverPrompt` だが、複数ペイン使用時の誤クローズが気になる場合:

```lua
config.window_close_confirmation = "AlwaysPrompt"
```

## 完成版サンプル

そのまま `wezterm.lua` に置き換え可能なバランス重視の設定。

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- フォント
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Regular" },
  { family = "Hiragino Sans" },
})
config.font_size = 14.0
config.line_height = 1.1
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- カラースキーム
config.color_scheme = "Tokyo Night"

-- ウィンドウ
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.initial_cols = 120
config.initial_rows = 36

-- タブバー
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- ペイン
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

-- スクロールバック
config.scrollback_lines = 10000

-- IME
config.use_ime = true

-- パフォーマンス
config.front_end = "WebGpu"
config.max_fps = 120
config.check_for_updates = false

-- 挙動
config.window_close_confirmation = "NeverPrompt"

-- キーバインド（macOS）
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
  { key = "k", mods = "CMD", action = wezterm.action.Multiple({
      wezterm.action.ClearScrollback("ScrollbackAndViewport"),
      wezterm.action.SendKey({ key = "L", mods = "CTRL" }),
  })},
}

return config
```

## 参考リンク

- [WezTerm 公式ドキュメント](https://wezfurlong.org/wezterm/)
- [カラースキーム一覧](https://wezfurlong.org/wezterm/colorschemes/index.html)
- [Lua API リファレンス](https://wezfurlong.org/wezterm/config/lua/general.html)
- [キーアサイメント](https://wezfurlong.org/wezterm/config/keys.html)

# WezTerm

ターミナルエミュレータ [WezTerm](https://wezfurlong.org/wezterm/) の設定。実体は `wezterm/wezterm.lua`
で、`setup.sh` が `~/.config/wezterm/` をこのディレクトリへのシンボリックリンクとして張る。

| ファイル | 役割 |
|---------|------|
| `wezterm.lua` | 実際に読み込まれる設定（唯一の情報源） |
| `recommendations.md` | おすすめ設定のリファレンス。採用候補のメモで、動作には影響しない |

Nerd Font + Tokyo Night + 透過 + Powerlevel10k 風プロンプト（Starship）を前提にした構成。

## インストール

`setup.sh` が `wezterm@nightly`（nightly ビルド = 事実上のメインライン）とフォント 3 種を導入する。
安定版 `wezterm` が入っている場合は自動でアンインストールして nightly に置き換える。

設定を反映するには **`Cmd+Q` で完全終了してから再起動** する（フォント・カラースキーム・透過は
再起動しないと反映されないことがある）。

## フォント

`font_with_fallback` で 4 段のフォールバックを構成している。

| 優先 | フォント | 役割 |
|-----|---------|------|
| 1 | PlemolJP Console NF (Bold) | IBM Plex Mono + IBM Plex Sans JP ベースの UD 等幅。透過背景でも視認性が高く、Nerd Font アイコンを内蔵 |
| 2 | UDEV Gothic 35LG (Bold) | UD 系フォールバック |
| 3 | HackGen Console NF (Bold) | Nerd Font アイコンのフォールバック |
| 4 | Hiragino Sans | macOS 標準の日本語フォント |

| 設定 | 値 | 意図 |
|------|-----|------|
| `font_size` | 15.0 | 透過時の視認性を優先して大きめ |
| `line_height` | 1.15 | 行間にゆとりを持たせる |
| `harfbuzz_features` | `calt=1` / `clig=1` / `liga=1` | リガチャ（`=>`・`!=` 等）を有効化 |
| `bold_brightens_ansi_colors` | `true` | ANSI ボールドを明色化してコントラストを上げる |
| `freetype_load_target` | `"Light"` | Light hinting で細部のシャープさを維持 |
| `freetype_render_target` | `"Normal"` | グレースケール AA。LCD サブピクセル描画による透過時の色滲み（フリンジ）を避ける |

## 外観

| 設定 | 値 | 意図 |
|------|-----|------|
| `color_scheme` | Tokyo Night | 暗紫系。Starship / fzf / bat の配色もこれに合わせている |
| `colors.split` | `#7aa2f7` | ペイン境界線の色 |
| `window_background_opacity` | 0.85（フォーカス時）/ 0.5（非アクティブ時） | `window-focus-changed` イベントで自動切替。作業中は読みやすく、離席中は背景が透ける |
| `macos_window_background_blur` | 20 | すりガラス風ブラー |
| `window_decorations` | `RESIZE` | タイトルバーを省いて表示領域を稼ぐ |
| `window_padding` | 上下左右 8px | |
| `initial_cols` / `initial_rows` | 120 / 36 | 起動時のウィンドウサイズ |
| `inactive_pane_hsb` | saturation 0.9 / brightness 0.7 | 非アクティブペインを暗くして現在位置を示す |

透過の既定値は `wezterm.lua` 冒頭の `FOCUSED_OPACITY` / `UNFOCUSED_OPACITY` で調整する。
一時的な変更はキーバインド（`Ctrl+Shift+O` / `Cmd+Shift++` / `Cmd+Shift+-`）で行える。

### タブバー

| 設定 | 値 | 意図 |
|------|-----|------|
| `use_fancy_tab_bar` | `false` | テキスト式のタブバー |
| `tab_bar_at_bottom` | `true` | 下部に配置 |
| `hide_tab_bar_if_only_one_tab` | `true` | タブが 1 つなら非表示 |
| `show_new_tab_button_in_tab_bar` | `false` | 新規タブ `+` ボタンを非表示 |
| `format-tab-title` | アクティブ: 金色 `#e0af68` / 非アクティブ: 暗青 `#3b4261` | ペインのタイトルを表示幅に合わせて右側を省略 |

## 挙動・パフォーマンス

| 設定 | 値 | 意図 |
|------|-----|------|
| `automatically_reload_config` | `true` | 設定を保存すると自動リロード |
| `window_close_confirmation` | `NeverPrompt` | クローズ確認を出さない |
| `scrollback_lines` | 10000 | |
| `use_ime` | `true` | macOS の IME（ことえり等）に対応 |
| `front_end` | `WebGpu` | GPU レンダリング |
| `max_fps` | 120 | |
| `check_for_updates` | `false` | 自動更新チェックを無効化（更新は `brew` 経由） |

## キーバインド（macOS）

`Leader` は `Ctrl+Q`。押してから **2 秒以内**（`timeout_milliseconds = 2000`）に次のキーを入力する。

| キー | 動作 |
|------|------|
| `Leader` → `w` | ワークスペース一覧を開く |
| `Leader` → `[` | コピーモードに入る |
| `Leader` → `d` / `r` | 上下 / 左右にペインを分割 |
| `Leader` → `x` | 確認付きで現在のペインを閉じる |
| `Leader` → `h` / `j` / `k` / `l` | 左 / 下 / 上 / 右のペインへ移動 |
| `Leader` → `z` | ペインの最大化 / 解除 |

| キー | 動作 |
|------|------|
| `Cmd+T` | 新規タブ |
| `Cmd+W` | 確認なしで現在のペインを閉じる（最後の 1 ペインならタブも閉じる） |
| `Cmd+1` 〜 `Cmd+3` | 1 〜 3 番目のタブへ移動 |
| `Cmd+D` / `Cmd+Shift+D` | 左右 / 上下にペインを分割 |
| `Cmd+[` / `Cmd+]` | 前 / 次のペインへ移動 |
| `Cmd+Opt+←↓↑→` | 方向でペインを移動 |
| `Cmd+Ctrl+←↓↑→` | ペイン境界を 1 セル動かしてサイズ調整 |
| `Cmd+Shift+Enter` | ペインの最大化 / 解除 |
| `Cmd+Shift+R` | ペイン配置を時計回りに入れ替え |
| `Cmd+Shift+S` | 選択したペインと現在のペインを入れ替え |
| `Cmd+K` | 画面とスクロールバックをクリア |
| `Ctrl+C` | 選択中のテキストがあればコピー、なければ中断（SIGINT） |
| `Ctrl+Shift+O` | 背景透過のオン / オフ（設定値 ⇔ `1.0`） |
| `Cmd+Shift++`（`=` キー） | 不透明度を 0.05 上げる（最大 1.0） |
| `Cmd+Shift+-` | 不透明度を 0.05 下げる（最小 0.0） |

透過を変える 3 つのキーは、変更後の値をトースト通知で 1.5 秒表示する。

### Ctrl+C の二役

Windows / Linux と同じ感覚でコピーできるよう、`Ctrl+C` を「選択があればコピー、なければ SIGINT」に
振り分けている（`window:get_selection_text_for_pane` で選択の有無を判定）。コピー先はクリップボードと
プライマリセレクションの両方で、コピー後は選択を解除する。

**選択を残したまま実行中のコマンドを止めようとすると、中断ではなくコピーになる。**
`Esc` かペイン内の左クリックで選択を外してから `Ctrl+C` を押す。`Cmd+C`（WezTerm 既定）は
これまでどおりコピー専用なので、確実に中断したいときと使い分ける。

一覧は [`kb` コマンド](../zsh/README.md#キーバインドの横断検索)でも検索できる。
キーを追加・変更したときは、同じ行の `-- kb:` コメントも更新する（`kb` はこのコメントを読み取る）。

```lua
-- key と mods は同じ行に文字列で書き、行末に説明コメントを添える
{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") }, -- kb: 新規タブ
```

## 設定の再読み込み

`automatically_reload_config = true` のため、`wezterm.lua` を保存すれば自動で反映される。
手動で再読み込みする場合は `Ctrl+Shift+R`（WezTerm の既定キー）。
Lua の構文エラーがある場合はエラーが通知され、直前の設定が維持される。

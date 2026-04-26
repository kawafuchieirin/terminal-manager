# terminal-manager

macOS 開発環境のターミナル一式（WezTerm + Zsh + Starship）を Git 管理し、`setup.sh` 一発で再現するリポジトリ。`setup-terminal`（Ghostty 版）の後継。

## セットアップ

### 前提条件

- [Homebrew](https://brew.sh/) がインストール済み

### 実行

```bash
git clone <このリポジトリのURL> ~/work-space/terminal-manager
cd ~/work-space/terminal-manager
chmod +x setup.sh
./setup.sh
```

`setup.sh` は冪等で、何度実行しても安全。

### setup.sh が行うこと

1. Homebrew パッケージのインストール
   - cask: `wezterm@nightly`（nightly ビルド = 事実上のメイン）, `font-udev-gothic`（UD系で視認性最重視）, `font-hackgen-nerd`（Nerd Font アイコン用フォールバック）
   - formula: `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `fd`, `ripgrep`, `bat`, `pre-commit`, `gitleaks`, `shellcheck`
   - 既存の安定版 `wezterm` が入っている場合は自動で nightly に置き換え
2. WezTerm 設定のシンボリックリンク作成（`~/.config/wezterm/`）
3. Starship 設定のシンボリックリンク作成（`~/.config/starship.toml`）
4. Zsh 設定のシンボリックリンク作成（`~/.config/zsh/`）+ `~/.zshrc` に source 行を追加
5. pre-commit フックのインストール（`.git/hooks/pre-commit`）

セットアップ完了後は **WezTerm を `Cmd+Q` で完全終了→再起動** すると、フォント・カラースキーム・透過などが反映される。

## 構成

| パス | 内容 |
|------|------|
| `setup.sh` | セットアップスクリプト（パッケージインストール + シンボリックリンク作成 + pre-commit インストール） |
| `wezterm/wezterm.lua` | [WezTerm](https://wezfurlong.org/wezterm/) ターミナルエミュレータの設定 |
| `wezterm/recommendations.md` | WezTerm のおすすめ設定リファレンス（採用候補のメモ） |
| `starship/starship.toml` | [Starship](https://starship.rs/) プロンプトの設定 |
| `zsh/.zshrc` | Zsh のメイン設定（プラグイン読み込み・キーバインド・fzf×fd×bat 連携） |
| `zsh/aliases.zsh` | シェルエイリアス定義 |
| `zsh/hidden/` | 環境固有の設定（Git 管理外、`.zsh` ファイルを自動読み込み） |
| `.pre-commit-config.yaml` | [pre-commit](https://pre-commit.com/) フック定義（シークレット検出・基本チェック・shell lint） |

## WezTerm

開発者向けにチューニングした構成。Nerd Font + Tokyo Night + 透過 + Powerlevel10k 風プロンプトに対応。

### 主要設定

| カテゴリ | 設定 | 値 | 説明 |
|---------|------|-----|------|
| フォント | `font` | UDEV Gothic 35LG (Bold) → HackGen Console NF (Bold) → Hiragino Sans | UD系で視認性最重視。透過背景でもくっきり見える Bold ウェイト |
| | `font_size` | 15.0 | 透過時の視認性向上のため大き目 |
| | `line_height` | 1.15 | 行間を少しゆとりを持たせて視認性UP |
| | `harfbuzz_features` | `calt=1, clig=1, liga=1` | リガチャ有効化（`=>`, `!=` 等。LG バリアント使用時のみ作動） |
| | `bold_brightens_ansi_colors` | `true` | ANSI ボールドテキストを明色化してコントラスト UP |
| | `freetype_load_target` | `"Light"` / `"HorizontalLcd"` | 透過時のにじみ抑制＋サブピクセル描画 |
| カラー | `color_scheme` | Tokyo Night | 暗紫系の人気スキーム |
| ウィンドウ | `window_background_opacity` | 0.92 | 背景透過 |
| | `macos_window_background_blur` | 20 | すりガラス風ブラー |
| | `window_decorations` | `RESIZE` | タイトルバー削減 |
| | `window_padding` | 8px (上下左右) | |
| タブバー | `use_fancy_tab_bar` | `false` | テキスト式 |
| | `tab_bar_at_bottom` | `true` | 下部配置 |
| | `hide_tab_bar_if_only_one_tab` | `true` | タブ1つなら非表示 |
| ペイン | `inactive_pane_hsb` | sat 0.9 / br 0.7 | 非アクティブを暗く |
| 挙動 | `window_close_confirmation` | `NeverPrompt` | クローズ確認なし |
| | `scrollback_lines` | 10000 | |
| | `use_ime` | `true` | macOS IME（ことえり等）対応 |
| 性能 | `front_end` | `WebGpu` | GPU レンダリング |
| | `max_fps` | 120 | |

### キーバインド (macOS)

| キー | 動作 |
|------|------|
| `Cmd+T` / `Cmd+W` | 新規タブ / タブを閉じる |
| `Cmd+1`〜`Cmd+3` | タブ切り替え |
| `Cmd+D` / `Cmd+Shift+D` | 横分割 / 縦分割 |
| `Cmd+[` / `Cmd+]` | ペイン移動 |
| `Cmd+K` | 画面・スクロールバッククリア |
| `Ctrl+Shift+O` | 背景透過のオン/オフをトグル（`window_background_opacity` の設定値 ⇔ `1.0`） |
| `Cmd+Shift++` | 透明度を上げる（より不透明に、`+0.05`、最大 `1.0`） |
| `Cmd+Shift+-` | 透明度を下げる（より透ける、`-0.05`、最小 `0.0`） |

設定ファイル保存で自動リロードされる。手動リロードは `Ctrl+Shift+R`。透過具合は `window_background_opacity` を `0.85`〜`1.0` で調整。

## Zsh

### プラグイン・連携ツール

| ツール | 役割 | 連携 |
|--------|------|------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish 風の自動補完 | `setup.sh` で導入 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Fish 風のシンタックスハイライト | `setup.sh` で導入 |
| [fzf](https://github.com/junegunn/fzf) | 曖昧検索（履歴・ファイル・ディレクトリ） | Tokyo Night 配色＋ボーダー＋reverse layout |
| [fd](https://github.com/sharkdp/fd) | `find` の高速代替 | `FZF_DEFAULT_COMMAND` / `FZF_ALT_C_COMMAND` のバックエンドとして連携、`.gitignore` を尊重 |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` の高速代替 | デフォルトで `.gitignore` を尊重しサブディレクトリを再帰検索 |
| [bat](https://github.com/sharkdp/bat) | `cat` の代替（ハイライト+Git diff） | fzf の `Ctrl+T` プレビューで使用、`BAT_THEME=TwoDark` |
| [mise](https://mise.jdx.dev/) | 言語ランタイム・CLI ツールのバージョン管理 | `.zshrc` で `mise activate zsh` を呼び出し（任意導入：未インストールならスキップ） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 高速ディレクトリジャンプ（`z` コマンド） | `.zshrc` で `zoxide init zsh` を呼び出し、`cd` を `z` にエイリアス（任意導入） |

`mise` と `zoxide` は `setup.sh` のインストール対象外（任意の追加ツール）。利用したい場合は別途 `brew install mise zoxide` を実行する。

### キーバインド

| キー | 動作 |
|------|------|
| `↑` / `↓` | 現在の入力にマッチする履歴を検索 |
| `Ctrl+W` / `Alt+Backspace` | パス区切りで止まる単語削除（`WORDCHARS=''`） |
| `Ctrl+R` | fzf でコマンド履歴を曖昧検索 |
| `Ctrl+T` | fzf でカレント配下のファイルを曖昧検索して挿入 |
| `Alt+C` | fzf でカレント配下のディレクトリを曖昧検索して `cd` |
| `**` + `Tab` | fzf 補完（パス・プロセス等を曖昧検索） |

### エイリアス

#### Git

| エイリアス | コマンド |
|-----------|---------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gpl` | `git pull` |

#### ナビゲーション・ファイル操作

| エイリアス | コマンド |
|-----------|---------|
| `..` / `...` / `....` | 上のディレクトリへ移動 |
| `ls` | `ls -G`（カラー） |
| `ll` | `ls -lah` |
| `la` | `ls -a` |
| `rm` / `cp` / `mv` | 確認付き（`-i`） |
| `cd` | `z`（zoxide） |

#### ショートカット

| エイリアス | コマンド |
|-----------|---------|
| `c` | `clear` |
| `h` | `history` |
| `v` / `vi` | `nvim` |

#### Docker

| エイリアス | コマンド |
|-----------|---------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |

#### Claude

| エイリアス | コマンド |
|-----------|---------|
| `cc` | `claude --dangerously-skip-permissions` |

### 環境変数

| 変数 | 値 | 用途 |
|------|-----|------|
| `LANG` | `en_US.UTF-8` | ロケール |
| `EDITOR` | `nvim` | デフォルトエディタ |
| `WORDCHARS` | `''` | 単語削除をパス区切りで止める |
| `FZF_DEFAULT_OPTS` | （Tokyo Night 配色等） | fzf の見た目 |
| `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` | `fd --type f --hidden --follow --exclude .git` | fd 連携 |
| `FZF_ALT_C_COMMAND` | `fd --type d --hidden --follow --exclude .git` | fd によるディレクトリ検索 |
| `FZF_CTRL_T_OPTS` | `--preview 'bat ...'` | `Ctrl+T` 時のシンタックスハイライト付きプレビュー |
| `BAT_THEME` | `TwoDark` | bat の配色（Tokyo Night と相性◎） |

### hidden/ ディレクトリ

`~/.config/zsh/hidden/` に `.zsh` ファイルを置くと自動的に読み込まれる。API キーや PC 固有の PATH 設定など、Git 管理に含めたくない設定用。

## Starship

二段プロンプト。Nerd Font のアイコン表示前提（`font-hackgen-nerd` 等を使用）。

### 表示要素

```
   ~/path  on   main [+1!2?3]  via   v20.10.0  on   prod
❯
```

| セグメント | 内容 |
|-----------|------|
|  | OS アイコン（macOS / Linux / Ubuntu） |
|  ディレクトリ | カレントディレクトリ（リポジトリルートからの相対、3階層で省略） |
|   ブランチ | Git ブランチ名（Nerd Font アイコン付き） |
| `[+1!2?3]` | Git ステータス（staged/modified/untracked/deleted/conflicted/ahead/behind） |
|  /  /  /  /  /  /  | 言語ランタイムバージョン（Node/Python/Go/Rust/Java/Ruby/PHP） |
|  /  ☸ /  /  | Docker context / Kubernetes context / AWS profile / GCP account |
| 右プロンプト | コマンド実行時間（500ms 以上）+ 現在時刻 |

### カスタマイズ

`starship/starship.toml` を直接編集。アイコンが豆腐（□）になる場合は WezTerm が Nerd Font を読み込めていない可能性があるため、`font-hackgen-nerd` のインストールと WezTerm の再起動を確認。

## pre-commit

`setup.sh` が `pre-commit install` まで実行するため、コミット時に自動でフックが走る。シークレットの誤コミットを物理的に防ぐのが主目的。

### 適用フック

| フック | 役割 |
|--------|------|
| [gitleaks](https://github.com/gitleaks/gitleaks) | API キー・トークン等のシークレット検出（Slack・AWS・GCP 等の主要パターンを網羅） |
| `detect-private-key` | SSH/PEM 等の秘密鍵を検出 |
| `check-added-large-files` | 1MB 超のファイルコミットをブロック |
| `check-merge-conflict` | マージ競合マーカーの残存を検出 |
| `trailing-whitespace` / `end-of-file-fixer` | 行末空白・末尾改行の整形 |
| [shellcheck](https://www.shellcheck.net/) | `setup.sh` 等のシェルスクリプト lint |

### 運用

```bash
pre-commit run --all-files   # 全ファイルに対して手動実行
pre-commit autoupdate        # 各フックのバージョンを最新化
```

誤検出が発生した場合は `.pre-commit-config.yaml` 側で除外設定を追加する。シークレットの真陽性が出た場合は **コミットせずローテーション**（再発行・無効化）を最優先で行う。

## 設計方針

- **ポータビリティ**: `setup.sh` 一発で環境構築が完了する
- **冪等性**: 何度実行しても同じ結果になる
- **環境固有設定の分離**: PC 固有の値・シークレットは `zsh/hidden/` に分離し Git 管理外で扱う
- **シークレット流出の予防**: pre-commit + gitleaks でコミット時に検査し、誤って公開リポジトリへ push される事故を防ぐ

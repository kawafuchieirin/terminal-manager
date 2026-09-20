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
   - cask: `wezterm@nightly`（nightly ビルド = 事実上のメイン）, `font-plemol-jp-nf`（PlemolJP Console NF / 透過背景でも最高クラスの視認性, Nerd Font 内蔵）, `font-udev-gothic`（UD系フォールバック）, `font-hackgen-nerd`（Nerd Font アイコン用フォールバック）
   - formula: `python`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `fd`, `ripgrep`, `bat`, `pet`, `lazygit`, `pre-commit`, `gitleaks`, `shellcheck`
   - 既存の安定版 `wezterm` が入っている場合は自動で nightly に置き換え
2. WezTerm 設定のシンボリックリンク作成（`~/.config/wezterm/`）
3. Starship 設定のシンボリックリンク作成（`~/.config/starship.toml`）
4. Zsh 設定のシンボリックリンク作成（`~/.config/zsh/`）+ `~/.zshrc` に source 行を追加
5. pet スニペット設定（`~/.config/pet/snippet.toml` のリンク作成 + `config.toml` を生成）
6. lazygit 設定のシンボリックリンク作成（`~/Library/Application Support/lazygit/config.yml`）
7. pre-commit フックのインストール（`.git/hooks/pre-commit`）

セットアップ完了後は **WezTerm を `Cmd+Q` で完全終了→再起動** すると、フォント・カラースキーム・透過などが反映される。

## 構成

| パス | 内容 |
|------|------|
| `setup.sh` | セットアップスクリプト（パッケージインストール + シンボリックリンク作成 + pre-commit インストール） |
| `wezterm/wezterm.lua` | [WezTerm](https://wezfurlong.org/wezterm/) ターミナルエミュレータの設定 |
| `wezterm/recommendations.md` | WezTerm のおすすめ設定リファレンス（採用候補のメモ） |
| `starship/starship.toml` | [Starship](https://starship.rs/) プロンプトの設定 |
| `zsh/.zshrc` | Zsh のメイン設定（プラグイン読み込み・キーバインド・fzf×fd×bat 連携・fzf ディレクトリ移動） |
| `zsh/keybindings.zsh` | `kb` コマンド（キーバインドの一覧・横断検索） |
| `zsh/keybindings.py` | 設定ファイルからキーバインド一覧を読み取る（Python 3.9 以上、標準ライブラリのみ） |
| `zsh/keybindings-defaults.tsv` | 設定に書かれていない主要な既定キーの参照表 |
| `zsh/aliases.zsh` | シェルエイリアス定義 |
| `zsh/hidden/` | 環境固有の設定（Git 管理外、`.zsh` ファイルを自動読み込み） |
| `pet/snippet.toml` | [pet](https://github.com/knqyf263/pet) コマンドスニペット集（`Ctrl+G` で呼び出し） |
| `pet/select.sh` | pet の selectcmd。表示だけコマンドを行頭へ並べ替え、主タグごとに色分けし、`F1`〜`F6` でカテゴリ絞り込み・下部プレビューでコマンド全文を表示する fzf ラッパー |
| `pet/README.md` | pet の使い方（呼び出し・登録・編集・共有） |
| `lazygit/config.yml` | [lazygit](https://github.com/jesseduffield/lazygit) Git TUI の設定（`lg` で起動） |
| `.pre-commit-config.yaml` | [pre-commit](https://pre-commit.com/) フック定義（シークレット検出・基本チェック・shell lint） |

## WezTerm

開発者向けにチューニングした構成。Nerd Font + Tokyo Night + 透過 + Powerlevel10k 風プロンプトに対応。

### 主要設定

| カテゴリ | 設定 | 値 | 説明 |
|---------|------|-----|------|
| フォント | `font` | PlemolJP Console NF (Bold) → UDEV Gothic 35LG (Bold) → HackGen Console NF (Bold) → Hiragino Sans | IBM Plex 系の UD 等幅で透過背景でも最高クラスの視認性。Nerd Font 内蔵 |
| | `font_size` | 15.0 | 透過時の視認性向上のため大き目 |
| | `line_height` | 1.15 | 行間を少しゆとりを持たせて視認性UP |
| | `harfbuzz_features` | `calt=1, clig=1, liga=1` | リガチャ有効化（`=>`, `!=` 等） |
| | `bold_brightens_ansi_colors` | `true` | ANSI ボールドテキストを明色化してコントラスト UP |
| | `freetype_load_target` / `freetype_render_target` | `"Light"` / `"Normal"` | Light hinting でシャープさを保ちつつ、グレースケール AA で透過時の色滲み（フリンジ）を排除 |
| カラー | `color_scheme` | Tokyo Night | 暗紫系の人気スキーム |
| ウィンドウ | `window_background_opacity` | 0.85（フォーカス時）/ 0.5（非アクティブ時） | フォーカス連動で自動切替。作業中は読みやすく、離席中は背景が透ける |
| | `macos_window_background_blur` | 20 | すりガラス風ブラー |
| | `window_decorations` | `RESIZE` | タイトルバー削減 |
| | `window_padding` | 8px (上下左右) | |
| | `initial_cols` / `initial_rows` | 120 / 36 | 起動時のウィンドウサイズ |
| タブバー | `use_fancy_tab_bar` | `false` | テキスト式 |
| | `tab_bar_at_bottom` | `true` | 下部配置 |
| | `hide_tab_bar_if_only_one_tab` | `true` | タブ1つなら非表示 |
| | `show_new_tab_button_in_tab_bar` | `false` | 新規タブ＋ボタンを非表示 |
| | `format-tab-title` | アクティブ: 金色 / 非アクティブ: 暗青色 | ペインのタイトルを表示幅に合わせて省略 |
| ペイン | `inactive_pane_hsb` | sat 0.9 / br 0.7 | 非アクティブを暗く |
| 挙動 | `window_close_confirmation` | `NeverPrompt` | クローズ確認なし |
| | `scrollback_lines` | 10000 | |
| | `use_ime` | `true` | macOS IME（ことえり等）対応 |
| | `automatically_reload_config` | `true` | 設定保存時の自動リロードを明示的に有効化 |
| 性能 | `front_end` | `WebGpu` | GPU レンダリング |
| | `max_fps` | 120 | |
| | `check_for_updates` | `false` | 自動更新チェックを無効化 |

### キーバインド (macOS)

`Leader` は `Ctrl+Q`。押してから2秒以内に次のキーを入力する。

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
| `Cmd+T` / `Cmd+W` | 新規タブ / 現在のペインを閉じる（最後の1ペインならタブも閉じる） |
| `Cmd+1`〜`Cmd+3` | タブ切り替え |
| `Cmd+D` / `Cmd+Shift+D` | 横分割 / 縦分割 |
| `Cmd+[` / `Cmd+]` | ペイン移動 |
| `Cmd+Shift+R` | ペイン配置を時計回りに入れ替え |
| `Cmd+Shift+S` | 選択したペインと現在のペインを入れ替え |
| `Cmd+K` | 画面・スクロールバッククリア |
| `Ctrl+Shift+O` | 背景透過のオン/オフをトグル（`window_background_opacity` の設定値 ⇔ `1.0`） |
| `Cmd+Shift++` | 透明度を上げる（より不透明に、`+0.05`、最大 `1.0`） |
| `Cmd+Shift+-` | 透明度を下げる（より透ける、`-0.05`、最小 `0.0`） |

設定ファイル保存で自動リロードされる。手動リロードは `Ctrl+Shift+R`。透過具合は `wezterm/wezterm.lua` 冒頭の `FOCUSED_OPACITY` / `UNFOCUSED_OPACITY` で調整（フォーカス連動の自動切替は `window-focus-changed` イベントで実装）。

## Zsh

### プラグイン・連携ツール

| ツール | 役割 | 連携 |
|--------|------|------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish 風の自動補完 | `setup.sh` で導入 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Fish 風のシンタックスハイライト | `setup.sh` で導入 |
| [fzf](https://github.com/junegunn/fzf) | 曖昧検索（履歴・ファイル・ディレクトリ） | Tokyo Night 配色＋ボーダー＋reverse layout。`cdf_find` / `cdf_fd` で選択したディレクトリへ `cd` |
| [fd](https://github.com/sharkdp/fd) | `find` の高速代替 | `FZF_DEFAULT_COMMAND` / `FZF_ALT_C_COMMAND` / `cdf_fd` のバックエンドとして連携、`.gitignore` を尊重 |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` の高速代替 | デフォルトで `.gitignore` を尊重しサブディレクトリを再帰検索 |
| [bat](https://github.com/sharkdp/bat) | `cat` の代替（ハイライト+Git diff） | fzf の `Ctrl+T` プレビューで使用、`BAT_THEME=TwoDark` |
| [pet](https://github.com/knqyf263/pet) | コマンドスニペット管理 | `Ctrl+G` で fzf 検索 → プロンプトに挿入。スニペットは `pet/snippet.toml` で Git 管理 |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git 操作の TUI | `lg` で起動。設定は `lazygit/config.yml`（macOS 既定パス `~/Library/Application Support/lazygit/` へリンク） |
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
| `Ctrl+O` | fzf でカレント配下のディレクトリを検索し、選択した場所へ `cd`（fd があれば高速版、なければ find 版） |
| `Ctrl+G` | pet スニペットを fzf 検索し、選んだコマンドをプロンプトに挿入（少し変更して実行できる） |
| `**` + `Tab` | fzf 補完（パス・プロセス等を曖昧検索） |

### キーバインドの横断検索

新しいシェルで `kb` を実行すると、WezTerm・Zsh/fzf・pet・gh-dash・lazygit のキーバインドを検索できる。
既存のシェルには `source ~/.config/zsh/keybindings.zsh` で読み込む（セットアップ済みの場合）。

```sh
kb             # fzf でツール名・キー・説明・設定元を横断検索
kb wezterm     # 初期検索語を指定
kb ペイン      # 日本語でも検索
kb --list      # 全件を表示（fzf 不要）
```

Enter は選択行を表示するだけで、記載された操作を実行しない。Esc / Ctrl+C で閉じる。
fzf が未導入の場合は全件表示に切り替わる。

`kb` の起動ごとにリポジトリの設定ファイルを読み取るため、キーの変更・削除は次に開いた一覧へ自動反映される。
Python 3.9 以上が必要（`setup.sh` で導入。既存環境では `brew install python`）。生成ファイルの保存や同期コマンドは不要。

- **WezTerm / Zsh / gh-dash**: キー定義と同じ行にある `kb:` コメントを読み取る。新規登録時も下記の形式で説明を添える。
- **pet**: `pet/select.sh` の `--bind=` を読み取る（1行に1つのキーとアクション）。
- **既定キー**: `zsh/keybindings-defaults.tsv` を参照する。これは手動管理で、ツール更新時には gh-dash / lazygit 内の `?` などで確認する。

```lua
-- WezTerm: key と mods は同じ行に文字列で指定
{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") }, -- kb: 新規タブ
```

```sh
bindkey '^O' fzf-cd-widget # kb: ディレクトリを検索して移動
```

```yaml
- key: N # kb: 起動ディレクトリのリポジトリにIssueを作成
```

同期は **設定ファイル → 一覧** の方向。動作を変更した場合は、同じ行の説明コメントも更新する。
設定コードは実行せずに読み取るため、変数・ループによるキー定義や `hidden/` の上書き、実行中アプリの状態は対象外。
一覧には参照元の行番号を表示する。注釈付きの行が対応形式から外れると、エラーを表示して終了する。

キーは Mac の記号（`⌃` Control / `⌥` Option / `⇧` Shift / `⌘` Command、`↩` Enter / `⇥` Tab）で表示し、検索用にキー名も併記する（例: `⇧⌘D (Shift+Cmd+D)`）。
記号は入力しづらいため、検索は `cmd` や `opt` などのキー名で行う。WezTerm の `Leader` は実際のキーに展開する（例: `⌃Q → w (Ctrl+Q → w)`）。
設定ファイルや `zsh/keybindings-defaults.tsv` 側は従来どおり `Ctrl` / `Alt` / `Shift` / `Cmd` で書き、表示時に変換する。
各列は開始位置を揃え、列の間を4桁あける（`zsh/keybindings.py` の `COLUMN_GAP` で変更できる）。

確認コマンド:

```sh
python3 -B zsh/test-keybindings.py
zsh -f zsh/test-keybindings.zsh
```

### 履歴（History）

複数タブ・複数端末で履歴を即時共有（`SHARE_HISTORY`）。重複コマンドは古い方を削除（`HIST_IGNORE_ALL_DUPS`）、先頭スペース付きコマンドは記録しない（`HIST_IGNORE_SPACE`）、余分な空白は圧縮して記録（`HIST_REDUCE_BLANKS`）。履歴展開（`!`）は即実行せずプロンプトに展開（`HIST_VERIFY`）。保存件数は `HISTSIZE` / `SAVEHIST` ともに 100,000 件。`Ctrl+R`（fzf）からどの端末の履歴も横断検索できる。

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
| `lg` | `lazygit`（Git 操作の TUI を起動） |

#### ナビゲーション・ファイル操作

| エイリアス | コマンド |
|-----------|---------|
| `..` / `...` / `....` | 上のディレクトリへ移動 |
| `ls` | `ls -G`（カラー） |
| `ll` | `ls -lah` |
| `la` | `ls -a` |
| `rm` / `cp` / `mv` | 確認付き（`-i`） |

#### ショートカット

| エイリアス | コマンド |
|-----------|---------|
| `h` | `history` |
| `v` | `nvim` |

#### Docker

| エイリアス | コマンド |
|-----------|---------|
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |

#### pet（コマンドスニペット）

| エイリアス | コマンド |
|-----------|---------|
| `pn` | `pet new`（新規スニペットを対話的に登録） |
| `pe` | `pet edit`（`snippet.toml` をエディタで直接編集） |

> `prev` は `.zshrc` 定義のシェル関数（エイリアスではない）。直前に実行したコマンドをそのまま `pet new` に渡して登録する。タグも付けるなら `prev -t`。

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

### fzf ディレクトリ移動

カレントディレクトリ配下のフォルダを fzf で絞り込み、選択したフォルダへ移動する関数を定義している。`cdf_find` は標準の `find` 版、`cdf_fd` は `fd` を使う高速版。`Ctrl+O` は `fd` があれば `cdf_fd`、なければ `cdf_find` を実行する。`Ctrl+G` は pet 用に使っているため、ディレクトリ移動は `Ctrl+O` に割り当てている。

### hidden/ ディレクトリ（会社 / 個人の使い分け）

`~/.config/zsh/hidden/` に `.zsh` ファイルを置くと自動的に読み込まれる。API キーや PC 固有の PATH 設定など、Git 管理に含めたくない設定用。`hidden/*` は `.gitignore` 済みのため **`git push` されない／`git pull` で消えない**ので、会社Mac・個人Macそれぞれが自分用の中身を持つことで使い分ける（リポジトリ本体は両Mac共通）。

| ファイル | 用途 | Git |
|----------|------|-----|
| `secrets.zsh` | シークレット（トークン・APIキー） | 除外 |
| `env.zsh` | 非秘匿のマシン固有設定（PATH・会社用エイリアス等） | 除外 |
| `*.example` | 上記の雛形（ダミー値のみ追跡） | 追跡 |

新しいMacでは雛形をコピーして実値を埋める:

```bash
cd ~/.config/zsh/hidden
cp secrets.zsh.example secrets.zsh   # 会社Mac=会社用 / 個人Mac=個人用の値
cp env.zsh.example    env.zsh
```

git のメール・名前は `hidden/` ではなく `~/.gitconfig`（リポジトリ外・マシンローカル）で各Mac一度だけ設定する:

```bash
git config --global user.email "you@example.com"   # 会社Macは会社メール
```

### コマンドスニペット（pet）

「よく使うが覚えきれない」コマンドや、`<param>` で一部だけ差し替えて使いたいコマンドを登録・呼び出す仕組み。

- **呼び出し**: `Ctrl+G` で fzf 検索が開き、選んだコマンドが**実行されずプロンプトに挿入**される。そのまま編集して Enter で実行できる（「少し変更して使う」用途）。
- **コマンド先頭表示**: pet の既定では各行が `[説明]: コマンド …` と説明が左にくるため、長い説明があるとコマンドが画面右端で見切れる。`select.sh` は**表示だけコマンドを行頭へ並べ替える**（`コマンド #tags  [説明]`）ので、コマンドが常に視認できる。pet へ返す行は元のまま温存するため選択結果は正しく解決される。
- **色分け**: 一覧は主タグ（タグの先頭）ごとに色分けされる。`git`=緑 / `docker`=青 / `ssh`=黄 / `network`=シアン / `search`=ピンク / `terminal-manager`・`setup`=紫 / その他=グレー。
- **カテゴリ絞り込み**: fzf 表示中に `F1`=全件 / `F2`=git / `F3`=docker / `F4`=ssh / `F5`=network / `F6`=search でカテゴリを切り替えられる（クエリを `'#<tag>` に差し替える方式）。タグ文字をそのまま入力しても絞り込める。
- **プレビュー**: 一覧下部に選択中スニペットのコマンド全文・説明・タグが折り返し表示される（行頭表示でも切れるほど長いコマンドの全体確認用）。`Ctrl+P` で表示/非表示を切り替え。
- **登録**: `pn`（`pet new`）で対話的に追加。直前に実行したコマンドをそのまま登録するなら `prev`（タグも付けるなら `prev -t`）。`prev` は `.zshrc` 定義のシェル関数で、履歴から直近の実コマンドを取り出して `pet new` に渡す（`pet new` 単体では Command 欄が自動で埋まらないため）。
- **編集**: `pe`（`pet edit`）で `snippet.toml` をエディタで直接編集。
- **パラメータ**: `command` 内に `<param>` や `<param=default>` を書くとプレースホルダになる。挿入後にプロンプト上で値を埋める。
- **selectcmd**: 色分けとカテゴリ絞り込みは `pet/select.sh`（fzf ラッパー）が担う。`config.toml` の `selectcmd` がこのスクリプトを指す。
- **Git 管理**: スニペット本体は `pet/snippet.toml`（リポジトリ側の実体）。`~/.config/pet/snippet.toml` はそこへのシンボリックリンク。`config.toml` は絶対パスを含むため `setup.sh` がマシンごとに生成する（追跡対象外）。登録・編集後は通常どおり `git commit` で共有する。

### Git TUI（lazygit）

ステージング・コミット・ブランチ操作・push/pull を TUI で行う。`lg`（= `lazygit`）で Git リポジトリ内から起動。

- **設定**: `lazygit/config.yml`（リポジトリ側の実体）。`mouseEvents: true`（マウス操作）/ `showBottomLine: false`（下部バー非表示で表示領域拡大）/ `editPreset: "nvim"`（ファイルを開くエディタ）/ `overrideGpg: true`（GPG 署名コミット対応）。
- **配置**: lazygit は macOS では既定で `~/Library/Application Support/lazygit/config.yml` を参照する（`XDG_CONFIG_HOME` 未設定時）。`setup.sh` がそこへリポジトリ側へのシンボリックリンクを張る。参照先は `lazygit -cd` で確認できる。
- **主なキー**: `Space`=ステージ / `a`=全ステージ / `c`=コミット / `C`=Amend / `p`=push / `P`=pull / `n`=ブランチ作成 / `z`=アンドゥ。

## Starship

二段プロンプト。Nerd Font のアイコン表示前提（`font-hackgen-nerd` 等を使用）。

### 表示要素

```
   ~/path   main [+1!2?3]   v20.10.0   prod
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

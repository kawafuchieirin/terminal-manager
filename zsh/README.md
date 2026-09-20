# Zsh

Zsh の設定一式。実体はこのディレクトリで、`setup.sh` が `~/.config/zsh/` をここへのシンボリックリンクとして張り、
`~/.zshrc` に読み込み行を追加する。

```sh
# ~/.zshrc に追記される内容
if [ -f "$HOME/.config/zsh/.zshrc" ]; then
  source "$HOME/.config/zsh/.zshrc"
fi
```

| ファイル | 役割 |
|---------|------|
| `.zshrc` | メイン設定（プラグイン読み込み・履歴・キーバインド・fzf 連携・関数定義） |
| `aliases.zsh` | エイリアス定義。`.zshrc` から source |
| `keybindings.zsh` | `kb` コマンド（キーバインドの一覧・横断検索）。`.zshrc` から source |
| `keybindings.py` | 設定ファイルからキーバインド一覧を組み立てる（Python 3.9 以上・標準ライブラリのみ） |
| `keybindings-defaults.tsv` | 設定ファイルに書かれていない既定キーの参照表（手動管理） |
| `test-keybindings.py` / `test-keybindings.zsh` | 上記 2 つのテスト |
| `hidden/` | 環境固有の設定・シークレット（Git 管理外）。詳細は [hidden/README.md](hidden/README.md) |

## .zshrc の読み込み順

1. ロケール・エディタ（`LANG` / `EDITOR`）
2. Starship プロンプト（`starship init zsh`）
3. zsh-autosuggestions / zsh-syntax-highlighting（`$HOMEBREW_PREFIX/share/` から source）
4. 履歴設定（`HISTFILE` ほか、後述）
5. 矢印キーの履歴検索（`up-line-or-beginning-search` / `down-line-or-beginning-search`）
6. `WORDCHARS=''`
7. `hidden/*.zsh` を読み込み（存在するものだけ）
8. `aliases.zsh` / `keybindings.zsh`
9. `mise activate zsh` と PATH 追加（`~/npm-global/bin` / `~/.local/bin`）
10. fzf 本体・配色・fd / bat 連携
11. `cdf_find` / `cdf_fd` / `fzf-cd-widget`（`Ctrl+O`）
12. pet 連携（`Ctrl+G` と `prev` 関数）
13. zoxide（`z` コマンド。初期化順の都合で最後）

`hidden/` がエイリアスより先に読み込まれるため、`aliases.zsh` の定義を `hidden/` 側で上書きすることはできない。
マシン固有のエイリアスは別名で定義する。

## プラグイン・連携ツール

| ツール | 役割 | 連携のしかた |
|--------|------|-------------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish 風の入力補完（履歴からの候補をグレー表示、`→` で確定） | `setup.sh` で導入 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | コマンドラインのシンタックスハイライト | `setup.sh` で導入 |
| [fzf](https://github.com/junegunn/fzf) | 曖昧検索（履歴・ファイル・ディレクトリ・スニペット） | `fzf --zsh` で初期化。Tokyo Night 配色 + `--border=rounded` + `--layout=reverse` + 高さ 60% |
| [fd](https://github.com/sharkdp/fd) | `find` の高速代替 | `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` / `FZF_ALT_C_COMMAND` / `cdf_fd` のバックエンド。`.gitignore` を尊重 |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` の高速代替 | 既定で `.gitignore` を尊重して再帰検索。zsh 側の追加設定はなし |
| [bat](https://github.com/sharkdp/bat) | `cat` の代替（ハイライト + Git diff） | `Ctrl+T` のプレビューに使用。`BAT_THEME=TwoDark` |
| [pet](https://github.com/knqyf263/pet) | コマンドスニペット管理 | `Ctrl+G` で検索してプロンプトへ挿入。詳細は [pet/README.md](../pet/README.md) |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git 操作の TUI | `lg` エイリアスで起動。詳細は [lazygit/README.md](../lazygit/README.md) |
| [mise](https://mise.jdx.dev/) | 言語ランタイム・CLI のバージョン管理 | `mise activate zsh` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 使用頻度に基づくディレクトリジャンプ（`z <部分文字列>`） | `zoxide init zsh` |

fzf / fd / bat / pet は `command -v` で存在を確認してから設定するため、未導入でも起動に影響しない。
いっぽう **`mise` と `zoxide` は無条件に `eval` している**。この 2 つは `setup.sh` のインストール対象外なので、
使わないマシンではシェル起動時にエラーが出る。導入するか、該当行を `hidden/` へ寄せて調整する。

```sh
brew install mise zoxide
```

## キーバインド

| キー | 動作 |
|------|------|
| `↑` / `↓` | 現在の入力にマッチする履歴を前方 / 後方へ検索 |
| `Ctrl+W` / `Alt+Backspace` | 単語削除。`WORDCHARS=''` によりパス区切り（`/`・`.`・`-` 等）で止まる |
| `Ctrl+R` | fzf でコマンド履歴を曖昧検索 |
| `Ctrl+T` | fzf でカレント配下のファイルを検索し、コマンドラインへ挿入（bat プレビュー付き） |
| `Alt+C` | fzf でカレント配下のディレクトリを検索して `cd` |
| `Ctrl+O` | ディレクトリを fzf 検索して移動（`fd` があれば高速版、なければ `find` 版） |
| `Ctrl+G` | pet スニペットを検索し、選んだコマンドをプロンプトへ挿入（実行はしない） |
| `**` + `Tab` | fzf 補完（パス・プロセス等を曖昧検索） |

`Ctrl+G` を pet に使っているため、ディレクトリ移動は `Ctrl+O` に割り当てている。

### fzf ディレクトリ移動の実装

| 関数 | 中身 |
|------|------|
| `cdf_find` | `find . -type d -not -path '*/.git/*'` の結果を fzf で選び `cd` |
| `cdf_fd` | `fd . --type d --hidden --exclude .git` の結果を fzf で選び `cd` |
| `fzf-cd-widget` | `fd` があれば `cdf_fd`、なければ `cdf_find` を呼び、`zle reset-prompt` でプロンプトを再描画（`Ctrl+O` にバインド） |

いずれも `builtin cd` を使うため、`cd` にエイリアスや関数を被せても影響を受けない。

### キーバインドの横断検索

`kb` は WezTerm / Zsh・fzf / pet / gh-dash / lazygit のキーバインドを 1 つの一覧にまとめて検索するコマンド。

```sh
kb             # fzf でツール名・キー・説明・設定元を横断検索
kb wezterm     # 初期検索語を指定
kb ペイン      # 日本語でも検索できる
kb --list      # 全件を表示（fzf 不要）
```

- Enter は選択行を表示するだけで、記載された操作は実行しない。Esc / `Ctrl+C` で閉じる。
- fzf が未導入なら自動で全件表示に切り替わる。
- セットアップ済みの既存シェルへ読み込む場合は `source ~/.config/zsh/keybindings.zsh`。

**同期の方向は「設定ファイル → 一覧」**。`kb` は起動ごとにリポジトリの設定ファイルを読み直すため、
キーの変更・削除は次に開いた一覧へ自動反映される。生成ファイルの保存や同期コマンドは不要。

| 取得元 | 読み取り方 |
|--------|-----------|
| `wezterm/wezterm.lua` | キー定義と同じ行の `-- kb:` コメント。`key` と `mods` を同じ行に文字列で書く |
| `zsh/.zshrc` | `bindkey 'キー' widget # kb: 説明` の形式 |
| `gh-dash/config.yml` | `- key: X # kb: 説明` の形式 |
| `pet/select.sh` | `--bind='キー:アクション'` の行（1 行に 1 つ） |
| `zsh/keybindings-defaults.tsv` | 設定ファイルに現れない既定キー（手動管理） |

```lua
{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") }, -- kb: 新規タブ
```

```sh
bindkey '^O' fzf-cd-widget # kb: ディレクトリを検索して移動
```

```yaml
- key: N # kb: 起動ディレクトリのリポジトリにIssueを作成
```

表示のきまり:

- キーは Mac の記号（`⌃` Control / `⌥` Option / `⇧` Shift / `⌘` Command、`↩` Enter / `⇥` Tab）で表示し、
  検索用にキー名も併記する（例: `⇧⌘D (Shift+Cmd+D)`）。記号は入力しづらいため、検索は `cmd` / `opt` などのキー名で行う。
- 修飾キーの並びは macOS のメニューと同じ `⌃⌥⇧⌘` 順。
- WezTerm の `Leader` は実際のキーへ展開する（例: `⌃Q → w (Ctrl+Q → w)`）。
- 設定ファイルと `keybindings-defaults.tsv` 側は `Ctrl` / `Alt` / `Shift` / `Cmd` で書き、表示時に変換する。
- 列は開始位置を揃え、間を 4 桁あける（`keybindings.py` の `COLUMN_GAP`）。全角は 2 桁、`→` や `⇧` は 1 桁で数える。

制約:

- 設定コードは**実行せず読み取る**ため、変数やループで組み立てたキー定義、`hidden/` での上書き、
  実行中アプリの状態は一覧に出ない。
- `kb:` コメントの付いた行が上記の形式から外れると、行番号付きのエラーを表示して終了する。
- `keybindings-defaults.tsv` は手動管理。ツール更新時は gh-dash / lazygit の `?` で実機の一覧を確認する。

確認コマンド:

```sh
python3 -B zsh/test-keybindings.py   # mac_key の変換・一覧の組み立て・エラー検出
zsh -f zsh/test-keybindings.zsh      # kb --list と fzf 経由の検索結果
```

Python 3.9 以上が必要（`setup.sh` で `python` を導入。既存環境では `brew install python`）。

## 履歴

| 設定 | 値 | 効果 |
|------|-----|------|
| `HISTFILE` | `~/.zsh_history` | 保存先 |
| `HISTSIZE` / `SAVEHIST` | 100,000 | メモリ上 / ファイル上の保存件数 |
| `SHARE_HISTORY` | on | 複数タブ・複数端末で履歴を即時共有 |
| `HIST_IGNORE_ALL_DUPS` | on | 重複コマンドは古い方を削除 |
| `HIST_IGNORE_SPACE` | on | 先頭にスペースを付けたコマンドは記録しない |
| `HIST_REDUCE_BLANKS` | on | 余分な空白を圧縮して記録 |
| `HIST_VERIFY` | on | 履歴展開（`!`）は即実行せずプロンプトへ展開 |

`Ctrl+R`（fzf）からどの端末の履歴も横断検索できる。

## 環境変数

| 変数 | 値 | 用途 |
|------|-----|------|
| `LANG` | `en_US.UTF-8` | ロケール |
| `EDITOR` | `nvim` | 既定エディタ |
| `WORDCHARS` | `''` | 単語削除をパス区切りで止める |
| `PATH` | `~/npm-global/bin` / `~/.local/bin` を前方追加 | グローバル npm パッケージ・ユーザーローカルのツール |
| `FZF_DEFAULT_OPTS` | 高さ 60% / reverse / rounded border / Tokyo Night 配色 | fzf の見た目 |
| `FZF_DEFAULT_COMMAND`・`FZF_CTRL_T_COMMAND` | `fd --type f --hidden --follow --exclude .git` | ファイル検索（fd 導入時のみ） |
| `FZF_ALT_C_COMMAND` | `fd --type d --hidden --follow --exclude .git` | ディレクトリ検索（fd 導入時のみ） |
| `FZF_CTRL_T_OPTS` | `--preview 'bat --color=always --style=numbers --line-range=:500 {}'` | `Ctrl+T` のプレビュー（bat 導入時のみ） |
| `BAT_THEME` | `TwoDark` | bat の配色（Tokyo Night と合わせている） |

## エイリアス

`aliases.zsh` の全定義。

### Git

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
| `lg` | `lazygit` |

### ディレクトリ移動・ファイル操作

| エイリアス | コマンド |
|-----------|---------|
| `..` / `...` / `....` | `cd ..` / `cd ../..` / `cd ../../..` |
| `ls` | `ls -G`（カラー） |
| `ll` | `ls -lah` |
| `la` | `ls -a` |
| `rm` / `cp` / `mv` | `-i` 付き（上書き・削除前に確認） |

### ショートカット

| エイリアス | コマンド |
|-----------|---------|
| `h` | `history` |
| `v` | `nvim` |

### Docker

| エイリアス | コマンド |
|-----------|---------|
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |

### pet（コマンドスニペット）

| エイリアス | コマンド |
|-----------|---------|
| `pn` | `pet new`（対話的に新規登録） |
| `pe` | `pet edit`（`snippet.toml` をエディタで編集） |

### AWS

| エイリアス | コマンド |
|-----------|---------|
| `sso` | `aws sso login --profile management-account` |
| `wssso` | `aws sso login --profile workload-account` |

プロファイル名は `~/.aws/config` 側の定義に依存する。`hidden/` は `aliases.zsh` より先に読み込まれて上書きできないため、
マシンごとに違う場合は `aliases.zsh` の値を直接直すか、`hidden/env.zsh` で別名のエイリアスを足す。

### Claude

| エイリアス | コマンド |
|-----------|---------|
| `cc` | `claude --dangerously-skip-permissions` |

## `.zshrc` 定義の関数

| 関数 | 役割 |
|------|------|
| `cdf_find` / `cdf_fd` / `fzf-cd-widget` | fzf でディレクトリを選んで移動（前述） |
| `pet-select` | `pet search --query "$LBUFFER"` の結果をコマンドラインへ挿入（`Ctrl+G`） |
| `prev` | 直前に実行したコマンドを `pet new` に渡して登録する。タグも付けるなら `prev -t` |

`prev` がある理由: `pet new` は Command 欄を自動で埋めないため、履歴から直近の実コマンドを取り出して渡している。
対話シェルでは `prev` の呼び出し行自体が履歴の先頭に入るので、その行を読み飛ばしてから拾う。

## 環境固有の設定

API キー・マシン固有の PATH などは `hidden/` に置く（Git 管理外）。会社 Mac / 個人 Mac の使い分けもここで行う。
→ [hidden/README.md](hidden/README.md)

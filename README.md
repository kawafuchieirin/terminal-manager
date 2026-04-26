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

1. Homebrew パッケージのインストール（`wezterm`(cask), `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `pre-commit`, `gitleaks`, `shellcheck`）
2. WezTerm 設定のシンボリックリンク作成（`~/.config/wezterm/`）
3. Starship 設定のシンボリックリンク作成（`~/.config/starship.toml`）
4. Zsh 設定のシンボリックリンク作成（`~/.config/zsh/`）+ `~/.zshrc` に source 行を追加
5. pre-commit フックのインストール（`.git/hooks/pre-commit`）

## 構成

| パス | 内容 |
|------|------|
| `setup.sh` | セットアップスクリプト（パッケージインストール + シンボリックリンク作成 + pre-commit インストール） |
| `wezterm/wezterm.lua` | [WezTerm](https://wezfurlong.org/wezterm/) ターミナルエミュレータの設定 |
| `starship/starship.toml` | [Starship](https://starship.rs/) プロンプトの設定 |
| `zsh/.zshrc` | Zsh のメイン設定（プラグイン読み込み・キーバインド等） |
| `zsh/aliases.zsh` | シェルエイリアス定義 |
| `zsh/hidden/` | 環境固有の設定（Git 管理外、`.zsh` ファイルを自動読み込み） |
| `.pre-commit-config.yaml` | [pre-commit](https://pre-commit.com/) フック定義（シークレット検出・基本チェック・shell lint） |

## WezTerm

最小構成（WezTerm のデフォルト寄り）。

| 設定 | 値 |
|------|-----|
| `font_size` | 14 |
| `hide_tab_bar_if_only_one_tab` | `true` |
| `window_close_confirmation` | `NeverPrompt` |

設定ファイル保存で自動リロードされる。手動リロードは `Ctrl+Shift+R`。

## Zsh

### プラグイン

| プラグイン | 説明 |
|-----------|------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish 風の自動補完 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Fish 風のシンタックスハイライト |

### キーバインド

| キー | 動作 |
|------|------|
| `↑` / `↓` | 現在の入力にマッチする履歴を検索 |
| `Ctrl+W` / `Alt+Backspace` | パス区切りで止まる単語削除（`WORDCHARS=''`） |

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

### hidden/ ディレクトリ

`~/.config/zsh/hidden/` に `.zsh` ファイルを置くと自動的に読み込まれる。API キーや PC 固有の PATH 設定など、Git 管理に含めたくない設定用。

## Starship

Git ブランチ名とステータス（staged/modified/untracked/deleted/conflicted/ahead/behind）を表示。コマンド入力前に空行を挿入。

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

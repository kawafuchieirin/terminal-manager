# shellcheck shell=bash
# shellcheck disable=SC2034  # ここで定義した値は source 先で使う
#
# setup.sh と uninstall.sh が共有する定義。source 専用で、単体実行はしない。
#
# インストール対象のパッケージと、設定の配置先はここだけを更新する。
# 両スクリプトで同じ一覧を二重管理すると、片方だけ古くなって
# 「setup.sh が作ったものを uninstall.sh が消し残す」事故につながるため。

# =========================
# Homebrew パッケージ
# =========================

# cask（アプリ・フォント）
BREW_CASKS=(
  wezterm@nightly
  font-plemol-jp-nf
  font-udev-gothic
  font-hackgen-nerd
)

# formula（CLI ツール）
BREW_FORMULAE=(
  python
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  fd
  ripgrep
  bat
  pet
  lazygit
  pre-commit
  gitleaks
  shellcheck
  # cornix-lp/format-vil.sh が .vil の整形に使う。1.7 未満は数値リテラルを
  # 作り直して uid を壊すため、新しい版を Homebrew で入れる
  jq
)

# =========================
# 設定の配置先
# =========================

# WezTerm: ディレクトリごとリンクする
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
# 旧バージョンが参照していた単一ファイル。setup.sh が .bak へ退避する
WEZTERM_LEGACY_CONFIG="$HOME/.wezterm.lua"

# Starship
STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Zsh: ディレクトリごとリンクし、~/.zshrc から source する
ZSH_CONFIG_DIR="$HOME/.config/zsh"
ZSHRC="$HOME/.zshrc"
# ~/.zshrc へ追記するブロックの先頭行。uninstall.sh がこの行を目印に
# ブロックを特定して削除するため、変更すると既存環境の削除ができなくなる
ZSHRC_MARKER='# terminal-manager リポジトリから zsh 設定を読み込む'

# pet: snippet.toml はリンク、config.toml は絶対パスを含むため生成する
PET_CONFIG_DIR="$HOME/.config/pet"
PET_SNIPPET="$PET_CONFIG_DIR/snippet.toml"
PET_CONFIG="$PET_CONFIG_DIR/config.toml"

# lazygit: macOS 既定のパス（XDG_CONFIG_HOME 未設定時）
LAZYGIT_CONFIG_DIR="$HOME/Library/Application Support/lazygit"
LAZYGIT_CONFIG="$LAZYGIT_CONFIG_DIR/config.yml"

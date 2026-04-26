#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# =========================
# Homebrew パッケージ
# =========================
install_brew_packages() {
  echo "=== Homebrew パッケージインストール ==="

  if ! command -v brew &>/dev/null; then
    echo "エラー: Homebrew がインストールされていません"
    echo "https://brew.sh/ からインストールしてください"
    exit 1
  fi

  # WezTerm（cask）
  if brew list --cask wezterm &>/dev/null; then
    echo "既にインストール済み: wezterm"
  else
    echo "インストール中: wezterm"
    brew install --cask wezterm
  fi

  # formula
  local packages=(
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    pre-commit
    gitleaks
    shellcheck
  )

  for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      echo "既にインストール済み: $pkg"
    else
      echo "インストール中: $pkg"
      brew install "$pkg"
    fi
  done

  echo "Homebrew パッケージインストール完了"
}

# =========================
# WezTerm
# =========================
setup_wezterm() {
  local legacy_config="$HOME/.wezterm.lua"
  local config_dir="$HOME/.config/wezterm"
  local source_dir="$SCRIPT_DIR/wezterm"

  echo "=== WezTerm セットアップ ==="

  # レガシーパス（~/.wezterm.lua）が存在する場合はバックアップ
  if [ -f "$legacy_config" ] && [ ! -L "$legacy_config" ]; then
    echo "レガシー設定ファイルをバックアップ: ${legacy_config}.bak"
    mv "$legacy_config" "${legacy_config}.bak"
  fi

  # 既存の設定ディレクトリがシンボリックリンクでない場合はバックアップ
  if [ -d "$config_dir" ] && [ ! -L "$config_dir" ]; then
    echo "既存の設定ディレクトリをバックアップ: ${config_dir}.bak"
    mv "$config_dir" "${config_dir}.bak"
  fi

  # ~/.config ディレクトリがなければ作成
  mkdir -p "$(dirname "$config_dir")"

  # シンボリックリンクを作成
  if [ -L "$config_dir" ]; then
    echo "シンボリックリンクは既に存在します: $config_dir"
  else
    ln -s "$source_dir" "$config_dir"
    echo "シンボリックリンクを作成: $config_dir -> $source_dir"
  fi

  echo "WezTerm セットアップ完了"
}

# =========================
# Starship
# =========================
setup_starship() {
  local config_dir="$HOME/.config"
  local source_file="$SCRIPT_DIR/starship/starship.toml"
  local target_file="$config_dir/starship.toml"

  echo "=== Starship セットアップ ==="

  mkdir -p "$config_dir"

  if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
    echo "既存の設定ファイルをバックアップ: ${target_file}.bak"
    mv "$target_file" "${target_file}.bak"
  fi

  if [ -L "$target_file" ]; then
    echo "シンボリックリンクは既に存在します: $target_file"
  else
    ln -s "$source_file" "$target_file"
    echo "シンボリックリンクを作成: $target_file -> $source_file"
  fi

  echo "Starship セットアップ完了"
}

# =========================
# Zsh
# =========================
setup_zsh() {
  local source_dir="$SCRIPT_DIR/zsh"
  local config_dir="$HOME/.config/zsh"
  local zshrc="$HOME/.zshrc"

  echo "=== Zsh セットアップ ==="

  if [ -d "$config_dir" ] && [ ! -L "$config_dir" ]; then
    echo "既存の設定ディレクトリをバックアップ: ${config_dir}.bak"
    mv "$config_dir" "${config_dir}.bak"
  fi

  # 壊れたシンボリックリンクの場合は削除
  if [ -L "$config_dir" ] && [ ! -e "$config_dir" ]; then
    echo "壊れたシンボリックリンクを削除: $config_dir"
    rm "$config_dir"
  fi

  if [ -L "$config_dir" ]; then
    echo "シンボリックリンクは既に存在します: $config_dir"
  else
    mkdir -p "$(dirname "$config_dir")"
    ln -s "$source_dir" "$config_dir"
    echo "シンボリックリンクを作成: $config_dir -> $source_dir"
  fi

  # ~/.zshrc に source 行を追加（既にあればスキップ）
  if [ -f "$zshrc" ] && grep -qF '.config/zsh/.zshrc' "$zshrc"; then
    # shellcheck disable=SC2088 # 表示用文字列のため変数展開不要
    echo "~/.zshrc に source 行は既に存在します"
  else
    # shellcheck disable=SC2088 # 表示用文字列のため変数展開不要
    echo "~/.zshrc に source 行を追加"
    if [ -f "$zshrc" ] && [ -s "$zshrc" ] && [ "$(tail -c 1 "$zshrc")" != "" ]; then
      echo "" >> "$zshrc"
    fi
    cat >> "$zshrc" << 'EOF'

# terminal-manager リポジトリから zsh 設定を読み込む
if [ -f "$HOME/.config/zsh/.zshrc" ]; then
  source "$HOME/.config/zsh/.zshrc"
fi
EOF
  fi

  # hidden ディレクトリを作成（なければ）
  mkdir -p "$source_dir/hidden"

  echo "Zsh セットアップ完了"
}

# =========================
# pre-commit
# =========================
setup_pre_commit() {
  local hook_file="$SCRIPT_DIR/.git/hooks/pre-commit"

  echo "=== pre-commit セットアップ ==="

  if ! command -v pre-commit &>/dev/null; then
    echo "警告: pre-commit がインストールされていません。スキップします"
    return 0
  fi

  if [ ! -d "$SCRIPT_DIR/.git" ]; then
    echo "警告: Git リポジトリではないためスキップします"
    return 0
  fi

  if [ -f "$hook_file" ] && grep -qF 'pre-commit.com' "$hook_file" 2>/dev/null; then
    echo "pre-commit フックは既にインストール済みです"
  else
    (cd "$SCRIPT_DIR" && pre-commit install)
    echo "pre-commit フックをインストールしました"
  fi

  echo "pre-commit セットアップ完了"
}

# =========================
# メイン
# =========================
main() {
  echo "ターミナル環境セットアップを開始します"
  echo ""

  install_brew_packages
  echo ""
  setup_wezterm
  echo ""
  setup_starship
  echo ""
  setup_zsh
  echo ""
  setup_pre_commit

  echo ""
  echo "セットアップが完了しました"
  echo "ターミナルを再起動して設定を反映してください"
}

main

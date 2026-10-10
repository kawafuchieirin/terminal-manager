#!/bin/bash
# setup.sh が作ったものを取り外す。
#
# 既定ではシンボリックリンク・生成ファイル・~/.zshrc の追記ブロックだけを消す。
# Homebrew パッケージは他のプロジェクトでも使っている可能性があるため、
# --purge-brew を明示しない限り触らない。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# パッケージ一覧と設定の配置先は setup.sh と共有する
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

DRY_RUN=false
RESTORE_BACKUPS=false
PURGE_BREW=false
ASSUME_YES=false

# 実体が残っていて手動確認が必要になった項目
WARNINGS=()

usage() {
  cat << 'EOF'
使い方: ./uninstall.sh [オプション]

setup.sh が作ったシンボリックリンク・生成ファイル・~/.zshrc の追記を取り外す。

オプション:
  --dry-run            何も変更せず、削除される対象だけを表示する
  --restore-backups    setup.sh が退避した *.bak を元の場所へ戻す
  --purge-brew         Homebrew パッケージ（cask・フォント含む）も削除する
  -y, --yes            確認プロンプトを出さずに実行する
  -h, --help           このヘルプを表示する

例:
  ./uninstall.sh --dry-run                 # 消える対象を確認するだけ
  ./uninstall.sh --restore-backups         # リンクを外し、旧設定を復元する
  ./uninstall.sh --purge-brew -y           # パッケージまで含めて一括削除
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --restore-backups) RESTORE_BACKUPS=true ;;
      --purge-brew) PURGE_BREW=true ;;
      -y | --yes) ASSUME_YES=true ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        echo "エラー: 不明なオプション: $1" >&2
        echo "" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

# --dry-run では実行せず内容だけ表示する
run() {
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

warn() {
  echo "  警告: $1"
  WARNINGS+=("$1")
}

# =========================
# 共通処理
# =========================

# setup.sh が張ったリンクを外す。実体ファイル／ディレクトリは消さない
remove_link() {
  local target="$1"

  if [ -L "$target" ]; then
    echo "  リンクを削除: $target"
    run rm "$target"
  elif [ -e "$target" ]; then
    warn "リンクではない実体が残っています（内容を確認して手動で削除）: $target"
  else
    echo "  対象なし: $target"
  fi
}

# setup.sh が生成した実ファイルを消す
remove_file() {
  local target="$1"

  if [ -f "$target" ] || [ -L "$target" ]; then
    echo "  ファイルを削除: $target"
    run rm "$target"
  else
    echo "  対象なし: $target"
  fi
}

# setup.sh が .bak へ退避した旧設定を元の場所へ戻す
restore_backup() {
  local target="$1"
  local backup="${target}.bak"

  if [ ! -e "$backup" ] && [ ! -L "$backup" ]; then
    return 0
  fi

  if [ "$RESTORE_BACKUPS" != true ]; then
    echo "  バックアップあり（--restore-backups で復元）: $backup"
    return 0
  fi

  # リンク削除が失敗していた場合に上書きしないよう、空であることを確かめる
  if [ -e "$target" ] || [ -L "$target" ]; then
    warn "$target が残っているため復元できません: $backup"
    return 0
  fi

  echo "  バックアップを復元: $backup -> $target"
  run mv "$backup" "$target"
}

# 空のディレクトリだけ削除する（他ツールのファイルが残っていれば残す）
remove_dir_if_empty() {
  local dir="$1"

  [ -d "$dir" ] || return 0
  [ ! -L "$dir" ] || return 0

  if [ -z "$(ls -A "$dir")" ]; then
    echo "  空のディレクトリを削除: $dir"
    run rmdir "$dir"
  else
    echo "  ディレクトリに他のファイルが残っているため保持: $dir"
  fi
}

# =========================
# WezTerm
# =========================
uninstall_wezterm() {
  echo "=== WezTerm ==="
  remove_link "$WEZTERM_CONFIG_DIR"
  restore_backup "$WEZTERM_CONFIG_DIR"
  restore_backup "$WEZTERM_LEGACY_CONFIG"
}

# =========================
# Starship
# =========================
uninstall_starship() {
  echo "=== Starship ==="
  remove_link "$STARSHIP_CONFIG"
  restore_backup "$STARSHIP_CONFIG"
}

# =========================
# Zsh
# =========================
uninstall_zsh() {
  echo "=== Zsh ==="
  remove_link "$ZSH_CONFIG_DIR"
  restore_backup "$ZSH_CONFIG_DIR"
  clean_zshrc
}

# ~/.zshrc から setup.sh が追記したブロックを取り除く。
# マーカー行から対応する fi までを 1 ブロックとして扱い、直前の空行も落とす。
clean_zshrc() {
  local zshrc="$ZSHRC"

  if [ ! -f "$zshrc" ]; then
    echo "  対象なし: $zshrc"
    return 0
  fi

  if ! grep -qF "$ZSHRC_MARKER" "$zshrc"; then
    if grep -qF '.config/zsh/.zshrc' "$zshrc"; then
      warn "$zshrc に source 行があるがマーカー行がないため自動削除できません。次の行を手動で削除してください"
      grep -nF '.config/zsh/.zshrc' "$zshrc" | sed 's/^/    /'
    else
      echo "  対象なし: $zshrc の追記ブロック"
    fi
    return 0
  fi

  local tmp status=0
  tmp="$(mktemp)"

  awk -v marker="$ZSHRC_MARKER" '
    # ブロックの中は fi まで読み捨てる
    skip {
      if ($0 ~ /^[[:space:]]*fi[[:space:]]*$/) { skip = 0 }
      next
    }
    # 空行は保留し、ブロック直前のものだけを捨てる
    /^[[:space:]]*$/ { pending[++npending] = $0; next }
    index($0, marker) {
      npending = 0
      skip = 1
      removed = 1
      next
    }
    {
      for (i = 1; i <= npending; i++) print pending[i]
      npending = 0
      print
    }
    END {
      # 閉じる fi が見つからないまま終端した場合は、以降を失わないよう中止する
      if (skip) exit 2
      if (!removed) exit 3
      for (i = 1; i <= npending; i++) print pending[i]
    }
  ' "$zshrc" > "$tmp" || status=$?

  if [ "$status" -ne 0 ]; then
    rm -f "$tmp"
    case "$status" in
      2) warn "$zshrc の追記ブロックが閉じられていないため自動削除できません。手動で削除してください" ;;
      3) warn "$zshrc の追記ブロックを特定できませんでした。手動で削除してください" ;;
      *) warn "$zshrc の解析に失敗しました（awk 終了コード: $status）。手動で削除してください" ;;
    esac
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] $zshrc から次の差分を適用:"
    diff -u "$zshrc" "$tmp" | sed 's/^/    /' || true
    rm -f "$tmp"
    return 0
  fi

  local backup
  backup="${zshrc}.bak-$(date +%Y%m%d%H%M%S)"
  cp "$zshrc" "$backup"
  echo "  バックアップを作成: $backup"

  # パーミッションと inode を保つため上書きコピーする
  cat "$tmp" > "$zshrc"
  rm -f "$tmp"
  echo "  追記ブロックを削除: $zshrc"
}

# =========================
# pet
# =========================
uninstall_pet() {
  echo "=== pet ==="
  remove_link "$PET_SNIPPET"
  restore_backup "$PET_SNIPPET"
  # config.toml は setup.sh が毎回生成するため、バックアップは存在しない
  remove_file "$PET_CONFIG"
  remove_dir_if_empty "$PET_CONFIG_DIR"
}

# =========================
# lazygit
# =========================
uninstall_lazygit() {
  echo "=== lazygit ==="
  remove_link "$LAZYGIT_CONFIG"
  restore_backup "$LAZYGIT_CONFIG"
}

# =========================
# pre-commit
# =========================
uninstall_pre_commit() {
  echo "=== pre-commit ==="

  local hook_file="$SCRIPT_DIR/.git/hooks/pre-commit"

  if [ ! -f "$hook_file" ]; then
    echo "  対象なし: $hook_file"
    return 0
  fi

  if ! command -v pre-commit &>/dev/null; then
    warn "pre-commit コマンドがないためフックを外せません: $hook_file"
    return 0
  fi

  echo "  pre-commit フックを削除"
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] pre-commit uninstall"
  else
    (cd "$SCRIPT_DIR" && pre-commit uninstall)
  fi
}

# =========================
# Homebrew パッケージ（--purge-brew のときだけ）
# =========================
purge_brew_packages() {
  echo "=== Homebrew パッケージ ==="

  if [ "$PURGE_BREW" != true ]; then
    echo "  スキップ（削除するには --purge-brew を指定）"
    return 0
  fi

  if ! command -v brew &>/dev/null; then
    warn "Homebrew が見つからないためパッケージを削除できません"
    return 0
  fi

  local cask
  for cask in "${BREW_CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      echo "  削除: $cask"
      if [ "$DRY_RUN" = true ]; then
        echo "  [dry-run] brew uninstall --cask $cask"
      elif ! brew uninstall --cask "$cask"; then
        warn "$cask の削除に失敗しました"
      fi
    else
      echo "  対象なし: $cask"
    fi
  done

  local pkg
  for pkg in "${BREW_FORMULAE[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      echo "  削除: $pkg"
      if [ "$DRY_RUN" = true ]; then
        echo "  [dry-run] brew uninstall $pkg"
      elif ! brew uninstall "$pkg"; then
        # 他の formula が依存している場合は失敗する。残しても害はないため続行する
        warn "$pkg の削除に失敗しました（他のパッケージが依存している可能性）"
      fi
    else
      echo "  対象なし: $pkg"
    fi
  done
}

# =========================
# 確認
# =========================
confirm() {
  [ "$DRY_RUN" = true ] && return 0
  [ "$ASSUME_YES" = true ] && return 0

  echo "次の対象を削除します:"
  echo "  - $WEZTERM_CONFIG_DIR"
  echo "  - $STARSHIP_CONFIG"
  echo "  - $ZSH_CONFIG_DIR"
  echo "  - $ZSHRC の追記ブロック（編集前にバックアップを取る）"
  echo "  - $PET_SNIPPET / $PET_CONFIG"
  echo "  - $LAZYGIT_CONFIG"
  echo "  - $SCRIPT_DIR/.git/hooks/pre-commit"
  if [ "$RESTORE_BACKUPS" = true ]; then
    echo "  + *.bak を元の場所へ復元する"
  fi
  if [ "$PURGE_BREW" = true ]; then
    echo "  + Homebrew パッケージ ${#BREW_CASKS[@]} 個の cask と ${#BREW_FORMULAE[@]} 個の formula"
  fi
  echo ""

  if [ ! -t 0 ]; then
    echo "エラー: 対話実行ではないため確認を取れません。--yes か --dry-run を指定してください" >&2
    exit 1
  fi

  local answer
  read -r -p "続行しますか? [y/N] " answer
  case "$answer" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *)
      echo "中止しました"
      exit 0
      ;;
  esac
}

# =========================
# メイン
# =========================
main() {
  parse_args "$@"

  if [ "$DRY_RUN" = true ]; then
    echo "ターミナル環境の削除内容を確認します（--dry-run: 変更しません）"
  else
    echo "ターミナル環境の削除を開始します"
  fi
  echo ""

  confirm

  uninstall_wezterm
  echo ""
  uninstall_starship
  echo ""
  uninstall_zsh
  echo ""
  uninstall_pet
  echo ""
  uninstall_lazygit
  echo ""
  uninstall_pre_commit
  echo ""
  purge_brew_packages
  echo ""

  if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "手動対応が必要な項目が ${#WARNINGS[@]} 件あります:"
    local w
    for w in "${WARNINGS[@]}"; do
      echo "  - $w"
    done
    echo ""
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "確認を終了しました（何も変更していません）"
    return 0
  fi

  echo "削除が完了しました"
  echo "ターミナルを再起動すると設定が外れた状態になります"
  echo ""
  echo "リポジトリ自体を消す場合は、Git 管理外の $SCRIPT_DIR/zsh/hidden/ に"
  echo "必要な設定が残っていないか確認してから削除してください"
}

main "$@"

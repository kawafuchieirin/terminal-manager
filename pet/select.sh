#!/usr/bin/env bash
# =============================================================================
# pet の selectcmd（snippet 選択 UI）
# =============================================================================
# pet は config.toml の selectcmd にスニペット一覧を stdin で流し込み、選択結果
# （1 行）を stdout から受け取る。このスクリプトはその間に立ち、
#
#   1. 主タグ（行内の最初の #tag）ごとに行全体を色分けして fzf に渡す
#   2. fzf をカテゴリ絞り込みキー付きで起動する（F1=全件 / F2〜=各カテゴリ）
#
# を行う。fzf --ansi は表示時に ANSI を解釈し、選択結果からは ANSI を除去する
# ため、pet 側はコマンドを正しく解析できる。
#
# pet は selectcmd に "fzf" 文字列が無いと初期クエリを `--query <値>` 形式で
# 末尾に付与する。このスクリプトはその引数を "$@" で受け取り fzf に透過するので
# `pet search --query "$LBUFFER"`（Ctrl+G）の初期クエリも機能する。
# =============================================================================

set -euo pipefail

# 主タグ → ANSI 256 色（前景色）。pet のタグ入力順の先頭をカテゴリとみなす。
colorize() {
  awk '
  {
    cat = "default"
    if (match($0, /#[A-Za-z0-9_-]+/)) {
      cat = substr($0, RSTART + 1, RLENGTH - 1)
    }
    # カテゴリ → 色コード
    col["git"]              = "38;5;114"  # 緑
    col["docker"]           = "38;5;75"   # 青
    col["ssh"]              = "38;5;179"  # 黄
    col["network"]          = "38;5;80"   # シアン
    col["search"]           = "38;5;204"  # ピンク
    col["terminal-manager"] = "38;5;176"  # 紫
    col["setup"]            = "38;5;176"  # 紫
    col["default"]          = "38;5;245"  # グレー

    code = (cat in col) ? col[cat] : col["default"]
    printf "\033[%sm%s\033[0m\n", code, $0
  }
  '
}

colorize | fzf \
  --ansi \
  --layout=reverse \
  --info=inline \
  --prompt='snippet> ' \
  --header='F1:全件  F2:git  F3:docker  F4:ssh  F5:network  F6:search' \
  --bind="f1:change-query()" \
  --bind="f2:change-query('#git)" \
  --bind="f3:change-query('#docker)" \
  --bind="f4:change-query('#ssh)" \
  --bind="f5:change-query('#network)" \
  --bind="f6:change-query('#search)" \
  "$@"

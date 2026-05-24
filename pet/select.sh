#!/usr/bin/env bash
# =============================================================================
# pet の selectcmd（snippet 選択 UI）
# =============================================================================
# pet は config.toml の selectcmd にスニペット一覧を stdin で流し込み、選択結果
# （1 行）を stdout から受け取る。pet が渡す 1 行の形式は
#
#     [<説明>]: <コマンド> #tag1 #tag2␣      （末尾に半角スペースが付く）
#
# で、説明が先頭にある。長い日本語の説明が左を占有すると肝心のコマンドが
# 画面右端で見切れるため、このスクリプトは表示だけコマンドを先頭へ並べ替える。
#
# 【重要】pet は selectcmd が返した行を、内部生成した行と「完全一致」で照合して
# スニペットを特定する（末尾スペース含む）。したがって並べ替えた行をそのまま
# 返すと一致せずコマンドが挿入されない。これを避けるため各行を
#
#     <色付き・並べ替え後の表示>\t<pet が渡してきた元の行>
#
# というタブ区切りに変換し、fzf には `--with-nth=1` で第 1 フィールド（表示）だけ
# を見せ、選択後に第 2 フィールド（元の行）を取り出して pet へ返す。ANSI は
# 第 1 フィールド内で閉じるため、第 2 フィールドは常に無加工の元行になる。
#
# pet は selectcmd に "fzf" 文字列が無いと初期クエリを `--query <値>` 形式で
# 末尾に付与する。このスクリプトはその引数を "$@" で受け取り fzf に透過するので
# `pet search --query "$LBUFFER"`（Ctrl+G）の初期クエリも機能する。
# =============================================================================

set -euo pipefail

# pet の各行を「表示用（色付き・コマンド先頭）\t 元の行」に変換する。
#   主タグ = 行内最初の #tag。pet のタグ入力順の先頭をカテゴリとみなす。
colorize() {
  awk '
  {
    orig = $0                                   # pet が完全一致で照合する元の行（末尾スペースも保持）

    # カテゴリ（主タグ）→ ANSI 256 色（前景色）
    cat = "default"
    if (match($0, /#[A-Za-z0-9_-]+/)) {
      cat = substr($0, RSTART + 1, RLENGTH - 1)
    }
    col["git"]              = "38;5;114"  # 緑
    col["docker"]           = "38;5;75"   # 青
    col["ssh"]              = "38;5;179"  # 黄
    col["network"]          = "38;5;80"   # シアン
    col["search"]           = "38;5;204"  # ピンク
    col["terminal-manager"] = "38;5;176"  # 紫
    col["setup"]            = "38;5;176"  # 紫
    col["default"]          = "38;5;245"  # グレー
    code = (cat in col) ? col[cat] : col["default"]

    # "[<説明>]: <コマンド> #tags" → 表示は "<コマンド> #tags    [<説明>]"
    desc = ""; body = orig
    if (match(orig, /^\[[^]]*\]: /)) {
      d = substr(orig, 1, RLENGTH); sub(/: $/, "", d)   # "[<説明>]"
      desc = d
      body = substr(orig, RLENGTH + 1)                  # "<コマンド> #tags "
    }
    display = body "   " desc

    printf "\033[%sm%s\033[0m\t%s\n", code, display, orig
  }
  '
}

colorize | fzf \
  --ansi \
  --delimiter='\t' \
  --with-nth=1 \
  --layout=reverse \
  --info=inline \
  --prompt='snippet> ' \
  --preview='printf "%s\n" {2}' \
  --preview-window='down,30%,wrap,border-top' \
  --bind='ctrl-p:toggle-preview' \
  --header='F1:全件  F2:git  F3:docker  F4:ssh  F5:network  F6:search  C-p:プレビュー' \
  --bind="f1:change-query()" \
  --bind="f2:change-query('#git)" \
  --bind="f3:change-query('#docker)" \
  --bind="f4:change-query('#ssh)" \
  --bind="f5:change-query('#network)" \
  --bind="f6:change-query('#search)" \
  "$@" \
  | awk -F'\t' '{ print $2 }'   # pet へは元の行（タブ右側）をそのまま返す

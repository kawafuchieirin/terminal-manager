#!/usr/bin/env bash
# =============================================================================
# Vial のキーマップ（.vil）を jq で整形する
# =============================================================================
# Vial が書き出す .vil は 1 行の JSON で、キーを 1 つ変えただけでも diff が
# ファイル全体になり「どのレイヤーのどのキーを変えたか」が履歴から読めない。
# jq で 2 スペースインデントに展開すると、キーコードが 1 行 1 個に並ぶため
# 行単位の diff になる。
#
# キー割り当ては一切変更しない。整形前後の JSON を正規形（jq -S -c）で比較し、
# 一致しない場合は書き戻さずエラーで止める。
#
# 使い方:
#   ./format-vil.sh                # keymaps/ 配下の .vil をすべて整形
#   ./format-vil.sh a.vil b.vil    # 指定したファイルを整形（pre-commit 用）
#   ./format-vil.sh --check        # 整形せず、未整形のファイルがあれば終了コード 1
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYMAPS_DIR="$SCRIPT_DIR/keymaps"

# jq 1.7 未満は整形時に数値リテラルを再生成するため、.vil の uid（64bit 整数）が
# 指数表記に丸められて別の個体の設定として壊れる。1.7 以降は変更していない
# リテラルをそのまま出力する
JQ_REQUIRED_MAJOR=1
JQ_REQUIRED_MINOR=7

CHECK_ONLY=0

usage() {
  cat <<'USAGE'
使い方: format-vil.sh [--check] [ファイル...]

  引数なし        keymaps/ 配下の .vil をすべて整形する
  ファイル指定    指定した .vil だけを整形する
  --check         整形せず、未整形のファイルがあれば終了コード 1 で終わる
  -h, --help      このヘルプを表示する
USAGE
}

# jq が無い／古いときは、何をすれば直るかまで出してから止める
require_jq() {
  if ! command -v jq &>/dev/null; then
    cat >&2 <<'ERROR'
エラー: jq がインストールされていません

.vil の整形には jq が必要です。次のいずれかで導入してください。

  brew install jq      # 単体で入れる
  ./setup.sh           # リポジトリ全体のセットアップ（jq も含む）

Homebrew 自体が未導入の場合は https://brew.sh/ を参照してください。
ERROR
    exit 1
  fi

  local version major minor
  # "jq-1.8.1" / "jq-1.6" / "jq-1.7rc1" のいずれの形式でも先頭 2 桁を取る
  version="$(jq --version 2>/dev/null | sed -n 's/^jq-\{0,1\}\([0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p')"
  if [ -z "$version" ]; then
    echo "エラー: jq のバージョンを判定できません（jq --version: $(jq --version 2>&1)）" >&2
    exit 1
  fi
  major="${version%%.*}"
  minor="${version##*.}"

  if [ "$major" -lt "$JQ_REQUIRED_MAJOR" ] ||
    { [ "$major" -eq "$JQ_REQUIRED_MAJOR" ] && [ "$minor" -lt "$JQ_REQUIRED_MINOR" ]; }; then
    cat >&2 <<ERROR
エラー: jq $version は古すぎます（${JQ_REQUIRED_MAJOR}.${JQ_REQUIRED_MINOR} 以降が必要）

jq ${JQ_REQUIRED_MAJOR}.${JQ_REQUIRED_MINOR} より前のバージョンは整形時に数値を再生成するため、
.vil の uid（64bit 整数）が丸められて設定が壊れます。

  brew upgrade jq
ERROR
    exit 1
  fi
}

# 整形前後で中身が変わっていないことを確認する。キー順の違いを無視した
# 正規形で比較するので、インデントや改行の違いだけが許容される
assert_same_content() {
  local original="$1" formatted="$2"

  if ! diff -q <(jq -S -c . "$original") <(jq -S -c . "$formatted") >/dev/null; then
    echo "エラー: 整形で内容が変化しました（書き戻しません）: $original" >&2
    return 1
  fi
}

# 戻り値: 0 = 変更なし, 1 = 整形した（--check では「要整形」）, 2 = エラー
format_file() {
  local file="$1"
  local tmp status

  if [ ! -f "$file" ]; then
    echo "エラー: ファイルがありません: $file" >&2
    return 2
  fi

  if ! jq empty "$file" 2>/dev/null; then
    echo "エラー: JSON として読めません: $file" >&2
    jq empty "$file" 2>&1 | sed 's/^/  /' >&2
    return 2
  fi

  tmp="$(mktemp)"
  status=0

  if ! jq --indent 2 . "$file" >"$tmp"; then
    echo "エラー: 整形に失敗しました: $file" >&2
    status=2
  elif ! assert_same_content "$file" "$tmp"; then
    status=2
  elif cmp -s "$file" "$tmp"; then
    status=0
  elif [ "$CHECK_ONLY" -eq 1 ]; then
    echo "未整形: $file"
    status=1
  else
    # mv ではなく中身を上書きして、パーミッションとシンボリックリンクを保つ
    cat "$tmp" >"$file"
    echo "整形: $file"
    status=1
  fi

  rm -f "$tmp"
  return "$status"
}

main() {
  local -a targets=()
  local arg

  while [ $# -gt 0 ]; do
    arg="$1"
    case "$arg" in
      --check)
        CHECK_ONLY=1
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        targets+=("$@")
        break
        ;;
      -*)
        echo "エラー: 不明なオプション: $arg" >&2
        usage >&2
        exit 1
        ;;
      *)
        targets+=("$arg")
        shift
        ;;
    esac
  done

  require_jq

  # 引数が無ければ keymaps/ 配下をすべて対象にする
  if [ "${#targets[@]}" -eq 0 ]; then
    if [ ! -d "$KEYMAPS_DIR" ]; then
      echo "エラー: keymaps ディレクトリがありません: $KEYMAPS_DIR" >&2
      exit 1
    fi
    while IFS= read -r -d '' file; do
      targets+=("$file")
    done < <(find "$KEYMAPS_DIR" -maxdepth 1 -type f -name '*.vil' -print0 | sort -z)

    if [ "${#targets[@]}" -eq 0 ]; then
      echo "対象の .vil がありません: $KEYMAPS_DIR"
      echo "Vial の File → Save current layout で保存したファイルを置いてください"
      exit 0
    fi
  fi

  local changed=0 failed=0 status
  for file in "${targets[@]}"; do
    status=0
    format_file "$file" || status=$?
    case "$status" in
      1) changed=$((changed + 1)) ;;
      2) failed=$((failed + 1)) ;;
      *) ;;
    esac
  done

  if [ "$failed" -gt 0 ]; then
    echo "失敗: $failed 件（内容は変更していません）" >&2
    exit 2
  fi

  if [ "$CHECK_ONLY" -eq 1 ]; then
    if [ "$changed" -gt 0 ]; then
      echo "未整形のファイルが $changed 件あります。./cornix-lp/format-vil.sh を実行してください" >&2
      exit 1
    fi
    echo "すべて整形済みです"
    exit 0
  fi

  if [ "$changed" -eq 0 ]; then
    echo "整形済み（変更なし）"
  fi
}

main "$@"

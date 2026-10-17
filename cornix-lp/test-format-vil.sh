#!/usr/bin/env bash
# =============================================================================
# format-vil.sh のテスト
# =============================================================================
# 「整形しても .vil の中身（キー割り当て）が変わらない」ことが最重要の性質なので、
# 正規形の一致・uid のバイト列保持・冪等性をここで固定する。
#
# 使い方: ./cornix-lp/test-format-vil.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$SCRIPT_DIR/format-vil.sh"

PASS=0
FAIL=0
SANDBOXES=()

# Vial が書き出す 1 行 JSON を模した入力。uid は 64bit 整数、レイヤーには
# -1（キーなし）や KC_TRNS が混ざる
FIXTURE='{"version":1,"uid":12345678901234567890,"layout":[[["KC_Q","KC_W","KC_E"],["KC_A","KC_S","KC_D"]],[[-1,"KC_TRNS","MO(2)"],["KC_LEFT","KC_DOWN","KC_UP"]]],"encoder_layout":[[["KC_VOLU","KC_VOLD"]]],"layout_options":-1,"macro":[[],[]],"vial_protocol":6,"via_protocol":12,"tap_dance":[["KC_NO","KC_NO","KC_NO","KC_NO",0]],"combo":[["KC_NO","KC_NO","KC_NO","KC_NO","KC_NO"]],"key_override":[],"settings":{"0":0}}'

cleanup() {
  local dir
  for dir in ${SANDBOXES[@]+"${SANDBOXES[@]}"}; do
    rm -rf "$dir"
  done
}
trap cleanup EXIT

ok() {
  PASS=$((PASS + 1))
  echo "  ok: $1"
}

ng() {
  FAIL=$((FAIL + 1))
  echo "  NG: $1" >&2
}

assert_eq() {
  local expected="$1" actual="$2" label="$3"
  if [ "$expected" = "$actual" ]; then
    ok "${label}"
  else
    ng "${label} -- 期待: ${expected} / 実際: ${actual}"
  fi
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  if printf '%s' "$haystack" | grep -q -- "$needle"; then
    ok "${label}"
  else
    ng "${label} -- '${needle}' を含まない"
  fi
}

# format-vil.sh は自分の隣の keymaps/ を既定の対象にするため、
# テストごとに「スクリプト + keymaps/」のセットを使い捨てで作る
new_sandbox() {
  local dir
  dir="$(mktemp -d)"
  SANDBOXES+=("$dir")
  mkdir -p "$dir/keymaps"
  cp "$TARGET" "$dir/format-vil.sh"
  printf '%s' "$dir"
}

test_format() {
  echo "=== 整形の基本動作 ==="
  local sandbox vil before_canonical before_layout status lines out
  sandbox="$(new_sandbox)"
  vil="$sandbox/keymaps/cornix-lp.vil"
  printf '%s\n' "$FIXTURE" >"$vil"

  before_canonical="$(jq -S -c . "$vil")"
  before_layout="$(jq -S -c '.layout' "$vil")"

  status=0
  "$sandbox/format-vil.sh" >/dev/null || status=$?
  assert_eq 0 "$status" "終了コード 0 で整形できる"
  assert_eq "$before_canonical" "$(jq -S -c . "$vil")" "整形前後で JSON の内容が一致する"
  assert_eq "$before_layout" "$(jq -S -c '.layout' "$vil")" "キー割り当て（layout）が変わらない"

  lines="$(wc -l <"$vil" | tr -d ' ')"
  if [ "$lines" -gt 50 ]; then
    ok "行単位の diff が読める形に展開される（${lines} 行）"
  else
    ng "展開されていない（${lines} 行）"
  fi

  assert_contains "$(cat "$vil")" '12345678901234567890' "uid の 64bit 整数がリテラルのまま保持される"
  assert_contains "$(cat "$vil")" '      "KC_Q",' "キーコードが 1 行ずつ並ぶ"

  # 2 回目は何も変えない（冪等）
  out="$("$sandbox/format-vil.sh")"
  assert_contains "$out" '変更なし' "2 回目の実行では変更しない（冪等）"
}

test_check_mode() {
  echo "=== --check ==="
  local sandbox vil original status out
  sandbox="$(new_sandbox)"
  vil="$sandbox/keymaps/cornix-lp.vil"
  printf '%s\n' "$FIXTURE" >"$vil"
  original="$(cat "$vil")"

  status=0
  out="$("$sandbox/format-vil.sh" --check 2>&1)" || status=$?
  assert_eq 1 "$status" "未整形なら終了コード 1"
  assert_contains "$out" '未整形' "未整形のファイル名を報告する"
  assert_eq "$original" "$(cat "$vil")" "--check はファイルを書き換えない"

  "$sandbox/format-vil.sh" >/dev/null
  status=0
  "$sandbox/format-vil.sh" --check >/dev/null || status=$?
  assert_eq 0 "$status" "整形済みなら終了コード 0"
}

test_explicit_files() {
  echo "=== ファイル指定（pre-commit と同じ渡し方） ==="
  local sandbox a b status out
  sandbox="$(new_sandbox)"
  a="$sandbox/a.vil"
  b="$sandbox/b.vil"
  printf '%s\n' "$FIXTURE" >"$a"
  printf '%s\n' "$FIXTURE" >"$b"

  status=0
  out="$("$sandbox/format-vil.sh" "$a" "$b")" || status=$?
  assert_eq 0 "$status" "keymaps/ 外のファイルも引数で整形できる"
  assert_contains "$out" 'a.vil' "整形したファイルを報告する"
  assert_eq "$(jq -S -c . <<<"$FIXTURE")" "$(jq -S -c . "$b")" "指定した全ファイルを整形する"
}

test_errors() {
  echo "=== エラー処理 ==="
  local sandbox broken status out
  sandbox="$(new_sandbox)"

  # 壊れた JSON は書き換えずに失敗する
  broken="$sandbox/keymaps/broken.vil"
  printf '%s' '{"version":1,' >"$broken"
  status=0
  out="$("$sandbox/format-vil.sh" 2>&1)" || status=$?
  assert_eq 2 "$status" "壊れた JSON は終了コード 2"
  assert_contains "$out" 'JSON として読めません' "JSON パースエラーを報告する"
  assert_eq '{"version":1,' "$(cat "$broken")" "壊れた JSON のファイルを書き換えない"
  rm -f "$broken"

  # 存在しないファイル
  status=0
  out="$("$sandbox/format-vil.sh" "$sandbox/missing.vil" 2>&1)" || status=$?
  assert_eq 2 "$status" "存在しないファイルは終了コード 2"
  assert_contains "$out" 'ファイルがありません' "存在しないファイルを報告する"

  # 対象が無いときは成功扱いで案内を出す
  status=0
  out="$("$sandbox/format-vil.sh" 2>&1)" || status=$?
  assert_eq 0 "$status" ".vil が無いときは終了コード 0"
  assert_contains "$out" 'Save current layout' ".vil が無いとき保存手順を案内する"

  # 不明なオプション
  status=0
  out="$("$sandbox/format-vil.sh" --bogus 2>&1)" || status=$?
  assert_eq 1 "$status" "不明なオプションは終了コード 1"
  assert_contains "$out" '不明なオプション' "不明なオプションを報告する"
}

test_jq_requirements() {
  echo "=== jq の前提チェック ==="
  local sandbox bin status out
  sandbox="$(new_sandbox)"
  printf '%s\n' "$FIXTURE" >"$sandbox/keymaps/cornix-lp.vil"

  # jq が PATH に無い状態。macOS は /usr/bin/jq を同梱するため、ディレクトリを
  # 絞るだけでは再現できない。jq 判定に到達するまでに必要なコマンド
  # （shebang の bash、SCRIPT_DIR の dirname、エラー表示の cat）だけを
  # 置いた PATH で実行する
  bin="$sandbox/bin-nojq"
  mkdir -p "$bin"
  ln -s /bin/bash "$bin/bash"
  ln -s /usr/bin/dirname "$bin/dirname"
  ln -s /bin/cat "$bin/cat"
  status=0
  out="$(PATH="$bin" "$sandbox/format-vil.sh" 2>&1)" || status=$?
  assert_eq 1 "$status" "jq が無いと終了コード 1"
  assert_contains "$out" 'jq がインストールされていません' "jq 未導入をわかりやすく報告する"
  assert_contains "$out" 'brew install jq' "jq の導入方法を案内する"

  # jq が古い状態（1.6 を名乗るスタブを PATH の先頭に置く）
  bin="$sandbox/bin-oldjq"
  mkdir -p "$bin"
  printf '#!/bin/sh\necho jq-1.6\n' >"$bin/jq"
  chmod +x "$bin/jq"
  status=0
  out="$(PATH="$bin:$PATH" "$sandbox/format-vil.sh" 2>&1)" || status=$?
  assert_eq 1 "$status" "jq が古いと終了コード 1"
  assert_contains "$out" '古すぎます' "jq のバージョン不足を報告する"
}

test_format
test_check_mode
test_explicit_files
test_errors
test_jq_requirements

echo
echo "結果: ${PASS} 件成功 / ${FAIL} 件失敗"
[ "$FAIL" -eq 0 ]

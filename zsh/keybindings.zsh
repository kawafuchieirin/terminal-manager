# キーバインド参照専用。%x はこの関数を定義したファイル（リンクも解決）。
function kb() {
  local catalog
  catalog=$(python3 "${${(%):-%x}:A:h}/keybindings.py") || return $?
  if [[ "${1:-}" == '--list' ]] || ! command -v fzf &>/dev/null; then
    print -r -- "$catalog"
    return
  fi

  local result=0
  fzf --header-lines=1 --layout=reverse \
    --prompt='keybindings> ' \
    --header='ツール・キー・説明で検索 / Enter: 表示のみ / Esc: 閉じる' \
    --query="$*" <<< "$catalog" || result=$?
  # 該当なし・キャンセルは正常終了。
  (( result == 1 || result == 130 )) && return 0
  return "$result"
}

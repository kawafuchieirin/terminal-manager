#!/bin/zsh -f
# 実行: zsh -f zsh/test-keybindings.zsh
set -eu
source "${0:A:h}/keybindings.zsh"
catalog=$(python3 "${0:A:h}/keybindings.py")

[[ "$(kb --list)" == "$catalog" ]]
# 列は空白で揃える（タブは端末ごとに幅が変わる）。
[[ "$catalog" == ツール*キー*説明*設定元* && "$catalog" != *$'\t'* ]]

# 呼び出し元のディレクトリに依存せず、日本語・キーでも検索できる。
cd /tmp
fzf() { command fzf "$@" --filter='WezTerm ペイン'; }
[[ "$(kb)" == *WezTerm*ペイン* ]]
# Mac の記号は入力しづらいため、キー名（Ctrl / Opt / Shift / Cmd）でも検索できる。
for query in 'Ctrl+G' '⌃G'; do
  fzf() { command fzf "$@" --filter="$query"; }
  [[ "$(kb)" == *petスニペット* ]]
done

# 初期検索語はシェルコードとして実行せず、1つの引数として渡す。
fzf() { [[ "$*" == *'--query=gh-dash Issue'* ]]; }
kb gh-dash Issue

fzf() { return 1; }
kb
fzf() { return 130; }
kb
fzf() { return 2; }
if kb; then
  print -u2 'fzf のエラーが失われています'
  exit 1
fi
unfunction fzf

# 生成失敗時は検索を開かず、そのエラーを返す。
python3() { return 2; }
if kb --list; then
  print -u2 '一覧の生成エラーが失われています'
  exit 1
fi
unfunction python3

# fzf 未導入でも一覧を参照できる。
(
  python_bin=$(command -v python3)
  python3() { "$python_bin" "$@"; }
  path=(/usr/bin /bin)
  [[ "$(kb)" == "$catalog" ]]
)
print 'keybindings: OK'

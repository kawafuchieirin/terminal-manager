# lazygit

Git 操作の TUI [lazygit](https://github.com/jesseduffield/lazygit) の設定。実体は `lazygit/config.yml` で、
`setup.sh` が macOS の既定パスへシンボリックリンクを張る。

```
~/Library/Application Support/lazygit/config.yml -> lazygit/config.yml
```

`XDG_CONFIG_HOME` が未設定の macOS では `~/.config/` ではなく上記が参照される。
実際の参照先は `lazygit -cd` で確認できる。

## 起動

```sh
lg        # = lazygit（zsh/aliases.zsh のエイリアス）
```

Git リポジトリ内から起動する。gh-dash から `G` で開くこともできる（[gh-dash/README.md](../gh-dash/README.md)）。

## 設定内容

| キー | 値 | 意図 |
|------|-----|------|
| `gui.mouseEvents` | `true` | クリックでのパネル移動・スクロールを有効化 |
| `gui.showBottomLine` | `false` | 画面下部のキー案内バーを隠して表示領域を広げる（キー一覧は `?` で開く） |
| `os.editPreset` | `"nvim"` | コミット内のファイルを開くときのエディタ |
| `git.overrideGpg` | `true` | GPG 署名コミットを TUI ではなく端末側で処理させ、パスフレーズ入力を通す |

設定できる項目の一覧は [Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) を参照。

## 主なキー

`showBottomLine: false` にしているため、キー一覧は **`?`** で開く（現在のパネルに応じた一覧が出る）。

| キー | 操作 |
|------|------|
| `?` | 現在の画面のキー一覧 |
| `Tab` / `1`〜`5` | パネル切り替え（Status / Files / Branches / Commits / Stash） |
| `Space` | ステージ / 解除（Files パネル） |
| `a` | 全ファイルをステージ / 解除 |
| `c` | コミット |
| `C` | Amend（直前のコミットに追加） |
| `p` / `P` | push / pull |
| `n` | ブランチ作成（Branches パネル） |
| `z` | アンドゥ |
| `q` | 終了 |

上記は lazygit の既定キー（このリポジトリではキーの変更をしていない）。
`kb` コマンドの一覧にも出るが、その内容は `zsh/keybindings-defaults.tsv` の手動管理なので、
lazygit を更新したときは実機の `?` で確認する（[zsh/README.md](../zsh/README.md#キーバインドの横断検索)）。

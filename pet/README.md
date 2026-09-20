# pet — コマンドスニペット

「よく使うが覚えきれない」コマンドや、`<param>` で一部だけ差し替えて使いたいコマンドを
登録・呼び出すための仕組み（[pet](https://github.com/knqyf263/pet)）。スニペット本体はこのディレクトリの
`snippet.toml` で Git 管理する。

## 構成

| ファイル | 役割 | 管理 |
|---------|------|------|
| `pet/snippet.toml` | スニペットの実体 | リポジトリで Git 管理 |
| `pet/select.sh` | pet の `selectcmd`。色分け・カテゴリ絞り込み・プレビュー付きの fzf ラッパー | リポジトリで Git 管理 |
| `~/.config/pet/snippet.toml` | 上記スニペットへのシンボリックリンク | `setup.sh` が作成 |
| `~/.config/pet/config.toml` | pet 本体の設定（`snippetfile` の絶対パス・`selectcmd`・`editor` 等） | `~` 展開に対応しないため `setup.sh` が毎回生成（Git 管理外） |

`setup.sh` が生成する `config.toml`:

```toml
[General]
  snippetfile = "/Users/<you>/.config/pet/snippet.toml"
  editor = "nvim"
  column = 40
  selectcmd = "/path/to/terminal-manager/pet/select.sh"
  sortby = "recency"
```

マシン固有のカスタマイズは行わない方針で、`select.sh` の更新を確実に反映するため毎回上書きする。

## 有効化（最初の一度だけ）

```bash
./setup.sh          # pet のインストール + リンク作成 + config.toml 生成
source ~/.zshrc     # もしくはターミナル再起動
```

## 1. 呼び出す（`Ctrl+G`）

プロンプトで **`Ctrl+G`** → fzf 一覧が開く → 絞り込んで Enter。

- 選んだコマンドは **実行されずに入力行へ挿入** される。そのまま編集して `Enter` で実行できる
  （これが「少し変更して使う」用途の中核）。
- 入力途中で `Ctrl+G` を押すと、その文字列で初期フィルタされた状態で開く
  （例: `doc` まで打って `Ctrl+G` → docker 系が絞り込まれる）。
- `Ctrl+G` は `zsh/.zshrc` の `pet-select` 関数（`pet search --query "$LBUFFER"`）に割り当てている。

### 一覧の見え方（`select.sh`）

| 機能 | 内容 |
|------|------|
| コマンド先頭表示 | pet 既定では `[説明]: コマンド` と説明が左に来るため、長い日本語の説明があるとコマンドが右端で見切れる。`select.sh` は**表示だけ** `コマンド #tags   [説明]` の順へ並べ替える |
| 色分け | 主タグ（行内で最初の `#tag`）ごとに色を変える。`git`=緑 / `docker`=青 / `ssh`=黄 / `network`=シアン / `search`=ピンク / `terminal-manager`・`setup`=紫 / その他=グレー |
| カテゴリ絞り込み | `F1`=全件 / `F2`=git / `F3`=docker / `F4`=ssh / `F5`=network / `F6`=search（クエリを `'#<tag>` に差し替える方式）。タグ文字を直接入力しても絞り込める |
| プレビュー | 一覧下部（高さ 30%・折り返し）に選択中のコマンド全文・説明・タグを表示。`Ctrl+P` で表示 / 非表示を切り替え |

pet は selectcmd が返した行を内部生成した行と**完全一致**で照合してスニペットを特定する（末尾のスペースを含む）。
そのため `select.sh` は各行を `<並べ替えた表示>\t<pet が渡してきた元の行>` に変換し、
fzf には `--with-nth=1` で表示側だけを見せ、選択後に元の行を pet へ返している。
表示を変えても選択結果が壊れないのはこの仕組みによる。

### パラメータ付きスニペット

`ssh <user>@<host>` のように `<...>` を含むスニペットを選ぶと、その箇所がそのまま挿入される。
プロンプト上で実際の値に書き換えて Enter。`<port=3000>` のように `=` 付きはデフォルト値の目印。

## 2. 登録する

```bash
prev         # 直前に実行したコマンドを取り込んで登録（おすすめ）
prev -t      # 上記 + タグも入力する
pn           # その場で Command / Description を入力して登録（= pet new）
```

`prev` は `zsh/.zshrc` 定義のシェル関数。`pet new` は Command 欄を自動で埋めないため、
履歴から直近の実コマンドを取り出して `pet new` に渡している。

差し替えたい箇所は `<param>` と書いておくと、次回呼び出し時にプレースホルダになる。

例:
- Command: `kubectl logs -f <pod> -n <namespace=default>`
- Description: `Pod のログを追跡`

## 3. 編集・整理する

```bash
pe           # snippet.toml を nvim で直接編集（= pet edit）
```

1 エントリの形式:

```toml
[[Snippets]]
  Description = "説明（fzf の検索対象になる）"
  Output = ""
  Tag = ["docker", "k8s"]
  command = "実行したいコマンド <param>"
```

`Tag` の**先頭**が主タグとして色分け・カテゴリ絞り込みに使われる。色を効かせたい場合は
`git` / `docker` / `ssh` / `network` / `search` / `terminal-manager` / `setup` のいずれかを先頭に置く。
新しいカテゴリを増やすときは `select.sh` の色テーブルと `--bind` を合わせて追加する
（`--bind` の行は `kb` の一覧にも自動反映される）。

## 4. Git で共有する

登録・編集したら通常どおりコミットする（pet 内蔵の Gist 同期は使わず、リポジトリを単一の情報源とする）。

```bash
git add pet/snippet.toml
git commit -m "feat: pet スニペットを追加"
```

別マシンでは `git pull` → `./setup.sh` で同じスニペットが使える。

## エイリアス・キー

| 呼び出し | 内容 |
|---------|------|
| `Ctrl+G` | スニペットを検索してプロンプトへ挿入 |
| `prev` / `prev -t` | 直前のコマンドを登録（`.zshrc` の関数） |
| `pn` | `pet new` |
| `pe` | `pet edit` |

## 使い分けの目安

- **過去に自分が 1 回打ったものを呼び戻す** → `Ctrl+R`（fzf 履歴検索）
- **繰り返し使う・覚えにくい・一部だけ変えたい定型** → `prev` / `pn` で登録し `Ctrl+G` で呼び出す

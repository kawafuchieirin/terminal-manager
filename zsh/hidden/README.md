# hidden/

環境固有の設定やシークレットを配置するディレクトリ。**会社Mac / 個人Mac の使い分け**もここで行う。

- `.zsh` 拡張子のファイルが `.zshrc` から自動的に読み込まれる
- このディレクトリの内容は `.gitignore` で除外される（`README.md` と `*.example` を除く）
- gitignore 済みのため **`git push` されない／`git pull` で消えない**（各マシン固有の状態が保たれる）

## ファイル構成

| ファイル | 用途 | Git |
|----------|------|-----|
| `secrets.zsh` | シークレット（トークン・APIキー） | 除外 |
| `env.zsh` | 非秘匿のマシン固有設定（PATH・会社用エイリアス等） | 除外 |
| `*.example` | 上記の雛形（ダミー値のみ） | 追跡 |

## セットアップ（新しいMac / 2台目）

```bash
cd ~/.config/zsh/hidden
cp secrets.zsh.example secrets.zsh   # 値を実物に書き換える
cp env.zsh.example    env.zsh        # そのマシン固有の設定を書く
```

会社Macには会社用の値、個人Macには個人用の値を埋める。`*.example` だけが Git 追跡対象なので、実値が push されることはない。

> hidden/ の中身は Git で同期されないため、片方のMacで足した設定はもう片方へ手動でコピーする。

## git のメール・名前

`hidden/` ではなく `~/.gitconfig`（リポジトリ外・マシンローカル）で設定する。各Macで一度だけ:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"   # 会社Macは会社メール
```

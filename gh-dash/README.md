# GitHub をターミナルで操作する

GitHub の Issue・PR は [gh-dash](https://www.gh-dash.dev/)、ローカルの Git 操作は既存の lazygit を使う。
Issue / PR の作成は gh-dash から GitHub CLI の対話入力を開く。

## 導入

前提: `gh`、`lazygit`、`delta`、ターミナル用エディタ（この環境では `nvim`）。
未導入なら `brew install gh lazygit git-delta neovim` を実行する。

```sh
gh auth status
# 未認証の場合のみ実行（初回認証ではブラウザを使う場合がある）
gh auth login
gh extension install dlvhdr/gh-dash
```

このリポジトリのルートで、設定を配置する。既存設定があれば先に別名で保存する。

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash"
ln -s "$PWD/gh-dash/config.yml" "${XDG_CONFIG_HOME:-$HOME/.config}/gh-dash/config.yml"
```

`ln` は既存ファイルを上書きしない。設定配置なしでも、リポジトリのルートから
`gh dash --config gh-dash/config.yml` で試せる。
更新は `gh extension upgrade gh-dash`。

## 日常の操作

作業対象の clone ディレクトリで `gh dash` を起動する。

| キー | 操作 |
| --- | --- |
| `?` | 利用中のバージョンのキー一覧 |
| `s` | PR / Issue 表示を切り替え |
| `N` | 起動ディレクトリのリポジトリに Issue を対話作成 |
| `P` | 起動ディレクトリのリポジトリに PR を対話作成 |
| `G` | 起動ディレクトリで lazygit を開く（`q` で戻る） |
| `q` | 終了 |

一覧は自分の Issue・PR、レビュー依頼、担当 Issue を表示する。
clone 内では標準のフィルタにより、そのリポジトリに絞り込まれる。
**`N` / `P` / `G` の対象は選択行ではなく起動ディレクトリ**。
作成画面では Submit を選ぶとターミナル内で投稿できる。
PR の差分・コメント・レビュー・マージは `?` に表示される標準操作を使う。
ブラウザを開く操作もあるため、キー一覧で区別する。

## Issue → ブランチ → 作業 → PR

1. 対象リポジトリで `gh dash` → `N` から Issue を作成し、番号を控える。
2. `q` でシェルに戻り、`gh issue develop 123 --checkout` を実行する（`123` は Issue 番号）。GitHub に Issue と関連付けたブランチを作成し、ローカルでも切り替える。
3. エディタで実装し、`lazygit` で差分確認・ステージ・コミット・push を行う。
4. `gh dash` → `P` で PR を作成する。本文に `Closes #123` を記載する。
5. gh-dash の PR 一覧から差分・チェックを確認し、レビューやマージを行う。

ブランチ作成前に `git status` で作業状態を確認する。
`repoPaths` は `kawafuchieirin/*` を `~/work-space/*` に対応させている。
別の場所の clone を gh-dash から checkout する場合は設定を調整する。

設定仕様: [キーの追加](https://www.gh-dash.dev/configuration/keybindings/) / [clone の場所](https://www.gh-dash.dev/configuration/repo-paths/)。

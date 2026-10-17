# Starship

プロンプト [Starship](https://starship.rs/) の設定。実体は `starship/starship.toml` で、
`setup.sh` が `~/.config/starship.toml` をこのファイルへのシンボリックリンクとして張る。
初期化は `zsh/.zshrc` の `eval "$(starship init zsh)"`。

Nerd Font のアイコン表示を前提にしている（`setup.sh` が導入する PlemolJP Console NF / HackGen Console NF に内蔵）。

## 表示のかたち

Powerlevel10k 風の二段プロンプト。情報行の下に入力行を置くので、長いパスやブランチ名でも入力位置がずれない。

```
   ~/path   main [ ステージ1 変更2 未追跡3 ]   Node v24.15.0    AWS prod
❯
```

記号だと意味を思い出せないため、Git の状態とランタイム名は日本語ラベル・名前付きで表示する。

`format` の並び順（`add_newline = true` でプロンプトの前に空行を入れる）:

1. `$os` — OS アイコン
2. `$directory` — カレントディレクトリ
3. `$git_branch` `$git_status` `$git_state` — Git の状態
4. `$nodejs` `$python` `$golang` `$rust` `$java` `$ruby` `$php` — 言語ランタイム
5. `$docker_context` `$kubernetes` `$aws` `$gcloud` — コンテナ / クラウドのコンテキスト
6. `$line_break` `$character` — 改行してプロンプト記号

各モジュールは該当する状況でのみ表示される（Node プロジェクトでだけ Node のバージョンが出る、など）。

## セグメントごとの設定

| セグメント | 設定 | 内容 |
|-----------|------|------|
| 入力記号 | `[character]` | 成功時は緑の `❯`、直前のコマンドが失敗したときは赤の `❯`、Vi コマンドモードでは `❮` |
| OS |  /  /  | macOS / Linux / Ubuntu を太字青で表示 |
| ディレクトリ | `truncation_length = 3` / `truncate_to_repo = true` / `truncation_symbol = "…/"` | Git リポジトリ内ではリポジトリルートからの相対パス。3 階層を超えると先頭を `…/` で省略。読み取り専用なら 󰌾 を添える |
| Git ブランチ |  + ブランチ名 | 太字紫 |
| Git ステータス | `[ 変更2 未追跡3 ]` 形式 | 下表のラベルを該当するものだけ並べる。太字黄 |
| Git 状態 | `(リベース中 1/3)` 形式 | rebase・merge・cherry-pick など進行中の操作と進捗を日本語で表示 |

#### Git ステータスのラベル

| ラベル | 意味 | Starship の項目 |
|-------|------|----------------|
| `ステージ1` | `git add` 済みが 1 件 | `staged` |
| `変更2` | 変更したがまだ `git add` していないものが 2 件 | `modified` |
| `未追跡3` | Git がまだ追跡していない新規ファイルが 3 件 | `untracked` |
| `削除1` | 削除したファイルが 1 件 | `deleted` |
| `衝突1` | コンフリクト中のファイルが 1 件 | `conflicted` |
| `未push1` | リモートより 1 コミット進んでいる（push していない） | `ahead` |
| `未pull1` | リモートより 1 コミット遅れている（pull していない） | `behind` |
| `未push1 未pull2` | 双方に差分がある（diverged） | `diverged` |

各ラベルは先頭に空白を含み、`format` の閉じ括弧前にも空白を置いて `[ 変更2 未追跡3 ]` と左右を揃えている。

#### Git 状態の日本語表記

| 表示 | 進行中の操作 |
|------|-------------|
| `リベース中` | `git rebase` |
| `マージ中` | `git merge` |
| `リバート中` | `git revert` |
| `チェリーピック中` | `git cherry-pick` |
| `二分探索中` | `git bisect` |
| `パッチ適用中` | `git am` |

### 言語ランタイム

プロジェクトのファイル（`package.json` や `go.mod` 等）を検出したときだけバージョンを表示する。

何のバージョンか一目でわかるよう、アイコンのあとに言語名を出す（例: ` Node v24.15.0`）。

| 言語 | 表示 | 色 |
|------|------|-----|
| Node.js | ` Node ` + バージョン | 緑 |
| Python | ` Python ` + バージョン | 黄（virtualenv 名も併記） |
| Go | ` Go ` + バージョン | シアン |
| Rust | ` Rust ` + バージョン | 赤 |
| Java | ` Java ` + バージョン | 赤 |
| Ruby | ` Ruby ` + バージョン | 赤 |
| PHP | ` PHP ` + バージョン | 青 |

### クラウド / コンテナ

| 対象 | 表示 | 条件 |
|------|------|------|
| Docker | ` Docker ` + context 名 | `only_with_files = true`（`docker-compose.yml` 等があるときだけ） |
| Kubernetes | `☸ K8s ` + context 名（namespace があれば `(ns)`） | `disabled = false` で明示的に有効化 |
| AWS | `  AWS ` + プロファイル名（期限があれば `[残り時間]`） | `AWS_PROFILE` 等が設定されているとき。プロファイル未設定ならアイコンのみ |
| GCP | ` GCP ` + アカウント（`@domain` / `(region)`） | `gcloud` の設定があるとき |

AWS のプロファイル表示は、`sso` / `wssso` エイリアス（[zsh/README.md](../zsh/README.md#aws)）でログインした
プロファイルを取り違えないための安全装置でもある。

## カスタマイズ

`starship/starship.toml` を直接編集する。シンボリックリンク経由で即座に反映されるので、
新しいシェルを開くか `exec zsh` で確認できる。設定項目は [Starship の設定リファレンス](https://starship.rs/config/)を参照。

よく使う操作:

```sh
starship explain     # 現在のプロンプトの各モジュールが何を表示しているか確認
starship timings     # 遅いモジュールを特定（プロンプトが重いとき）
```

アイコンが豆腐（□）になる場合は、WezTerm が Nerd Font を読み込めていない可能性が高い。
`font-plemol-jp-nf` / `font-hackgen-nerd` の導入と WezTerm の再起動（`Cmd+Q` で完全終了）を確認する。

# terminal-manager

macOS 開発環境のターミナル一式（WezTerm + Zsh + Starship）を Git 管理し、`setup.sh` 一発で再現するリポジトリ。
`setup-terminal`（Ghostty 版）の後継。

このファイルは**全体の索引**。各ツールの設定内容・キーバインド・使い方は、それぞれのディレクトリの README にまとめている。

## 目次

- [クイックスタート](#クイックスタート)
- [ドキュメント索引](#ドキュメント索引)
- [ファイル構成](#ファイル構成)
- [setup.sh が行うこと](#setupsh-が行うこと)
- [アンインストール](#アンインストール)
- [pre-commit](#pre-commit)
- [リリース](#リリース)
- [設計方針](#設計方針)

## クイックスタート

前提: [Homebrew](https://brew.sh/) がインストール済み。

```bash
git clone <このリポジトリのURL> ~/work-space/terminal-manager
cd ~/work-space/terminal-manager
./setup.sh
```

`setup.sh` は冪等で、何度実行しても安全。完了後は **WezTerm を `Cmd+Q` で完全終了 → 再起動** すると、
フォント・カラースキーム・透過などが反映される。

キーバインドを忘れたら `kb`（WezTerm / Zsh / pet / gh-dash / lazygit を横断検索）。
→ [zsh/README.md](zsh/README.md#キーバインドの横断検索)

環境を元に戻すときは `./uninstall.sh`。→ [アンインストール](#アンインストール)

## ドキュメント索引

| ドキュメント | 内容 |
|-------------|------|
| [wezterm/README.md](wezterm/README.md) | WezTerm の設定（フォント・Tokyo Night・透過とフォーカス連動・タブバー・ペイン・全キーバインド） |
| [zsh/README.md](zsh/README.md) | Zsh の設定（読み込み順・プラグインと連携ツール・履歴・キーバインド・`kb` コマンド・エイリアス一覧・環境変数・関数） |
| [zsh/hidden/README.md](zsh/hidden/README.md) | 環境固有の設定とシークレット（会社 Mac / 個人 Mac の使い分け） |
| [starship/README.md](starship/README.md) | 二段プロンプトの表示要素・セグメント設定・カスタマイズ |
| [pet/README.md](pet/README.md) | コマンドスニペットの呼び出し（`Ctrl+G`）・登録・共有、`select.sh` の仕組み |
| [lazygit/README.md](lazygit/README.md) | Git TUI の設定と主なキー |
| [gh-dash/README.md](gh-dash/README.md) | GitHub の Issue / PR をターミナルで扱う（`setup.sh` 対象外・手動導入） |
| [wezterm/recommendations.md](wezterm/recommendations.md) | WezTerm のおすすめ設定リファレンス（採用候補のメモ） |

## ファイル構成

| パス | 内容 | 配置先 |
|------|------|--------|
| `setup.sh` | セットアップスクリプト | — |
| `uninstall.sh` | 取り外しスクリプト | — |
| `lib/config.sh` | パッケージ一覧と配置先の定義（`setup.sh` / `uninstall.sh` が共有） | — |
| `wezterm/wezterm.lua` | [WezTerm](https://wezfurlong.org/wezterm/) の設定 | `~/.config/wezterm/`（ディレクトリをリンク） |
| `starship/starship.toml` | [Starship](https://starship.rs/) プロンプトの設定 | `~/.config/starship.toml` |
| `zsh/.zshrc` | Zsh のメイン設定 | `~/.config/zsh/`（ディレクトリをリンク、`~/.zshrc` から source） |
| `zsh/aliases.zsh` | エイリアス定義 | 同上 |
| `zsh/keybindings.zsh` / `keybindings.py` / `keybindings-defaults.tsv` | `kb` コマンド（キーバインドの一覧・横断検索） | 同上 |
| `zsh/test-keybindings.py` / `test-keybindings.zsh` | `kb` のテスト | — |
| `zsh/hidden/` | 環境固有の設定（Git 管理外、`.zsh` を自動読み込み） | 同上 |
| `pet/snippet.toml` | [pet](https://github.com/knqyf263/pet) のスニペット集 | `~/.config/pet/snippet.toml` |
| `pet/select.sh` | pet の `selectcmd`（色分け・カテゴリ絞り込み付き fzf ラッパー） | `~/.config/pet/config.toml` から参照 |
| `lazygit/config.yml` | [lazygit](https://github.com/jesseduffield/lazygit) の設定 | `~/Library/Application Support/lazygit/config.yml` |
| `gh-dash/config.yml` | [gh-dash](https://www.gh-dash.dev/) の設定 | `~/.config/gh-dash/config.yml`（手動リンク） |
| `.pre-commit-config.yaml` | [pre-commit](https://pre-commit.com/) フック定義 | — |
| `.github/workflows/release.yml` | タグ push で GitHub Release を作成 | — |
| `.claude/rules/` | Claude Code 用のルール（README 更新規約など） | — |

設定ファイルはリポジトリ側を実体とし、`~/.config/` 側をシンボリックリンクにする。
実体のディレクトリ / ファイルが既にある場合は `.bak` にリネームしてから張り替える。

## setup.sh が行うこと

関数単位で分割している（`install_brew_packages` / `setup_wezterm` / `setup_starship` / `setup_zsh` /
`setup_pet` / `setup_lazygit` / `setup_pre_commit`）。新しいツールを足すときは同じパターンで関数を作り `main` から呼ぶ。

インストールするパッケージ一覧と設定の配置先は `lib/config.sh` に切り出し、`uninstall.sh` と共有している。
片方だけが古くなって消し残しが出るのを防ぐため、追加・変更はこのファイルだけで行う。

1. **Homebrew パッケージのインストール**
   - cask: `wezterm@nightly` / `font-plemol-jp-nf` / `font-udev-gothic` / `font-hackgen-nerd`
   - formula: `python` / `starship` / `zsh-autosuggestions` / `zsh-syntax-highlighting` / `fzf` / `fd` /
     `ripgrep` / `bat` / `pet` / `lazygit` / `pre-commit` / `gitleaks` / `shellcheck`
   - 安定版 `wezterm` が入っている場合は自動で nightly に置き換える
2. **WezTerm**: `~/.config/wezterm/` を `wezterm/` へリンク（レガシーな `~/.wezterm.lua` があれば `.bak` へ退避）
3. **Starship**: `~/.config/starship.toml` を `starship/starship.toml` へリンク
4. **Zsh**: `~/.config/zsh/` を `zsh/` へリンクし、`~/.zshrc` に source 行を追加（既にあればスキップ）
5. **pet**: `~/.config/pet/snippet.toml` をリンクし、絶対パスを含む `config.toml` を生成
6. **lazygit**: macOS 既定パス（`~/Library/Application Support/lazygit/config.yml`）へリンク
7. **pre-commit**: `.git/hooks/pre-commit` をインストール（未導入・非 Git リポジトリなら警告してスキップ）

`mise` / `zoxide` / `gh-dash` はインストール対象外。必要に応じて個別に導入する
（`.zshrc` は `mise` と `zoxide` を無条件に初期化するため、未導入だとシェル起動時にエラーが出る）。

## アンインストール

```bash
./uninstall.sh --dry-run   # 何が消えるかを先に確認する
./uninstall.sh             # 対象を表示して確認を取ってから削除する
```

`setup.sh` が作ったシンボリックリンク・生成ファイル・`~/.zshrc` の追記ブロックを取り外す。
`setup.sh` と同様に冪等で、何度実行しても安全。

| オプション | 役割 |
|-----------|------|
| `--dry-run` | 何も変更せず、削除される対象だけを表示する |
| `--restore-backups` | `setup.sh` が `.bak` へ退避した旧設定を元の場所へ復元する |
| `--purge-brew` | Homebrew パッケージ（cask・フォント含む）も削除する |
| `-y` / `--yes` | 確認プロンプトを出さずに実行する |

安全側に寄せた既定値にしている。

- **Homebrew パッケージは既定では消さない**。`python` / `fzf` / `ripgrep` 等は他のプロジェクトでも
  使うため、`--purge-brew` を明示したときだけ削除する（依存があって失敗したものは警告して続行）
- **`~/.zshrc` は編集前に `~/.zshrc.bak-<タイムスタンプ>` へバックアップする**。削除するのは
  マーカー行（`# terminal-manager リポジトリから zsh 設定を読み込む`）から対応する `fi` までの
  ブロックと直前の空行だけで、前後の設定はそのまま残す
- **判断がつかないものは消さずに報告する**。マーカー行が見つからない、ブロックが閉じていない、
  リンクではない実体が置かれている——といった場合は変更せず、最後に手動対応が必要な項目として一覧表示する
- `*.bak` は既定では残す（`--restore-backups` で復元）。`~/.config/pet/` は空になったときだけ削除する

`zsh/hidden/` は Git 管理外のため、リポジトリごと削除すると復元できない。
PATH や API キーが入っている場合は、先に別の場所へ退避してからリポジトリを消す。

## pre-commit

`setup.sh` が `pre-commit install` まで行うため、コミット時に自動でフックが走る。
**シークレットの誤コミットを物理的に防ぐ**のが主目的。

| フック | 役割 |
|--------|------|
| [gitleaks](https://github.com/gitleaks/gitleaks) | API キー・トークン等のシークレット検出 |
| `detect-private-key` | SSH / PEM 等の秘密鍵を検出 |
| `check-added-large-files` | 1MB 超（`--maxkb=1000`）のファイルコミットをブロック |
| `check-merge-conflict` | マージ競合マーカーの残存を検出 |
| `trailing-whitespace` / `end-of-file-fixer` | 行末空白・末尾改行の整形 |
| [shellcheck](https://www.shellcheck.net/) | シェルスクリプトの lint（`zsh/` は zsh 固有構文のため除外） |

```bash
pre-commit run --all-files   # 全ファイルに対して手動実行
pre-commit autoupdate        # 各フックのバージョンを最新化
```

誤検出は `.pre-commit-config.yaml` 側で除外設定を追加する。シークレットの真陽性が出た場合は
**コミットせずローテーション**（再発行・無効化）を最優先で行う。

## リリース

`main` に push（PR をマージ）すると `.github/workflows/release.yml` が動き、前回タグ以降の
コンベンショナルコミットから次のバージョンを判定してタグを打ち、GitHub Release を作成する
（リリースノートは自動生成）。タグを手で打つ必要はない。

| コミットの型 | 上がる桁 | 例 |
|-------------|---------|-----|
| `feat!:` / 本文に `BREAKING CHANGE:` | major | v1.2.3 → v2.0.0 |
| `feat:` | minor | v1.2.3 → v1.3.0 |
| `fix:` `docs:` `refactor:` `chore:` `ci:` 等 | patch | v1.2.3 → v1.2.4 |
| 該当する型のコミットなし | リリースしない | — |

初回リリースは `v0.1.0` から始まる。マージコミットは判定対象から除外し、同じタグのリリースが
既にある場合はスキップする（冪等）。

バージョンを明示したいときは Actions の `Release` を手動実行（`workflow_dispatch`）し、
`bump` に `auto` / `patch` / `minor` / `major` を指定する。

## 設計方針

- **ポータビリティ**: `setup.sh` 一発で環境構築が完了する
- **冪等性**: 何度実行しても同じ結果になる
- **可逆性**: `uninstall.sh` で元に戻せる。`setup.sh` に作るものを足したら、外す処理も同時に足す
- **リポジトリ側を実体にする**: 設定は Git 管理下に置き、`~/.config/` はシンボリックリンクにする。既存設定は `.bak` に退避
- **環境固有設定の分離**: PC 固有の値・シークレットは `zsh/hidden/` に分離し Git 管理外で扱う
- **シークレット流出の予防**: pre-commit + gitleaks でコミット時に検査し、公開リポジトリへ push される事故を防ぐ
- **ドキュメントの階層化**: このファイルは索引、詳細は各ディレクトリの README。設定を変えたらその README も更新する

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

macOS 開発環境のターミナル一式（**WezTerm + Zsh + Starship**）の設定とセットアップを Git 管理するリポジトリ。`../setup-terminal/`（Ghostty + Zsh + Starship）を廃止して本リポジトリへ統合した後継プロジェクト。

## 設計方針

- **ポータビリティ**: `setup.sh` 一発で環境構築が完了。冪等で何度実行しても安全。
- **シンボリックリンク配置**: 設定ファイルはリポジトリ側に置き、`~/.config/<tool>/` をリンクとして張る（実体はリポジトリ側）。
- **既存設定の保護**: 実体ディレクトリ／ファイルが既にある場合は `.bak` にリネームしてから張り替える。
- **環境固有値の分離**: ホスト固有の値（PATH・APIキー等）は `zsh/hidden/` に配置。`hidden/*` は `.gitignore` 済み（`README.md` のみ追跡）。`.zshrc` 等の追跡ファイルにシークレットを直接書かない。

## ツール構成

| ツール | リポジトリ側 | リンク先 |
|--------|-------------|----------|
| WezTerm | `wezterm/wezterm.lua` | `~/.config/wezterm/` |
| Starship | `starship/starship.toml` | `~/.config/starship.toml` |
| Zsh | `zsh/` | `~/.config/zsh/`（`~/.zshrc` から source） |

## セットアップと取り外し

```bash
./setup.sh                 # 構築
./uninstall.sh --dry-run   # 取り外し対象の確認
./uninstall.sh             # 取り外し
```

`setup.sh` は関数単位で分割（`install_brew_packages` / `setup_wezterm` / `setup_starship` / `setup_zsh` / `setup_pet` / `setup_lazygit` / `setup_pre_commit`）。新ツール追加時は同パターンで関数を足し `main` から呼び出す。

`uninstall.sh` は対になる `uninstall_*` 関数を持つ。**`setup.sh` に作る処理を足したら、`uninstall.sh` に外す処理も同時に足す**（消し残しを防ぐ）。パッケージ一覧と設定の配置先は `lib/config.sh` が単一の情報源で、両スクリプトが source する。ここを経由せずパスを直書きしない。

`uninstall.sh` は安全側に倒す方針: Homebrew パッケージは `--purge-brew` 指定時のみ削除、`~/.zshrc` は編集前にバックアップ、判断がつかないもの（リンクでない実体・マーカー不一致）は消さず警告する。

## ドキュメント構成と自動更新

- ルートの `README.md` は**索引**（概要・クイックスタート・ドキュメント索引・ファイル構成・`setup.sh` の処理・pre-commit・リリース・設計方針）。
- 各ツールの詳細は**そのディレクトリの `README.md`**（`wezterm/` `zsh/` `zsh/hidden/` `starship/` `pet/` `lazygit/` `gh-dash/`）。同じ表をルートと重複管理しない。

設定ファイルや `setup.sh` を変更したら `.claude/rules/update-readme.md` の規約に従い、該当ディレクトリの README（必要ならルートの索引も）を実態と一致させる。エイリアス表は `zsh/aliases.zsh` から生成し、推測で項目を増やさない。

## コミットとリリース

コミットメッセージの型がそのまま公開バージョンを決める（`main` への push で `.github/workflows/release.yml` がタグと GitHub Release を自動作成）。型の選び方・破壊的変更の基準・書き方は `.claude/rules/commit-convention.md` に従う。現在 0.x 系のため、破壊的変更でも `!` と行頭 `BREAKING CHANGE:` は使わない（v1.0.0 は手動リリースで出す）。

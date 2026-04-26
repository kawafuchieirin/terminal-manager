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

## セットアップ

```bash
./setup.sh
```

`setup.sh` は関数単位で分割（`install_brew_packages` / `setup_wezterm` / `setup_starship` / `setup_zsh`）。新ツール追加時は同パターンで関数を足し `main` から呼び出す。

## README 自動更新

設定ファイルや `setup.sh` を変更したら `.claude/rules/update-readme.md` の規約に従い `README.md` を実態と一致させる。エイリアス表は `zsh/aliases.zsh` から生成し、推測で項目を増やさない。

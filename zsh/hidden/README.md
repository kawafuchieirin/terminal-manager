# hidden/

環境固有の設定やシークレットを配置するディレクトリ。

- `.zsh` 拡張子のファイルが自動的に読み込まれます
- このディレクトリの内容は `.gitignore` で除外されています（README.md を除く）

例:
```
hidden/
├── README.md
├── path.zsh      # PC固有のPATH設定
└── secrets.zsh   # APIキーなど
```

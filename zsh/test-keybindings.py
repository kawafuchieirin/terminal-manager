"""実行: python3 -B zsh/test-keybindings.py"""

import shutil
import tempfile
from pathlib import Path

from keybindings import catalog


def main():
    original = Path(__file__).resolve().parent.parent
    with tempfile.TemporaryDirectory(prefix="keybindings test ") as directory:
        root = Path(directory)
        for filename in ("wezterm/wezterm.lua", "zsh/.zshrc", "gh-dash/config.yml",
                         "pet/select.sh", "zsh/keybindings-defaults.tsv"):
            target = root / filename
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original / filename, target)

        before = catalog(root)
        assert len(before) == 66
        assert len({(row[0], row[1]) for row in before}) == len(before)

        # 各設定のキーだけを変えれば次の読み取りで一覧も変わる。
        for filename, old, new, tool, old_key, new_key in [
            ("wezterm/wezterm.lua", 'key = "q", mods = "CTRL"',
             'key = "a", mods = "ALT"', "WezTerm", "Ctrl+Q", "Alt+A"),
            ("wezterm/wezterm.lua", 'key = "o", mods = "CTRL|SHIFT"',
             'key = "u", mods = "CTRL|SHIFT"', "WezTerm", "Ctrl+Shift+O", "Ctrl+Shift+U"),
            ("zsh/.zshrc", "bindkey '^g'", "bindkey '^b'", "Zsh", "Ctrl+G", "Ctrl+B"),
            ("gh-dash/config.yml", "- key: N", "- key: I", "gh-dash", "N", "I"),
            ("pet/select.sh", "f2:change-query", "f7:change-query", "pet / fzf", "F2", "F7"),
        ]:
            path = root / filename
            assert old in path.read_text()
            path.write_text(path.read_text().replace(old, new))
            keys = {(row[0], row[1]) for row in catalog(root)}
            assert (tool, old_key) not in keys
            assert (tool, new_key) in keys

        path = root / "zsh/.zshrc"
        text = path.read_text()
        entry = "bindkey '^X' example-widget # kb: 新しい操作\n"
        path.write_text(text + entry)
        assert any(row[1:3] == ("Ctrl+X", "新しい操作") for row in catalog(root))
        path.write_text(text + "# " + entry)
        assert not any(row[1] == "Ctrl+X" for row in catalog(root))
        path.write_text(text)
        assert not any(row[1] == "Ctrl+X" for row in catalog(root))

        path.write_text(text + "bindkey # kb: 壊れた定義\n")
        try:
            catalog(root)
        except ValueError as error:
            assert "zsh/.zshrc:" in str(error)
        else:
            raise AssertionError("解析できない定義を黙って無視しています")
    print("keybindings sync: OK")


if __name__ == "__main__":
    main()

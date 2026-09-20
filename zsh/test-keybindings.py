"""実行: python3 -B zsh/test-keybindings.py"""

import shutil
import tempfile
from pathlib import Path

from keybindings import COLUMN_GAP, catalog, mac_key, table


def test_mac_key():
    for key, expected in [
        ("Cmd+Shift+D", "⇧⌘D (Shift+Cmd+D)"),  # macOS のメニューと同じ ⌃⌥⇧⌘ の順
        ("Cmd+Alt+←", "⌥⌘← (Opt+Cmd+←)"),
        ("Cmd+Shift+Enter", "⇧⌘↩ (Shift+Cmd+Enter)"),
        ("Ctrl+Q → w", "⌃Q → w (Ctrl+Q → w)"),
        ("** → Tab", "** → ⇥ (** → Tab)"),
        ("Cmd++", "⌘+ (Cmd++)"),
        # 修飾キーのない表記はそのまま。
        ("N", "N"), ("F2", "F2"), ("↑", "↑"), ("Space", "Space"), ("+", "+"),
    ]:
        assert mac_key(key) == expected, (key, mac_key(key))
    for key in ("", "Ctrl+Q → "):
        try:
            mac_key(key)
        except ValueError as error:
            assert repr(key) in str(error)
        else:
            raise AssertionError(f"空のキー {key!r} を黙って表示しています")


def test_table():
    # 全角は2桁、記号・矢印は1桁として、各列の開始位置を揃える。
    lines = table([("ツール", "キー", "説明"), ("Zsh", "⇧⌘↩ (Shift+Cmd+Enter)", "全角の説明"),
                   ("pet / fzf", "↑", "x")])
    gap = " " * COLUMN_GAP
    assert lines == ["ツール   " + gap + "キー                 " + gap + "説明",
                     "Zsh      " + gap + "⇧⌘↩ (Shift+Cmd+Enter)" + gap + "全角の説明",
                     "pet / fzf" + gap + "↑                    " + gap + "x"], lines


def main():
    test_mac_key()
    test_table()
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
             'key = "a", mods = "ALT"', "WezTerm", "⌃Q (Ctrl+Q)", "⌥A (Opt+A)"),
            ("wezterm/wezterm.lua", 'key = "o", mods = "CTRL|SHIFT"',
             'key = "u", mods = "CTRL|SHIFT"', "WezTerm", "⌃⇧O (Ctrl+Shift+O)", "⌃⇧U (Ctrl+Shift+U)"),
            ("zsh/.zshrc", "bindkey '^g'", "bindkey '^b'", "Zsh", "⌃G (Ctrl+G)", "⌃B (Ctrl+B)"),
            ("gh-dash/config.yml", "- key: N", "- key: I", "gh-dash", "N", "I"),
            ("pet/select.sh", "f2:change-query", "f7:change-query", "pet / fzf", "F2", "F7"),
        ]:
            path = root / filename
            assert old in path.read_text()
            path.write_text(path.read_text().replace(old, new))
            keys = {(row[0], row[1]) for row in catalog(root)}
            assert (tool, old_key) not in keys
            assert (tool, new_key) in keys

        # Leader は実際のキーで表示し、Leader の変更にも追従する（上で Ctrl+Q → Alt+A に変更済み）。
        assert ("WezTerm", "⌥A → w (Opt+A → w)") in keys
        assert not any("Leader" in key or "⌃Q" in key for _, key in keys)

        path = root / "zsh/.zshrc"
        text = path.read_text()
        entry = "bindkey '^X' example-widget # kb: 新しい操作\n"
        path.write_text(text + entry)
        assert any(row[1:3] == ("⌃X (Ctrl+X)", "新しい操作") for row in catalog(root))
        path.write_text(text + "# " + entry)
        assert not any("Ctrl+X" in row[1] for row in catalog(root))
        path.write_text(text)
        assert not any("Ctrl+X" in row[1] for row in catalog(root))

        path.write_text(text + "bindkey # kb: 壊れた定義\n")
        try:
            catalog(root)
        except ValueError as error:
            assert "zsh/.zshrc:" in str(error)
        else:
            raise AssertionError("解析できない定義を黙って無視しています")
        path.write_text(text)

        # 未対応の修飾キーや、定義のない Leader は誤った表示にせずエラーにする。
        path = root / "wezterm/wezterm.lua"
        text = path.read_text()
        for old, new in [('mods = "CMD|SHIFT"', 'mods = "CMD|HYPER"'),
                         ("config.leader =", "config.other =")]:
            assert old in text
            path.write_text(text.replace(old, new, 1))
            try:
                catalog(root)
            except ValueError as error:
                assert "wezterm/wezterm.lua:" in str(error)
            else:
                raise AssertionError(f"{new} を黙って表示しています")
    print("keybindings sync: OK")


if __name__ == "__main__":
    main()

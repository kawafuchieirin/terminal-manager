"""設定行の kb: コメントとキーを読み取る。設定コード自体は実行しない。"""

import csv
import re
import shlex
import sys
from pathlib import Path


def display_key(key):
    arrows = {"^[[A": "↑", "^[[B": "↓", "LeftArrow": "←",
              "RightArrow": "→", "UpArrow": "↑", "DownArrow": "↓"}
    if key in arrows:
        return arrows[key]
    if re.fullmatch(r"\^[a-zA-Z]", key):
        return "Ctrl+" + key[1].upper()
    return key


def annotated(root, tool, filename):
    for number, line in enumerate((root / filename).read_text().splitlines(), 1):
        if line.lstrip().startswith(("#", "--")):
            continue
        code, marker, note = line.partition("-- kb:" if tool == "WezTerm" else "# kb:")
        if not marker:
            continue
        source = f"{filename}:{number}"
        try:
            if tool == "WezTerm":
                fields = {}
                for field, value in re.findall(r'''\b(key|mods)\s*=\s*["']([^"']*)["']''', code):
                    fields.setdefault(field, value)
                key = display_key(fields["key"])
                mods = fields["mods"].split("|")
                if "LEADER" in mods:
                    mods.remove("LEADER")
                    prefix = "Leader → "
                else:
                    prefix = ""
                    if len(key) == 1 and mods != ["NONE"]:
                        key = key.upper()
                key = prefix + "+".join([m.title() for m in mods if m != "NONE"] + [key])
            elif tool == "Zsh":
                tokens = shlex.split(code)
                if len(tokens) != 3 or tokens[0] != "bindkey":
                    raise ValueError("bindkey 'キー' widget の形式が必要です")
                key = display_key(tokens[1])
            else:
                match = re.fullmatch(r"\s*-\s+key:\s*(.+?)\s*", code)
                if not match:
                    raise ValueError("- key: キー の形式が必要です")
                tokens = shlex.split(match[1])
                if len(tokens) != 1:
                    raise ValueError("キーは1つの文字列で指定してください")
                key = tokens[0]
            if not note.strip() or not key:
                raise ValueError("キーまたは説明が空です")
        except (KeyError, ValueError) as error:
            raise ValueError(f"{source}: kb コメントの行を解析できません: {error}") from error
        yield tool, key, note.strip(), source


def catalog(root):
    rows = [("ツール", "キー", "説明", "設定元")]
    for tool, filename in [("WezTerm", "wezterm/wezterm.lua"),
                           ("Zsh", "zsh/.zshrc"), ("gh-dash", "gh-dash/config.yml")]:
        rows.extend(annotated(root, tool, filename))
    for number, line in enumerate((root / "pet/select.sh").read_text().splitlines(), 1):
        if not line.lstrip().startswith("--bind="):
            continue
        # このリポジトリの形式: 1行に1つの --bind='キー:アクション'。
        binding = shlex.split(line.rstrip().removesuffix("\\"))[0].removeprefix("--bind=")
        key, action = binding.split(":", 1)
        note = {"toggle-preview": "プレビューの表示 / 非表示",
                "change-query()": "全スニペットを表示"}.get(action, action)
        tag = re.fullmatch(r"change-query\('#([\w-]+)\)", action)
        if tag:
            note = tag[1] + "タグで絞り込み"
        rows.append(("pet / fzf", "+".join(part.title() for part in key.split("-")),
                     note, f"pet/select.sh:{number}"))
    with (root / "zsh/keybindings-defaults.tsv").open() as stream:
        defaults = csv.reader(stream, delimiter="\t")
        next(defaults)
        rows.extend(defaults)
    if any(len(row) != 4 or any("\n" in cell or "\t" in cell for cell in row) for row in rows):
        raise ValueError("キーバインド一覧はタブ・改行を含まない4列で指定してください")
    return rows


if __name__ == "__main__":
    try:
        rows = catalog(Path(__file__).resolve().parent.parent)
    except (OSError, ValueError) as error:
        sys.exit(f"kb: {error}")
    csv.writer(sys.stdout, delimiter="\t", lineterminator="\n").writerows(rows)

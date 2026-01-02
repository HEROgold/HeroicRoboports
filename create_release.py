import json
import os
from pathlib import Path
from zipfile import ZipFile


ROOT = Path(__file__).parent
RELEASE = ROOT / "releases"
INFO= ROOT / "info.json"
DATA = (
    ROOT / "data.lua",
    ROOT / "data-updates.lua",
    ROOT / "data-final-fixes.lua",
)
CHANGELOG = ROOT / "changelog.txt"
SETTINGS = ROOT / "settings.lua"
CONTROL = ROOT / "control.lua"

dirs: list[Path] = []
for i in ROOT.iterdir():
    if not i.is_dir() or i == RELEASE or i.name.startswith("."):
        continue
    dirs.append(i)

def main() -> Path:
    RELEASE.mkdir(exist_ok=True)

    info = json.loads(INFO.read_bytes())
    mod_name = info["name"]
    version = info["version"]
    if version == "0.0.0":
        print(f"Skipping {mod_name} as it has version 0.0.0")

    files = flatten_dirs(dirs)

    zip_file = RELEASE / f"{mod_name}_{version}.zip"
    with ZipFile(zip_file, "w") as f:
        for i in (INFO, CHANGELOG, *DATA, SETTINGS, CONTROL, *files):
            if not i.exists(): continue
            f.write(os.path.relpath(i))
    print(f"Created release {mod_name}{version}")
    return zip_file

def flatten_dirs(dirs: list[Path]) -> list[Path]:
    """Recursively flatten directories into filepaths."""
    x = dirs
    y: list[Path] = []
    while x:
        i = x[0]
        if i.is_dir():
            for j in i.iterdir():
                if i.is_dir():
                    x.append(j)
                else:
                    y.append(j)
        else:
            y.append(i)
        x.remove(i)
    return y


if __name__ == "__main__":
    main()

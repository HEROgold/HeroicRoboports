import json
from pathlib import Path
from zipfile import ZipFile


ROOT = Path(__file__).parent
RELEASE = ROOT / "releases"
INFO= ROOT / "info.json"
CHANGELOG = ROOT / "changelog.txt"
THUMBNAIL = ROOT / "thumbnail.png"

dirs: list[Path] = []
for i in ROOT.iterdir():
    if not i.is_dir() or i == RELEASE or i.name.startswith((".", "__")):
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
        # Root .lua files cover data/settings/control plus shared modules such as limits.lua.
        for i in (INFO, CHANGELOG, THUMBNAIL, *sorted(ROOT.glob("*.lua")), *files):
            if not i.exists() or "__pycache__" in i.parts: continue
            # Factorio requires every file under a single top-level folder named after the mod.
            f.write(i, f"{mod_name}/{i.relative_to(ROOT).as_posix()}")
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

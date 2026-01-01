import json
import os
from pathlib import Path
from zipfile import ZipFile


current_directory = Path(__file__).parent
release_dir = current_directory / "releases"
info_file = current_directory / "info.json"

IGNORE_DIRECTORIES = [
    ".git",
    ".vscode",
    "releases",
    "__pycache__",
]

def main():
    """
    Create releases for each mod found in current directory
    """
    release_dir.mkdir(exist_ok=True)

    with info_file.open() as f:
        info = json.loads(f.read())
        mod_name = info["name"]
        version = info["version"]
        if version == "0.0.0":
            print(f"Skipping {mod_name} as it has version 0.0.0")
            return
        f.close()

    zip_path = release_dir / f"{mod_name}_{version}.zip"

    with ZipFile(zip_path, "w") as f:
        for file in release_dir.iterdir():
            f.write(os.path.relpath(file))

    print(f"Successfully created {zip_path}")


if __name__ == "__main__":
    main()

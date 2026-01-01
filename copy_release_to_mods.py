import os
import shutil
from pathlib import Path

from .create_release import main as release


def main():
    """
    Creates release's for the each mod found, and copies them to the player's mod folder
    """
    release() # Also runs the create_releases file.
    for entry in (Path(__file__).parent / "releases").iterdir():

        mod_path = f"{os.getenv("APPDATA")}/factorio/mods/{entry.name}"

        try:
            os.remove(mod_path)
        except (FileNotFoundError, PermissionError):
            pass

        shutil.copy(entry, mod_path)



if __name__ == "__main__":
    print(main())

import os
import shutil

from create_release import main as release


def main() -> None:
    """
    Creates release's for the current mod, and copies them to the player's mod folder
    """
    entry = release() # Also runs the create_releases file.

    mod_path = f"{os.getenv("APPDATA")}/factorio/mods/{entry.name}"

    try:
        os.remove(mod_path)
    except (FileNotFoundError, PermissionError):
        pass

    shutil.copy(entry, mod_path)
    print(f"Copied {entry.name} to mods.")



if __name__ == "__main__":
    main()

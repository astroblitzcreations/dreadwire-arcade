#!/usr/bin/env python3
"""Add the cabinet's script-based Homebrew system to EmulationStation."""

from pathlib import Path
import sys

SYSTEM = """  <system>
    <name>homebrew</name>
    <fullname>Dreadwire Crew / Homebrew</fullname>
    <path>~/RetroPie/roms/homebrew</path>
    <extension>.sh .SH</extension>
    <command>bash %ROM%</command>
    <platform>pc</platform>
    <theme>ports</theme>
  </system>
"""


def main() -> None:
    config = Path(sys.argv[1])
    text = config.read_text(encoding="utf-8")
    if "<name>homebrew</name>" in text:
        print("Homebrew system already present; no XML change needed.")
        return
    marker = "</systemList>"
    if marker not in text:
        raise SystemExit(f"Invalid EmulationStation system file: {config}")
    backup = config.with_suffix(config.suffix + ".before-homebrew")
    if not backup.exists():
        backup.write_text(text, encoding="utf-8")
    config.write_text(text.replace(marker, SYSTEM + marker), encoding="utf-8")
    print(f"Added Homebrew system to {config}")


if __name__ == "__main__":
    main()


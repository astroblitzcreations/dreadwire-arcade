# Dreadwire Arcade

The complete software package for the Astroblitz Creations Raspberry Pi arcade cabinet: RetroPie integration, the Dreadwire Arcade Remote, controller support, homebrew launchers, audio, fan control, media shares, Wi-Fi setup, boot splash management, and release updates.

## Cabinet update flow

Stable GitHub Releases contain `dreadwire-arcade-update.tar.gz`. When the cabinet has Internet access, Arcade Remote checks the latest release and shows its release notes. An administrator can install it from the update popup. Updates preserve ROMs, BIOS files, player data, music, screenshots, controller mappings, Wi-Fi credentials, and user splash videos.

## Custom startup videos

Copy one or more videos to the Windows share `\\retropie\splashscreens`. The cabinet validates and converts incompatible formats automatically. One video plays every boot; with multiple videos, one is chosen randomly. Source videos stay untouched.

## Wi-Fi without a keyboard

Connect a phone to the cabinet's normal network or its offline `Dreadwire-Arcade` hotspot, open Arcade Remote, sign in as administrator, and use the **Wi-Fi** tab. Passwords are sent only to the cabinet and are never returned or displayed afterward.

## Release

Push a version tag such as `v1.0.1`. GitHub Actions builds the update archive and publishes a release. Put user-facing changes in the release notes so cabinets can display them.

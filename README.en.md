<p align="center"><img src="docs/images/app-icon.png" width="112" alt="Codex Pets"></p>

# Codex Pets

[简体中文](README.md)

A native macOS store for community Pets made for Codex. Browse, preview every animation, save favorites, install and uninstall companions.

## Install

Apple Silicon · macOS 13+.

Download **Codex-Pets-1.0.0-arm64.dmg** from [GitHub Releases](https://github.com/duoduocats/codex-pets/releases/latest), drag Codex Pets into Applications, and open it.

This build is ad hoc signed and not Apple-notarized. If macOS blocks the first launch, dismiss the alert, open **System Settings → Privacy & Security → Open Anyway**, and confirm. The DMG includes an [illustrated installation guide](docs/install/Installation-Guide.pdf). Download from this repository; see [Apple’s launch instructions](https://support.apple.com/en-us/102445).

## Use

- **Discover:** source popularity is the default order. Switch to name order, filter a source, or search pets and creators.
- **Preview:** all animations play by default. Click an action once to switch and play. Pause or resume; v2 pets include directional looking.
- **Favorites:** bookmark pets and browse them in Favorites. Favorites stay on this Mac, including saved information while a source is offline.
- **Install:** choose Install locally and confirm attribution, license and destination. Open Codex settings, manually choose Pets in the sidebar, refresh and select your companion.
- **Uninstall:** choose Trash in Installed and confirm. The whole package moves to system Trash and can be restored; favorites remain. Switch away from an active pet in Codex first.
- **Guide:** use the sidebar, Settings menu or ⌘,. Close with ×, Close or Esc.

Animations stop when the window is hidden, occluded, minimized or inactive. Supports reduced motion, English and Simplified Chinese, light and dark appearance.

Twelve built-in catalogs include Petdex, codex-pet.com, Codex PokéPets, Pets Codex, codexpets.org, Arknights Pets, HuaqingAI, Cute-chen, legeling, Senyo, David and Rito. Enable sources separately and add up to eight [compatible public catalogs](docs/pet-catalog.md). Source identities and credits are preserved. Missing creators or artwork licenses are explicitly marked.

Popularity comes from Codex Pet Gallery’s public snapshot and reflects that source’s recorded installs and likes. Missing counters remain unknown, and the original snapshot time is available. These are not worldwide usage figures.

Installation saves files in Codex’s public Pets directory. Selection and restoring the default remain in Codex. External settings links currently open its Settings home; choose the Pets tab manually. Other installation methods in “…” depend on Codex supporting an installation window. Use this store’s local installation if no window appears.

## Build

Requires Xcode 26+ for Apple’s layered icon compiler. No additional runtime dependencies.

```sh
bash scripts/test.sh
BUILD_DIR=$(mktemp -d /private/tmp/codex-pets-build.XXXXXX) bash build.sh
```

For a DMG, install `scripts/requirements-packaging.txt` in a build-only environment and run `bash scripts/package.sh`. See the [native icon notes](docs/native-icon.md).

## License

[GPL-3.0-only](LICENSE), the same as [Codex Buddy](https://github.com/duoduocats/codex-buddy). Community artwork keeps its own source terms; see [third-party notices](THIRD_PARTY_NOTICES.md).

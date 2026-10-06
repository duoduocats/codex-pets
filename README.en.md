<p align="center"><img src="docs/images/app-icon.png" width="112" alt="Codex Pets app icon" /></p>

# Codex Pets — macOS community pet store for Codex

English · [简体中文](README.md) · [Download latest release](https://github.com/duoduocats/codex-pets/releases/latest)

**Discover, preview, save and install community pets for Codex** on your Mac. Choose a companion for your Codex desktop app.

A native macOS app for **Apple Silicon · macOS 13+**. Browsing the store requires no additional login or API key.

## Features

- **Discover community pets:** source popularity is the default order. Switch to name order, filter a source, or search pets and credits.
- **Complete animation previews:** cycle through every action, or click an action once to switch and play. Pause or resume; v2 pets also include directional looking.
- **Local favorites:** bookmark pets and browse them in Favorites. Saved information remains available when a source is temporarily offline.
- **Install locally:** confirm attribution, license and destination, then select your installed pet in Codex settings.
- **Uninstall and restore:** move a pet from Installed to system Trash. You can restore it; favorites remain.
- **Community sources:** twelve built-in catalogs can be enabled separately. Add up to eight [compatible public catalogs](docs/pet-catalog.md).
- **Settings guidance:** follow the steps for using an installed pet. Close the guide with ×, Close or Esc.
- **English and Simplified Chinese:** follows macOS preferred languages, with light/dark appearance and reduced motion support.

## Community sources and popularity

Built-in sources include Petdex, codex-pet.com, Codex PokéPets, Pets Codex, codexpets.org, Arknights Pets, and collections from HuaqingAI, Cute-chen, legeling, Senyo, David and Rito. Each source retains its credits, artwork terms and original links. Missing creators or artwork licenses are explicitly marked.

Popularity comes from Codex Pet Gallery’s public statistics snapshot and reflects that source’s recorded installs and likes. Missing counters show “—”; the snapshot time is available in pet details. These are not worldwide usage figures.

## Download and install

1. Download and open the **arm64 DMG** from [GitHub Releases](https://github.com/duoduocats/codex-pets/releases/latest).
2. Drag **Codex Pets.app** into **Applications** on the right.
3. Open Codex Pets from Applications and browse community pets.

The DMG includes a drag-to-install background and an **[illustrated English and Chinese installation guide](docs/install/Installation-Guide.pdf)** for first-time users.

### If macOS cannot verify the developer

Current releases are ad hoc signed and are not Apple notarized. After confirming that the download came from this repository:

1. Try opening the app once, then dismiss the blocked-launch alert.
2. Open **System Settings → Privacy & Security**, scroll to the Codex Pets notice, and click **Open Anyway**.
3. Complete the system confirmation, then click **Open**.

macOS saves the app as a security exception. These steps apply to developer-verification or notarization alerts. If macOS reports malware or a damaged file, stop and check the download. See [Apple’s instructions](https://support.apple.com/en-us/102445).

## Install and use a pet

1. Choose a pet and review its animations, source and artwork terms.
2. Click **Install locally**, check the information and confirm.
3. Open Codex settings, manually choose **Pets** in the sidebar, refresh the list and select your installed companion.

Selection, switching pets and restoring the default remain in Codex. To uninstall, click Trash in **Installed** and confirm. Switch away from an active pet in Codex before removing it.

## Default settings

| Setting | First-open default |
| --- | --- |
| Discovery order | Source popularity; name order is available |
| Animation preview | All actions; pause or click an action to switch |
| Community sources | Twelve built-in sources enabled; disable separately |
| Language and appearance | Follow macOS |

Favorites and source choices stay on your Mac and are preserved when you reopen the app.

## Lightweight and private

A native macOS app with a current download of about **2.6 MB**. It reads public community information and your local pet directory, without reading ChatGPT / Codex credentials, conversations or project code. Favorites stay on this Mac; you confirm each installation and removal.

## Frequently asked questions

### Why can’t I see a pet after installation?

Manually choose **Pets** in Codex settings, refresh the list and select it. The store’s settings shortcut opens Codex Settings home; choose the Pets tab yourself.

### Why does “Confirm installation in Codex” do nothing?

This option under “…” depends on Codex supporting an installation window. If no window appears, choose **Install locally** in the store, then follow the steps above to select the pet.

### Why did the animation preview pause?

Previews stop when the window is hidden, occluded, minimized or inactive. Reduced motion also stops automatic playback. Use the detail controls to pause or resume, or click an action to switch the preview.

### Are Intel Macs supported?

The current release artifact supports Apple Silicon (arm64) only and requires macOS 13 or later.

### How do I change the interface language?

English and Simplified Chinese follow your macOS preferred language. You can also set an app-specific language in System Settings; relaunch the app to apply it.

## Feedback

Report a problem or suggest a feature in [GitHub Issues](https://github.com/duoduocats/codex-pets/issues).

## License

[GPL-3.0-only](LICENSE), the same as [Codex Buddy](https://github.com/duoduocats/codex-buddy). Community artwork keeps its own source terms; see [third-party notices](THIRD_PARTY_NOTICES.md).

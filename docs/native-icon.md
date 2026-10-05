# Native app icon

`Resources/AppIcon.icon` is an editable Apple Icon Composer document. It keeps
the canonical Codex Buddy cat head and terminal cutouts, with the selected curled
tail beneath it. `Resources/CanonicalCat.png` snapshots Buddy's exact cat layer,
so the independent project builds without reading or depending on Buddy's files.
The cat and tail are separate layers in one group, with the same default glass
material, neutral shadow and translucency used by the Codex Buddy icon.

Default has a Music-red automatic gradient behind white artwork. Dark has a black
background and the same red artwork. The color is referenced from the installed
Music icon's Display P3 background endpoint (0.917, 0.176, 0.230), converted to
Icon Composer's extended-sRGB notation. Mono is rendered by the system.

Recreate the deterministic layers with:

```sh
swift scripts/generate-icon-layers.swift .
```

The generator preserves antialiasing and excludes optional PNG metadata.
`build.sh` uses Xcode 26+ `actool` to produce both `Assets.car` and its matching
`AppIcon.icns` compatibility resource. It never replaces that compiled icon with
the earlier flat source ICNS. Icon Composer and its compiler are build tools and
are not included in the app. `PetMark.png` combines the same head and tail for the
frameless in-app marks; the earlier black-tail artwork supplies only the tail
when recreating layers. The generator adjusts the tail's spacing for the wider
canonical cat, preserving the tail shape and excluding the four Buddy dots.

Reference: https://developer.apple.com/icon-composer/

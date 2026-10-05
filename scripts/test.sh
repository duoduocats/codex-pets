#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_BUILD="${TEST_BUILD_DIR:-$(mktemp -d /private/tmp/codex-pet-store-tests.XXXXXX)}"
mkdir -p "$TEST_BUILD"
swiftc -module-cache-path "$TEST_BUILD/module-cache" -swift-version 5 -target arm64-apple-macosx13.0 -framework AppKit -framework SwiftUI \
 "$ROOT/Sources/Localization.swift" "$ROOT/Sources/PetCatalog.swift" "$ROOT/Sources/PetCommunityCatalogs.swift" "$ROOT/Sources/PetStoreClient.swift" "$ROOT/Sources/PetPopularity.swift" "$ROOT/Sources/PetCodexLauncher.swift" "$ROOT/Sources/PetFavorites.swift" "$ROOT/Sources/PetPackageInstaller.swift" "$ROOT/Sources/PetPackageUninstaller.swift" "$ROOT/Sources/Brand.swift" "$ROOT/Sources/PetPreview.swift" "$ROOT/Sources/ThemeStoreModel.swift" "$ROOT/Tests/PetFavoritesTests.swift" "$ROOT/Tests/PetPackageInstallerTests.swift" "$ROOT/Tests/PetPackageUninstallerTests.swift" "$ROOT/Tests/PetCommunityCatalogTests.swift" "$ROOT/Tests/PetPreviewTests.swift" "$ROOT/Tests/PetStoreTests.swift" -o "$TEST_BUILD/pet-store-tests"
"$TEST_BUILD/pet-store-tests"

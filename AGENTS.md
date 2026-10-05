# Codex Pets development

- Repository: duoduocats/codex-pets. Bundle identifier: com.duoduocat.codexpetstore.
- GPL-3.0-only. Preserve LICENSE and THIRD_PARTY_NOTICES.md.
- Native AppKit, SwiftUI, Foundation and URLSession. No bundled CLI, login credentials or internal Codex state writes.
- Public community data retains attribution and source terms. Never infer artwork rights from software licenses.
- Local installation and uninstall require per-theme confirmation. Use scoped public pets/avatars packages; keep rollback copies and system Trash recovery.
- Tests use synthetic data. Never read or publish user credentials, chats, private captures or account state.
- Run bash scripts/test.sh and BUILD_DIR=<fresh-temp-directory> bash build.sh. DMG changes also require scripts/test-dmg.py.
- Build and install locally before publication. Wait for the user’s corresponding release authorization before pushing, merging, tagging or publishing.

# 从源码构建 / Build from source

需要 Apple Silicon Mac 与 Xcode 26+，用于 Swift 编译及 Apple 分层图标编译。应用不需要额外运行时依赖。

Requires an Apple Silicon Mac and Xcode 26+ for Swift and Apple’s layered icon compiler. The app has no additional runtime dependencies.

## 测试与构建 / Test and build

```sh
bash scripts/test.sh
BUILD_DIR=$(mktemp -d /private/tmp/codex-pets-build.XXXXXX) bash build.sh
```

构建输出为指定 BUILD_DIR 中的 `Codex Pets.app`。图标构建要求见 [分层图标文档](native-icon.md)。

The app is created as `Codex Pets.app` inside BUILD_DIR. See the [native icon notes](native-icon.md) for icon build requirements.

## DMG

在仅用于构建的虚拟环境中安装打包依赖，再制作并验证 DMG：

Install packaging dependencies in a build-only virtual environment, then create and verify the DMG:

```sh
python3 -m venv /private/tmp/codex-pets-packaging-venv
source /private/tmp/codex-pets-packaging-venv/bin/activate
python -m pip install -r scripts/requirements-packaging.txt
BUILD_DIR=$(mktemp -d /private/tmp/codex-pets-build.XXXXXX) bash scripts/package.sh
python scripts/test-dmg.py dist/*.dmg
```

打包工具不会随应用分发。/ Packaging tools are not included in the app.

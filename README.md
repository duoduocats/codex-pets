<p align="center"><img src="docs/images/app-icon.png" width="112" alt="Codex Pets"></p>

# Codex Pets

[English](README.en.md)

原生 macOS 宠物主题商店，浏览社区为 Codex 制作的小伙伴，预览完整动画，收藏、安装或卸载。

## 安装

Apple Silicon · macOS 13+。

从 [GitHub Releases](https://github.com/duoduocats/codex-pets/releases/latest) 下载 **Codex-Pets-1.0.0-arm64.dmg**，将 Codex Pets 拖入 Applications 后打开。

当前构建为 ad hoc 签名，未经过 Apple 公证。首次打开若被拦截，先关闭提示，再到 **系统设置 → 隐私与安全性 → 仍要打开**，按系统提示确认。安装包附有[中英文图文指南](docs/install/Installation-Guide.pdf)。请从本仓库下载；[Apple 安全打开说明](https://support.apple.com/zh-cn/102445)。

## 使用

- **发现宠物**：默认按来源热度排序，可改按名称，或筛选来源、搜索主题及作者。
- **完整动作预览**：默认轮播全部动作，直接点动作按钮即可切换并播放。支持暂停、继续，v2 主题支持环视。
- **本地收藏**：点击书签，在“收藏”集中浏览；收藏保存在这台 Mac，来源暂时离线时保留信息。
- **安装与使用**：点击“安装到本机”，核对署名、授权与保存位置后确认。完成后打开 Codex 设置，手动选择左侧“虚拟宠物”，刷新并选择使用。
- **卸载与恢复**：在“已安装”点击废纸篓并确认，主题包移到系统废纸篓，可恢复，收藏保留。卸载正在使用的主题前先在 Codex 中切换。
- **设置指引**：侧栏或菜单栏入口、⌘, 可查看步骤；右上角 ×、关闭按钮或 Esc 都可关闭。

预览在窗口隐藏、遮挡、最小化或失活时停止；支持系统减少动态效果、简体中文与英文、深色与浅色外观。

默认接入 12 个社区来源：Petdex、codex-pet.com、Codex PokéPets、Pets Codex、codexpets.org、明日方舟宠物，以及 HuaqingAI、Cute-chen、legeling、Senyo、David、Rito 的合集。可分别启用或关闭，也可添加最多八个[兼容公开目录](docs/pet-catalog.md)。不同来源的主题保留独立署名和来源，缺失作者或素材授权会明确标注。

热度使用 Codex Pet Gallery 的公开统计快照，只代表该来源的安装及喜欢记录；没有统计的主题显示“—”，可查看原始快照时间。热度不是全球使用量。

本机安装保存到 Codex 的公开 Pets 目录；选择使用、切换与恢复默认仍在 Codex 中进行。当前外部链接只支持打开设置首页，需手动进入宠物页签。“…”中的其他安装方式需要 Codex 支持安装确认窗口；没有弹窗时用本商店安装。

## 从源码构建

需要 Xcode 26+（用于 Apple 分层图标编译），不需要其他运行时依赖。

```sh
bash scripts/test.sh
BUILD_DIR=$(mktemp -d /private/tmp/codex-pets-build.XXXXXX) bash build.sh
```

制作 DMG 的构建依赖见 `scripts/requirements-packaging.txt`，然后运行 `bash scripts/package.sh`。安装包的图标与[分层图标文档](docs/native-icon.md)保持一致。

## 许可证

[GPL-3.0-only](LICENSE)，与 [Codex Buddy](https://github.com/duoduocats/codex-buddy) 一致。社区素材按各自来源授权，见 [第三方声明](THIRD_PARTY_NOTICES.md)。

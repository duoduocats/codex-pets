# 添加 Codex Pet 主题来源 / Add a Codex Pet source

在主题商店的 **主题来源 → 添加来源** 中粘贴公开 HTTPS 目录地址。目录可以是 GitHub Raw 文件，也可以由你的网站提供。最多添加 8 个自定义来源，可随时关闭或移除。

In Codex Pets, choose **Sources → Add source** and paste a public HTTPS catalog URL. You can host it on GitHub Raw or your own website. Add up to 8 custom sources, and disable or remove them at any time.

目录使用以下格式；空的 `pets` 数组也有效。所有图片、清单和来源链接均需使用完整的公开 HTTPS 地址，不应包含密码或登录令牌。

Use the following format; an empty `pets` array is also valid. Image, manifest, and source links must be absolute public HTTPS URLs without passwords or login tokens.

```json
{
  "schemaVersion": 1,
  "name": "My Pet Collection",
  "websiteURL": "https://example.com/pets",
  "pets": [
    {
      "id": "sample-pet",
      "name": "Sample Pet",
      "description": "A small companion for your work.",
      "author": "Example Author",
      "license": "CC BY 4.0",
      "category": "Animals",
      "manifestURL": "https://example.com/pets/sample-pet/pet.json",
      "previewURL": "https://example.com/pets/sample-pet/idle.gif",
      "websiteURL": "https://example.com/pets/sample-pet"
    }
  ]
}
```

`category` 和 `previewURL` 可省略，其余字段必填。一个自定义目录最多包含 500 个主题，目录文件不超过 2 MB。请使用不含斜线的唯一 `id`，并准确注明作者与图片授权。

`category` and `previewURL` are optional; the other fields are required. A custom catalog supports up to 500 themes and a 2 MB file size. Use unique IDs without slashes, and provide accurate author and artwork-license information.

每个主题的 `pet.json` 与精灵图放在同一目录，例如：

Place each `pet.json` beside its sprite sheet:

```json
{
  "id": "sample-pet",
  "displayName": "Sample Pet",
  "description": "A small companion for your work.",
  "spritesheetPath": "spritesheet.webp",
  "spriteVersionNumber": 1
}
```

支持 PNG / WebP 精灵图：v1 为 1536 × 1872，v2 为 1536 × 2288，用于官方安装的图片不超过 20 MiB。`spritesheetPath` 是同目录文件名，不能指向其他目录。预览图片支持 GIF / PNG / WebP，最大 6 MB。

PNG and WebP sprite sheets are supported: v1 is 1536 × 1872; v2 is 1536 × 2288, with a 20 MiB limit for official installation. `spritesheetPath` must be a filename in the same directory. Preview images may be GIF, PNG, or WebP, up to 6 MB.

点击 **安装到本机**，确认主题、作者、授权与目标位置后，商店把已校验的包保存到 Codex 公开的 Pets 目录。安装成功后打开 Codex 设置，在宠物页面刷新并选择使用。每个来源保留独立安装身份，更新本机副本须单独确认，旧文件保留用于恢复。切换和恢复默认仍在 Codex 中进行。

Choose **Install locally** and confirm the theme, attribution and destination. The store saves verified files to Codex’s public Pets directory. Open Codex settings, refresh Pets, and choose the theme. Sources retain separate installation identities. Replacing a local copy requires confirmation and keeps recovery files. Switching and restoring the default remain in Codex.

## 热度 / Popularity

默认接入十二个社区来源：HuaqingAI、Cute-chen、legeling、Senyo、Petdex、codex-pet.com、Codex PokéPets、Pets Codex、codexpets.org、David、Rito 与明日方舟宠物。安装与喜欢统计目前由 legeling 的公开统计快照提供：
https://raw.githubusercontent.com/legeling/awesome-codex-pet/main/web/public/stats.json

快照以主题 slug 关联目录，包含来源安装记录、喜欢次数、近七日计数及生成时间。界面显示生成时间及本机时区；这些计数只代表该来源记录的操作，不代表全球使用量、活跃用户或本应用的使用情况。相同主题在不同来源中保留独立身份，不转借另一个来源的统计。缺失统计显示未知；统计中明确记录的零可以显示为零。

The public snapshot is matched by source and theme slug. Counts reflect that source’s recorded actions, not worldwide usage, active users or this app’s usage. The snapshot time is displayed in the local time zone. Themes in other catalogs do not inherit these counters, even when names match. Missing statistics remain unknown; an explicitly reported zero is shown as zero.

统计采用只读 HTTPS GET，沿用无凭据、无 Cookie 的请求。不会回传安装、喜欢或浏览操作。更新失败时保留缓存及原始快照时间；关闭商店会取消正在获取的统计。

Statistics are read through credential-free, cookie-free HTTPS GET requests. The store does not report installs, likes or views. If updates fail, it keeps the cached snapshot and its original timestamp. Closing the store cancels statistics loading.

## 官方安装入口 / Official install handoff

安装遵循官方桌面链接说明：
https://learn.chatgpt.com/docs/reference/commands

官方安装窗口需要桌面端启用对应功能。商店向桌面应用显式发送安装链接，并等待 macOS 的打开结果；收到系统成功回调不代表确认窗口已出现，也不代表安装完成。缺少桌面应用或系统打开失败会显示错误。此方式位于详情 **… → 其他安装方式 → 在 Codex 中确认安装**，同处也可以复制安装链接。如果没有出现窗口，请直接用“安装到本机”，已安装的主题可选择“重新安装这个宠物”。本机安装不依赖 Codex 安装弹窗；是否使用宠物仍由用户在 Codex 设置中选择。

The official install window requires the desktop feature to be enabled. The store sends the link to Codex and waits for macOS’s launch result. Successful delivery does not confirm that a window appeared or installation completed. Choose **… → Other ways to install → Confirm installation in Codex**, or copy the link from the same panel. If no window appears, use Install locally; an already installed theme offers Reinstall this pet. Selection remains in Codex settings.

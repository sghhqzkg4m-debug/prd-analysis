# PRD 到飞书设计交付

分享这个仓库链接即可让其他 Codex 用户安装完整的 Skill 包。主 Skill 的入口是 [SKILL.md](SKILL.md)；`packages/` 包含它实际需要的四个专业 Skill，以及主 Skill 的安装归档。

## 一次安装

在 macOS 或 Linux 终端运行：

```bash
curl -fsSL https://raw.githubusercontent.com/sghhqzkg4m-debug/prd-analysis/main/install.sh | bash
```

安装脚本会校验归档的 SHA-256，然后将以下五个 Skill 分别放入 `${CODEX_HOME:-$HOME/.codex}/skills/`：

- `prd-to-feishu-design`：入口与交付编排
- `prd-to-knowledge`：需求与交互分析，所有分析任务都需要
- `prd-to-ui-spec`：AI 页面生成规格
- `sangfor-cloud-console`：深信服控制台页面与组件参考
- `beautiful-feishu-whiteboard`：飞书白板视觉与可编辑图形

安装后开启一个新的 Codex 会话，使用 `$prd-to-feishu-design`。已有同名 Skill 且内容不同时，脚本会停止，避免覆盖本地修改。确认需要替换时，先下载仓库，再运行 `bash install.sh --source-dir . --force`；旧版本会备份到 `~/.codex/skills/.backup/`（或对应的 `CODEX_HOME` 下）。

也可以先克隆仓库，再执行 `bash install.sh --source-dir .`。这种方式使用仓库内的归档，不会再次下载。

## 环境能力

浏览器核查需要 Codex 环境提供可用的浏览器能力；若使用 `browser-act`，需按其自身说明另行安装与授权。竞品研究可以结合 `competitive-analysis`，但它不是完成本 Skill 的必需依赖。

飞书同步需要使用者连接可写入飞书文档和白板的工具，并拥有目标文档的编辑权限。白板 Skill 的原始流程使用已安装并登录的 `@larksuite/cli`；也可由环境中等价的飞书白板工具完成。安装此仓库不会自动配置飞书账号或权限。本地校验脚本需要 Node.js。

`beautiful-feishu-whiteboard` 原作者为 Zara Zhang，按归档内的 MIT License 分发。

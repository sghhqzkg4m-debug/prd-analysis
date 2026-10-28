# PRD 到飞书设计交付

这是 Codex Skill `prd-to-feishu-design` 的完整目录。入口见 [SKILL.md](SKILL.md)；`references/`、`assets/`、`scripts/` 和 `agents/` 是配套文件，安装时请一并保留。

## 安装

将整个仓库克隆或复制到 `~/.codex/skills/prd-to-feishu-design/`，然后在新会话中使用 `$prd-to-feishu-design`。

## 依赖

本 Skill 会按任务需要调用 `prd-to-knowledge`、`prd-to-ui-spec`、`sangfor-cloud-console`、`beautiful-feishu-whiteboard` 等其他 Skill；它们不包含在本仓库中。飞书同步还需要可用的飞书文档和白板工具及目标文档的编辑权限。本地校验脚本需要 Node.js。

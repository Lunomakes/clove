<div align="center">

[English](README.md) · 简体中文

<img src="Clove/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" alt="" width="96" />

# Clove 中文版

**AI 代理加载的一切，集中在一个原生 Mac 应用里。**

Skill、指令文件、规则、命令、子代理、MCP 服务器、Hook、权限，以及它们需要的 API 密钥，覆盖 Claude Code、Cursor 和 Codex。在 [skills.sh](https://skills.sh) 上发现新的 Skill，查看每个代理装了什么，清理用不到的东西，看清是什么占满了磁盘。

[**下载 Mac 版**](https://github.com/Lunomakes/clove/releases/latest) · [上游项目](https://github.com/keshav-exe/clove) · [官网](https://clove.kshv.me)

开源 · MIT · 简体／繁体中文 · 自动更新 · macOS 26

<img src="docs/screenshots/framed/home.png" alt="Clove 首页：需要留意的事项，以及 Skill、运行中的代理、清理和上下文卡片" />

</div>

> 这是 [keshav-exe/clove](https://github.com/keshav-exe/clove) 的中文 fork，与上游同步更新。它在上游基础上增加了简体中文和繁体中文界面、应用内语言选择，以及独立的自动更新源。截图来自上游英文版。

## 首页

把现在需要留意的事集中在一页：从来不用的 Skill、代理下载后忘掉的残留文件、旧的会话历史、以明文存放的密钥。旁边是 skills.sh 上的热门 Skill，点一下就能打开它的页面。

## 快捷面板

<img src="docs/product-preview.png" alt="Clove 快捷面板正在搜索代理 Skill" width="420" align="right" />

Skill 散落在 `~/.cursor`、`~/.claude`、插件和项目文件夹里。Clove 会找出 Mac 上所有的 `SKILL.md`，包括从 dotfiles 仓库链接进来的 Skill，用一个快捷键就能调出来。

- 按名称、描述和群组搜索
- 拷贝可以直接放进提示词的引用，例如 `/animations` 或 `@nextjs`，而不是文件路径
- 把面板固定在编辑器旁边（`⌘⇧K`），或把 Skill 直接拖进提示词
- 给 Skill 分组，一次拷贝整组

<br clear="right" />

## 发现

<img src="docs/screenshots/framed/discover.png" alt="skills.sh 上的一个 Skill，显示安装量、星标、安全审计、亮点和 SKILL.md" />

- 浏览 skills.sh 的排行、趋势和热门榜单，或搜索全部 Skill
- 安装前先阅读 Skill 的 SKILL.md、亮点和安全审计
- 一键安装到所有位置或某个项目。Clove 在 `.agents/skills` 中保存一份，再链接到你选择的代理，目录结构与 `npx skills add` 相同
- 检查已安装的 Skill 是否有更新，并原地更新

## 上下文与工具

- **指令文件：** 全局和各项目的 `CLAUDE.md`、`AGENTS.md`、`GEMINI.md` 和 Copilot 指令，并显示各自占用多少上下文。可以让多个代理指向同一个文件，只改一次
- **规则：** Cursor 规则（`.cursor/rules/*.mdc`、`.cursorrules`）、Windsurf 规则和 Copilot 指令文件，并显示各自何时生效
- **命令和子代理：** 支持 Claude Code、Cursor 和 Codex。共享给另一个代理时，Clove 会建立链接，改一处两边都生效
- **MCP 服务器：** 来自 Claude Code、Cursor、Codex、Gemini、Claude Desktop 和 Windsurf。一键添加到另一个代理。环境变量和请求头只显示名称
- **Hook：** 来自 Claude Code、Cursor 和 Codex，Hook 的脚本缺失时会提示
- **权限：** 各项目中 Claude Code 的允许和拒绝规则

## 密钥

- 把 API 密钥存进登录钥匙串，而不是 `~/.zshenv`
- Clove 会找出 shell 配置文件里以明文导出的密钥并迁移，把每一行改成从钥匙串读取
- 可以为任意密钥拷贝一行 shell 命令或适合 MCP 的命令。除 Clove 之外的程序读取密钥前，macOS 都会先询问

## 运行

<img src="docs/screenshots/framed/running.png" alt="运行中的代理会话和 MCP 服务器，以及各自的文件夹、内存和命令" />

正在运行的代理会话、它们启动的 MCP 服务器，以及它们留下的开发服务器。查看每一项由谁启动、在哪里运行、占用多少内存，用完的可以直接停止。

Docker 容器也列在这里，支持 Docker Desktop、OrbStack、Colima 和 Rancher Desktop。可以启动、停止、重启容器，或在浏览器中打开。

## 清理

<img src="docs/screenshots/framed/cleanup.png" alt="清理页列出未使用的 Skill，以及它们每次会话占用的 token" />

- 根据 Mac 上 Claude Code、Codex 和 Cursor 的历史记录，查看哪些 Skill、命令和子代理在 30 天、90 天或 6 个月内没有用过
- 看清它们的成本：每个已安装 Skill 的描述都会加载进每一次代理会话
- 找出残留文件，例如旧的 Chrome for Testing、闲置的 `npx` 安装和不再使用的 Claude Code 版本
- 一键全部移到废纸篓，可以撤销

## 储存空间

<img src="docs/screenshots/framed/storage.png" alt="储存空间：按类型划分的点阵磁盘条，突出显示开发者部分，下方列出最大的文件夹" />

用一条实时的点阵条显示磁盘：应用、代码和工具链、照片、影片、文稿、音乐、系统数据、缓存和废纸篓，各用一种颜色。

- 鼠标停在某一段上可以查看其中内容，例如“开发者”下的旧模拟器、`node_modules` 或代理历史；点按即可列出其中最大的项目
- 一步清除缓存。缓存会先移到废纸篓，清倒废纸篓之前都可以在“最近清理”中放回。正在运行的应用和 macOS 自身的缓存不会被清除
- 把文件夹标记为“始终保留”后，以后的扫描都不会再清除或建议它。清理页中的 Skill 和命令也一样
- 清倒废纸篓，或从列表中把大文件夹移到废纸篓。每一步都会先确认，`~/.claude` 这类完整的代理文件夹永远不会出现在建议里
- 扫描以低优先级运行，完成的扫描结果保留 30 分钟，磁盘条稳定后停止动画

## 菜单栏面板

自选菜单栏面板包含哪些区块：Skill、储存空间、运行、清理和趋势。区块的标签排在面板底部，用 `⌘1` 到 `⌘5` 切换，“设置 → 通用”中也会列出。储存空间区块就是同一条实时磁盘条，宽度与面板相同。右键点按菜单栏图标可以进入每个页面，并按原生方式显示面板快捷键。

想一眼看到某个数字，可以在“设置 → 通用 → 图标旁显示”中选择在图标旁显示可用空间、开发服务器数、全部服务器数或容器数。

## 编写

- 编辑任意 SKILL.md，带实时预览，并按 Agent Skills 格式检查（`⌘E`）
- 从指南、工作流或审查模板新建 Skill（`⌘N`）

## 安装

需要 macOS 26 或更高版本，支持 Apple 芯片和 Intel。

从 [Releases](https://github.com/Lunomakes/clove/releases/latest) 下载 `Clove-<版本>.dmg`，打开后把 Clove 拖到“应用程序”文件夹。之后 Clove 会自动更新。

中文版使用 ad-hoc 签名，没有经过 Apple 公证。第一次打开如果被拦下，到“系统设置 → 隐私与安全性”点按“仍要打开”。中文版不需要许可证密钥。

在 App 内可以于“设置 → 通用”中切换简体中文、繁体中文或英文。

## 从源码构建

```bash
git clone https://github.com/Lunomakes/clove.git
cd clove
open Clove.xcodeproj
```

或使用命令行：

```bash
xcodebuild -scheme Clove -configuration Release -destination 'platform=macOS' build
```

需要 Xcode 26 和 macOS 26 SDK。从源码构建会跳过许可证检查，可以免费使用。

同步上游、翻译和发布中文版的流程见 [docs/fork-maintenance.md](docs/fork-maintenance.md)。

## 隐私

Skill 不会离开你的 Mac。清理功能只在本机读取代理对话记录，从中找出 Skill 名称，除名称和日期外什么都不保留。只有在你安装、编辑或删除 Skill 时，Clove 才会改动 Skill 文件，被替换的内容都会移到废纸篓。群组保存在“应用程序支持”中的一个 JSON 文件里。储存空间会保存上一次的扫描结果，即大小和最大文件夹的名称，存放在 Clove 自己的缓存文件夹中、只有你能读取的文件里，并且不会进入备份。只有在清除缓存或清倒废纸篓时才会删除文件，并在删除那一刻再次检查每个路径。

Clove 与 [skills CLI](https://github.com/vercel-labs/skills) 共用 `~/.agents/.skill-lock.json`，所以无论用哪种方式安装的 Skill 都能显示来源，两边也都能更新它们。

网络请求：使用“发现”或安装、更新 Skill 时访问 skills.sh 和 GitHub，以及检查 App 更新。从 Clove 安装不会发送遥测，因此这些安装不计入 skills.sh 排行榜。没有统计分析，不需要账户。

## 致谢

2.0 中的多项功能来自 [Ram (@ramxcodes)](https://x.com/ramxcodes/status/2113292890294423802) 的建议：把 Skill 安装到单个项目、Hook 和 AGENTS.md 等指令文件、在多个代理之间共享同一套配置，以及把密钥从 `~/.zshenv` 移进“密钥”。谢谢。

<a href="https://x.com/ramxcodes/status/2113292890294423802"><img src="docs/ram-tweet.png" alt="Ram 的帖子，建议支持项目范围、Hook 和 AGENTS.md、跨代理移植配置，以及按需读取环境变量" width="420" /></a>

## 许可证

源码采用 [MIT](LICENSE) 许可证：可以阅读、构建和 fork。Clove 由 [Keshav](https://github.com/keshav-exe) 开发；如果你喜欢它，可以在 [clove.kshv.me](https://clove.kshv.me) 购买官方签名版支持作者。

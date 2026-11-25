# 中文 fork 维护

本仓库是 `Lunomakes/clove`，上游是 `keshav-exe/clove`。fork 增加简体／繁体中文、应用内语言选择、中文文案修正及独立 Sparkle 更新源。源码构建不启用 `CLOVE_LICENSED`，Licensing 实现不改动；权限／解析器状态的进一步本地化另行决定。上游的 `tools/release.sh` 与 `tools/MakeDMG.sh` 保持原样。

| EN | 简体 | 繁體（台灣） |
| --- | --- | --- |
| Skill | Skill | Skill |
| Hook | Hook | Hook |
| Subagent | 子代理 | 子代理程式 |
| MCP Server | MCP 服务器 | MCP 伺服器 |
| Trash | 废纸篓 | 垃圾桶 |
| Keychain | 钥匙串 | 鑰匙圈 |
| Menu Bar | 菜单栏 | 選單列 |
| Copy | 拷贝 | 複製 |
| Undo | 撤销 | 還原 |
| Settings | 设置 | 設定 |
| File / Folder | 文件 / 文件夹 | 檔案 / 檔案夾 |
| Quotes | “…” | 「…」 |

## 同步与翻译

先保持工作树干净，再 `git switch main`、`git fetch upstream`、`git merge upstream/main`（merge，不 rebase）。按实际上游默认分支调整分支名。解决冲突时保留语言选择、中文翻译和 fork 的更新配置；project.pbxproj 的版本跟随上游。只向 origin 推送；upstream 的 push URL 必须保持 `DISABLED`。

新 UI 文案使用完整的 `LocalizedStringResource`／`String(localized:)` 字面量，不拼接本地化句子，不从本地化标题生成搜索提示。不把第三方数据、路径和解析器状态当本地化键。修改 `Clove/Localizable.xcstrings` 或 `Clove/InfoPlist.xcstrings` 时补齐 en、zh-Hans、zh-Hant，`stringUnit.state` 都设为 `translated`；保留占位符类型／位置与复数变体。繁体使用「」。JSON 保持 2 空格缩进、`" : "` 分隔符和原始 Unicode。

Release 构建后运行 `python3 -I tools/check-localization.py`。它检查翻译、占位符、stale 键及编译器提取的缺失键。新增／删除文案后，可用 `xcrun xcstringstool sync` 对 Release 的 app-target `.stringsdata` 同步目录，再翻译新增键、移除 stale 键并重新构建检查。验证器依赖最近一次 Release 提取结果，不能替代构建或逐页视觉检查。

`.github/README.md` 是 `README.md` 的中文版（GitHub 优先显示它作为仓库首页，根目录 `README.md` 因此可保持与上游一致；其中相对路径以 `../` 开头），安装、构建和隐私部分按 fork 实际情况改写（Lunomakes 的 DMG、ad-hoc 签名、无许可证检查、fork 更新源）。合并时如果上游改了 `README.md`，同步更新中文版；`README.md` 顶部的语言切换行要保留。

共享 scheme 的测试语言固定为 en／US，因为测试断言英文文案和英文列表格式。仓库位于 `~/Documents` 等受 TCC 保护的目录时，测试宿主可能在启动时等待文件访问授权而报 “test runner hung”；此时在非受保护路径的 worktree 中对同一提交运行测试。

## 版本与发布

项目版本保留上游值（当前 `3.9`／`21`）。脚本从 app target 读值，并读取本地 tags：`v<上游版本>-zh.<n>` 的最大 n 加 1，无后缀 `v3.2-zh` 算 0。构建时注入 marketing version `<上游版本>-zh.<n>` 和 build `<上游build>*100+n`，不改项目文件。同步到 3.9 后首个版本为 `3.9-zh.1`／`2101`，高于此前的 `3.4-zh.1`／`1501`。发布前同步 origin tags；脚本发现远端缺失于本地的 tag 会拒绝继续。

先运行本地检查和 `python3 -I -B -m unittest discover -s tools/tests`，再运行 `tools/release-zh.sh [notes.md] --dry-run`。dry-run 在任意干净分支可用；正式发布必须在干净的 `main` 上，运行 `tools/release-zh.sh [notes.md]`。需要已登录的 gh、Xcode 和 Sparkle 工具。脚本构建无许可证版、strip、重签整个 bundle、扫描本机 home／用户名、生成 DMG、只读挂载验证、生成 EdDSA appcast 和 SHA-256。产物在 `dist/`，`build/` 与 `dist/` 不入库。正式发布会创建 annotated tag，仅 `git push origin main <tag>`，发布 DMG／checksums／appcast，重新下载全部资产核对 SHA-256。发布失败后先检查已有 tag／release，勿盲目重复发布。发布产物没有 Developer ID 公证，仍需单独验证 Gatekeeper 安装体验。

使用 **ad-hoc 代码签名 + EdDSA 归档签名**。本地 Sparkle 源码 `Sparkle/SUUpdateValidator.m` 的 `passesBasicUpdatePolicyWithHostIsCodeSigned:…` 明确允许 ad-hoc；`validateUpdateForHost:…` 接受 EdDSA 或旧指定要求匹配任一成功，同时独立验证新 app 的代码签名完整性。`Autoupdate/SUCodeSigningVerifier.m` 的 `codeSignatureIsValidAtBundleURL:checkNestedCode:error:` 用空 requirement 检查新签名，不要求 Team ID。不同 ad-hoc 构建的 cdhash 可能不匹配，但同一 EdDSA 公钥签名的更新仍可接受。无需改用 Apple Development：它不等于 Developer ID／公证，会增加证书有效期、个人身份元数据及嵌套 framework 的 Team ID 一致性维护。strip 后整个 bundle 以 `codesign --force --deep` 重签并保留辅助程序 entitlements，再严格验证。

**私钥仅在 login Keychain 的 `clove-zh` 账户**，仓库只存 `SUPublicEDKey`。初次运行 `build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys --account clove-zh`；已有密钥会复用。维护者应自行备份到安全存储：`generate_keys --account clove-zh -x <file>`（工具完整路径同上；备份文件绝不能放进仓库或发布资产）。丢失该私钥意味着现有安装副本无法再接收通过此公钥验证的自动更新。feed 固定为 `https://github.com/Lunomakes/clove/releases/latest/download/appcast.xml`。已发布的 `v3.2-zh` 没有 feed 且仍含上游公钥，用户须手动安装一次新版本，之后才能沿 fork 密钥链自动更新。

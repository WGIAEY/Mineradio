# Mineradio

![Mineradio 暗场启动页](./docs/assets/readme/cinema-beat-smoke.png)

Mineradio 是一款桌面沉浸式音乐播放器，把天气电台、搜索播放、歌词舞台、粒子视觉和 3D 歌单架组合成一个更接近现场感的私人音乐空间。支持 **Windows** 和 **macOS**。

## 下载

| 平台 | 文件名 | 适用机型 |
|------|--------|---------|
| Windows | `Mineradio-x.x.x-Setup.exe` | x64 PC |
| macOS · Apple 芯片 | `Mineradio-x.x.x-mac-**apple**.dmg` | M1 / M2 / M3 / M4 |
| macOS · Intel 芯片 | `Mineradio-x.x.x-mac-**intel**.dmg` | Intel Mac |

> ⚠️ **Apple Silicon 用户请务必下载 `apple` 版本**。下载 `intel` 版本到 M 芯片 Mac 上会通过 Rosetta 转译运行，首次打开时系统会提示「需要更新以兼容此 Mac」。
>
> 所有 macOS 版本均为原生 arm64 / x86_64 二进制，支持 macOS 11 Big Sur 及以上，经过 ad-hoc 签名。

## macOS 首次打开提示"无法验证开发者"怎么办

Mineradio 使用 ad-hoc 签名（`identity: "-"`），未经过 Apple 付费开发者公证。从 GitHub Release 下载后首次打开，macOS Gatekeeper 会阻止运行。有以下几种方法可以打开：

### 方法一：右键打开（最简单）

1. 在 Finder 中找到 `Mineradio.app`
2. **右键点击**（或按住 `Control` 点击）→ 选择「**打开**」
3. 弹出对话框中出现「**打开**」按钮 → 点击即可
4. 之后再次打开只需双击，不再提示

### 方法二：系统设置中允许

如果右键打开无效，可通过「隐私与安全性」放行：

1. 双击 `Mineradio.app` → 出现拦截提示 → 点击「**好**」
2. 打开 **系统设置** → **隐私与安全性**
3. 向下滚动，在「安全性」一栏找到：
   > 「Mineradio」已被阻止打开，因为它不是从 App Store 下载的。
4. 点击旁边的「**仍要打开**」按钮
5. 输入系统密码确认 → 之后双击即可正常打开

### 方法三：终端移除隔离标记

如果以上方法都无效，打开终端执行：

```bash
sudo xattr -rd com.apple.quarantine /Applications/Mineradio.app
```

然后双击打开即可。

> **原理**：macOS Gatekeeper 对从网络下载的应用添加 `com.apple.quarantine` 隔离标记。ad-hoc 签名（`identity: "-"`）确保应用可通过「右键打开」或「隐私与安全性」放行，无需 Apple Developer 账号（$99/年）。

## Windows 下载或安装被拦截怎么办

小众 Electron 桌面软件、未签名安装包有时会被浏览器、Windows Defender 或 SmartScreen 提示风险。请先确认安装包来自上面的蓝奏云或 GitHub Release 官方入口。

1. 浏览器下载栏提示风险时，打开下载列表，点这条下载右侧的 `...` 三个点，选择 `保留` / `仍要保留`。
2. Windows SmartScreen 弹出蓝色拦截窗口时，点 `更多信息`，再点 `仍要运行`。
3. 如果杀毒软件明确显示木马、高危或已经隔离，不要强行运行；删除该文件后重新下载，仍然异常请带截图反馈给作者。

## 当前版本

当前版本：`1.1.1`

> 安全提示：`v1.0.10` 及更早旧安装包不再建议继续安装或传播，请先隔离旧安装包。

## 核心特性

- Open-Meteo 天气电台，根据当前位置、城市和天气 mood 生成更合适的播放队列
- 首页包含天气电台、每日推荐、私人电台、继续听、听歌画像和我的歌单入口
- Wallpaper 银河首页背景，未播放状态保持干净的星河氛围
- 播放后切换到 Emily / 默认播放态视觉，歌词舞台与粒子舞台同步工作
- 基于节奏的电影镜头视觉系统
- 面向长播客和 DJ 曲目的专属视觉模式
- 歌词舞台、自定义歌词、歌词位置与视觉控制
- 自定义专辑封面上传与裁剪
- 右键唤起 3D 歌单架，支持歌单队列浏览
- 网易云音乐账号、搜索、歌单、播客等体验接入
- QQ 音乐搜索、登录态与音源补充接入
- GitHub Releases 更新检测与下载入口
- 首次启动内置「默认测试」视觉用户存档
- 壁纸模式 — 粒子动效设为全屏桌面背景
- macOS 原生红绿灯控件、触控板滚动降敏、Cmd/Opt 热键适配

## 开发运行

### 环境要求

- Node.js >= 18
- npm >= 9（或 pnpm）

### 快速启动

```bash
# 安装依赖
npm install

# 开发模式运行
npm start
```

### 构建打包

```bash
# macOS
npm run build:mac          # 生成 DMG + ZIP
npm run build:mac:dir      # 仅生成 .app 目录（调试用）

# Windows
npm run build:win          # 生成 NSIS 安装包
npm run build:win:dir      # 仅生成目录（调试用）
```

或使用 Makefile（macOS/Linux）：

```bash
make help        # 查看所有命令
make start       # 开发运行
make build       # 构建当前平台
make build-mac   # 构建 macOS
make build-win   # 构建 Windows（可交叉构建）
make build-all   # 构建所有平台
make clean       # 清理构建产物
make info        # 查看环境信息
```

产物位于 `dist/` 目录。

### 更新机制

Mineradio 会请求 GitHub Releases latest 检测新版本。远端版本高于本地版本时，应用内更新入口会展示 Release 内容并下载安装包。

本地验证更新链路时，可以通过 `MINERADIO_UPDATE_MANIFEST` 指向本地 manifest JSON 或 HTTP 地址来模拟线上 Release。

## 第三方音乐平台说明

Mineradio 不是网易云音乐、QQ 音乐或腾讯音乐娱乐集团的官方客户端，也不隶属于任何音乐平台。

项目中的第三方平台接入仅用于个人学习、本地客户端体验和用户自有账号的播放辅助。请遵守对应平台的用户协议、版权规则和会员权益规则。项目不会提供绕过付费、绕过会员、破解音质或重新分发音乐内容的能力。

## 用户数据与隐私

登录 Cookie、搜索历史、自定义封面、自定义歌词、节奏分析缓存等数据只应保存在本机用户数据目录或浏览器本地存储中，不应提交到仓库。

更多说明见 [PRIVACY.md](./PRIVACY.md)。

## 致谢

Mineradio 由 XxHuberrr 主要设计与打造。emily 作为早期视觉底层想法与 `emily` 视觉预设改进方向的共创者和灵感来源之一，特此感谢。

同时感谢小天才e宝、应春日、锋将军、軌跡、林中、骊、风痕、花椰菜🥦在早期体验、测试反馈和发布准备中的帮助。

## 版权与授权

Copyright (C) 2026 XxHuberrr.

本项目采用 GPL-3.0 授权。详见 [LICENSE](./LICENSE)。

MR Logo、Mineradio 名称、界面视觉设计与原创视觉表达归作者所有；第三方依赖和第三方服务分别遵循其各自授权与服务条款。

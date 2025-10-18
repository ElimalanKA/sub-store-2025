# mihomo 安装脚本说明

本脚本用于自动安装或卸载 MetaCubeX/mihomo 代理程序，支持自动识别架构、默认安装最新版、以及指定历史版本安装。

> 安全提示：脚本会从远程仓库下载并执行二进制或安装脚本。请仅在受信任的环境中运行，并在必要时先查看 inst.sh 源码以确认安全性。

## 直接下载脚本（可点击）
[Download inst.sh (raw)](https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh)

或使用徽章（点击即打开 raw 链接）：
[![Download inst.sh](https://img.shields.io/badge/Download-inst.sh-blue?logo=github&style=flat-square)](https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh)

## 推荐（更安全）的用法 — 可复制命令（GitHub 会为下列代码块显示“复制”按钮）
先下载再执行（推荐）：

```bash
curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh
bash inst.sh install
```

一行快捷执行（风险高 — 会立即执行远程脚本）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh) install
```

或使用管道形式：

```bash
curl -fsSL https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh | bash -s -- install
```

## 安装指定版本示例（先下载再运行）

```bash
curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh
bash inst.sh install v1.19.14
```

## 卸载

```bash
curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh
bash inst.sh uninstall
```

## 说明与注意事项

- 将命令放到代码块中，GitHub 会为这些代码块显示“复制”按钮，这是实现“一键复制”最直接的方式。  
- GitHub README 不允许运行自定义 JavaScript，因此无法直接在 README 中添加“复制并运行”之类的自定义按钮。若需更高级的交互（例如在云 IDE 上一键运行），可考虑添加 Gitpod / Repl.it / Codespaces 的链接或外部网页。  
- 出于安全考虑，建议用户先下载脚本后审查内容再运行，或在受信任环境中执行。  

如果你需要我把这段内容提交到仓库（直接提交到 main 或创建分支并发 PR），告诉我你想要的提交方式；目前我不会自动提交，等你手动粘贴即可。  

本脚本用于自动安装或卸载 MetaCubeX/mihomo 代理程序，支持自动识别架构、默认安装最新版、以及指定历史版本安装。

安装最新版 mihomo

可直接复制以下链接（原始脚本的 raw 链接）：

https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh

或复制并直接运行（先下载脚本再执行）：

curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh && bash inst.sh install

安装指定版本（例如 v1.19.14）

curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh && bash inst.sh install v1.19.14


卸载 mihomo

curl -fsSL -o inst.sh https://raw.githubusercontent.com/ElimalanKA/sub-store-2025/main/mihomo/inst.sh && bash inst.sh uninstall

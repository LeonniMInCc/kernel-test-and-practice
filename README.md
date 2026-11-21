# Linux 内核安全与路由转发实验

这个项目用可复跑的实验学习 Linux 内核安全、数据包转发和嵌入式 Linux 固件分析。第一阶段从源码编译 Linux 内核并确认它在 Debian 虚拟机中启动。后续沿着同一套环境追踪内核对象和网络路径，再把测试迁移到 OpenWrt。

## 项目目标

- 建立可恢复的内核实验环境，掌握内核配置、构建、安装、启动与版本验证。
- 用源码、调试符号和运行时记录解释内核行为，理解内存边界、引用计数、并发和权限控制。
- 在自建拓扑中验证路由与防火墙策略。用抓包、接口及规则计数器和内核跟踪定位行为差异。
- 用自行构建的 OpenWrt 镜像梳理启动链、固件组件和版本来源，评估辅助审计工具带来的实际收益。

## 实验环境

宿主机为 CachyOS x86_64，AMD Ryzen 9 5900X 已启用 SVM，普通用户可读写 `/dev/kvm`。宿主机终端使用 fish，QEMU 通过 Nix 提供并使用 KVM 加速。实验客机为 Debian 13 amd64，起步配置为 6 vCPU、8 GiB 内存及 100 GiB 动态分配的 qcow2 磁盘，通过 QEMU NAT 下载软件包。

Debian 虚拟机已安装编译与调试工具，并保存了关机状态下的磁盘基线。内核实操命令在 Debian 内用 Bash 执行。宿主机继续保留现有的 Hyprland 版本锁定。网络实验从虚拟机内的 network namespace 与 veth 开始，后续再增加连接到隔离实验网络的 OpenWrt 虚拟路由器。

## 学习与实验路线

以下周期为计划，结合实际进度调整。

| 阶段 | 内容 | 验收产物 |
| --- | --- | --- |
| 第 1–2 周 · 构建与启动 | 内核配置、构建、initramfs、GRUB、串口、GDB 与 ftrace | 启动实验内核，保存版本、配置、符号及一次正常系统调用的跟踪记录 |
| 第 3–5 周 · 内核安全基础 | 内存分配、对象生命周期、引用计数、锁、RCU、capabilities、LSM 和内核内存权限 | 内核对象生命周期图，KASAN 日志阅读笔记，KUnit 或 kselftest 的行为验证记录 |
| 第 6–9 周 · 网络与转发 | NAPI、`sk_buff`、路由、Netfilter、conntrack、nftables，再选一个扩展变量 | 三节点拓扑、放行与丢弃用例、抓包、规则计数与路径说明 |
| 第 10–12 周 · OpenWrt 与固件 | 构建镜像、设备树、启动链、rootfs、组件版本及镜像签名 | 镜像构建记录、组件清单、迁移后的转发测试和一个用户态组件的审计记录 |

## ARTEX-IOT 在项目中的用途

ARTEX-IOT 是基于 ARTEX-God 的固件组件审计工作台。仓库文档描述了固件解包、组件管理、反编译浏览及证据导出等功能。本次调研查阅了仓库、发布记录与 `INP.py`，尚未实测固件兼容性和分析准确率。反编译需要自备 IDA 9.0+。计划以自行构建的 OpenWrt 镜像做对照，记录组件识别准确率、定位耗时和证据可追溯性。内核与转发行为以源码、调试和测试结果为依据。 [ARTEX-IOT 项目](https://github.com/buobo/ARTEX-IOT) · [发布记录](https://github.com/buobo/ARTEX-IOT/releases)

## 科研练习

以 **OpenWrt 防火墙策略与实际转发行为的一致性** 为阶段性课题。先在自建客户端、路由器和服务端拓扑中定义预期策略，收集抓包、规则计数器和关键内核路径。基线跑通后每次改变一个变量，例如开启 flow offload，比较策略结果，同时记录吞吐与 CPU 开销。

## 实验目录

每次实验独立建目录 `experiments/NN-实验主题/`。实验 Markdown 写明目标、前提、步骤、验收和恢复方法。`practice/` 存放该次实验的脚本、配置、测量数据和记录。

| 实验 | 内容 | 状态 |
| --- | --- | --- |
| 01 | [从源码构建并启动 Linux 内核](experiments/01-build-and-boot/experiment.md) · [实操材料](experiments/01-build-and-boot/practice/) | 实验环境基线已保存，客机执行结果待记录 |

大体积构建产物保留在实验机，如 ISO、qcow2、源码树、`vmlinux` 和 initramfs。提交精简的配置、版本信息和验证记录，便于复跑和对照。

## 参考资料

- [Linux 内核构建指南](https://docs.kernel.org/admin-guide/quickly-build-trimmed-linux.html)
- [Linux 内核测试指南](https://docs.kernel.org/dev-tools/testing-overview.html)
- [Linux 内核自保护文档](https://docs.kernel.org/security/self-protection.html)
- [Linux 网络文档](https://docs.kernel.org/networking/)
- [OpenWrt 源码](https://github.com/openwrt/openwrt)

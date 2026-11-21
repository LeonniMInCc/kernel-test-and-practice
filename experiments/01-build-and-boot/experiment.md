# 实验 01 · 从源码构建并启动 Linux 内核

在 Debian 13 amd64 实验机中构建 Linux 6.12.118，装入 `/boot`，通过 GRUB 启动，然后验证根文件系统和虚拟网卡。独立的版本号 `6.12.118-kernel-lab01` 用于区分 Debian 原内核与实验内核。

## 前提

- Debian 实验机可启动并联网，已保存关机时的 qcow2 基线。
- 在客机里用 Bash 执行。源码所在分区建议预留约 30 GiB，并检查 `/boot` 是否有空间。
- 使用当前 Debian 内核配置，保留磁盘、根文件系统和虚拟网卡所需驱动。若客机启用了 Secure Boot，启动自编内核前需要按客机配置安排签名或调整客机的 Secure Boot 设置。

## 1. 准备工具和源码

```bash
uname -r
df -h "$HOME" /boot
sudo apt update
sudo apt install build-essential git bc bison flex libssl-dev libelf-dev \
    libncurses-dev dwarves gdb cpio rsync xz-utils zstd openssl wget
```

将当前的 `uname -r` 结果记到实操记录中，以便在 GRUB 中定位原内核。下载并解压固定版本的上游源码。 [Linux Kernel Archives](https://www.kernel.org/)

```bash
mkdir -p ~/src ~/Downloads
wget -O ~/Downloads/linux-6.12.118.tar.xz \
    https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.118.tar.xz
tar -xf ~/Downloads/linux-6.12.118.tar.xz -C ~/src
cd ~/src/linux-6.12.118
```


## 2. 配置并编译

以下步骤以首次构建为例。保留 `.config`，供下一次实验对照。清空两个证书路径是为了去掉可能指向 Debian 打包环境的引用。 [Linux 内核构建指南](https://docs.kernel.org/admin-guide/quickly-build-trimmed-linux.html)

```bash
cp "/boot/config-$(uname -r)" .config
./scripts/config --set-str LOCALVERSION "-kernel-lab01"
./scripts/config --disable LOCALVERSION_AUTO
./scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
./scripts/config --set-str SYSTEM_REVOCATION_KEYS ""
make olddefconfig
make -s kernelrelease
```

确认版本为 `6.12.118-kernel-lab01` 后，用普通用户编译。

```bash
make -j"$(nproc)"
```

构建成功后，保留 `arch/x86/boot/bzImage`、源码目录的 `vmlinux` 和 `.config`。记录编译时长，后续做 GDB 实验时使用匹配的 `vmlinux`。

## 3. 安装并确认启动文件

编译成功后，先安装模块，再安装内核镜像。

```bash
sudo make modules_install &&
sudo make install
```

确认安装命令成功后执行：

```bash
release=$(make -s kernelrelease)
ls -lh "/boot/vmlinuz-$release" "/boot/initrd.img-$release"
```

如果镜像存在但 initramfs 缺失，运行 `sudo update-initramfs -c -k "$release"`，然后重新确认两个文件。若镜像缺失，检查安装输出。两项齐全后刷新 GRUB：

```bash
sudo update-grub
```

确认输出找到 `vmlinuz-6.12.118-kernel-lab01`，再重启客机。

## 4. 从 GRUB 启动并验收

在 GRUB 的 **Advanced options for Debian** 里选实验内核的普通启动项。登录后运行 `uname -r`、`findmnt -no SOURCE,FSTYPE /` 和 `ip -br addr`，或用 [验收脚本](practice/verify-boot.sh) 汇总输出。

- 内核版本为 `6.12.118-kernel-lab01`。
- 根文件系统正常挂载。
- 虚拟网卡获得地址。如需确认 NAT 的 DNS，再运行 `getent hosts deb.debian.org`。
- 将实际结果填入 [实操记录](practice/record.md)。

如果实验内核启动失败，从 GRUB 的高级菜单选择原 Debian 内核，记录屏幕报错和失败阶段。必要时关机，使用已保存的磁盘基线恢复。

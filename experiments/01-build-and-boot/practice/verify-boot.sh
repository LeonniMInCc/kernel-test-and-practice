#!/bin/sh
set -eu

expected_release=6.12.118-kernel-lab01
running_release=$(uname -r)

printf '运行中的内核：%s\n' "$running_release"
findmnt -no SOURCE,FSTYPE /
ip -br addr

if [ "$running_release" != "$expected_release" ]; then
    printf '预期启动的内核：%s\n' "$expected_release" >&2
    exit 1
fi

printf '内核版本匹配。请核对上方根文件系统和虚拟网卡地址。\n'

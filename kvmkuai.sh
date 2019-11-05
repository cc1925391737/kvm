#!/bin/bash
qemu-img create - f \                    ##创建快照，-f格式qcow2
-b /var/lib/libvirt/images/$1.qcow2 \         ##-b 源虚拟机磁盘文件
/var/lib/libvirt/images/$2.qcow2              ##目标路径

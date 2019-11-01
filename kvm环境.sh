#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
[ $? -ne 0 ] && echo "Hardware virtualization is not supported" &&exit 1
#关闭防火墙安全机制
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
setenforce 0
echo ' * - nofile 100000 ' >>/etc/security/limits.conf
#配置DNS
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
EOF
#配置BR0网卡
cat > /etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
TYPE="Bridge"
BOOTPROTO="static"
NAME="br0"
DEVICE="br0"
ONBOOT="yes"
IPADDR="192.168.175.152"
NETMASK="255.255.255.0"
GATEWAY=192.168.175.2
EOF


mv /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33.bak

cat > /etc/sysconfig/network-scripts/ifcfg-ens33 <<EOF
TYPE="Ethernet"
BOOTPROTO="none"
NAME="ens33"
BRIDGE="br0"
DEVICE="ens33"
ONBOOT="yes"
EOF


lsmod | grep kvm
#安装kvm所需组件
yum -y install qemu-kvm libvirt virt-install
yum -y groupinstall Virtualization "Virtualization Client"
systemctl start libvirtd
systemctl status libvirtd
systemctl restart network
[ $? -eq 0 ] && echo "Success!"

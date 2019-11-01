#!/bin/bash

read -p "请输入ip地址：" ip
ping -c 1 $ip  > /dev/null 2>&1

if [ $? -eq 0 ]
then
    echo "当前ip已经存在！请重新设置！"
    exit 1
else
    echo "这个ip可以使用！"
fi



#获取网卡名称
NAME=`ifconfig | head -1 | awk -F ":" '{print $1}'`


cat > /etc/sysconfig/network-scripts/ifcfg-$NAME <<EOF
TYPE=Ethernet
NAME=$NAME
DEVICE=$NAME
ONBOOT=yes
BOOTPROTO=static
IPADDR=$ip
NETMASK=255.255.255.0
GATEWAY=192.168.175.2
DNS1=8.8.8.8
EOF

systemctl restart network

#!/bin/bash
read -p "请输入将要做模版的虚拟机：" BASEVM
read -p "请输入新的虚拟机名字：" NEWVM
qemu-img create -f qcow2 -b /var/lib/libvirt/images/${BASEVM}.qcow2 /var/lib/libvirt/images/${NEWVM}.qcow2 &>/dev/null
cp /etc/libvirt/qemu/${BASEVM}.xml /tmp/${NEWVM}.xml
sed -i "/<name>${BASEVM}/s/${BASEVM}/${NEWVM}/" /tmp/${NEWVM}.xml
sed -i "/${BASEVM}\.qcow2/s/${BASEVM}/${NEWVM}/" /tmp/${NEWVM}.xml
sed -i '/uuid/'d /tmp/${NEWVM}.xml




sed -i '/mac address/'d /tmp/${NEWVM}.xml
virsh define /tmp/${NEWVM}.xml &>/dev/null && echo "已成功"
read -p "是否开启虚拟机，请输入y或n：" open
if [ $open = y ]
then
virsh start $NEWVM &>/dev/null && echo "已启动"
else
echo "Finish"
fi
~                                                                                                                                 
~                                 

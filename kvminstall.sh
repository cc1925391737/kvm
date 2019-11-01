#！/bin/bash
#set LANG
export LANG=zh_CN.UTF-8
DATE=`date "+%Y-%m-%d %H:%M:%S"`
D=`date +%Y%m%d`
USER_N=`whoami`
HOSTNAME=`hostname`
LOGDIR=/opt
SYS=/var/lib/libvirt/images/centos7.6-kvm
IPADDR=`grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-br0|cut -d= -f 2 `
FREE=1024
CPU=1
CDROM=/tmp/centos7.iso/CentOS-7-x86_64-DVD-1810.iso
#判断目录是否存在
if [ -f /opt/expr.log ];then
echo -e "\033[40;33m $USER_N $DATE $HOSTNAME expr.log file already exists! \033[0m" >>"$LOGDIR"/kvm_${D}.log
else
echo "0" > /opt/expr.log && echo -e "\033[40;33m $USER_N $DATE $HOSTNAME expr.log create file successfully! \033[0m" >>"$LOGDIR"/kvm_${D}.log
fi
#虚拟机序号+1
EXPR=`tail -1 /opt/expr.log`
EXP=`expr "$EXPR" + 1`
echo "$EXP" >/opt/expr.log
NAME=centos7.6-kvm$EXP
#虚拟机安装
echo "================KVM虚拟机安装========================================"
if [ ! -d "$SYS$EXP" ]; then
qemu-img create -f qcow2 "$SYS$EXP" 6G >>"$LOGDIR"/kvm_${D}.log
echo -e "\033[40;33m "$USER_N $DATE $HOSTNAME KVM create directory successfully!"\033[0m" >>"$LOGDIR"/kvm_${D}.log
fi
echo "$SYS虚拟机安装文件建成功"     
virt-install \
--name "$NAME" \
--virt-type kvm \
--ram "$FREE" \
--vcpus "$CPU" \
--cdrom "$CDROM" \
--disk "$SYS$EXP",size=6 \
--network bridge=br0 \
--network network=default \
--graphics vnc,listen=0.0.0.0 \
--noautoconsole >>"$LOGDIR"/kvm_${D}.log 
echo "$SYS虚拟机创建中请稍后" 
virsh list --all

#!/bin/bash

######################################################################
#
# author@patrick
# 
# 功能作用：
# 初始化安装和配置服务器脚本在centos7.x系统上使用。如果不需要使用哪个功能直接在
# 最后面注释掉即可。
# 
######################################################################


function basesoft {
    yum install gcc make autoconf vim sysstat net-tools iostat git wget
}

function timezero {
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    if ! crontab -l |grep ntpdate &>/dev/null ; then
        (echo "* 1 * * * ntpdate time.windows.com >/dev/null 2>&1";crontab -l) |crontab
    fi
}

function selinux {
    setenforce 0
    sed -i '/SELINUX/{s/permissive/disabled/}' /etc/selinux/config
}

function firewall {
    if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
        systemctl stop firewalld
        systemctl disable firewalld
        systemctl mask firewalld
    elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null; then
        iptables -F
        service iptables stop
        chkconfig iptables off
    fi
}

function historycommand {
    if ! grep HISTTIMEFORMAT /etc/bashrc; then
        echo 'export HISTTIMEFORMAT="%T %F `whoami` "' >> /etc/bashrc
    fi
}

function sshtimeout {
    if ! grep "TMOUT=600" /etc/profile &>/dev/null; then
        echo "export TMOUT=600" >> /etc/profile
    fi
}

function loginlimit {
    # 禁止root远程登录
    # sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    # 设置ssh用户登陆失败锁定策略(普通用户连续登陆失败3次锁定600s,root登陆失败3次锁定3600秒)
	echo "auth required pam_tally2.so onerr=fail deny=3 unlock_time=600 even_deny_root root_unlock_time=3600" >> /etc/pam.d/sshd 
}

function sendsystemmail {
    sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab
}

function fileslimit {
    if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null; then
    cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
EOF
    fi
}

function systemoptimization {
    cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480
net.ipv4.tcp_max_syn_backlog = 20480
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_fin_timeout = 20
EOF
}

function swap {
    echo "0" > /proc/sys/vm/swappiness
}

function passwd {
    # 设置密码复杂度(最小32位,尝试次数为3次,最少有3个不同字符)
	sed -i "s/^password.*requisite.*pam_pwquality.so.*/password requisite pam_cracklib.so retry=3 difok=3 minlen=32/g" /etc/pam.d/system-auth
}

function sshport {  
	read -p "输入要更改的ssh端口: " sshpn
	sed -i "s/.Port .*/ Port "$sshpn"/g" /etc/ssh/sshd_config
    systemctl restart sshd
    echo "修改完毕......"   
}

function staticip {
    # 自行修改网卡名字和ip地址
    sed -i 's/^ONBOOT.*/ONBOOT=yes/g;s/^BOOTPROTO.*/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3
    sed -i '/^BOOTPROTO.*/a\IPADDR=192.168.1.123\nPREFIX=19\nGATEWAY=192.168.1.1\nDNS1=8.8.8.8' /etc/sysconfig/network-scripts/ifcfg-enp0s3
    systemctl restart network
}




# 安装系统性能分析工具及其他
basesoft
# 设置时区并同步时间
timezero
# 关闭selinux
selinux
# 关闭防火墙
firewall
# 添加历史命令的时间和用户
historycommand
# SSH超时时间
sshtimeout
# 登陆限制
loginlimit
# 禁止定时任务向发送邮件
sendsystemmail
# 设置最大打开文件数
fileslimit
# 系统内核优化
systemoptimization
# 减少SWAP使用
swap
# 密码复杂度
passwd
# 修改ssh端口
sshport
# 修改静态ip地址
staticip
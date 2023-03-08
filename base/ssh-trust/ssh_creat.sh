#!/bin/bash
#
######################################################################
#
# author@patrick
# 
# 功能作用：
# 在centos7.x系统上使用。ssh互相信任的脚本，需要做互相信任的ip地址写在host文件中
# 执行该脚本就可以创建互相信任关系，脚本有一个前提是所有主机的用户名和密码是相同的
# 
######################################################################
#
#需要先安装expect和tcl
#
yum install -y expect tcl
#定义登陆的用户名和密码
HOST_USER=$1
HOST_PASSWD=$2
HOST_FILE=$3
#
if [ $# -ne 3 ]; then
    echo "Usage:"
    echo "$0 用户名、密码、主机地址文件"
    exit 1
fi
#
#设置ssh变量
SSH_DIR=~/.ssh
SCRIPT_PREFIX=/tmp
echo ===========================
#
#设置ssh的目录权限
#
mkdir $SSH_DIR
chmod 700 $SSH_DIR
#
TMP_SCRIPT=$SCRIPT_PREFIX.sh
echo  "#!/usr/bin/expect">$TMP_SCRIPT
echo  "spawn ssh-keygen -b 1024 -t rsa">>$TMP_SCRIPT
echo  "expect *key*">>$TMP_SCRIPT
echo  "send \r">>$TMP_SCRIPT
if [ -f $SSH_DIR/id_rsa ]; then
    echo  "expect *verwrite*">>$TMP_SCRIPT
    echo  "send y\r">>$TMP_SCRIPT
fi
echo  "expect *passphrase*">>$TMP_SCRIPT
echo  "send \r">>$TMP_SCRIPT
echo  "expect *again:">>$TMP_SCRIPT
echo  "send \r">>$TMP_SCRIPT
echo  "interact">>$TMP_SCRIPT

chmod +x $TMP_SCRIPT

/usr/bin/expect $TMP_SCRIPT
rm $TMP_SCRIPT
#
cat $SSH_DIR/id_rsa.pub >> $SSH_DIR/authorized_keys
#
chmod 600 $SSH_DIR/authorized_keys
echo ===========================
#
echo
echo
#
for ip in $(cat $HOST_FILE)
do
    if [ "x$ip" != "x" ]; then
        echo -------------------------
        TMP_SCRIPT=${SCRIPT_PREFIX}.$ip.sh
        # check known_hosts
        val=`ssh-keygen -F $ip`
        if [ "x$val" == "x" ]; then
            echo "$ip not in $SSH_DIR/known_hosts, need to add"
            val=`ssh-keyscan $ip 2>/dev/null`
            if [ "x$val" == "x" ]; then
                echo "ssh-keyscan $ip failed!"
            else
                echo $val>>$SSH_DIR/known_hosts
            fi
        fi
        echo "copy $SSH_DIR to $ip"

        echo  "#!/usr/bin/expect">$TMP_SCRIPT
        echo  "spawn scp -r  $SSH_DIR $HOST_USER@$ip:~/">>$TMP_SCRIPT
        echo  "expect *assword*">>$TMP_SCRIPT
        echo  "send $HOST_PASSWD\r">>$TMP_SCRIPT
        echo  "interact">>$TMP_SCRIPT

        chmod +x $TMP_SCRIPT
        #echo "/usr/bin/expect $TMP_SCRIPT" >$TMP_SCRIPT.do
        #sh $TMP_SCRIPT.do&

        /usr/bin/expect $TMP_SCRIPT
        rm $TMP_SCRIPT
        echo "copy done."
    fi
done
#
echo done
#

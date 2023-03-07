#!/bin/bash
#
#author patrick@patricksg@qq.com
#
#定义自变量
#
#下载目录
Version=5.15.11
DownLoadDir=/apps/activitymq
ActivitymqPackage=/apps/activitymq/apache-activemq-$Version-bin.tar.gz
ActivitymqInstallPackage=/apps/activitymq/$Version
InitFile=/etc/init.d/activitymq
ActivitymqLink=https://archive.apache.org/dist/activemq/$Version/apache-activemq-$Version-bin.tar.gz
#加载初始提示信息
echo "--------------------Install Activitymq-$Version-------------------"
echo "-------安装目录：/apps/activitymq    ---------------------------"
echo "----------------------------------------------------------------"
#
#
#解压软件源码安装包
function TarPackage {
    tar -xf $ActivitymqPackage -C $DownLoadDir &> /dev/null
    if [ $? -ne 0 ];then
       echo "软件包解压失败...已退出..."
       exit
    fi
}
#下载解压软件
function DownLoadApp {
    rpm -qa | grep wget &> /dev/null
    if [ $? -eq 0 ]; then
        echo "准备下载安装包..."
        wget -P $DownLoadDir $ActivitymqLink
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕..."
           TarPackage
        else
           echo "activitymq-9.0.41下载失败，请重新下载...已退出"
           exit
        fi
    else
        echo "未安装wget下载软件...已退出"
        exit
    fi
}
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
if [ ! -d $DownLoadDir/apache-activitymq-$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $ActivitymqPackage ]; then
         echo "源码包已准备完毕..."
         #解压源码包
         TarPackage
      else
         #下载解压源码包
         mkdir -p $DownLoadDir
         DownLoadApp
      fi
   else
       #创建下载目录，下载软件源码
       mkdir -p $DownLoadDir
       DownLoadApp
   fi
fi
#
echo "安装完毕...请手动修改配置..."
#
echo "-----------------安装已完成----------------------"
exit
#
